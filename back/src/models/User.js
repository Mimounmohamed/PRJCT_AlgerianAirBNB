const mongoose = require('mongoose');
const bcrypt = require('bcryptjs');

const userSchema = new mongoose.Schema(
  {
    // ── Personal Info ──────────────────────────────────────
    fullName: { type: String, required: true, trim: true },
    email:    { type: String, unique: true, sparse: true, lowercase: true, trim: true },
    phone: {
      countryCode: { type: String, default: '+213' },
      number:      { type: String, unique: false, sparse: true, trim: true },
    },
    passwordHash: { type: String, select: false },
    profilePhoto: { type: String, default: null },

    // ── Sign-Up Extra Info ─────────────────────────────────
    gender:      { type: String, enum: ['Male', 'Female', 'Other'] },
    birthday:    { type: Date },
    country:     { type: String, default: 'Algeria' },
    city:        { type: String },
    wilaya:      { type: String },
    fullAddress: { type: String },

    // ── Role ───────────────────────────────────────────────
    isHost:      { type: Boolean, default: false },
    isSuperhost: { type: Boolean, default: false },
    hostSince:   { type: Date },

    // ── Identity Verification ──────────────────────────────
    identityVerified: { type: Boolean, default: false },
    identityVerification: {
      status: {
        type: String,
        enum: ['not_started', 'pending', 'under_review', 'approved', 'rejected'],
        default: 'not_started',
      },
      documentType: {
        type: String,
        enum: ['passport', 'national_id', 'driving_license'],
      },
      documentImageUrl: String,
      submittedAt:      Date,
      reviewedAt:       Date,
      rejectionReason:  String,
    },
    trustedHostBadge: { type: Boolean, default: false },

    // ── Social Accounts ────────────────────────────────────
    socialAccounts: {
      google: {
        id:    String,
        email: String,
      },
    },

    // ── Security ───────────────────────────────────────────
    security: {
      twoFactorEnabled: { type: Boolean, default: false },
      twoFactorMethod:  { type: String, enum: ['sms', 'email'] },
    },

    // ── Notification Preferences ───────────────────────────
    notificationSettings: {
      bookingUpdates: { type: Boolean, default: true },
      messages:       { type: Boolean, default: true },
      promotions:     { type: Boolean, default: false },
      priceDrop:      { type: Boolean, default: true },
      helpUpdates:    { type: Boolean, default: true },
      appUpdates:     { type: Boolean, default: false },
    },

    // ── App Settings ───────────────────────────────────────
    settings: {
      language: { type: String, default: 'en' },
      currency: { type: String, default: 'DZD' },
    },

    // ── Account Status ─────────────────────────────────────
    accountStatus: {
      type: String,
      enum: ['active', 'deactivated', 'suspended'],
      default: 'active',
    },
  },
  { timestamps: true }
);

// ── Hash password before saving ────────────────────────────
userSchema.pre('save', async function (next) {
  if (!this.isModified('passwordHash')) return next();
  this.passwordHash = await bcrypt.hash(this.passwordHash, 12);
  next();
});

// ── Compare password method ────────────────────────────────
userSchema.methods.comparePassword = async function (candidatePassword) {
  return bcrypt.compare(candidatePassword, this.passwordHash);
};

// ── Indexes ────────────────────────────────────────────────
userSchema.index({ email: 1 });
userSchema.index({ isHost: 1 });
userSchema.index({ isSuperhost: 1 });

module.exports = mongoose.model('User', userSchema);
