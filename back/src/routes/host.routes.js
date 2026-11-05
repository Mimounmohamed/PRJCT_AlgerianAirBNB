const express = require('express');
const router = express.Router();
const { protect, requireHost } = require('../middleware/auth.middleware');
const User = require('../models/User');
const Listing = require('../models/Listing');
const Booking = require('../models/Booking');
const { parseCloudinaryUrl, destroyImagesInBackground } = require('../config/cloudinary');
const Availability = require('../models/Availability');
const { ACTIVE_BOOKING_STATUSES, MS_PER_DAY, parseDay, dayKey, bookedNightsInRange } = require('../utils/bookingNights');

// Every host-facing query excludes soft-deleted listings — "Delete" on the
// Manage Listing page must make the listing disappear for the host too,
// not just from public search.
const notDeleted = { isDeleted: { $ne: true } };

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
    const listings = await Listing.find({ hostId: req.user._id, ...notDeleted });
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
    const listings = await Listing.find({ hostId: req.user._id, ...notDeleted }).sort({ createdAt: -1 });
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
    const listing = await Listing.findOne({ _id: req.params.id, hostId: req.user._id, ...notDeleted });
    if (!listing) return res.status(404).json({ error: 'Listing not found or unauthorized.' });
    res.json(listing);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// POST /api/host/listings/:id/pause — "Pause Listing" on the Manage
// Listing page. Only an active listing can be paused (a listing that's
// pending review or rejected isn't live, so there's nothing to pause —
// and allowing it would let pause→resume skip the review).
router.post('/listings/:id/pause', protect, requireHost, async (req, res) => {
  try {
    const listing = await Listing.findOne({ _id: req.params.id, hostId: req.user._id, ...notDeleted });
    if (!listing) return res.status(404).json({ error: 'Listing not found or unauthorized.' });
    if (listing.status !== 'active') {
      return res.status(400).json({ error: 'Only an active listing can be paused.' });
    }

    listing.status = 'inactive';
    listing.visibility = 'unlisted';
    await listing.save();
    res.json(listing);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// POST /api/host/listings/:id/resume — "Resume Listing" on the Manage
// Listing page. Only a paused (inactive) listing can be resumed. Where it
// goes depends on bookingPreferences.autoPublish:
//   - autoPublish on  → straight back to 'active' / 'listed'
//   - autoPublish off → 'pending_review' / 'unlisted', waiting for an admin
router.post('/listings/:id/resume', protect, requireHost, async (req, res) => {
  try {
    const listing = await Listing.findOne({ _id: req.params.id, hostId: req.user._id, ...notDeleted });
    if (!listing) return res.status(404).json({ error: 'Listing not found or unauthorized.' });
    if (listing.status !== 'inactive') {
      return res.status(400).json({ error: 'Only a paused listing can be resumed.' });
    }

    if (listing.bookingPreferences?.autoPublish === true) {
      listing.status = 'active';
      listing.visibility = 'listed';
      if (!listing.publishedAt) listing.publishedAt = new Date();
    } else {
      listing.status = 'pending_review';
      listing.visibility = 'unlisted';
    }
    await listing.save();
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
      { _id: req.params.id, hostId: req.user._id, ...notDeleted },
      { isDeleted: true, status: 'inactive', visibility: 'unlisted' },
      { new: true }
    );
    if (!listing) return res.status(404).json({ error: 'Listing not found or unauthorized.' });
    res.json({ message: 'Listing deactivated.' });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// GET /api/host/listings/:id/calendar?month=11&year=2026 — the Manage
// Calendar view of one month. Merges the host's own Availability marks
// (available/blocked/booked-offline + price overrides) with real guest
// bookings: every night of a pending/confirmed booking comes back as
// status 'booked' with its bookingId, so the app can show it and refuse
// to edit it. Only days with something to say are returned; missing days
// are plain 'available' at the base price.
//
// Response: [{ date: "2026-11-05", status, priceOverride, bookingId, bookingStatus }]
router.get('/listings/:id/calendar', protect, requireHost, async (req, res) => {
  try {
    const listing = await Listing.findOne({ _id: req.params.id, hostId: req.user._id, ...notDeleted });
    if (!listing) return res.status(404).json({ error: 'Listing not found or unauthorized.' });

    const month = parseInt(req.query.month, 10);
    const year = parseInt(req.query.year, 10);
    if (!(month >= 1 && month <= 12) || !(year >= 2000 && year <= 2100)) {
      return res.status(400).json({ error: 'month (1-12) and year are required.' });
    }

    const rangeStart = new Date(Date.UTC(year, month - 1, 1));
    const rangeEnd = new Date(Date.UTC(year, month, 1));

    const [marks, bookedNights] = await Promise.all([
      Availability.find({ listingId: listing._id, date: { $gte: rangeStart, $lt: rangeEnd } }),
      bookedNightsInRange(listing._id, rangeStart, rangeEnd),
    ]);

    const days = new Map();
    for (const mark of marks) {
      days.set(dayKey(mark.date), {
        date: dayKey(mark.date),
        status: mark.status,
        priceOverride: mark.priceOverride ?? null,
        bookingId: null,
        bookingStatus: null,
      });
    }
    for (const [key, booking] of bookedNights) {
      days.set(key, {
        date: key,
        status: 'booked',
        priceOverride: days.get(key)?.priceOverride ?? null,
        bookingId: booking._id,
        bookingStatus: booking.status,
      });
    }

    res.json([...days.values()].sort((a, b) => a.date.localeCompare(b.date)));
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// GET /api/host/listings/:id/bookings/on/:date — the guest booking that
// occupies a given night ("2026-11-05"), for the Booking Details page
// opened from Manage Calendar. 404 when no active booking covers it.
router.get('/listings/:id/bookings/on/:date', protect, requireHost, async (req, res) => {
  try {
    const listing = await Listing.findOne({ _id: req.params.id, hostId: req.user._id, ...notDeleted });
    if (!listing) return res.status(404).json({ error: 'Listing not found or unauthorized.' });

    const day = parseDay(req.params.date);
    if (!day) return res.status(400).json({ error: 'date must be "YYYY-MM-DD".' });

    const bookedNights = await bookedNightsInRange(listing._id, day, new Date(day.getTime() + MS_PER_DAY));
    const match = bookedNights.get(dayKey(day));
    if (!match) return res.status(404).json({ error: 'No guest booking on this date.' });

    const booking = await Booking.findOne({
      _id: match._id,
      hostId: req.user._id,
      status: { $in: ACTIVE_BOOKING_STATUSES },
    }).populate('guestId', 'fullName profilePhoto');
    if (!booking) return res.status(404).json({ error: 'No guest booking on this date.' });

    res.json(booking);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// POST /api/host/media/discard — { urls: [...] }
// Called when a host uploads photos in Edit Listing and then leaves without
// saving, so those uploads don't stay on Cloudinary forever.
//
// Uploads are unsigned (straight from the app), so the server can't prove
// who uploaded a given image. To keep this safe it only deletes images
// that are BOTH recent (Cloudinary's upload version timestamp, which can't
// be faked, is under 6 hours old) AND not referenced by any document in
// the app (checked inside destroyImageIfUnused).
const DISCARD_MAX_AGE_SECONDS = 6 * 60 * 60;

router.post('/media/discard', protect, requireHost, async (req, res) => {
  try {
    const urls = Array.isArray(req.body?.urls) ? req.body.urls.slice(0, 20) : [];
    const now = Math.floor(Date.now() / 1000);

    const deletable = urls.filter((url) => {
      const parsed = parseCloudinaryUrl(url);
      return parsed && now - parsed.version >= 0 && now - parsed.version <= DISCARD_MAX_AGE_SECONDS;
    });

    destroyImagesInBackground(deletable);
    res.json({ message: `Queued ${deletable.length} image(s) for deletion.` });
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