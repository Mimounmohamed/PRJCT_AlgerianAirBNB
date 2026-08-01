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
