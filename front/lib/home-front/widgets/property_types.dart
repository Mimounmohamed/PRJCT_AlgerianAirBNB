import 'package:flutter/material.dart';

/// One kind of stay a host can list — the exact `propertyType` values the
/// backend accepts (back/src/models/Listing.js enum). Used by the Discover
/// shortcuts, the Filters page and the search screen's "Popular stay
/// types", so a guest can find every type a host can create.
class PropertyType {
  final String label;
  final IconData icon;
  final String blurb;
  const PropertyType(this.label, this.icon, this.blurb);
}

const List<PropertyType> kPropertyTypes = [
  PropertyType('Apartment', Icons.apartment, 'City stays close to everything'),
  PropertyType('House', Icons.house, 'A whole home for family and friends'),
  PropertyType('Villa', Icons.villa, 'Space, privacy and often a pool'),
  PropertyType('Duplex', Icons.other_houses, 'Two floors of room to spread out'),
  PropertyType('Hotel', Icons.hotel, 'Rooms with hotel service'),
  PropertyType('Touristic Complex', Icons.holiday_village, 'Resorts with shared facilities'),
  PropertyType('Beach Cabin', Icons.beach_access, 'Steps from the Mediterranean'),
  PropertyType('Desert Cabin', Icons.terrain, 'Saharan nights under the stars'),
];

PropertyType? propertyTypeByLabel(String label) {
  for (final t in kPropertyTypes) {
    if (t.label == label) return t;
  }
  return null;
}
