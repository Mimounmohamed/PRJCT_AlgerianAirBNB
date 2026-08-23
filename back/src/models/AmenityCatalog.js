const mongoose = require('mongoose');

// Fixed category list — used for both the catalog and for custom amenities
// a host adds manually (they pick from this same set).
const AMENITY_CATEGORIES = [
  'Scenic views',
  'Bedroom and laundry',
  'Bathroom',
  'Internet and office',
  'Entertainment',
  'Kitchen and dining',
  'Heating and cooling',
  'Home safety',
  'Outdoor',
  'Parking and facilities',
  'Accessibility',
  'Other',
];

const amenityCatalogSchema = new mongoose.Schema(
  {
    key: { type: String, required: true, unique: true, trim: true }, // slug, e.g. 'sea_view'
    name: { type: String, required: true, trim: true }, // 'Sea view'
    category: { type: String, required: true, enum: AMENITY_CATEGORIES },
    // Maps to a Flutter IconData via a lookup table on the client —
    // see lib/models/amenity_model.dart's iconFor().
    iconName: { type: String, required: true },
  },
  { timestamps: true }
);

amenityCatalogSchema.index({ category: 1 });

module.exports = mongoose.model('AmenityCatalog', amenityCatalogSchema);
module.exports.AMENITY_CATEGORIES = AMENITY_CATEGORIES;