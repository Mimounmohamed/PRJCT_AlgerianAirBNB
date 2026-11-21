const express = require('express');
const router = express.Router();
const { protect, requireHost } = require('../middleware/auth.middleware');
const Availability = require('../models/Availability');
const Listing = require('../models/Listing');
const { MS_PER_DAY, parseDay, dayKey, bookedNightsInRange } = require('../utils/bookingNights');

// GET /api/availability/:listingId — Get calendar for a listing
router.get('/:listingId', async (req, res) => {
  try {
    const { month, year } = req.query;
    const filter = { listingId: req.params.listingId };

    if (month && year) {
      const start = new Date(year, month - 1, 1);
      const end = new Date(year, month, 0, 23, 59, 59);
      filter.date = { $gte: start, $lte: end };
    }

    const availability = await Availability.find(filter).sort({ date: 1 });
    res.json(availability);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// PUT /api/availability/:listingId — Bulk update dates (host only, and
// only the listing's own host — requireHost alone only checks the
// requester HAS a host account, not that they own THIS listing, so an
// ownership check is added here explicitly).
//
// Body: { dates: ["2026-11-05", ...], status, priceOverride? }
//   - status: 'available' | 'blocked' | 'booked' ('booked' = booked
//     outside the app; real in-app bookings come from the Booking
//     collection, see GET /api/host/listings/:id/calendar)
//   - priceOverride: omitted → each day keeps its current override;
//     a number → set it; null → clear it (day uses the base price)
//
// Dates taken by an active (pending/confirmed) guest booking are refused
// with 409 — the host has to handle the booking itself, not paint over it.
const HOST_CALENDAR_STATUSES = ['available', 'blocked', 'booked'];
const MAX_DATES_PER_UPDATE = 366;

router.put('/:listingId', protect, requireHost, async (req, res) => {
  try {
    const listing = await Listing.findOne({
      _id: req.params.listingId,
      hostId: req.user._id,
      isDeleted: { $ne: true },
    });
    if (!listing) return res.status(404).json({ error: 'Listing not found or unauthorized.' });

    const { dates, status } = req.body || {};

    if (!HOST_CALENDAR_STATUSES.includes(status)) {
      return res.status(400).json({ error: `status must be one of: ${HOST_CALENDAR_STATUSES.join(', ')}.` });
    }
    if (!Array.isArray(dates) || dates.length === 0) {
      return res.status(400).json({ error: 'dates must be a non-empty array of "YYYY-MM-DD" strings.' });
    }
    if (dates.length > MAX_DATES_PER_UPDATE) {
      return res.status(400).json({ error: `At most ${MAX_DATES_PER_UPDATE} dates per update.` });
    }

    const days = [...new Set(dates)].map(parseDay);
    if (days.some((d) => d === null)) {
      return res.status(400).json({ error: 'Every date must be a valid "YYYY-MM-DD" string.' });
    }

    const hasPriceOverride = Object.prototype.hasOwnProperty.call(req.body, 'priceOverride');
    const { priceOverride } = req.body;
    if (hasPriceOverride && priceOverride !== null && !(typeof priceOverride === 'number' && priceOverride > 0)) {
      return res.status(400).json({ error: 'priceOverride must be a positive number, or null to clear it.' });
    }

    // Refuse any date an active guest booking already occupies.
    const times = days.map((d) => d.getTime());
    const rangeStart = new Date(Math.min(...times));
    const rangeEnd = new Date(Math.max(...times) + MS_PER_DAY);
    const bookedNights = await bookedNightsInRange(listing._id, rangeStart, rangeEnd);
    const conflicts = days.map(dayKey).filter((key) => bookedNights.has(key));
    if (conflicts.length > 0) {
      return res.status(409).json({
        error: `${conflicts.length === 1 ? 'This date has' : 'These dates have'} a guest booking and can't be changed here: ${conflicts.join(', ')}.`,
        conflicts,
      });
    }

    const update = { status };
    if (hasPriceOverride) update.priceOverride = priceOverride;

    const ops = days.map((date) => ({
      updateOne: {
        filter: { listingId: listing._id, date },
        update: { $set: update },
        upsert: true,
      },
    }));

    await Availability.bulkWrite(ops);
    res.json({ message: `Updated ${days.length} dates.` });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

module.exports = router;