const express = require('express');
const router = express.Router();
const { protect } = require('../middleware/auth.middleware');
const Incident = require('../models/Incident');

// ─────────────────────────────────────────────────────────────
// POST /api/incidents
// Submit a new incident report (logged-in users only)
// Body: { type, description, photoUrls[], messageScreenshots[] }
// ─────────────────────────────────────────────────────────────
router.post('/', protect, async (req, res) => {
  try {
    const { type, description, photoUrls, messageScreenshots } = req.body;

    if (!description || description.trim() === '') {
      return res.status(400).json({ error: 'Description is required.' });
    }

    const incident = await Incident.create({
      userId: req.user._id,
      type: type || 'safety',
      description: description.trim(),
      photoUrls: photoUrls || [],
      messageScreenshots: messageScreenshots || [],
    });

    res.status(201).json({
      message: 'Incident report submitted successfully.',
      caseNumber: incident.caseNumber,
      incidentId: incident._id,
      status: incident.status,
      createdAt: incident.createdAt,
    });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// ─────────────────────────────────────────────────────────────
// GET /api/incidents/mine
// Get all incidents submitted by the logged-in user
// ─────────────────────────────────────────────────────────────
router.get('/mine', protect, async (req, res) => {
  try {
    const incidents = await Incident.find({ userId: req.user._id })
      .select('caseNumber type status description createdAt resolvedAt')
      .sort({ createdAt: -1 });

    res.json(incidents);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// ─────────────────────────────────────────────────────────────
// GET /api/incidents/:id
// Get details of a single incident (only the owner can see it)
// ─────────────────────────────────────────────────────────────
router.get('/:id', protect, async (req, res) => {
  try {
    const incident = await Incident.findById(req.params.id);

    if (!incident) {
      return res.status(404).json({ error: 'Incident not found.' });
    }

    // Only the reporter can view their own incident
    if (incident.userId.toString() !== req.user._id.toString()) {
      return res.status(403).json({ error: 'Access denied.' });
    }

    res.json(incident);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// ─────────────────────────────────────────────────────────────
// GET /api/incidents/admin/all
// Admin: list all incidents with user info
// Requires isAdmin flag on user (or you can add requireAdmin middleware later)
// ─────────────────────────────────────────────────────────────
router.get('/admin/all', protect, async (req, res) => {
  try {
    // Basic admin guard — adjust to your admin system
    if (!req.user.isAdmin) {
      return res.status(403).json({ error: 'Admin access required.' });
    }

    const { status, page = 1, limit = 20 } = req.query;
    const filter = {};
    if (status) filter.status = status;

    const incidents = await Incident.find(filter)
      .populate('userId', 'fullName email phone profilePhoto')
      .sort({ createdAt: -1 })
      .skip((page - 1) * limit)
      .limit(Number(limit));

    const total = await Incident.countDocuments(filter);

    res.json({ total, page: Number(page), incidents });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// ─────────────────────────────────────────────────────────────
// PUT /api/incidents/:id/status
// Admin: update the status of an incident
// Body: { status, adminNotes }
// ─────────────────────────────────────────────────────────────
router.put('/:id/status', protect, async (req, res) => {
  try {
    if (!req.user.isAdmin) {
      return res.status(403).json({ error: 'Admin access required.' });
    }

    const { status, adminNotes } = req.body;
    const allowed = ['pending', 'under_review', 'resolved', 'closed'];

    if (!allowed.includes(status)) {
      return res.status(400).json({ error: `Status must be one of: ${allowed.join(', ')}` });
    }

    const updates = { status };
    if (adminNotes !== undefined) updates.adminNotes = adminNotes;
    if (status === 'resolved') updates.resolvedAt = new Date();

    const incident = await Incident.findByIdAndUpdate(req.params.id, updates, {
      new: true,
    });

    if (!incident) {
      return res.status(404).json({ error: 'Incident not found.' });
    }

    res.json({ message: 'Status updated.', incident });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

module.exports = router;
