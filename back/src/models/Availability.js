const mongoose = require('mongoose');

const availabilitySchema = new mongoose.Schema({
  listingId: { type: mongoose.Schema.Types.ObjectId, ref: 'Listing', required: true },

  date: { type: Date, required: true },

  status: {
    type:    String,
    enum:    ['available', 'booked', 'blocked'],
    default: 'available',
  },

  // Optional per-day price override
  priceOverride: { type: Number, default: null },

  // Set when status === 'booked'
  bookingId: { type: mongoose.Schema.Types.ObjectId, ref: 'Booking', default: null },
});

availabilitySchema.index({ listingId: 1, date: 1 }, { unique: true });
availabilitySchema.index({ listingId: 1, status: 1 });

module.exports = mongoose.model('Availability', availabilitySchema);
