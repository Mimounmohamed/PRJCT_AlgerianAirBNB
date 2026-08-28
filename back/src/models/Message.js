const mongoose = require('mongoose');

const messageSchema = new mongoose.Schema(
  {
    conversationId: { type: mongoose.Schema.Types.ObjectId, ref: 'Conversation', required: true },
    senderId:       { type: mongoose.Schema.Types.ObjectId, ref: 'User', required: true },

    content:     { type: String, trim: true },
    messageType: {
      type:    String,
      enum:    ['text', 'image', 'video', 'system'],
      default: 'text',
    },
    imageUrl: { type: String },

    read:   { type: Boolean, default: false },
    readAt: { type: Date },
  },
  {
    timestamps: { createdAt: 'sentAt', updatedAt: false },
  }
);

messageSchema.index({ conversationId: 1, sentAt: 1 });
messageSchema.index({ senderId: 1 });

module.exports = mongoose.model('Message', messageSchema);
