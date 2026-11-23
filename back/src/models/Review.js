const mongoose = require('mongoose');

const reviewSchema = new mongoose.Schema(
  {
    bookingId:  { type: mongoose.Schema.Types.ObjectId, ref: 'Booking', required: false, sparse: true },
    listingId:  { type: mongoose.Schema.Types.ObjectId, ref: 'Listing', required: true },
    reviewerId: { type: mongoose.Schema.Types.ObjectId, ref: 'User', required: true },
    hostId:     { type: mongoose.Schema.Types.ObjectId, ref: 'User', required: true },

    // ── Ratings (1–5) ──────────────────────────────────────
    ratings: {
      overall:       { type: Number, required: true, min: 1, max: 5 },
      cleanliness:   { type: Number, required: true, min: 1, max: 5 },
      communication: { type: Number, required: true, min: 1, max: 5 },
      checkIn:       { type: Number, required: true, min: 1, max: 5 },
      location:      { type: Number, required: true, min: 1, max: 5 },
      value:         { type: Number, required: true, min: 1, max: 5 },
    },

    comment: { type: String, trim: true },
    photos:  [{ type: String }],

    // ── Host Reply ─────────────────────────────────────────
    hostReply: {
      comment:   { type: String, trim: true },
      repliedAt: { type: Date },
    },

    // ── Moderation ─────────────────────────────────────────
    isVisible:   { type: Boolean, default: true },
    flaggedAt:   { type: Date },
    flagReason:  { type: String },
  },
  { timestamps: true }
);

const GUEST_FAVORITE_MIN_REVIEWS = 5;
const GUEST_FAVORITE_MIN_RATING = 4.8;

// ── Post-save: update listing aggregated rating ────────────
reviewSchema.post('save', async function () {
  const Listing = mongoose.model('Listing');
  const reviews = await mongoose.model('Review').find({
    listingId: this.listingId,
    isVisible: true,
  });

  if (reviews.length === 0) return;

  const avg = (field) =>
    reviews.reduce((sum, r) => sum + r.ratings[field], 0) / reviews.length;

  const overall = parseFloat(avg('overall').toFixed(2));

  await Listing.findByIdAndUpdate(this.listingId, {
    // Guest Favorite: earned, never set by hand — at least
    // GUEST_FAVORITE_MIN_REVIEWS reviews averaging GUEST_FAVORITE_MIN_RATING.
    isGuestFavorite:
      reviews.length >= GUEST_FAVORITE_MIN_REVIEWS && overall >= GUEST_FAVORITE_MIN_RATING,
    'rating.overall':       overall,
    'rating.cleanliness':   parseFloat(avg('cleanliness').toFixed(2)),
    'rating.communication': parseFloat(avg('communication').toFixed(2)),
    'rating.checkIn':       parseFloat(avg('checkIn').toFixed(2)),
    'rating.location':      parseFloat(avg('location').toFixed(2)),
    'rating.value':         parseFloat(avg('value').toFixed(2)),
    'rating.totalReviews':  reviews.length,
  });
});

// ── Indexes ────────────────────────────────────────────────
reviewSchema.index({ listingId: 1 });
reviewSchema.index({ reviewerId: 1 });
reviewSchema.index({ 'ratings.overall': -1 });

module.exports = mongoose.model('Review', reviewSchema);
