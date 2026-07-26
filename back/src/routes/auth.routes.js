const express = require('express');
const router = express.Router();
const jwt = require('jsonwebtoken');

const User = require('../models/User');
const OtpVerification = require('../models/OtpVerification');
const { generateToken } = require('../middleware/auth.middleware');

// ─────────────────────────────────────────────────────────────
// POST /api/auth/register
// Step 1: Create account (name, email, phone, password)
// ─────────────────────────────────────────────────────────────
router.post('/register', async (req, res) => {
  try {
    const { fullName, email, phone, password } = req.body;

    // Check for existing user
    const exists = await User.findOne({
      $or: [{ email }, { 'phone.number': phone }],
    });
    if (exists) {
      return res.status(409).json({ error: 'Email or phone already registered.' });
    }

    const user = await User.create({
      fullName,
      email,
      phone: { countryCode: '+213', number: phone },
      passwordHash: password, // will be hashed by pre-save hook
    });

    const token = generateToken(user._id);

    res.status(201).json({
      message: 'Account created successfully.',
      token,
      user: {
        _id:      user._id,
        fullName: user.fullName,
        email:    user.email,
        phone:    user.phone,
      },
    });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// ─────────────────────────────────────────────────────────────
// PUT /api/auth/complete-profile
// Step 2: Personal info (gender, birthday, wilaya, baladiya, address)
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

    const user = await User.findByIdAndUpdate(
      decoded.id,
      { gender, birthday, wilaya, baladiya, fullAddress },
      { new: true }
    );

    res.json({ message: 'Profile updated.', user });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// ─────────────────────────────────────────────────────────────
// PUT /api/auth/profile-photo
// Step 3: Profile photo
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

    const user = await User.findByIdAndUpdate(
      decoded.id,
      { profilePhoto },
      { new: true }
    );

    res.json({ message: 'Photo updated.', user });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// ─────────────────────────────────────────────────────────────
// POST /api/auth/login/email
// Login with email + password
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
// Step 1: Send OTP to phone number
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

    // TODO: Send plainCode via Twilio SMS
    // await twilioClient.messages.create({ body: `Your AKRILI code: ${plainCode}`, from: ..., to: ... });

    console.log(`[DEV] OTP for ${phone}: ${plainCode}`); // Remove in production!

    res.json({ message: 'OTP sent to your phone number.' });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// ─────────────────────────────────────────────────────────────
// POST /api/auth/verify-otp
// Verify OTP and return JWT
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

    // Find or create user for signup flow
    let user = await User.findById(otpRecord.userId);
    if (!user && purpose === 'signup') {
      // User will be created in the next registration step
      return res.json({ message: 'OTP verified.', verified: true });
    }

    const token = generateToken(user._id);
    res.json({ token, user: { _id: user._id, fullName: user.fullName } });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// ─────────────────────────────────────────────────────────────
// POST /api/auth/google
// Sign in / Register with Google
// ─────────────────────────────────────────────────────────────
router.post('/google', async (req, res) => {
  try {
    const { googleId, email, fullName, profilePhoto } = req.body;

    let user = await User.findOne({ 'socialAccounts.google.id': googleId });

    if (!user) {
      // Create new user from Google data
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

router.post('/send-otp', async (req, res) => {
  try {
    const authHeader = req.headers.authorization;
    if (!authHeader || !authHeader.startsWith('Bearer ')) {
      return res.status(401).json({ error: 'No token provided.' });
    }

    const token = authHeader.split(' ')[1];
    const decoded = jwt.verify(token, process.env.JWT_SECRET);

    const { channel } = req.body; // Expects 'sms' or 'email'
    const user = await User.findById(decoded.id);
    if (!user) {
      return res.status(404).json({ error: 'User not found.' });
    }

    const target = channel === 'sms' ? user.phone.number : user.email;
    const otpType = channel === 'sms' ? 'phone' : 'email';

    if (!target) {
      return res.status(400).json({ error: `No ${channel} found for this account.` });
    }

    const { plainCode } = await OtpVerification.generateOTP(
      target, otpType, 'signup', user._id
    );

    console.log(`[DEV] Signup OTP for ${target} (${channel}): ${plainCode}`);

    res.json({ message: `OTP sent to your ${channel}.` });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

module.exports = router;