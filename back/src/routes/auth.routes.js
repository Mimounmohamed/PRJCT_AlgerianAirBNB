const express = require('express');
const router = express.Router();
const jwt = require('jsonwebtoken');
const twilio = require('twilio');
const { Resend } = require('resend');
const User = require('../models/User');
const PendingSignup = require('../models/PendingSignup');
const OtpVerification = require('../models/OtpVerification');
const { generateToken } = require('../middleware/auth.middleware');
const { auth: firebaseAuth } = require('../config/firebaseAdmin');

const twilioClient = twilio(
  process.env.TWILIO_ACCOUNT_SID,
  process.env.TWILIO_AUTH_TOKEN
);

const resend = new Resend(process.env.RESEND_API_KEY);

const LOGO_URL = 'https://res.cloudinary.com/bcaeahkm/image/upload/v1785290463/logo_yu3xmx.png';
const WELCOME_IMAGE_URL = 'https://res.cloudinary.com/bcaeahkm/image/upload/v1785290452/marhaban_v7kstu.png';

function generatePendingToken(pendingId) {
  return jwt.sign({ id: pendingId, pending: true }, process.env.JWT_SECRET, {
    expiresIn: '24h',
  });
}

// ─────────────────────────────────────────────────────────────
// Sends the branded welcome email after a real User is created
// ─────────────────────────────────────────────────────────────
async function sendWelcomeEmail(user) {
  try {
    console.log(`[DEBUG] Sending welcome email to: "${user.email}"`);
    const { data, error } = await resend.emails.send({
      from: 'AKRILI <onboarding@resend.dev>',
      to: [user.email],
      subject: 'Welcome to AKRILI!',
      html: `
        <div style="font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif; background-color: #EDE4D3; padding: 32px 20px;">
          <div style="max-width: 460px; margin: 0 auto; background-color: #FFFCF5; border-radius: 20px; overflow: hidden; border: 1px solid #E3D8C0;">
            <div style="padding: 28px 24px 20px; text-align: center;">
              <h1 style="color: #1A1A1A; font-size: 22px; font-weight: 700; letter-spacing: 3px; margin: 0;">AKRILI</h1>
            </div>
            <div style="padding: 0 16px;">
              <img src="${WELCOME_IMAGE_URL}" alt="" width="460" style="display: block; width: 100%; height: 220px; object-fit: cover; border-radius: 14px;" />
            </div>
            <div style="padding: 32px 32px 8px; text-align: center;">
              <div style="width: 48px; height: 2px; background-color: #006972; margin: 0 auto 20px;"></div>
              <h2 style="color: #1A1A1A; font-size: 24px; font-weight: 700; margin: 0 0 10px;">Marhaban, ${user.fullName}!</h2>
              <p style="color: #6B6B6B; font-size: 14px; line-height: 1.6; margin: 0 0 28px;">
                Your account is verified and ready. Your journey into the heart of Algeria begins here — discover authentic stays that tell a story.
              </p>
            </div>
            <div style="background-color: #FBF3E7; padding: 22px 32px; text-align: center; border-top: 1px solid #E3D8C0;">
              <p style="color: #1A1A1A; font-size: 13px; font-weight: 700; letter-spacing: 2px; margin: 0 0 4px;">AKRILI</p>
              <p style="color: #9A9188; font-size: 11px; margin: 0;">Discover Algeria's hidden architectural gems</p>
            </div>
          </div>
        </div>
      `,
    });

    if (error) {
      console.error('[WELCOME EMAIL ERROR]', JSON.stringify(error));
      return;
    }
    console.log('[RESEND] Welcome email sent. ID:', data?.id);
  } catch (err) {
    console.error('[WELCOME EMAIL ERROR]', err.message);
  }
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

    await PendingSignup.deleteMany({ email });

    const pending = await PendingSignup.create({
      fullName,
      email,
      phone: { countryCode: '+213', number: phone },
      passwordHash: password,
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
      const pending = await PendingSignup.findById(otpRecord.userId).select('+passwordHash');
      if (!pending) {
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

      sendWelcomeEmail(user); // fire-and-forget, don't block the response

      const appToken = generateToken(user._id);
      return res.json({ message: 'Account created and verified.', token: appToken, user: {
        _id: user._id, fullName: user.fullName, email: user.email,
      }});
    }

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
      console.log(`[DEBUG] Sending email OTP to: "${target}"`);
      const { data, error } = await resend.emails.send({
        from: 'AKRILI <onboarding@resend.dev>',
        to: [target],
        subject: 'Your AKRILI verification code',
        html: `
          <div style="font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif; background-color: #EDE4D3; padding: 32px 20px;">
            <div style="max-width: 460px; margin: 0 auto; background-color: #FFFCF5; border-radius: 20px; overflow: hidden; border: 1px solid #E3D8C0;">
              <div style="padding: 36px 24px 20px; text-align: center;">
                <img src="${LOGO_URL}" alt="AKRILI" width="64" height="64" style="display: block; margin: 0 auto 16px; border-radius: 16px;" />
                <h1 style="color: #1A1A1A; font-size: 20px; font-weight: 700; letter-spacing: 3px; margin: 0;">AKRILI</h1>
              </div>
              <div style="padding: 8px 32px 8px; text-align: center;">
                <div style="width: 48px; height: 2px; background-color: #006972; margin: 0 auto 20px;"></div>
                <h2 style="color: #1A1A1A; font-size: 22px; font-weight: 700; margin: 0 0 10px;">Verify your account</h2>
                <p style="color: #6B6B6B; font-size: 14px; line-height: 1.6; margin: 0 0 24px;">
                  Enter the code below to verify your email and start exploring authentic Algerian stays.
                </p>
              </div>
              <div style="padding: 0 32px;">
                <div style="background-color: #FBF3E7; border: 1px solid #D9CDB5; border-radius: 14px; padding: 22px; text-align: center; margin-bottom: 28px;">
                  <p style="color: #9A9188; font-size: 11px; letter-spacing: 1px; margin: 0 0 8px; text-transform: uppercase;">Your verification code</p>
                  <span style="font-size: 34px; font-weight: 700; letter-spacing: 10px; color: #006972;">${plainCode}</span>
                </div>
              </div>
              <div style="padding: 0 32px 32px; text-align: center;">
                <p style="color: #9A9188; font-size: 12px; line-height: 1.5; margin: 0;">
                  This code expires in 10 minutes. Didn't request this? You can safely ignore this email.
                </p>
              </div>
              <div style="background-color: #FBF3E7; padding: 22px 32px; text-align: center; border-top: 1px solid #E3D8C0;">
                <p style="color: #1A1A1A; font-size: 13px; font-weight: 700; letter-spacing: 2px; margin: 0 0 4px;">AKRILI</p>
                <p style="color: #9A9188; font-size: 11px; margin: 0;">Discover Algeria's hidden architectural gems</p>
              </div>
            </div>
          </div>
        `,
      });

      if (error) {
        console.error('[RESEND ERROR]', JSON.stringify(error));
        return res.status(500).json({ error: 'Failed to send verification email.' });
      }

      console.log('[RESEND] Email sent successfully. ID:', data?.id);
    }

    res.json({ message: `OTP sent to your ${channel}.` });
  } catch (err) {
    console.error('[SEND-OTP ERROR]', JSON.stringify({
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

    sendWelcomeEmail(user); // fire-and-forget, don't block the response

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