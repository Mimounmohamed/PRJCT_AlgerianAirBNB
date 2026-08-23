const express = require('express');
const router = express.Router();
const AmenityCatalog = require('../models/AmenityCatalog');

// GET /api/amenities-catalog — full predefined amenity list, used by the
// host "select amenities" checklist. Grouped by category for convenience.
router.get('/', async (req, res) => {
  try {
    const items = await AmenityCatalog.find({}).sort({ category: 1, name: 1 });

    const grouped = {};
    for (const item of items) {
      if (!grouped[item.category]) grouped[item.category] = [];
      grouped[item.category].push({
        key: item.key,
        name: item.name,
        iconName: item.iconName,
      });
    }

    res.json({ categories: grouped });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

module.exports = router;