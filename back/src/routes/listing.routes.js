const express = require('express');
const router = express.Router();
const { protect, optionalAuth, requireHost } = require('../middleware/auth.middleware');
const Listing = require('../models/Listing');
const ListingView = require('../models/ListingView');
const { destroyImagesInBackground } = require('../config/cloudinary');
const { MAX_SNOOZE_DAYS, listedFilter } = require('../utils/snooze');
const Availability = require('../models/Availability');
const { parseDay, dayKey, bookedNightsInRange } = require('../utils/bookingNights');

// GET /api/listings — Browse all active listings (public)
router.get('/', async (req, res) => {
  try {
    const {
      category,
      propertyType,
      wilaya,
      minPrice,
      maxPrice,
      guests,
      search,
      sort = 'rating',
      page = 1,
      limit = 20,
    } = req.query;

    const filter = { status: 'active', isDeleted: { $ne: true }, ...listedFilter() };

    if (category)     filter.categories = category;
    if (propertyType) filter.propertyType = propertyType;
    if (wilaya)       filter['location.wilaya'] = wilaya;
    if (guests)       filter['capacity.guests'] = { $gte: parseInt(guests) };
    if (minPrice || maxPrice) {
      filter['price.perNight'] = {};
      if (minPrice) filter['price.perNight'].$gte = parseInt(minPrice);
      if (maxPrice) filter['price.perNight'].$lte = parseInt(maxPrice);
    }
    // Uses the text index on title/description/location.city/location.wilaya
    // defined in the Listing schema (listing_text_search).
    if (search) filter.$text = { $search: search };

    const sortOptions = {
      rating:      { 'rating.overall': -1 },
      price_asc:   { 'price.perNight': 1 },
      price_desc:  { 'price.perNight': -1 },
      newest:      { publishedAt: -1 },
    };
    const sortBy = sortOptions[sort] || sortOptions.rating;

    const listings = await Listing.find(filter)
      .populate('hostId', 'fullName profilePhoto isSuperhost')
      .sort(sortBy)
      .skip((page - 1) * limit)
      .limit(parseInt(limit));

    const total = await Listing.countDocuments(filter);

    res.json({ listings, total, page: parseInt(page), pages: Math.ceil(total / limit) });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// GET /api/listings/:id/availability?from=YYYY-MM-DD&months=12 — the
// guest-facing calendar for the Booking page. Public. For every night in
// the range that is NOT bookable (blocked by the host, booked offline, or
// taken by another guest's pending/confirmed booking) it returns
// available:false — without saying why, so other guests' bookings stay
// private — plus each night's custom price where the host set one.
//
// Response: { basePrice, currency, rentalPeriod, days: [{ date, available, price }] }
// Nights not listed are available at basePrice.
router.get('/:id/availability', async (req, res) => {
  try {
    const listing = await Listing.findOne({ _id: req.params.id, isDeleted: { $ne: true } })
      .select('price status');
    if (!listing) return res.status(404).json({ error: 'Listing not found.' });

    const from = parseDay(req.query.from) || new Date(Date.UTC(new Date().getUTCFullYear(), new Date().getUTCMonth(), 1));
    const months = Math.min(Math.max(parseInt(req.query.months, 10) || 12, 1), 13);
    const to = new Date(Date.UTC(from.getUTCFullYear(), from.getUTCMonth() + months, from.getUTCDate()));

    const [marks, bookedNights] = await Promise.all([
      Availability.find({ listingId: listing._id, date: { $gte: from, $lt: to } }),
      bookedNightsInRange(listing._id, from, to),
    ]);

    const days = new Map();
    for (const mark of marks) {
      days.set(dayKey(mark.date), {
        date: dayKey(mark.date),
        available: mark.status === 'available',
        price: mark.priceOverride ?? null,
      });
    }
    for (const key of bookedNights.keys()) {
      days.set(key, { date: key, available: false, price: days.get(key)?.price ?? null });
    }

    res.json({
      basePrice: listing.price?.perNight || 0,
      currency: listing.price?.currency || 'DZD',
      rentalPeriod: listing.price?.rentalPeriod || 'nightly',
      days: [...days.values()].sort((a, b) => a.date.localeCompare(b.date)),
    });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// GET /api/listings/:id — Listing detail (public, but view-count tracking
// behaves differently depending on who's asking — see below)
//
// View counting rules:
//  - Anonymous (logged-out) requests never increment the counter at all —
//    there's no stable identity to dedup against.
//  - The listing's own host viewing their own listing never increments it
//    (covers both normal browsing and the "Preview my listing" flow after
//    publishing).
//  - Any other logged-in user increments it, but only once per user per
//    listing — enforced via ListingView's unique (listingId, userId) index
//    rather than an in-memory/app-level check, so it's safe under
//    concurrent requests.
router.get('/:id', optionalAuth, async (req, res) => {
  try {
    const listing = await Listing.findOne({ _id: req.params.id, isDeleted: { $ne: true } })
      .populate('hostId', 'fullName profilePhoto isSuperhost hostSince createdAt phone');

    if (!listing) return res.status(404).json({ error: 'Listing not found.' });

    const viewerId = req.user?._id;
    const isOwnListing = viewerId && viewerId.toString() === listing.hostId._id.toString();

    if (viewerId && !isOwnListing) {
      try {
        // Succeeds only the first time this (listing, user) pair is seen —
        // the unique index rejects duplicates, which we treat as "already
        // counted" rather than an error.
        await ListingView.create({ listingId: listing._id, userId: viewerId });
        listing.stats.totalViews += 1;
        await listing.save();
      } catch (viewErr) {
        if (viewErr.code !== 11000) throw viewErr; // 11000 = duplicate key, i.e. already viewed
      }
    }

    res.json(listing);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// Fields a host may set on their own listing, via POST (create) and PUT
// (update). Everything else (status, isDeleted, hostId, stats, rating,
// isGuestFavorite, publishedAt, rejectionReason, ...) is server-controlled
// and silently dropped from the request body.
const HOST_EDITABLE_FIELDS = [
  'title',
  'description',
  'descriptionTitle',
  'propertyType',
  'styleType',
  'categories',
  'location',
  'capacity',
  'photos',
  'coverPhotoIndex',
  'amenities',
  'houseRules',
  'bookingPreferences',
  'cancellationPolicy',
  'checkInInstructions',
  'visibility',
  'snoozedUntil',
];

// price is handled per sub-field: the host controls their own price and
// discounts, but the platform fees (serviceFeePercent, touristTaxPercent)
// stay server-controlled.
const HOST_EDITABLE_PRICE_FIELDS = [
  'perNight',
  'currency',
  'weeklyDiscountPercent',
  'monthlyDiscountPercent',
  'rentalPeriod',
];

// The Discover filter chips — must match kListingCategories in the app
// (front/lib/home-front/widgets/listing_category_picker.dart).
const LISTING_CATEGORIES = ['Riads', 'Sea view', 'Casbah', 'Desert'];
const MAX_LISTING_CATEGORIES = 3;

function pickHostEditable(body = {}) {
  const picked = {};
  for (const key of HOST_EDITABLE_FIELDS) {
    if (body[key] !== undefined) picked[key] = body[key];
  }
  // Unknown labels are dropped (they'd never match a filter), duplicates
  // removed, at most 3 kept.
  if (picked.categories !== undefined) {
    const list = Array.isArray(picked.categories) ? picked.categories : [];
    picked.categories = [...new Set(list.filter((c) => LISTING_CATEGORIES.includes(c)))]
      .slice(0, MAX_LISTING_CATEGORIES);
  }
  if (body.price && typeof body.price === 'object') {
    const price = {};
    for (const key of HOST_EDITABLE_PRICE_FIELDS) {
      if (body.price[key] !== undefined) price[key] = body.price[key];
    }
    if (Object.keys(price).length > 0) picked.price = price;
  }
  return picked;
}

// POST /api/listings — Create new listing (host only)
//
// Auto-publish: when the host has bookingPreferences.autoPublish set to
// true, the listing skips admin review entirely and goes live immediately
// (status: 'active', visibility: 'listed', publishedAt set to now).
// Otherwise it follows the normal review flow (status: 'pending_review',
// visibility forced to 'unlisted' until an admin approves it and flips
// it to 'active'/'listed').
router.post('/', protect, requireHost, async (req, res) => {
  try {
    const autoPublish = req.body?.bookingPreferences?.autoPublish === true;

    const listing = await Listing.create({
      ...pickHostEditable(req.body),
      hostId: req.user._id,
      status: autoPublish ? 'active' : 'pending_review',
      visibility: autoPublish ? 'listed' : 'unlisted',
      ...(autoPublish && { publishedAt: new Date() }),
    });
    res.status(201).json(listing);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// PUT /api/listings/:id — Update listing (host only)
//
// Only HOST_EDITABLE_FIELDS are applied. Status changes go through the
// dedicated pause/resume/delete routes in host.routes.js, never here.
// price sub-fields are set one by one so a partial `price` object
// doesn't wipe the platform fees.
router.put('/:id', protect, requireHost, async (req, res) => {
  try {
    const listing = await Listing.findOne({
      _id: req.params.id,
      hostId: req.user._id,
      isDeleted: { $ne: true },
    });
    if (!listing) return res.status(404).json({ error: 'Listing not found or unauthorized.' });

    const oldPhotoUrls = listing.photos.map((p) => p.url);

    const { price, ...rest } = pickHostEditable(req.body);

    // Visibility only means something for a live listing — a listing
    // that's paused, pending review or rejected stays unlisted until it's
    // active again (resume/admin approval set it then). snoozedUntil only
    // travels together with visibility.
    if (rest.visibility === undefined || listing.status !== 'active') {
      delete rest.visibility;
      delete rest.snoozedUntil;
    } else if (rest.visibility === 'snoozed') {
      const until = new Date(rest.snoozedUntil);
      const now = Date.now();
      if (Number.isNaN(until.getTime()) || until.getTime() <= now) {
        return res.status(400).json({ error: 'Pick a snooze end date in the future.' });
      }
      if (until.getTime() > now + MAX_SNOOZE_DAYS * 24 * 60 * 60 * 1000) {
        return res.status(400).json({ error: `A listing can be snoozed for at most ${MAX_SNOOZE_DAYS} days.` });
      }
      rest.snoozedUntil = until;
    } else {
      rest.snoozedUntil = null;
    }

    listing.set(rest);
    if (price) {
      for (const [key, value] of Object.entries(price)) {
        listing.set(`price.${key}`, value);
      }
    }

    await listing.save();

    // Photos the host removed are deleted from Cloudinary in the
    // background (skipped if anything else still uses the same URL).
    const newPhotoUrls = new Set(listing.photos.map((p) => p.url));
    destroyImagesInBackground(oldPhotoUrls.filter((url) => !newPhotoUrls.has(url)));

    res.json(listing);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// Pausing and deleting a listing live in host.routes.js
// (POST /api/host/listings/:id/pause, DELETE /api/host/listings/:id).

module.exports = router;