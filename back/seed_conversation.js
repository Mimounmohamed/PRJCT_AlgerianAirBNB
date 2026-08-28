/**
 * One-time seed: creates a test conversation between
 *   "test gggg"   (6a8dcdeb7d3d2da148512e11)
 *   "Test Tanich" (6a8b6d361b219b6ecac2155b)
 *
 * Run with:  node seed_conversation.js
 */

require('dotenv').config({ path: require('path').join(__dirname, '.env') });
const mongoose = require('mongoose');
const Conversation = require('./src/models/Conversation');
const Message     = require('./src/models/Message');

const USER_A = '6a8dcdeb7d3d2da148512e11'; // test gggg
const USER_B = '6a8b6d361b219b6ecac2155b'; // Test Tanich

async function seed() {
  await mongoose.connect(process.env.MONGODB_URI);
  console.log('✅ Connected to MongoDB');

  // Prevent duplicates — delete existing conversation between them
  const existing = await Conversation.findOne({
    participants: { $all: [USER_A, USER_B] },
    listingId: null,
  });
  if (existing) {
    await Message.deleteMany({ conversationId: existing._id });
    await Conversation.deleteOne({ _id: existing._id });
    console.log('🗑  Removed old test conversation');
  }

  // Create conversation
  const conv = await Conversation.create({
    participants: [USER_A, USER_B],
    listingId: null,
  });
  console.log('💬 Conversation created:', conv._id.toString());

  const now = new Date();
  const mins = (m) => new Date(now.getTime() - m * 60 * 1000);

  // Create messages (oldest → newest)
  const messages = await Message.insertMany([
    {
      conversationId: conv._id,
      senderId: USER_B,
      content: 'Salam! Comment ça va?',
      messageType: 'text',
      read: true,
      readAt: mins(20),
      sentAt: mins(30),
    },
    {
      conversationId: conv._id,
      senderId: USER_A,
      content: 'Bikhir! et toi?',
      messageType: 'text',
      read: true,
      readAt: mins(18),
      sentAt: mins(25),
    },
    {
      conversationId: conv._id,
      senderId: USER_B,
      content: 'Moi aussi, hamdullah. Tu es disponible ce weekend?',
      messageType: 'text',
      read: true,
      readAt: mins(10),
      sentAt: mins(15),
    },
    {
      conversationId: conv._id,
      senderId: USER_A,
      content: 'Oui, je suis disponible samedi! 🙌',
      messageType: 'text',
      read: false,
      sentAt: mins(5),
    },
  ]);
  console.log(`📨 ${messages.length} messages inserted`);

  // Update lastMessage + unreadCount (USER_B has 1 unread from USER_A)
  const last = messages[messages.length - 1];
  conv.lastMessage = {
    content: last.content,
    senderId: USER_A,
    sentAt: last.sentAt,
    read: false,
  };
  conv.unreadCount.set(USER_B, 1); // USER_B hasn't read USER_A's last msg
  conv.unreadCount.set(USER_A, 0);
  await conv.save();
  console.log('✅ lastMessage + unreadCount updated');

  console.log('\n🎉 Done! Conversation ID:', conv._id.toString());
  await mongoose.disconnect();
}

seed().catch((e) => {
  console.error('❌', e.message);
  process.exit(1);
});
