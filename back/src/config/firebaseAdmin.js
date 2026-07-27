const { initializeApp, cert } = require('firebase-admin/app');
const { getAuth } = require('firebase-admin/auth');

let credentialConfig;

// 1. Check if we are running locally (using the giant JSON string)
if (process.env.FIREBASE_SERVICE_ACCOUNT_JSON) {
  credentialConfig = cert(JSON.parse(process.env.FIREBASE_SERVICE_ACCOUNT_JSON));
} 
// 2. Otherwise, use the Azure setup (individual variables)
else {
  const privateKey = process.env.FIREBASE_PRIVATE_KEY 
    ? process.env.FIREBASE_PRIVATE_KEY.replace(/\\n/g, '\n') 
    : undefined;

  credentialConfig = cert({
    projectId: process.env.FIREBASE_PROJECT_ID,
    clientEmail: process.env.FIREBASE_CLIENT_EMAIL,
    privateKey: privateKey,
  });
}

const app = initializeApp({
  credential: credentialConfig,
});

const auth = getAuth(app);

module.exports = { auth };