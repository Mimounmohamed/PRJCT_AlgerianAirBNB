const mongoose = require('mongoose');

// ── Auto-generate case number: INC-YYYY-NNNNN ──────────────
async function generateCaseNumber() {
  const year = new Date().getFullYear();
  const count = await mongoose.model('Incident').countDocuments();
  const seq = String(count + 1).padStart(5, '0');
  return `INC-${year}-${seq}`;
}

const incidentSchema = new mongoose.Schema(
  {
    // ── Reporter ────────────────────────────────────────────
    userId: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'User',
      required: true,
    },

    // ── Incident Details ────────────────────────────────────
    type: {
      type: String,
      enum: ['safety', 'property_damage', 'host_issue', 'guest_issue', 'other'],
      default: 'safety',
    },
    description: {
      type: String,
      required: true,
      trim: true,
    },

    // ── Attachments (Cloudinary URLs) ───────────────────────
    photoUrls: {
      type: [String],
      default: [],
    },
    messageScreenshots: {
      type: [String],
      default: [],
    },

    // ── Case Tracking ───────────────────────────────────────
    caseNumber: {
      type: String,
      unique: true,
    },
    status: {
      type: String,
      enum: ['pending', 'under_review', 'resolved', 'closed'],
      default: 'pending',
    },

    // ── Admin Notes (internal) ──────────────────────────────
    adminNotes: {
      type: String,
      default: '',
    },
    resolvedAt: {
      type: Date,
      default: null,
    },
  },
  {
    timestamps: true, // createdAt + updatedAt auto-managed
  }
);

// ── Auto-assign caseNumber before saving ────────────────────
incidentSchema.pre('save', async function (next) {
  if (!this.caseNumber) {
    this.caseNumber = await generateCaseNumber();
  }
  next();
});

module.exports = mongoose.model('Incident', incidentSchema);
