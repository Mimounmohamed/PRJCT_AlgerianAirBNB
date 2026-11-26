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

/// A Discover shortcut that covers several property types, so the row
/// under the search bar fits the screen (4 groups + All) while every type
/// a host can create still belongs to one.
class StayGroup {
  final String label;
  final IconData icon;
  final Set<String> types;
  const StayGroup(this.label, this.icon, this.types);
}

const List<StayGroup> kStayGroups = [
  StayGroup('Apartments', Icons.apartment_outlined, {'Apartment', 'Duplex'}),
  StayGroup('Houses', Icons.house_outlined, {'House', 'Villa'}),
  StayGroup('Hotels', Icons.hotel_outlined, {'Hotel', 'Touristic Complex'}),
  StayGroup('Cabins', Icons.cabin_outlined, {'Beach Cabin', 'Desert Cabin'}),
];

/// The group whose types are exactly [types], if any.
StayGroup? stayGroupFor(Set<String> types) {
  for (final g in kStayGroups) {
    if (g.types.length == types.length && g.types.containsAll(types)) return g;
  }
  return null;
}

PropertyType? propertyTypeByLabel(String label) {
  for (final t in kPropertyTypes) {
    if (t.label == label) return t;
  }
  return null;
}
