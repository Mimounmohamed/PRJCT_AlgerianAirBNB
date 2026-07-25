const express = require('express');
const router = express.Router();
const { protect, requireHost } = require('../middleware/auth.middleware');
const Availability = require('../models/Availability');

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

// PUT /api/availability/:listingId — Bulk update dates (host only)
router.put('/:listingId', protect, requireHost, async (req, res) => {
  try {
    const { dates, status, priceOverride } = req.body;
    // dates: array of date strings ["2024-10-15", "2024-10-16", ...]

    const ops = dates.map((dateStr) => ({
      updateOne: {
        filter: { listingId: req.params.listingId, date: new Date(dateStr) },
        update: { status, priceOverride: priceOverride || null },
        upsert: true,
      },
    }));

    await Availability.bulkWrite(ops);
    res.json({ message: `Updated ${dates.length} dates.` });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

module.exports = router;
