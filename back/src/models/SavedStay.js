const mongoose = require('mongoose');

const savedStaySchema = new mongoose.Schema(
  {
    userId:    { type: mongoose.Schema.Types.ObjectId, ref: 'User', required: true },
    listingId: { type: mongoose.Schema.Types.ObjectId, ref: 'Listing', required: true },
  },
  { timestamps: { createdAt: 'savedAt', updatedAt: false } }
);

// Prevent duplicate saves
savedStaySchema.index({ userId: 1, listingId: 1 }, { unique: true });
savedStaySchema.index({ userId: 1 });

module.exports = mongoose.model('SavedStay', savedStaySchema);
