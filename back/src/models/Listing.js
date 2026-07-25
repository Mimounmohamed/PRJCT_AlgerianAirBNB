const mongoose = require('mongoose');

const photoSchema = new mongoose.Schema({
  url:     { type: String, required: true },
  caption: { type: String, default: '' },
  order:   { type: Number, default: 0 },
});

const listingSchema = new mongoose.Schema(
  {
    hostId: { type: mongoose.Schema.Types.ObjectId, ref: 'User', required: true },

    // ── Basics ─────────────────────────────────────────────
    title:       { type: String, required: true, trim: true },
    description: { type: String, required: true },
    propertyType: {
      type: String,
      required: true,
      enum: ['Riad', 'Apartment', 'Villa', 'Townhouse', 'Cabin', 'Private room', 'Desert House'],
    },
    styleType:  { type: String },
    categories: [{ type: String }], // ['Riads', 'Casbah', 'Sea view', 'Desert']

    // ── Location ───────────────────────────────────────────
    location: {
      wilaya:       { type: String, required: true },
      city:         { type: String, required: true },
      neighborhood: { type: String },
      fullAddress:  { type: String }, // only shared with confirmed guests
      coordinates: {
        type:        { type: String, default: 'Point' },
        coordinates: { type: [Number], required: true }, // [lng, lat]
      },
    },

    // ── Pricing ────────────────────────────────────────────
    price: {
      perNight:          { type: Number, required: true },
      currency:          { type: String, default: 'DZD' },
      touristTaxPercent: { type: Number, default: 5.5 },
      serviceFeePercent: { type: Number, default: 8 },
    },

    // ── Capacity ───────────────────────────────────────────
    capacity: {
      guests:    { type: Number, required: true, min: 1 },
      bedrooms:  { type: Number, required: true, min: 0 },
      bathrooms: { type: Number, required: true, min: 0.5 },
    },

    // ── Media ──────────────────────────────────────────────
    photos: [photoSchema],

    // ── Amenities ──────────────────────────────────────────
    amenities: [{ type: String }],
    // Examples: 'Fiber WiFi', 'Breakfast included', 'Full kitchen',
    // 'Air conditioning', 'Sea View Terrace', '24/7 Security',
    // 'Smoke alarm', 'Parking', 'In-unit washer', 'Espresso machine'

    // ── House Rules ────────────────────────────────────────
    houseRules: {
      petsAllowed:     { type: Boolean, default: false },
      smokingAllowed:  { type: Boolean, default: false },
      eventsAllowed:   { type: Boolean, default: false },
      adultOnly:       { type: Boolean, default: false },
      curfew:          { type: Boolean, default: false },
      curfewTime:      { type: String },
      additionalRules: { type: String },
    },

    // ── Booking Preferences ────────────────────────────────
    bookingPreferences: {
      instantBook:        { type: Boolean, default: false },
      advanceNoticeHours: { type: Number, default: 24 },
      minStayNights:      { type: Number, default: 1 },
      maxStayNights:      { type: Number, default: 365 },
      checkInTimeFrom:    { type: String, default: '14:00' },
      checkInTimeTo:      { type: String, default: '22:00' },
      checkOutTime:       { type: String, default: '11:00' },
    },

    cancellationPolicy: {
      type: String,
      enum: ['Flexible', 'Moderate', 'Strict'],
      default: 'Moderate',
    },
    checkInInstructions: { type: String },

    // ── Status & Visibility ────────────────────────────────
    visibility: {
      type:    String,
      enum:    ['listed', 'unlisted'],
      default: 'unlisted',
    },
    status: {
      type:    String,
      enum:    ['draft', 'pending_review', 'active', 'inactive', 'rejected'],
      default: 'draft',
    },
    rejectionReason: { type: String },

    // ── Aggregated Ratings (updated after each review) ─────
    rating: {
      overall:       { type: Number, default: 0 },
      cleanliness:   { type: Number, default: 0 },
      communication: { type: Number, default: 0 },
      checkIn:       { type: Number, default: 0 },
      location:      { type: Number, default: 0 },
      value:         { type: Number, default: 0 },
      totalReviews:  { type: Number, default: 0 },
    },

    // ── Performance Stats ──────────────────────────────────
    stats: {
      totalBookings:  { type: Number, default: 0 },
      totalViews:     { type: Number, default: 0 },
      totalFavorites: { type: Number, default: 0 },
      totalEarnings:  { type: Number, default: 0 },
    },
  },
  { timestamps: true }
);

// ── Indexes ────────────────────────────────────────────────
listingSchema.index({ hostId: 1 });
listingSchema.index({ status: 1, visibility: 1 });
listingSchema.index({ 'location.wilaya': 1 });
listingSchema.index({ 'location.coordinates': '2dsphere' }); // Geo queries
listingSchema.index({ categories: 1 });
listingSchema.index({ propertyType: 1 });
listingSchema.index({ 'price.perNight': 1 });
listingSchema.index({ 'rating.overall': -1 });

module.exports = mongoose.model('Listing', listingSchema);
