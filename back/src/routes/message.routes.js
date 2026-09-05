const express      = require('express');
const router       = express.Router();
const { protect }  = require('../middleware/auth.middleware');
const Conversation = require('../models/Conversation');
const Message      = require('../models/Message');
const User         = require('../models/User');
const { sendPushNotification } = require('../config/pushNotification');

// ── Helper: emit a new message to all participants ──────────
function emitMessage(req, conversation, message) {
  const io = req.app.get('io');
  if (!io) return;
  // Broadcast to the conversation room
  io.to(`conv_${conversation._id}`).emit('new_message', message);
  // Also push to each participant's personal room (for inbox badge update)
  conversation.participants.forEach((pid) => {
    io.to(pid.toString()).emit('conversation_updated', {
      conversationId: conversation._id,
      lastMessage: conversation.lastMessage,
      unreadCount: conversation.unreadCount,
    });
  });
}

// ── POST /api/messages/start — Start or find a conversation ─
// IMPORTANT: must be BEFORE /:conversationId to avoid being swallowed
router.post('/start', protect, async (req, res) => {
  try {
    const { recipientId, listingId, content } = req.body;

    let conversation = await Conversation.findOne({
      participants: { $all: [req.user._id, recipientId] },
      listingId,
    });

    if (!conversation) {
      conversation = await Conversation.create({
        participants: [req.user._id, recipientId],
        listingId,
      });
    }

    const message = await Message.create({
      conversationId: conversation._id,
      senderId:       req.user._id,
      content,
      messageType:    'text',
    });

    conversation.lastMessage = { content, senderId: req.user._id, sentAt: new Date(), read: false };
    conversation.unreadCount.set(recipientId.toString(), 1);
    await conversation.save();

    const populated = await message.populate('senderId', 'fullName profilePhoto');
    emitMessage(req, conversation, populated);

    res.status(201).json({ conversation, message: populated });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// ── GET /api/messages — Inbox: all conversations ────────────
router.get('/', protect, async (req, res) => {
  try {
    const conversations = await Conversation.find({ participants: req.user._id })
      .populate('participants', 'fullName profilePhoto')
      .populate('listingId', 'title location photos')
      .sort({ 'lastMessage.sentAt': -1 });
    res.json(conversations);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// ── GET /api/messages/:conversationId — Messages in thread ──
router.get('/:conversationId', protect, async (req, res) => {
  try {
    const { page = 1, limit = 50 } = req.query;
    const messages = await Message.find({ conversationId: req.params.conversationId })
      .populate('senderId', 'fullName profilePhoto')
      .sort({ sentAt: -1 })
      .skip((page - 1) * limit)
      .limit(parseInt(limit));

    // Mark messages as read
    await Message.updateMany(
      { conversationId: req.params.conversationId, senderId: { $ne: req.user._id }, read: false },
      { read: true, readAt: new Date() }
    );

    // Reset my unread count
    await Conversation.findByIdAndUpdate(req.params.conversationId, {
      [`unreadCount.${req.user._id}`]: 0,
    });

    res.json(messages.reverse());
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// ── POST /api/messages/:conversationId — Send a message ─────
router.post('/:conversationId', protect, async (req, res) => {
  try {
    const { content, messageType = 'text', imageUrl } = req.body;

    const conversation = await Conversation.findById(req.params.conversationId);
    if (!conversation) return res.status(404).json({ error: 'Conversation not found.' });

    const message = await Message.create({
      conversationId: req.params.conversationId,
      senderId:       req.user._id,
      content,
      messageType,
      imageUrl,
    });

    conversation.lastMessage = { content, senderId: req.user._id, sentAt: new Date(), read: false };

    const otherId = conversation.participants.find(
      (p) => p.toString() !== req.user._id.toString()
    );
    conversation.unreadCount.set(otherId.toString(), (conversation.unreadCount.get(otherId.toString()) || 0) + 1);
    await conversation.save();

    const populated = await message.populate('senderId', 'fullName profilePhoto');
    emitMessage(req, conversation, populated);

    // FCM push to recipient
    try {
      const recipientUser = await User.findById(otherId).select('fcmToken notificationSettings');
      if (recipientUser?.fcmToken && recipientUser?.notificationSettings?.messages !== false) {
        const senderName = req.user.fullName || 'New message';
        const preview = content && content.length > 80 ? content.substring(0, 80) + '…' : (content || '📎 Media');
        await sendPushNotification({
          fcmToken: recipientUser.fcmToken,
          title: senderName,
          body: preview,
          data: { type: 'message', conversationId: conversation._id.toString() },
        });
      }
    } catch (pushErr) {
      console.error('FCM push error:', pushErr.message);
    }

    res.status(201).json(populated);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// ── PUT /api/messages/:conversationId/read — Mark as read ───
router.put('/:conversationId/read', protect, async (req, res) => {
  try {
    await Message.updateMany(
      { conversationId: req.params.conversationId, senderId: { $ne: req.user._id }, read: false },
      { read: true, readAt: new Date() }
    );
    await Conversation.findByIdAndUpdate(req.params.conversationId, {
      [`unreadCount.${req.user._id}`]: 0,
    });
    res.json({ ok: true });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

module.exports = router;
