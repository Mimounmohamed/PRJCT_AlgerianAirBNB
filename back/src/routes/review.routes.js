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

    const Listing = require('../models/Listing');
    const listing = await Listing.findById(listingId);
    if (!listing) return res.status(404).json({ error: 'Listing not found.' });

    // Host cannot review their own listing
    if (listing.hostId && listing.hostId.toString() === req.user._id.toString()) {
      return res.status(403).json({ error: 'Hosts cannot write a review on their own listing.' });
    }

    const existing = await Review.findOne({ bookingId });
    if (existing) return res.status(409).json({ error: 'Review already submitted.' });

    const review = await Review.create({
      bookingId,
      listingId,
      reviewerId: req.user._id,
      hostId: listing.hostId || req.body.hostId,
      ratings,
      comment,
      photos: photos || [],
    });

    res.status(201).json(review);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// POST /api/reviews/:id/reply — Host reply to a guest review
router.post('/:id/reply', protect, async (req, res) => {
  try {
    const { comment } = req.body;
    if (!comment || !comment.trim()) {
      return res.status(400).json({ error: 'Reply comment is required.' });
    }

    const review = await Review.findById(req.params.id);
    if (!review) {
      return res.status(404).json({ error: 'Review not found.' });
    }

    // Verify caller is the host of this listing
    let isHost = false;
    if (review.hostId && review.hostId.toString() === req.user._id.toString()) {
      isHost = true;
    } else if (review.listingId) {
      const Listing = require('../models/Listing');
      const listing = await Listing.findById(review.listingId);
      if (listing && listing.hostId && listing.hostId.toString() === req.user._id.toString()) {
        isHost = true;
        review.hostId = listing.hostId;
      }
    }

    if (!isHost) {
      return res.status(403).json({ error: 'Only the host of this listing can reply to this review.' });
    }

    review.hostReply = {
      comment: comment.trim(),
      repliedAt: new Date(),
    };

    await review.save();

    const populated = await Review.findById(review._id)
      .populate('reviewerId', 'fullName profilePhoto city');

    res.json(populated);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

module.exports = router;
