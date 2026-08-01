const mongoose = require('mongoose');

const bookingSchema = new mongoose.Schema(
  {
    listingId: { type: mongoose.Schema.Types.ObjectId, ref: 'Listing', required: true },
    guestId:   { type: mongoose.Schema.Types.ObjectId, ref: 'User', required: true },
    hostId:    { type: mongoose.Schema.Types.ObjectId, ref: 'User', required: true },

    // ── Stay Details ───────────────────────────────────────
    checkIn:     { type: Date, required: true },
    checkOut:    { type: Date, required: true },
    nights:      { type: Number, required: true },
    guestsCount: { type: Number, required: true, min: 1 },

    // ── Price Breakdown ────────────────────────────────────
    pricing: {
      nightlyRate: { type: Number, required: true },
      subtotal:    { type: Number, required: true }, // nightlyRate × nights
      serviceFee:  { type: Number, required: true },
      touristTax:  { type: Number, required: true },
      totalDZD:    { type: Number, required: true },
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
      ],
      default: 'pending',
    },

    cancellationPolicy: {
      type: String,
      enum: ['Flexible', 'Moderate', 'Strict'],
    },
    cancellationReason: { type: String },
    cancelledAt:        { type: Date },
    cancelledBy:        { type: mongoose.Schema.Types.ObjectId, ref: 'User' },

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
    this.nights = Math.ceil((this.checkOut - this.checkIn) / msPerDay);
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

module.exports = mongoose.model('Booking', bookingSchema);
