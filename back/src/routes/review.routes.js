const express = require('express');
const router = express.Router();
const { protect } = require('../middleware/auth.middleware');
const Review = require('../models/Review');

// GET /api/reviews/listing/:listingId — Get reviews for a listing
router.get('/listing/:listingId', async (req, res) => {
  try {
    const { sort = 'recent', hasPhotos, page = 1, limit = 10 } = req.query;
    const filter = { listingId: req.params.listingId, isVisible: true };
    if (hasPhotos === 'true') filter.photos = { $ne: [] };

    let sortBy = { createdAt: -1 };
    if (sort === 'highest') sortBy = { 'ratings.overall': -1 };
    if (sort === 'lowest')  sortBy = { 'ratings.overall': 1 };

    const reviews = await Review.find(filter)
      .populate('reviewerId', 'fullName profilePhoto city')
      .sort(sortBy)
      .skip((page - 1) * limit)
      .limit(parseInt(limit));

    const total = await Review.countDocuments(filter);
    res.json({ reviews, total, page: parseInt(page) });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// POST /api/reviews — Submit a review (after completed stay)
router.post('/', protect, async (req, res) => {
  try {
    const { bookingId, listingId, ratings, comment, photos } = req.body;

    const existing = await Review.findOne({ bookingId });
    if (existing) return res.status(409).json({ error: 'Review already submitted.' });

    const review = await Review.create({
      bookingId,
      listingId,
      reviewerId: req.user._id,
      hostId: req.body.hostId,
      ratings,
      comment,
      photos: photos || [],
    });

    res.status(201).json(review);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

module.exports = router;
