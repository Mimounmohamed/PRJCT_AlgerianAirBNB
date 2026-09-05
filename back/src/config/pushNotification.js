const { getApps } = require('firebase-admin/app');
const { getMessaging } = require('firebase-admin/messaging');

async function sendPushNotification({ fcmToken, title, body, data = {} }) {
  try {
    const apps = getApps();
    if (!apps.length) { console.warn('Firebase not initialized, skipping push'); return; }
    const messaging = getMessaging(apps[0]);
    await messaging.send({
      token: fcmToken,
      notification: { title, body },
      data: Object.fromEntries(Object.entries(data).map(([k, v]) => [k, String(v)])),
      android: { priority: 'high', notification: { sound: 'default', channelId: 'messages' } },
      apns: { payload: { aps: { sound: 'default', badge: 1 } } },
    });
    console.log('Push sent to', fcmToken.substring(0, 12) + '...');
  } catch (err) {
    console.error('Push failed:', err.message);
  }
}

module.exports = { sendPushNotification };
