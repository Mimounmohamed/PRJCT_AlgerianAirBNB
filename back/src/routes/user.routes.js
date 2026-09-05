const express = require('express');
const router = express.Router();
const { protect } = require('../middleware/auth.middleware');
const User = require('../models/User');

// GET /api/users/me — Get current user profile
router.get('/me', protect, async (req, res) => {
  try {
    const user = await User.findById(req.user._id);
    res.json(user);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// PUT /api/users/me — Update profile (Step 2: personal info)
router.put('/me', protect, async (req, res) => {
  try {
    const allowed = [
      'fullName', 'gender', 'birthday', 'country', 'city',
      'wilaya', 'fullAddress', 'profilePhoto', 'phone', 'email'
    ];
    const updates = {};
    allowed.forEach((field) => {
      if (req.body[field] !== undefined) updates[field] = req.body[field];
    });

    const user = await User.findByIdAndUpdate(req.user._id, updates, { new: true });
    res.json(user);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// PUT /api/users/me/settings — Update notification/app settings
router.put('/me/settings', protect, async (req, res) => {
  try {
    const { notificationSettings, settings } = req.body;
    const updates = {};
    if (notificationSettings) updates.notificationSettings = notificationSettings;
    if (settings) updates.settings = settings;

    const user = await User.findByIdAndUpdate(req.user._id, updates, { new: true });
    res.json(user);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// DELETE /api/users/me — Deactivate account
router.delete('/me', protect, async (req, res) => {
  try {
    await User.findByIdAndUpdate(req.user._id, { accountStatus: 'deactivated' });
    res.json({ message: 'Account deactivated successfully.' });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// DELETE /api/users/me/permanent — Permanently delete account
router.delete('/me/permanent', protect, async (req, res) => {
  try {
    await User.findByIdAndDelete(req.user._id);
    res.json({ message: 'Account permanently deleted.' });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// PUT /api/users/fcm-token
router.put('/fcm-token', protect, async (req, res) => {
  try {
    const { fcmToken } = req.body;
    if (!fcmToken) return res.status(400).json({ error: 'fcmToken is required' });
    await User.findByIdAndUpdate(req.user._id, { fcmToken });
    res.json({ ok: true });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// PUT /api/users/notification-settings
router.put('/notification-settings', protect, async (req, res) => {
  try {
    const { messagesPush, remindersPush, promotionsEmail } = req.body;
    const update = {};
    if (messagesPush !== undefined) update['notificationSettings.messages'] = messagesPush;
    if (remindersPush !== undefined) update['notificationSettings.bookingUpdates'] = remindersPush;
    if (promotionsEmail !== undefined) update['notificationSettings.promotions'] = promotionsEmail;
    await User.findByIdAndUpdate(req.user._id, update);
    res.json({ ok: true });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

module.exports = router;
