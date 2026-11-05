const express = require('express');
const router = express.Router();
const { protect, optionalAuth, requireHost } = require('../middleware/auth.middleware');
const Listing = require('../models/Listing');
const ListingView = require('../models/ListingView');
const { destroyImagesInBackground } = require('../config/cloudinary');

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

    const filter = { status: 'active', visibility: 'listed', isDeleted: { $ne: true } };

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

function pickHostEditable(body = {}) {
  const picked = {};
  for (const key of HOST_EDITABLE_FIELDS) {
    if (body[key] !== undefined) picked[key] = body[key];
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
    // active again (resume/admin approval set it then).
    if (rest.visibility !== undefined && listing.status !== 'active') {
      delete rest.visibility;
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

// DELETE /api/listings/:id — Deactivate (pause) listing (host only).
// Legacy — the app uses POST /api/host/listings/:id/pause instead. Same
// rule: only an active listing can be paused, so a pending/rejected
// listing can't be paused and then resumed to skip review.
router.delete('/:id', protect, requireHost, async (req, res) => {
  try {
    const listing = await Listing.findOneAndUpdate(
      { _id: req.params.id, hostId: req.user._id, isDeleted: { $ne: true }, status: 'active' },
      { status: 'inactive', visibility: 'unlisted' },
      { new: true }
    );
    if (!listing) return res.status(404).json({ error: 'Listing not found, or not active.' });
    res.json({ message: 'Listing deactivated.' });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

module.exports = router;