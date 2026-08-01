const express = require('express');
const router = express.Router();
const jwt = require('jsonwebtoken');
const twilio = require('twilio');
const User = require('../models/User');
const PendingSignup = require('../models/PendingSignup');
const OtpVerification = require('../models/OtpVerification');
const { generateToken } = require('../middleware/auth.middleware');
const { auth: firebaseAuth } = require('../config/firebaseAdmin');

const twilioClient = twilio(
  process.env.TWILIO_ACCOUNT_SID,
  process.env.TWILIO_AUTH_TOKEN
);

// Generates a temporary token referencing a PendingSignup doc (not a real User yet)
function generatePendingToken(pendingId) {
  return jwt.sign({ id: pendingId, pending: true }, process.env.JWT_SECRET, {
    expiresIn: '24h',
  });
}

// ─────────────────────────────────────────────────────────────
// POST /api/auth/register
// Step 1: Create a PENDING signup (not a real User yet)
// ─────────────────────────────────────────────────────────────
router.post('/register', async (req, res) => {
  try {
    const { fullName, email, phone, password } = req.body;

    const existingUser = await User.findOne({ email });
    if (existingUser) {
      return res.status(409).json({ error: 'Email already registered.' });
    }

    // Remove any previous incomplete attempt for this email, then start fresh
    await PendingSignup.deleteMany({ email });

    const pending = await PendingSignup.create({
      fullName,
      email,
      phone: { countryCode: '+213', number: phone },
      passwordHash: password, // hashed by pre-save hook
    });

    const token = generatePendingToken(pending._id);

    res.status(201).json({
      message: 'Account details saved. Please complete your profile and verify your account.',
      token,
      user: {
        _id:      pending._id,
        fullName: pending.fullName,
        email:    pending.email,
        phone:    pending.phone,
      },
    });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// ─────────────────────────────────────────────────────────────
// PUT /api/auth/complete-profile
// Step 2: Update the PENDING signup with personal info
// ─────────────────────────────────────────────────────────────
router.put('/complete-profile', async (req, res) => {
  try {
    const authHeader = req.headers.authorization;
    if (!authHeader || !authHeader.startsWith('Bearer ')) {
      return res.status(401).json({ error: 'No token provided.' });
    }

    const token = authHeader.split(' ')[1];
    const decoded = jwt.verify(token, process.env.JWT_SECRET);

    const { gender, birthday, wilaya, baladiya, fullAddress } = req.body;

    const pending = await PendingSignup.findByIdAndUpdate(
      decoded.id,
      { gender, birthday, wilaya, baladiya, fullAddress },
      { new: true }
    );

    if (!pending) {
      return res.status(404).json({ error: 'Pending signup not found. Please register again.' });
    }

    res.json({ message: 'Profile updated.', user: pending });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// ─────────────────────────────────────────────────────────────
// PUT /api/auth/profile-photo
// Step 3: Update the PENDING signup with a profile photo
// ─────────────────────────────────────────────────────────────
router.put('/profile-photo', async (req, res) => {
  try {
    const authHeader = req.headers.authorization;
    if (!authHeader || !authHeader.startsWith('Bearer ')) {
      return res.status(401).json({ error: 'No token provided.' });
    }

    const token = authHeader.split(' ')[1];
    const decoded = jwt.verify(token, process.env.JWT_SECRET);

    const { profilePhoto } = req.body;

    const pending = await PendingSignup.findByIdAndUpdate(
      decoded.id,
      { profilePhoto },
      { new: true }
    );

    if (!pending) {
      return res.status(404).json({ error: 'Pending signup not found. Please register again.' });
    }

    res.json({ message: 'Photo updated.', user: pending });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// ─────────────────────────────────────────────────────────────
// POST /api/auth/login/email
// ─────────────────────────────────────────────────────────────
router.post('/login/email', async (req, res) => {
  try {
    const { email, password } = req.body;

    const user = await User.findOne({ email }).select('+passwordHash');
    if (!user || !(await user.comparePassword(password))) {
      return res.status(401).json({ error: 'Invalid email or password.' });
    }

    if (user.accountStatus !== 'active') {
      return res.status(403).json({ error: 'Account is deactivated.' });
    }

    const token = generateToken(user._id);
    res.json({ token, user: { _id: user._id, fullName: user.fullName, email: user.email } });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// ─────────────────────────────────────────────────────────────
// POST /api/auth/login/phone
// ─────────────────────────────────────────────────────────────
router.post('/login/phone', async (req, res) => {
  try {
    const { phone } = req.body;

    const user = await User.findOne({ 'phone.number': phone });
    if (!user) {
      return res.status(404).json({ error: 'Phone number not registered.' });
    }

    const { plainCode } = await OtpVerification.generateOTP(
      phone, 'phone', 'login', user._id
    );

    console.log(`[DEV] OTP for ${phone}: ${plainCode}`);

    res.json({ message: 'OTP sent to your phone number.' });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// ─────────────────────────────────────────────────────────────
// POST /api/auth/verify-otp
// Verifies EMAIL OTP for signup — creates the REAL User here
// ─────────────────────────────────────────────────────────────
router.post('/verify-otp', async (req, res) => {
  try {
    const { target, code, purpose } = req.body;

    const otpRecord = await OtpVerification.findOne({
      target,
      purpose,
      used: false,
    }).select('+codeHash');

    if (!otpRecord) {
      return res.status(404).json({ error: 'No active OTP found. Please request a new one.' });
    }

    const result = await otpRecord.verify(code);
    if (!result.valid) {
      return res.status(400).json({ error: result.reason });
    }

    if (purpose === 'signup') {
      // otpRecord.userId actually stores the PendingSignup._id in this flow
      const pending = await PendingSignup.findById(otpRecord.userId).select('+passwordHash');
      if (!pending) {
        return res.status(404).json({ error: 'Pending signup not found. Please register again.' });
      }

      const user = await User.create({
        fullName:     pending.fullName,
        email:        pending.email,
        phone:        pending.phone,
        passwordHash: pending.passwordHash, // already hashed — see note below
        gender:       pending.gender,
        birthday:     pending.birthday,
        wilaya:       pending.wilaya,
        fullAddress:  pending.fullAddress,
        profilePhoto: pending.profilePhoto,
        identityVerified: true,
      });

      await PendingSignup.deleteOne({ _id: pending._id });

      const appToken = generateToken(user._id);
      return res.json({ message: 'Account created and verified.', token: appToken, user: {
        _id: user._id, fullName: user.fullName, email: user.email,
      }});
    }

    // Non-signup purposes (login, 2FA, password reset) — existing real Users
    let user = await User.findById(otpRecord.userId);
    const token = generateToken(user._id);
    res.json({ token, user: { _id: user._id, fullName: user.fullName } });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// ─────────────────────────────────────────────────────────────
// POST /api/auth/google
// ─────────────────────────────────────────────────────────────
router.post('/google', async (req, res) => {
  try {
    const { googleId, email, fullName, profilePhoto } = req.body;

    let user = await User.findOne({ 'socialAccounts.google.id': googleId });

    if (!user) {
      user = await User.create({
        fullName,
        email,
        profilePhoto,
        socialAccounts: { google: { id: googleId, email } },
      });
    }

    const token = generateToken(user._id);
    res.json({ token, user: { _id: user._id, fullName: user.fullName, email: user.email } });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// ─────────────────────────────────────────────────────────────
// POST /api/auth/send-otp
// Sends OTP against the PENDING signup's phone/email
// ─────────────────────────────────────────────────────────────
router.post('/send-otp', async (req, res) => {
  try {
    const authHeader = req.headers.authorization;
    if (!authHeader || !authHeader.startsWith('Bearer ')) {
      return res.status(401).json({ error: 'No token provided.' });
    }

    const token = authHeader.split(' ')[1];
    const decoded = jwt.verify(token, process.env.JWT_SECRET);

    const { channel } = req.body;
    const pending = await PendingSignup.findById(decoded.id);
    if (!pending) {
      return res.status(404).json({ error: 'Pending signup not found. Please register again.' });
    }

    const target = channel === 'sms'
      ? `${pending.phone.countryCode}${pending.phone.number.replace(/^0/, '')}`
      : pending.email;
    const otpType = channel === 'sms' ? 'phone' : 'email';

    if (!target) {
      return res.status(400).json({ error: `No ${channel} found for this account.` });
    }

    // Note: userId here stores the PendingSignup._id, consumed in /verify-otp above
    const { plainCode } = await OtpVerification.generateOTP(
      target, otpType, 'signup', pending._id
    );

    if (channel === 'sms') {
      console.log(`[DEBUG] Sending SMS to: "${target}"`);
      await twilioClient.messages.create({
        body: `Your AKRILI verification code is: ${plainCode}`,
        from: process.env.TWILIO_PHONE_NUMBER,
        to: target,
      });
    } else {
      console.log(`[DEV] Email OTP for ${target}: ${plainCode}`);
    }

    res.json({ message: `OTP sent to your ${channel}.` });
  } catch (err) {
    console.error('[TWILIO ERROR]', JSON.stringify({
      message: err.message,
      code: err.code,
      status: err.status,
      moreInfo: err.moreInfo,
    }));
    res.status(500).json({ error: err.message });
  }
});

// ─────────────────────────────────────────────────────────────
// POST /api/auth/verify-firebase-phone
// Verifies Firebase SMS auth for signup — creates the REAL User here
// ─────────────────────────────────────────────────────────────
router.post('/verify-firebase-phone', async (req, res) => {
  try {
    if (!firebaseAuth) {
      console.error('[FIREBASE-VERIFY] Firebase Auth SDK is not initialized on the server.');
      return res.status(500).json({
        error: 'Firebase Admin SDK is not configured on the server. Please verify environment variables in Azure.'
      });
    }

    const { idToken } = req.body;
    console.log('[FIREBASE-VERIFY] Received idToken (length):', idToken?.length);

    const decodedFirebase = await firebaseAuth.verifyIdToken(idToken);
    console.log('[FIREBASE-VERIFY] Token verified. Phone:', decodedFirebase.phone_number, '| UID:', decodedFirebase.uid);

    const authHeader = req.headers.authorization;
    if (!authHeader || !authHeader.startsWith('Bearer ')) {
      console.log('[FIREBASE-VERIFY] Missing app JWT in Authorization header.');
      return res.status(401).json({ error: 'No token provided.' });
    }
    const jwtToken = authHeader.split(' ')[1];
    const jwtDecoded = jwt.verify(jwtToken, process.env.JWT_SECRET);
    console.log('[FIREBASE-VERIFY] Pending token decoded. ID:', jwtDecoded.id);

    const pending = await PendingSignup.findById(jwtDecoded.id).select('+passwordHash');
    if (!pending) {
      console.log('[FIREBASE-VERIFY] Pending signup not found for ID:', jwtDecoded.id);
      return res.status(404).json({ error: 'Pending signup not found. Please register again.' });
    }

    const user = await User.create({
      fullName:     pending.fullName,
      email:        pending.email,
      phone:        pending.phone,
      passwordHash: pending.passwordHash,
      gender:       pending.gender,
      birthday:     pending.birthday,
      wilaya:       pending.wilaya,
      fullAddress:  pending.fullAddress,
      profilePhoto: pending.profilePhoto,
      identityVerified: true,
    });

    await PendingSignup.deleteOne({ _id: pending._id });
    console.log('[FIREBASE-VERIFY] Real User created:', user._id);

    const appToken = generateToken(user._id);
    res.json({ message: 'Phone verified. Account created.', token: appToken, user: {
      _id: user._id, fullName: user.fullName, email: user.email,
    }});
  } catch (err) {
    console.error('[FIREBASE-VERIFY ERROR]', JSON.stringify({
      message: err.message,
      code: err.code,
      name: err.name,
    }));
    res.status(500).json({ error: err.message });
  }
});

module.exports = router;