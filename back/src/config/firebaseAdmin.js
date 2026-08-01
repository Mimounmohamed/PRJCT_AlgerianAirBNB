const { initializeApp, cert, getApps } = require('firebase-admin/app');
const { getAuth } = require('firebase-admin/auth');

let auth = null;

try {
  let credentialConfig = null;

  // 1. Check if giant JSON string is provided
  if (process.env.FIREBASE_SERVICE_ACCOUNT_JSON) {
    try {
      const rawJson = process.env.FIREBASE_SERVICE_ACCOUNT_JSON.trim();
      const serviceAccount = JSON.parse(rawJson);
      credentialConfig = cert(serviceAccount);
    } catch (parseErr) {
      console.error('❌ Failed to parse FIREBASE_SERVICE_ACCOUNT_JSON:', parseErr.message);
    }
  }

  // 2. Otherwise check individual Azure environment variables
  if (!credentialConfig && process.env.FIREBASE_PROJECT_ID && process.env.FIREBASE_CLIENT_EMAIL && process.env.FIREBASE_PRIVATE_KEY) {
    try {
      let privateKey = process.env.FIREBASE_PRIVATE_KEY.trim();
      // Remove surrounding quotes if pasted into Azure Portal with quotes
      if ((privateKey.startsWith('"') && privateKey.endsWith('"')) || (privateKey.startsWith("'") && privateKey.endsWith("'"))) {
        privateKey = privateKey.slice(1, -1);
      }
      privateKey = privateKey.replace(/\\n/g, '\n');

      credentialConfig = cert({
        projectId: process.env.FIREBASE_PROJECT_ID.trim(),
        clientEmail: process.env.FIREBASE_CLIENT_EMAIL.trim(),
        privateKey: privateKey,
      });
    } catch (certErr) {
      console.error('❌ Failed to create Firebase cert from individual env vars:', certErr.message);
    }
  }

  if (credentialConfig) {
    const app = getApps().length === 0 
      ? initializeApp({ credential: credentialConfig }) 
      : getApps()[0];
    auth = getAuth(app);
    console.log('✅ Firebase Admin SDK initialized successfully');
  } else {
    console.warn('⚠️ Firebase Admin SDK NOT initialized: Missing valid Firebase credentials in environment variables.');
  }
} catch (err) {
  console.error('❌ Firebase Admin initialization error:', err.message);
}

module.exports = { auth };