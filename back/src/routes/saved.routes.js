const express = require('express');
const mongoose = require('mongoose');
const router = express.Router();
const { protect } = require('../middleware/auth.middleware');
const SavedStay = require('../models/SavedStay');
const Listing = require('../models/Listing');

// listing.stats.totalFavorites follows the saves: +1 on save, -1 on unsave,
// so the host sees how many guests saved each listing.

// GET /api/saved — Get user's saved stays, newest first. Listings the host
// deleted are left out (the save stays, in case it ever matters).
router.get('/', protect, async (req, res) => {
  try {
    const saved = await SavedStay.find({ userId: req.user._id })
      .populate({
        path: 'listingId',
        select: 'title photos coverPhotoIndex location.city location.wilaya price rating propertyType isGuestFavorite status visibility isDeleted',
        populate: { path: 'hostId', select: 'fullName profilePhoto' },
      })
      .sort({ savedAt: -1 });
    res.json(saved.filter((s) => s.listingId && !s.listingId.isDeleted));
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// GET /api/saved/ids — Just the ids of the listings this user saved, so
// the app can fill in the ❤️ on every card.
router.get('/ids', protect, async (req, res) => {
  try {
    const saved = await SavedStay.find({ userId: req.user._id }).select('listingId').lean();
    res.json(saved.map((s) => s.listingId.toString()));
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// POST /api/saved/:listingId — Save a listing (saving twice is a no-op)
router.post('/:listingId', protect, async (req, res) => {
  try {
    const { listingId } = req.params;
    if (!mongoose.isValidObjectId(listingId)) return res.status(400).json({ error: 'Invalid listing.' });
    if (!(await Listing.exists({ _id: listingId, isDeleted: { $ne: true } }))) {
      return res.status(404).json({ error: 'Listing not found.' });
    }

    const saved = await SavedStay.create({ userId: req.user._id, listingId });
    await Listing.updateOne({ _id: listingId }, { $inc: { 'stats.totalFavorites': 1 } });
    res.status(201).json(saved);
  } catch (err) {
    if (err.code === 11000) return res.status(200).json({ message: 'Already saved.' });
    res.status(500).json({ error: err.message });
  }
});

// DELETE /api/saved/:listingId — Unsave a listing
router.delete('/:listingId', protect, async (req, res) => {
  try {
    const { listingId } = req.params;
    if (!mongoose.isValidObjectId(listingId)) return res.status(400).json({ error: 'Invalid listing.' });

    const removed = await SavedStay.findOneAndDelete({ userId: req.user._id, listingId });
    if (removed) {
      // Never below 0, even if old saves were made before counting started.
      await Listing.updateOne(
        { _id: listingId, 'stats.totalFavorites': { $gt: 0 } },
        { $inc: { 'stats.totalFavorites': -1 } }
      );
    }
    res.json({ message: 'Removed from saved stays.' });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

module.exports = router;
