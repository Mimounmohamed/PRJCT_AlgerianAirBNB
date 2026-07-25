const express = require('express');
const router = express.Router();
const { protect, requireHost } = require('../middleware/auth.middleware');
const Listing = require('../models/Listing');

// GET /api/listings — Browse all active listings (public)
router.get('/', async (req, res) => {
  try {
    const { category, propertyType, wilaya, minPrice, maxPrice, guests, page = 1, limit = 20 } = req.query;
    const filter = { status: 'active', visibility: 'listed' };

    if (category)     filter.categories = category;
    if (propertyType) filter.propertyType = propertyType;
    if (wilaya)       filter['location.wilaya'] = wilaya;
    if (guests)       filter['capacity.guests'] = { $gte: parseInt(guests) };
    if (minPrice || maxPrice) {
      filter['price.perNight'] = {};
      if (minPrice) filter['price.perNight'].$gte = parseInt(minPrice);
      if (maxPrice) filter['price.perNight'].$lte = parseInt(maxPrice);
    }

    const listings = await Listing.find(filter)
      .populate('hostId', 'fullName profilePhoto isSuperhost')
      .sort({ 'rating.overall': -1 })
      .skip((page - 1) * limit)
      .limit(parseInt(limit));

    const total = await Listing.countDocuments(filter);

    res.json({ listings, total, page: parseInt(page), pages: Math.ceil(total / limit) });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// GET /api/listings/:id — Listing detail (public)
router.get('/:id', async (req, res) => {
  try {
    const listing = await Listing.findById(req.params.id)
      .populate('hostId', 'fullName profilePhoto isSuperhost hostSince');

    if (!listing) return res.status(404).json({ error: 'Listing not found.' });

    // Increment view count
    listing.stats.totalViews += 1;
    await listing.save();

    res.json(listing);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// POST /api/listings — Create new listing (host only)
router.post('/', protect, requireHost, async (req, res) => {
  try {
    const listing = await Listing.create({
      ...req.body,
      hostId: req.user._id,
      status: 'pending_review',
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
