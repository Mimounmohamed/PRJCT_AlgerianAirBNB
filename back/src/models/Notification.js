const mongoose = require('mongoose');

const notificationSchema = new mongoose.Schema(
  {
    userId: { type: mongoose.Schema.Types.ObjectId, ref: 'User', required: true },

    type: {
      type: String,
      required: true,
      enum: [
        'booking_confirmed',
        'booking_cancelled',
        'booking_requested',
        'new_message',
        'review_received',
        'identity_verified',
        'listing_approved',
        'listing_rejected',
        'modification_approved',
        'price_drop',
        'promotion',
        'refer_a_friend',
      ],
    },

    title: { type: String, required: true },
    body:  { type: String, required: true },

    // Polymorphic reference
    relatedId: { type: mongoose.Schema.Types.ObjectId },
    relatedType: {
      type: String,
      enum: ['booking', 'listing', 'message', 'review', 'user'],
    },

    read:   { type: Boolean, default: false },
    readAt: { type: Date },
  },
  { timestamps: { createdAt: true, updatedAt: false } }
);

notificationSchema.index({ userId: 1, read: 1 });
notificationSchema.index({ userId: 1, createdAt: -1 });

module.exports = mongoose.model('Notification', notificationSchema);
