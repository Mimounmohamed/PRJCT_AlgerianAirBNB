const mongoose = require('mongoose');
const bcrypt = require('bcryptjs');

const otpVerificationSchema = new mongoose.Schema(
  {
    target:     { type: String, required: true }, // email or phone number
    targetType: { type: String, enum: ['email', 'phone'], required: true },
    codeHash:   { type: String, required: true, select: false }, // hashed OTP

    purpose: {
      type: String,
      enum: ['signup', 'login', 'two_factor', 'password_reset'],
      required: true,
    },

    userId:      { type: mongoose.Schema.Types.ObjectId, ref: 'User', default: null },
    attempts:    { type: Number, default: 0 },
    maxAttempts: { type: Number, default: 5 },

    expiresAt: { type: Date, required: true },
    used:      { type: Boolean, default: false },
    usedAt:    { type: Date },
  },
  { timestamps: { createdAt: true, updatedAt: false } }
);

// ── Static: generate + hash OTP ───────────────────────────
otpVerificationSchema.statics.generateOTP = async function (
  target,
  targetType,
  purpose,
  userId = null
) {
  const code = Math.floor(100000 + Math.random() * 900000).toString(); // 6-digit
  const codeHash = await bcrypt.hash(code, 10);
  const expiresAt = new Date(Date.now() + 10 * 60 * 1000); // 10 minutes

  // Invalidate previous OTPs for same target + purpose
  await this.deleteMany({ target, purpose, used: false });

  const otp = await this.create({
    target,
    targetType,
    codeHash,
    purpose,
    userId,
    expiresAt,
  });

  return { otp, plainCode: code }; // Send plainCode via SMS/email
};

// ── Method: verify OTP ─────────────────────────────────────
otpVerificationSchema.methods.verify = async function (inputCode) {
  if (this.used)               return { valid: false, reason: 'already_used' };
  if (new Date() > this.expiresAt) return { valid: false, reason: 'expired' };
  if (this.attempts >= this.maxAttempts) return { valid: false, reason: 'max_attempts' };

  const isMatch = await bcrypt.compare(inputCode, this.codeHash);
  if (!isMatch) {
    this.attempts += 1;
    await this.save();
    return { valid: false, reason: 'invalid_code' };
  }

  this.used = true;
  this.usedAt = new Date();
  await this.save();
  return { valid: true };
};

// TTL index — auto-delete expired OTPs
otpVerificationSchema.index({ expiresAt: 1 }, { expireAfterSeconds: 0 });
otpVerificationSchema.index({ target: 1, purpose: 1 });

module.exports = mongoose.model('OtpVerification', otpVerificationSchema);
