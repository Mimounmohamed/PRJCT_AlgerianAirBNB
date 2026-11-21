const mongoose = require('mongoose');

// Booking lifecycle (see utils/bookingService.js and routes/booking.routes.js):
//
//   guest books ─► pending ──host accepts──► confirmed ──check-out passes──► completed
//                    │  └─host declines──► rejected        │
//                    └─no answer in 24h──► expired          └─guest/host cancels──► cancelled_by_*
//
// With Instant Book on, a booking is created directly as 'confirmed'.
const bookingSchema = new mongoose.Schema(
  {
    listingId: { type: mongoose.Schema.Types.ObjectId, ref: 'Listing', required: true },
    guestId:   { type: mongoose.Schema.Types.ObjectId, ref: 'User', required: true },
    hostId:    { type: mongoose.Schema.Types.ObjectId, ref: 'User', required: true },

    // ── Stay Details ───────────────────────────────────────
    // Calendar days, stored as UTC midnight. checkOut is the departure day
    // (not a night of the stay).
    checkIn:     { type: Date, required: true },
    checkOut:    { type: Date, required: true },
    nights:      { type: Number, required: true },
    guestsCount: { type: Number, required: true, min: 1 },

    // ── Price Breakdown (computed server-side, never trusted from the app) ──
    pricing: {
      nightlyRate: { type: Number, required: true }, // average per-night price after custom calendar prices
      subtotal:    { type: Number, required: true }, // sum of nightly prices, minus discount
      discount:    { type: Number, default: 0 },     // weekly/monthly discount, already taken off subtotal
      serviceFee:  { type: Number, required: true },
      touristTax:  { type: Number, required: true },
      totalDZD:    { type: Number, required: true }, // what the guest pays
      hostPayout:  { type: Number, default: 0 },     // what the host earns (subtotal − AKRILI fee)
      currency:    { type: String, default: 'DZD' },
    },

    // ── Status ─────────────────────────────────────────────
    status: {
      type: String,
      enum: [
        'pending',
        'confirmed',
        'cancelled_by_guest',
        'cancelled_by_host',
        'completed',
        'rejected',
        'expired',
      ],
      default: 'pending',
    },

    // Pending requests expire if the host doesn't answer by then.
    expiresAt:     { type: Date, default: null },
    respondedAt:   { type: Date, default: null }, // host accepted/declined
    declineReason: { type: String, default: '' },
    completedAt:   { type: Date, default: null },

    cancellationPolicy: {
      type: String,
      // Copied from Listing.cancellationPolicy at booking time, so it must
      // accept the same values. 'Strict' is kept only for old documents.
      enum: ['Flexible', 'Moderate', 'Firm', 'Strict'],
    },
    cancellationReason: { type: String },
    cancelledAt:        { type: Date },
    cancelledBy:        { type: mongoose.Schema.Types.ObjectId, ref: 'User' },
    // Informational — payment happens outside the app for now.
    refundAmount:       { type: Number, default: null },

    instantBook: { type: Boolean, default: false },

    // ── Review tracking ────────────────────────────────────
    guestReviewId: { type: mongoose.Schema.Types.ObjectId, ref: 'Review', default: null },
    hostReviewId:  { type: mongoose.Schema.Types.ObjectId, ref: 'Review', default: null },
  },
  { timestamps: true }
);

// ── Pre-save: compute nights ───────────────────────────────
bookingSchema.pre('save', function (next) {
  if (this.checkIn && this.checkOut) {
    const msPerDay = 1000 * 60 * 60 * 24;
    this.nights = Math.round((this.checkOut - this.checkIn) / msPerDay);
  }
  next();
});

// ── Indexes ────────────────────────────────────────────────
bookingSchema.index({ guestId: 1 });
bookingSchema.index({ hostId: 1 });
bookingSchema.index({ listingId: 1 });
bookingSchema.index({ status: 1 });
bookingSchema.index({ checkIn: 1, checkOut: 1 });
bookingSchema.index({ listingId: 1, checkIn: 1, checkOut: 1 }); // overlap detection
bookingSchema.index({ status: 1, expiresAt: 1 });  // expiry sweep
bookingSchema.index({ status: 1, checkOut: 1 });   // completion sweep

module.exports = mongoose.model('Booking', bookingSchema);
