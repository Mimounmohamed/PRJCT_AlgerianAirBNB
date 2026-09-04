const express = require('express');
const router = express.Router();
const { protect, requireHost } = require('../middleware/auth.middleware');
const User = require('../models/User');
const Listing = require('../models/Listing');
const Booking = require('../models/Booking');

// POST /api/host/become — Become a host
router.post('/become', protect, async (req, res) => {
  try {
    const user = await User.findByIdAndUpdate(
      req.user._id,
      { isHost: true, hostSince: new Date() },
      { new: true }
    );
    res.json({ message: 'You are now a host!', user });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// GET /api/host/dashboard — Host dashboard overview
router.get('/dashboard', protect, requireHost, async (req, res) => {
  try {
    const listings = await Listing.find({ hostId: req.user._id });
    const activeListings = listings.filter((l) => l.status === 'active').length;
    const totalEarnings = listings.reduce((sum, l) => sum + (l.stats.totalEarnings || 0), 0);
    const totalBookings = listings.reduce((sum, l) => sum + (l.stats.totalBookings || 0), 0);
    // All-time total across the host's listings — see Listing.stats.totalViews.
    // Real 30-day-windowed view tracking isn't implemented yet, so this is
    // labeled plainly as "Views" on the frontend rather than "Views (30D)".
    const totalViews = listings.reduce((sum, l) => sum + (l.stats.totalViews || 0), 0);

    const avgRating = listings.length > 0
      ? listings.reduce((sum, l) => sum + (l.rating.overall || 0), 0) / listings.length
      : 0;

    const recentBookings = await Booking.find({ hostId: req.user._id })
      .populate('guestId', 'fullName profilePhoto')
      .populate('listingId', 'title')
      .sort({ createdAt: -1 })
      .limit(5);

    res.json({
      totalListings: listings.length,
      activeListings,
      totalEarnings,
      totalBookings,
      totalViews,
      avgRating: parseFloat(avgRating.toFixed(2)),
      recentBookings,
    });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// GET /api/host/listings — Get all host's listings
router.get('/listings', protect, requireHost, async (req, res) => {
  try {
    const listings = await Listing.find({ hostId: req.user._id }).sort({ createdAt: -1 });
    res.json(listings);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// GET /api/host/listings/:id — Single listing, scoped to the requesting
// host (ownership-checked), for the Manage Listing page. Unlike the public
// GET /api/listings/:id, this returns the raw doc (with stats/rating
// already on it — no separate aggregation needed) and 404s if the listing
// doesn't exist OR isn't owned by the requester, rather than exposing
// other hosts' data.
router.get('/listings/:id', protect, requireHost, async (req, res) => {
  try {
    const listing = await Listing.findOne({ _id: req.params.id, hostId: req.user._id });
    if (!listing) return res.status(404).json({ error: 'Listing not found or unauthorized.' });
    res.json(listing);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// DELETE /api/host/listings/:id — Permanently delete a listing (soft
// delete via isDeleted). Distinct from the public DELETE /api/listings/:id,
// which only pauses (status: 'inactive', visibility: 'unlisted') and is
// reversible — this is the "Delete" action on the Manage Listing page's
// advanced controls, meant to be permanent. isDeleted keeps the doc (and
// its bookings/reviews) intact for records, it just excludes it from
// every listing query going forward.
router.delete('/listings/:id', protect, requireHost, async (req, res) => {
  try {
    const listing = await Listing.findOneAndUpdate(
      { _id: req.params.id, hostId: req.user._id },
      { isDeleted: true, status: 'inactive', visibility: 'unlisted' },
      { new: true }
    );
    if (!listing) return res.status(404).json({ error: 'Listing not found or unauthorized.' });
    res.json({ message: 'Listing deactivated.' });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// POST /api/host/verify — Submit ID for verification
router.post('/verify', protect, requireHost, async (req, res) => {
  try {
    const { documentType, documentImageUrl } = req.body;
    const user = await User.findByIdAndUpdate(
      req.user._id,
      {
        identityVerification: {
          status: 'pending',
          documentType,
          documentImageUrl,
          submittedAt: new Date(),
        },
      },
      { new: true }
    );
    res.json({ message: 'Verification submitted. We\'ll review within 24 hours.', user });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

module.exports = router;