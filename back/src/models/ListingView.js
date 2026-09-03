const mongoose = require('mongoose');

// One document per (listing, user) pair that has ever viewed that listing.
// The compound unique index is what does the actual dedup work: inserting
// a duplicate pair throws a duplicate-key error, which the route catches
// and treats as "already viewed, don't increment again" rather than a
// real failure. Anonymous (logged-out) views never reach this collection
// at all — see listing.routes.js.
const listingViewSchema = new mongoose.Schema(
  {
    listingId: { type: mongoose.Schema.Types.ObjectId, ref: 'Listing', required: true },
    userId: { type: mongoose.Schema.Types.ObjectId, ref: 'User', required: true },
  },
  { timestamps: true }
);

listingViewSchema.index({ listingId: 1, userId: 1 }, { unique: true });

module.exports = mongoose.model('ListingView', listingViewSchema);