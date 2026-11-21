const express = require('express');
const router = express.Router();
const { protect } = require('../middleware/auth.middleware');
const mongoose = require('mongoose');
const Review = require('../models/Review');
const Booking = require('../models/Booking');
const Listing = require('../models/Listing');
const { notifyUser } = require('../utils/bookingService');

// GET /api/reviews/listing/:listingId — Get reviews for a listing
router.get('/listing/:listingId', async (req, res) => {
  try {
    const { sort = 'recent', hasPhotos } = req.query;
    const page = Math.max(parseInt(req.query.page, 10) || 1, 1);
    const limit = Math.min(Math.max(parseInt(req.query.limit, 10) || 10, 1), 50);
    const filter = { listingId: req.params.listingId, isVisible: true };
    if (hasPhotos === 'true') filter.photos = { $ne: [] };

    let sortBy = { createdAt: -1 };
    if (sort === 'highest') sortBy = { 'ratings.overall': -1 };
    if (sort === 'lowest')  sortBy = { 'ratings.overall': 1 };

    const reviews = await Review.find(filter)
      .populate('reviewerId', 'fullName profilePhoto city')
      .sort(sortBy)
      .skip((page - 1) * limit)
      .limit(limit);

    const total = await Review.countDocuments(filter);
    res.json({ reviews, total, page });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// A guest may review a stay only once it's completed (check-out passed —
// see utils/bookingService.js sweep), and only once per booking.
async function findReviewableBooking(userId, listingId) {
  return Booking.findOne({
    guestId: userId,
    listingId,
    status: 'completed',
    guestReviewId: null,
  }).sort({ checkOut: -1 });
}

// GET /api/reviews/eligible?listingId=… — can the logged-in user review
// this listing? → { bookingId } for their latest completed, not-yet-
// reviewed stay there, or { bookingId: null, reason } explaining why not.
router.get('/eligible', protect, async (req, res) => {
  try {
    const { listingId } = req.query;
    if (!listingId) return res.status(400).json({ error: 'listingId is required.' });

    const booking = await findReviewableBooking(req.user._id, listingId);
    if (booking) return res.json({ bookingId: booking._id });

    const [completed, upcoming] = await Promise.all([
      Booking.exists({ guestId: req.user._id, listingId, status: 'completed' }),
      Booking.exists({ guestId: req.user._id, listingId, status: 'confirmed' }),
    ]);
    const reason = completed
      ? "You've already reviewed your stays here."
      : upcoming
        ? 'You can review this place after your stay is completed.'
        : 'Only guests who stayed here can write a review.';
    res.json({ bookingId: null, reason });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

const RATING_FIELDS = ['overall', 'cleanliness', 'communication', 'checkIn', 'location', 'value'];

// POST /api/reviews — Submit a review for a completed stay.
// Body: { bookingId, ratings: { overall, cleanliness, communication,
// checkIn, location, value }, comment, photos? }
// The listing and host come from the booking — never from the request —
// so a review can only be about a place the reviewer actually stayed at.
router.post('/', protect, async (req, res) => {
  try {
    const { bookingId, ratings, comment, photos } = req.body || {};

    if (!bookingId || !mongoose.isValidObjectId(bookingId)) {
      return res.status(400).json({ error: 'Pick the stay you are reviewing.' });
    }
    const booking = await Booking.findOne({ _id: bookingId, guestId: req.user._id });
    if (!booking) return res.status(404).json({ error: 'Booking not found.' });
    if (booking.status !== 'completed') {
      return res.status(409).json({ error: 'You can review this place after your stay is completed.' });
    }
    if (booking.guestReviewId || (await Review.exists({ bookingId: booking._id }))) {
      return res.status(409).json({ error: "You've already reviewed this stay." });
    }

    for (const field of RATING_FIELDS) {
      const value = Number(ratings?.[field]);
      if (!(value >= 1 && value <= 5)) {
        return res.status(400).json({ error: `Rate ${field} from 1 to 5.` });
      }
    }
    const text = String(comment || '').trim();
    if (!text) return res.status(400).json({ error: 'Please write a short comment about your stay.' });
    if (text.length > 2000) return res.status(400).json({ error: 'Comments can be at most 2000 characters.' });

    const listing = await Listing.findById(booking.listingId).select('title hostId');
    if (!listing) return res.status(404).json({ error: 'Listing not found.' });

    const review = await Review.create({
      bookingId: booking._id,
      listingId: booking.listingId,
      reviewerId: req.user._id,
      hostId: booking.hostId,
      ratings: Object.fromEntries(RATING_FIELDS.map((f) => [f, Number(ratings[f])])),
      comment: text,
      photos: Array.isArray(photos) ? photos.slice(0, 10) : [],
    });

    booking.guestReviewId = review._id;
    await booking.save();

    notifyUser(booking.hostId, {
      type: 'review_received',
      title: 'New review ⭐',
      body: `${req.user.fullName || 'A guest'} rated ${listing.title} ${Number(ratings.overall)}/5.`,
      bookingId: booking._id,
    });

    const populated = await Review.findById(review._id).populate('reviewerId', 'fullName profilePhoto city');
    res.status(201).json(populated);
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
