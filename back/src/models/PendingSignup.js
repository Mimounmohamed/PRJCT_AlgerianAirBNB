const mongoose = require('mongoose');

const pendingSignupSchema = new mongoose.Schema(
  {
    fullName: { type: String, required: true, trim: true },
    email:    { type: String, required: true, lowercase: true, trim: true },
    phone: {
      countryCode: { type: String, default: '+213' },
      number:      { type: String, trim: true },
    },
    passwordHash: { type: String, required: true, select: false }, // plain password stored temporarily, hashed only at final User creation
    profilePhoto: { type: String, default: null },

    gender:      { type: String, enum: ['Male', 'Female', 'Other'] },
    birthday:    { type: Date },
    wilaya:      { type: String },
    baladiya:    { type: String },
    fullAddress: { type: String },

    createdAt: { type: Date, default: Date.now },
  }
);

pendingSignupSchema.index({ createdAt: 1 }, { expireAfterSeconds: 60 * 60 * 24 });
pendingSignupSchema.index({ email: 1 });

module.exports = mongoose.model('PendingSignup', pendingSignupSchema);