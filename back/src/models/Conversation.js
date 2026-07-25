const mongoose = require('mongoose');

const conversationSchema = new mongoose.Schema(
  {
    participants: [{ type: mongoose.Schema.Types.ObjectId, ref: 'User' }],
    listingId:   { type: mongoose.Schema.Types.ObjectId, ref: 'Listing' },
    bookingId:   { type: mongoose.Schema.Types.ObjectId, ref: 'Booking', default: null },

    // ── Last message preview (for inbox list) ──────────────
    lastMessage: {
      content:  { type: String },
      senderId: { type: mongoose.Schema.Types.ObjectId, ref: 'User' },
      sentAt:   { type: Date },
      read:     { type: Boolean, default: false },
    },

    // ── Unread count per user ──────────────────────────────
    // Stored as: { "userId1": 2, "userId2": 0 }
    unreadCount: {
      type: Map,
      of: Number,
      default: {},
    },
  },
  { timestamps: true }
);

conversationSchema.index({ participants: 1 });
conversationSchema.index({ listingId: 1 });
conversationSchema.index({ 'lastMessage.sentAt': -1 });

module.exports = mongoose.model('Conversation', conversationSchema);
