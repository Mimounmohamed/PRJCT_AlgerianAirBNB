const express = require('express');
const router = express.Router();
const { protect, optionalAuth, requireHost } = require('../middleware/auth.middleware');
const Listing = require('../models/Listing');
const ListingView = require('../models/ListingView');

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

// POST /api/listings — Create new listing (host only)
//
// Instant Book: when the host has bookingPreferences.instantBook set to
// true, the listing skips admin review entirely and goes live immediately
// (status: 'active', visibility: 'listed', publishedAt set to now).
// Otherwise it follows the normal review flow (status: 'pending_review',
// visibility stays at the schema default 'unlisted' until an admin
// approves it and flips it to 'active'/'listed').
router.post('/', protect, requireHost, async (req, res) => {
  try {
    const instantBook = req.body?.bookingPreferences?.instantBook === true;

    const listing = await Listing.create({
      ...req.body,
      hostId: req.user._id,
      status: instantBook ? 'active' : 'pending_review',
      ...(instantBook && { visibility: 'listed', publishedAt: new Date() }),
    });
    res.status(201).json(listing);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// PUT /api/listings/:id — Update listing (host only)
router.put('/:id', protect, requireHost, async (req, res) => {
  try {
    const listing = await Listing.findOne({ _id: req.params.id, hostId: req.user._id });
    if (!listing) return res.status(404).json({ error: 'Listing not found or unauthorized.' });

    Object.assign(listing, req.body);
    await listing.save();
    res.json(listing);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// DELETE /api/listings/:id — Deactivate listing (host only)
router.delete('/:id', protect, requireHost, async (req, res) => {
  try {
    const listing = await Listing.findOneAndUpdate(
      { _id: req.params.id, hostId: req.user._id },
      { status: 'inactive', visibility: 'unlisted' },
      { new: true }
    );
    if (!listing) return res.status(404).json({ error: 'Listing not found.' });
    res.json({ message: 'Listing deactivated.' });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

module.exports = router;