const express = require('express');
const router = express.Router();
const jwt = require('jsonwebtoken');
const nodemailer = require('nodemailer');
const User = require('../models/User');
const PendingSignup = require('../models/PendingSignup');
const OtpVerification = require('../models/OtpVerification');
const { generateToken } = require('../middleware/auth.middleware');

const mailTransporter = nodemailer.createTransport({
  host: process.env.EMAIL_HOST,
  port: Number(process.env.EMAIL_PORT),
  secure: false, // true for port 465, false for 587 (STARTTLS)
  auth: {
    user: process.env.EMAIL_USER,
    pass: process.env.EMAIL_PASS,
  },
});

const LOGO_URL = 'https://res.cloudinary.com/bcaeahkm/image/upload/v1785290463/logo_yu3xmx.png';
const WELCOME_IMAGE_URL = 'https://res.cloudinary.com/bcaeahkm/image/upload/v1785290452/marhaban_v7kstu.png';

const MALE_AVATAR_URL = 'https://res.cloudinary.com/bcaeahkm/image/upload/v1786136906/user_thpvmo.png';
const FEMALE_AVATAR_URL = 'https://res.cloudinary.com/bcaeahkm/image/upload/v1786136885/user_1_bmqnfp.png';

function getDefaultAvatar(gender) {
  if (gender === 'Male') return MALE_AVATAR_URL;
  if (gender === 'Female') return FEMALE_AVATAR_URL;
  return null; // no default for 'Other' / unspecified yet
}

// ─────────────────────────────────────────────────────────────
// Reusable branded OTP email — works for phone OTP, email OTP,
// password reset, etc. Just pass a title + description.
// ─────────────────────────────────────────────────────────────
async function sendOtpByEmail(toEmail, code, { title = 'Your verification code', description = 'Enter the code below to continue.', subject = 'Your AKRILI code' } = {}) {
  try {
    const info = await mailTransporter.sendMail({
      from: `"AKRILI" <${process.env.EMAIL_USER}>`,
      to: toEmail,
      subject,
      html: `
        <div style="font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif; background-color: #EDE4D3; padding: 32px 20px;">
          <div style="max-width: 460px; margin: 0 auto; background-color: #FFFCF5; border-radius: 20px; overflow: hidden; border: 1px solid #E3D8C0;">
            <div style="padding: 36px 24px 20px; text-align: center;">
              <img src="${LOGO_URL}" alt="AKRILI" width="64" height="64" style="display: block; margin: 0 auto 16px; border-radius: 16px;" />
              <h1 style="color: #1A1A1A; font-size: 20px; font-weight: 700; letter-spacing: 3px; margin: 0;">AKRILI</h1>
            </div>
            <div style="padding: 8px 32px 8px; text-align: center;">
              <div style="width: 48px; height: 2px; background-color: #006972; margin: 0 auto 20px;"></div>
              <h2 style="color: #1A1A1A; font-size: 22px; font-weight: 700; margin: 0 0 10px;">${title}</h2>
              <p style="color: #6B6B6B; font-size: 14px; line-height: 1.6; margin: 0 0 24px;">
                ${description}
              </p>
            </div>
            <div style="padding: 0 32px;">
              <div style="background-color: #FBF3E7; border: 1px solid #D9CDB5; border-radius: 14px; padding: 22px; text-align: center; margin-bottom: 28px;">
                <p style="color: #9A9188; font-size: 11px; letter-spacing: 1px; margin: 0 0 8px; text-transform: uppercase;">Your verification code</p>
                <span style="font-size: 34px; font-weight: 700; letter-spacing: 10px; color: #006972;">${code}</span>
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
    console.log(`[NODEMAILER] OTP email sent to ${toEmail}. Message ID: ${info.messageId}`);
  } catch (err) {
    console.error(`[NODEMAILER ERROR] Failed to send OTP email to ${toEmail}:`, err.message);
  }
}

// ─────────────────────────────────────────────────────────────
// Branded alert email — same AKRILI design but with a warning
// icon instead of the OTP code box. Used for password change
// confirmations, security alerts, etc.
// ─────────────────────────────────────────────────────────────
async function sendAlertEmail(toEmail, { title = 'Security Alert', description = '', subject = 'AKRILI — Security Alert', alertType = 'warning' } = {}) {
  const iconColor = alertType === 'success' ? '#006972' : '#D32F2F';
  const iconSymbol = alertType === 'success' ? '✓' : '!';
  const borderColor = alertType === 'success' ? '#006972' : '#D32F2F';

  try {
    const info = await mailTransporter.sendMail({
      from: `"AKRILI" <${process.env.EMAIL_USER}>`,
      to: toEmail,
      subject,
      html: `
        <div style="font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif; background-color: #EDE4D3; padding: 32px 20px;">
          <div style="max-width: 460px; margin: 0 auto; background-color: #FFFCF5; border-radius: 20px; overflow: hidden; border: 1px solid #E3D8C0;">
            <div style="padding: 36px 24px 20px; text-align: center;">
              <img src="${LOGO_URL}" alt="AKRILI" width="64" height="64" style="display: block; margin: 0 auto 16px; border-radius: 16px;" />
              <h1 style="color: #1A1A1A; font-size: 20px; font-weight: 700; letter-spacing: 3px; margin: 0;">AKRILI</h1>
            </div>
            <div style="padding: 8px 32px 8px; text-align: center;">
              <div style="width: 48px; height: 2px; background-color: ${borderColor}; margin: 0 auto 20px;"></div>
              <table role="presentation" cellpadding="0" cellspacing="0" border="0" style="margin: 0 auto 18px;"><tr><td style="width: 56px; height: 56px; border-radius: 50%; background-color: ${iconColor}; text-align: center; vertical-align: middle;"><span style="color: #FFFFFF; font-size: 28px; font-weight: 900;">${iconSymbol}</span></td></tr></table>
              <h2 style="color: #1A1A1A; font-size: 22px; font-weight: 700; margin: 0 0 10px;">${title}</h2>
              <p style="color: #6B6B6B; font-size: 14px; line-height: 1.6; margin: 0 0 24px;">
                ${description}
              </p>
            </div>
            <div style="padding: 0 32px 32px; text-align: center;">
              <p style="color: #9A9188; font-size: 12px; line-height: 1.5; margin: 0;">
                If you did not perform this action, please secure your account immediately.
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
    console.log(`[NODEMAILER] Alert email sent to ${toEmail}. Message ID: ${info.messageId}`);
  } catch (err) {
    console.error(`[NODEMAILER ERROR] Failed to send alert email to ${toEmail}:`, err.message);
  }
}

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
    const info = await mailTransporter.sendMail({
      from: `"AKRILI" <${process.env.EMAIL_USER}>`,
      to: user.email,
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
    console.log('[NODEMAILER] Welcome email sent. Message ID:', info.messageId);
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
    res.json({ token, user: { _id: user._id, fullName: user.fullName, email: user.email, profilePhoto: user.profilePhoto } });
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
        profilePhoto: pending.profilePhoto || getDefaultAvatar(pending.gender),
        identityVerified: true,
      });

      await PendingSignup.deleteOne({ _id: pending._id });

      sendWelcomeEmail(user); // fire-and-forget, don't block the response

      const appToken = generateToken(user._id);
      return res.json({ message: 'Account created and verified.', token: appToken, user: {
        _id: user._id, fullName: user.fullName, email: user.email, profilePhoto: user.profilePhoto,
      }});
    }

    let user = await User.findById(otpRecord.userId);
    const token = generateToken(user._id);
    res.json({ token, user: { _id: user._id, fullName: user.fullName, profilePhoto: user.profilePhoto } });
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

    // 1. Check if user already linked this Google account
    let user = await User.findOne({ 'socialAccounts.google.id': googleId });

    if (!user) {
      // 2. Check if a user with this email already exists (registered via email/password)
      const existing = await User.findOne({ email });

      if (existing) {
        return res.status(409).json({
          error: 'An account with this email already exists. Please log in with your email and password instead.',
        });
      }

      // 3. Brand new user — create account
      user = await User.create({
        fullName,
        email,
        profilePhoto,
        socialAccounts: { google: { id: googleId, email } },
      });
    }

    const token = generateToken(user._id);
    res.json({ token, user: { _id: user._id, fullName: user.fullName, email: user.email, profilePhoto: user.profilePhoto } });
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
      // Send the phone OTP via email
      if (pending.email) {
        await sendOtpByEmail(pending.email, plainCode, {
          subject: 'AKRILI — Phone Verification Code',
          title: 'Verify your phone number',
          description: `Use this code to verify your phone number (${target}) and complete your AKRILI account.`,
        });
      }
    } else {
      console.log(`[DEBUG] Sending email OTP to: "${target}"`);
      await sendOtpByEmail(target, plainCode, {
        subject: 'Your AKRILI verification code',
        title: 'Verify your account',
        description: 'Enter the code below to verify your email and start exploring authentic Algerian stays.',
      });
    }

    res.json({ message: `OTP sent to your ${channel}.` });
  } catch (err) {
    console.error('[SEND-OTP ERROR]', JSON.stringify({
      message: err.message,
      code: err.code,
      command: err.command,
    }));
    res.status(500).json({ error: err.message });
  }
});

// ─────────────────────────────────────────────────────────────
// POST /api/auth/send-reset-otp
// ─────────────────────────────────────────────────────────────
router.post('/send-reset-otp', async (req, res) => {
  try {
    const { phone, email, channel } = req.body;
    let user, target, otpType;

    if (channel === 'sms' && phone) {
      user = await User.findOne({ 'phone.number': phone });
      if (!user) return res.status(404).json({ error: 'Phone number not registered.' });
      target = `${user.phone.countryCode}${phone.replace(/^0/, '')}`;
      otpType = 'phone';
    } else if (channel === 'email' && email) {
      user = await User.findOne({ email });
      if (!user) return res.status(404).json({ error: 'Email not registered.' });
      target = email;
      otpType = 'email';
    } else {
      return res.status(400).json({ error: 'Provide phone or email with channel.' });
    }

    const { plainCode } = await OtpVerification.generateOTP(
      target, otpType, 'password_reset', user._id
    );

    if (channel === 'sms') {
      // Send the reset OTP via email
      if (user.email) {
        await sendOtpByEmail(user.email, plainCode, {
          subject: 'AKRILI — Password Reset Code',
          title: 'Reset your password',
          description: `Use this code to reset your password for your AKRILI account.`,
        });
      }
    } else {
      await sendOtpByEmail(target, plainCode, {
        subject: 'AKRILI — Password Reset Code',
        title: 'Reset your password',
        description: `Enter the code below to reset your password and secure your account.`,
      });
    }

    res.json({ message: `Reset code sent to your ${channel}.` });
  } catch (err) {
    console.error('[SEND-RESET-OTP ERROR]', err.message);
    res.status(500).json({ error: err.message });
  }
});

// ─────────────────────────────────────────────────────────────
// POST /api/auth/reset-password
// ─────────────────────────────────────────────────────────────
router.post('/reset-password', async (req, res) => {
  try {
    const { email, newPassword } = req.body;

    if (!email || !newPassword) {
      return res.status(400).json({ error: 'Email and new password are required.' });
    }
    if (newPassword.length < 8) {
      return res.status(400).json({ error: 'Password must be at least 8 characters.' });
    }

    const user = await User.findOne({ email }).select('+passwordHash');
    if (!user) {
      return res.status(404).json({ error: 'User not found.' });
    }

    // ── Rate limit: max 2 resets per 24h ──
    const now = new Date();
    const windowStart = new Date(now.getTime() - 24 * 60 * 60 * 1000);

    user.passwordResetHistory = (user.passwordResetHistory || []).filter(
      (d) => new Date(d) > windowStart
    );

    if (user.passwordResetHistory.length >= 2) {
      sendAlertEmail(user.email, {
        subject: 'AKRILI — Security Alert: Too Many Password Changes',
        title: 'Too many password changes!',
        description:
          'Someone has attempted to change your password too many times in the last 24 hours. ' +
          'For your security, password changes are limited to <strong>2 per 24 hours</strong>. ' +
          'If this wasn\'t you, please secure your account immediately.',
        alertType: 'warning',
      });

      return res.status(429).json({
        error: 'Password changed too many times. Please try again after 24 hours.',
      });
    }

    user.passwordHash = newPassword; // pre-save hook auto-hashes it
    user.passwordResetHistory.push(now);
    await user.save();

    sendAlertEmail(user.email, {
      subject: 'AKRILI — Password Changed Successfully',
      title: 'Password changed successfully',
      description:
        'Your AKRILI account password was just changed. ' +
        'If this was you, no action is needed. ' +
        'If you did not make this change, please reset your password immediately.',
      alertType: 'success',
    });

    res.json({ message: 'Password reset successfully.' });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// ─────────────────────────────────────────────────────────────
// POST /api/auth/login/phone
// Finds account by phone, returns masked contact details, sends OTP via email
// ─────────────────────────────────────────────────────────────
router.post('/login/phone', async (req, res) => {
  try {
    const { phone } = req.body;

    const user = await User.findOne({ 'phone.number': phone });
    if (!user) {
      return res.status(404).json({ error: 'Phone number not registered.' });
    }

    let maskedEmail = '';
    if (user.email) {
      const [name, domain] = user.email.split('@');
      const visiblePart = name.length > 2 ? name.slice(-2) : name;
      maskedEmail = `***${visiblePart}@${domain}`;
    }

    const phoneNumber = user.phone.number;
    const lastTwoDigits = phoneNumber.slice(-2);
    const maskedPhone = `••••••••${lastTwoDigits}`;

    const { plainCode } = await OtpVerification.generateOTP(
      phone, 'phone', 'login', user._id
    );

    const e164 = `${user.phone.countryCode}${phone.replace(/^0/, '')}`;
    if (user.email) {
      await sendOtpByEmail(user.email, plainCode, {
        subject: 'AKRILI — Phone Login Code',
        title: 'Phone login code',
        description: `Use this code to log in to your AKRILI account (phone: ${e164}).`,
      });
    }

    res.json({
      message: 'OTP sent.',
      maskedEmail,
      maskedPhone,
      realPhone: user.phone.number,
      realEmail: user.email,
    });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// ─────────────────────────────────────────────────────────────
// POST /api/auth/disconnect-google
// ─────────────────────────────────────────────────────────────
router.post('/disconnect-google', async (req, res) => {
  try {
    const authHeader = req.headers.authorization;
    if (!authHeader || !authHeader.startsWith('Bearer ')) {
      return res.status(401).json({ error: 'No token provided.' });
    }

    const token = authHeader.split(' ')[1];
    const decoded = jwt.verify(token, process.env.JWT_SECRET);

    const { password, confirmPassword } = req.body;

    if (!password || !confirmPassword) {
      return res.status(400).json({ error: 'Password and confirmation are required.' });
    }

    if (password.length < 6) {
      return res.status(400).json({ error: 'Password must be at least 6 characters.' });
    }

    if (password !== confirmPassword) {
      return res.status(400).json({ error: 'Passwords do not match.' });
    }

    const user = await User.findById(decoded.id).select('+passwordHash');
    if (!user) {
      return res.status(404).json({ error: 'User not found.' });
    }

    if (!user.socialAccounts?.google?.id) {
      return res.status(400).json({ error: 'No Google account linked.' });
    }

    // Set the new password (hashed automatically by pre-save hook)
    user.passwordHash = password;
    user.socialAccounts.google = undefined;
    await user.save();

    res.json({ message: 'Google account disconnected. You can now log in with your email and password.' });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});



module.exports = router;