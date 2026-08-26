require('dotenv').config({ path: require('path').join(__dirname, '.env') });
const mongoose = require('mongoose');
const Conversation = require('./src/models/Conversation');

const USER_A = '6a8dcdeb7d3d2da148512e11'; // test gggg
const USER_B = '6a8b6d361b219b6ecac2155b'; // Test Tanich

mongoose.connect(process.env.MONGODB_URI).then(async () => {
  const conv = await Conversation.findOne({
    participants: { $all: [USER_A, USER_B] }
  });

  if (!conv) { console.log('No conversation found'); process.exit(); }

  console.log('unreadCount (Map):', conv.unreadCount);
  console.log('unreadCount toJSON:', JSON.stringify(conv.toJSON().unreadCount));
  console.log('USER_A count:', conv.unreadCount.get(USER_A));

  // Give USER_A (test gggg) 2 unread messages so the dot can be tested
  conv.unreadCount.set(USER_A, 2);
  await conv.save();
  console.log('\nUpdated: test gggg now has 2 unread messages');
  console.log('Final toJSON:', JSON.stringify(conv.toJSON().unreadCount));

  await mongoose.disconnect();
}).catch(e => { console.error(e.message); process.exit(1); });
