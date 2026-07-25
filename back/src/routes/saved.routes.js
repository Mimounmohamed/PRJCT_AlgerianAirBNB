const express = require('express');
const router = express.Router();
const { protect } = require('../middleware/auth.middleware');
const SavedStay = require('../models/SavedStay');

// GET /api/saved — Get user's saved stays
router.get('/', protect, async (req, res) => {
  try {
    const saved = await SavedStay.find({ userId: req.user._id })
      .populate({
        path: 'listingId',
        select: 'title photos location price rating categories',
        populate: { path: 'hostId', select: 'fullName profilePhoto' },
      })
      .sort({ savedAt: -1 });
    res.json(saved);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// POST /api/saved/:listingId — Save a listing
router.post('/:listingId', protect, async (req, res) => {
  try {
    const saved = await SavedStay.create({
      userId: req.user._id,
      listingId: req.params.listingId,
    });
    res.status(201).json(saved);
  } catch (err) {
    if (err.code === 11000) return res.status(409).json({ error: 'Already saved.' });
    res.status(500).json({ error: err.message });
  }
});

// DELETE /api/saved/:listingId — Unsave a listing
router.delete('/:listingId', protect, async (req, res) => {
  try {
    await SavedStay.findOneAndDelete({
      userId: req.user._id,
      listingId: req.params.listingId,
    });
    res.json({ message: 'Removed from saved stays.' });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

module.exports = router;
