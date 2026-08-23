import 'package:flutter/material.dart';

/// A single amenity on a listing — either picked from the predefined
/// AmenityCatalog (catalogKey set) or added by the host as a one-off
/// custom amenity (catalogKey null, isCustom true).
class AmenityModel {
  final String? catalogKey;
  final String name;
  final String category;
  final String iconName;
  final String description;
  final bool isCustom;

  AmenityModel({
    required this.catalogKey,
    required this.name,
    required this.category,
    required this.iconName,
    required this.description,
    required this.isCustom,
  });

  factory AmenityModel.fromJson(Map<String, dynamic> json) {
    return AmenityModel(
      catalogKey: json['catalogKey'] as String?,
      name: json['name'] as String? ?? '',
      category: json['category'] as String? ?? 'Other',
      iconName: json['iconName'] as String? ?? '',
      description: json['description'] as String? ?? '',
      isCustom: json['isCustom'] as bool? ?? false,
    );
  }

  IconData get icon => iconFor(iconName);

  /// Maps the backend's iconName string (see AmenityCatalog.js /
  /// seedAmenityCatalog.js) to an actual Flutter icon. Only well-established
  /// Material icons are used here to avoid SDK-version compile issues —
  /// a few newer/uncertain names are mapped to a safe close equivalent.
  static IconData iconFor(String iconName) {
    switch (iconName) {
      // Scenic views
      case 'waves': return Icons.waves;
      case 'location_city': return Icons.location_city;
      case 'landscape': return Icons.landscape;
      case 'grass': return Icons.grass;
      case 'yard': return Icons.yard;
      case 'terrain': return Icons.terrain;
      case 'pool': return Icons.pool;
      case 'wb_twilight': return Icons.wb_twilight;
      case 'deck': return Icons.deck;

      // Bedroom and laundry
      case 'checkroom': return Icons.checkroom;
      case 'bed': return Icons.bed;
      case 'iron': return Icons.iron;
      case 'local_laundry_service': return Icons.local_laundry_service;
      case 'dry_cleaning': return Icons.dry_cleaning;
      case 'curtains': return Icons.curtains;
      case 'dry': return Icons.dry_cleaning;

      // Bathroom
      case 'water_drop': return Icons.water_drop;
      case 'air': return Icons.air;
      case 'soap': return Icons.soap;
      case 'bathtub': return Icons.bathtub;
      case 'shower': return Icons.shower;
      case 'wc': return Icons.wc;

      // Internet and office
      case 'wifi': return Icons.wifi;
      case 'work': return Icons.work_outline;
      case 'settings_ethernet': return Icons.settings_ethernet;
      case 'print': return Icons.print;
      case 'chair': return Icons.chair_alt;

      // Entertainment
      case 'tv': return Icons.tv;
      case 'settings_input_antenna': return Icons.settings_input_antenna;
      case 'live_tv': return Icons.live_tv;
      case 'menu_book': return Icons.menu_book;
      case 'casino': return Icons.casino;
      case 'speaker': return Icons.speaker;
      case 'sports_esports': return Icons.sports_esports;
      case 'album': return Icons.album;

      // Kitchen and dining
      case 'kitchen': return Icons.kitchen;
      case 'microwave': return Icons.microwave;
      case 'local_fire_department': return Icons.local_fire_department;
      case 'countertops': return Icons.countertops;
      case 'wash': return Icons.wash;
      case 'coffee_maker': return Icons.coffee_maker;
      case 'coffee': return Icons.coffee;
      case 'table_restaurant': return Icons.table_restaurant;
      case 'ramen_dining': return Icons.ramen_dining;
      case 'free_breakfast': return Icons.free_breakfast;
      case 'outdoor_grill': return Icons.outdoor_grill;
      case 'wine_bar': return Icons.wine_bar;
      case 'bakery_dining': return Icons.bakery_dining;

      // Heating and cooling
      case 'ac_unit': return Icons.ac_unit;
      case 'thermostat': return Icons.thermostat;
      case 'mode_fan_off': return Icons.air;
      case 'fireplace': return Icons.fireplace;
      case 'device_thermostat': return Icons.device_thermostat;

      // Home safety
      case 'shield': return Icons.shield_outlined;
      case 'detector_smoke': return Icons.warning_amber_rounded;
      case 'co2': return Icons.cloud_outlined;
      case 'medical_services': return Icons.medical_services_outlined;
      case 'fire_extinguisher': return Icons.local_fire_department_outlined;
      case 'lock': return Icons.lock_outline;
      case 'fence': return Icons.fence;
      case 'light': return Icons.lightbulb_outline;

      // Outdoor
      case 'weekend': return Icons.weekend;
      case 'beach_access': return Icons.beach_access;
      case 'roofing': return Icons.roofing;

      // Parking and facilities
      case 'local_parking': return Icons.local_parking;
      case 'elevator': return Icons.elevator;
      case 'luggage': return Icons.luggage;
      case 'key': return Icons.vpn_key_outlined;
      case 'pin': return Icons.pin_outlined;
      case 'fitness_center': return Icons.fitness_center;
      case 'ev_station': return Icons.ev_station;

      // Accessibility
      case 'accessible': return Icons.accessible;
      case 'accessible_forward': return Icons.accessible_forward;
      case 'stairs': return Icons.stairs;

      // Other
      case 'pets': return Icons.pets;
      case 'smoking_rooms': return Icons.smoking_rooms;
      case 'calendar_month': return Icons.calendar_month;
      case 'waving_hand': return Icons.waving_hand;
      case 'cleaning_services': return Icons.cleaning_services;

      default:
        return Icons.check_circle_outline;
    }
  }
}