import 'package:flutter/material.dart';

/// Static catalog of known amenities — id -> icon + display label.
///
/// This is the single source of truth for "what amenities can exist" in
/// the app. It's intentionally code-side, not database-seeded: it's
/// reference data (~dozens to ~100 fixed options), not per-listing data.
///
/// Grow this list as you design the hosting flow's "select amenities" UI.
/// Each listing will store a List<String> of ids selected from here
/// (plus possibly free-text custom entries later — see AmenitiesSection
/// below for how unknown ids/strings are handled gracefully).
class AmenityCatalog {
  static const List<AmenityDef> all = [
    AmenityDef(
      id: 'wifi',
      label: 'Fiber WiFi',
      icon: Icons.wifi,
      description: 'High-speed fiber internet available throughout the property.',
    ),
    AmenityDef(
      id: 'sea_view',
      label: 'Sea View Terrace',
      icon: Icons.deck_outlined,
      description: 'A private terrace with an open view over the sea.',
    ),
    AmenityDef(
      id: 'air_conditioning',
      label: 'Air conditioning',
      icon: Icons.ac_unit,
      description: 'Climate control available in the main living spaces.',
    ),
    AmenityDef(
      id: 'breakfast',
      label: 'Breakfast incl.',
      icon: Icons.free_breakfast_outlined,
      description: 'A breakfast is included with your stay.',
    ),
    AmenityDef(
      id: 'security',
      label: 'Security system',
      icon: Icons.shield_outlined,
      description: 'The property is monitored by a security system.',
    ),
    AmenityDef(
      id: 'kitchen',
      label: 'Full kitchen',
      icon: Icons.kitchen_outlined,
      description: 'A fully equipped kitchen you can use during your stay.',
    ),
    AmenityDef(
      id: 'parking',
      label: 'Parking',
      icon: Icons.local_parking_outlined,
      description: 'On-site parking is available for guests.',
    ),
    AmenityDef(
      id: 'washer',
      label: 'Washer',
      icon: Icons.local_laundry_service_outlined,
      description: 'A washing machine is available for guest use.',
    ),
    AmenityDef(
      id: 'coffee',
      label: 'Espresso machine',
      icon: Icons.coffee_outlined,
      description: 'An espresso machine is available in the kitchen.',
    ),
    AmenityDef(
      id: 'terrace',
      label: 'Terrace / Rooftop',
      icon: Icons.roofing_outlined,
      description: 'Outdoor terrace or rooftop space for guests to enjoy.',
    ),
    AmenityDef(
      id: 'courtyard',
      label: 'Courtyard',
      icon: Icons.yard_outlined,
      description: 'A shared or private courtyard on the property.',
    ),
    AmenityDef(
      id: 'guided_tours',
      label: 'Guided tours',
      icon: Icons.explore_outlined,
      description: 'Guided tours of the local area can be arranged with your host.',
    ),
    AmenityDef(
      id: 'traditional_dinner',
      label: 'Traditional dinner incl.',
      icon: Icons.restaurant_outlined,
      description: 'A traditional home-cooked dinner is included with your stay.',
    ),
    AmenityDef(
      id: 'campfire',
      label: 'Campfire',
      icon: Icons.local_fire_department_outlined,
      description: 'Evenings by an open campfire on the property.',
    ),
    AmenityDef(
      id: 'star_gazing',
      label: 'Star gazing',
      icon: Icons.nights_stay_outlined,
      description: 'Clear night skies make this a great spot for star gazing.',
    ),
    // TODO: keep extending toward the full ~100-option list.
  ];

  /// Looks up a catalog entry by id (preferred, once the hosting flow
  /// saves ids) or by fuzzily matching the raw label text. Matching is
  /// normalized (lowercase, punctuation/spacing stripped) and allows
  /// partial containment in either direction, so API label text that's
  /// slightly reworded from the catalog — e.g. "Traditional dinner
  /// included" vs. the catalog's "Traditional dinner incl." — still
  /// resolves to the right icon instead of falling back to the generic
  /// checkmark.
  static AmenityDef? find(String value) {
    for (final def in all) {
      if (def.id == value) return def;
    }
    final normalizedValue = _normalize(value);
    if (normalizedValue.isEmpty) return null;

    for (final def in all) {
      final normalizedLabel = _normalize(def.label);
      if (normalizedLabel == normalizedValue ||
          normalizedLabel.contains(normalizedValue) ||
          normalizedValue.contains(normalizedLabel)) {
        return def;
      }
    }
    return null;
  }

  static String _normalize(String s) =>
      s.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '');
}

class AmenityDef {
  final String id;
  final String label;
  final IconData icon;
  final String description;
  const AmenityDef({
    required this.id,
    required this.label,
    required this.icon,
    this.description = '',
  });
}

/// "What this place offers" section — a 2-column grid of amenity icons +
/// labels (first 6 shown), with a "Show all N amenities" button.
///
/// [amenities] currently comes straight from the API as raw label strings
/// (e.g. listing.amenities in ListingDetailModel). Each value is matched
/// against AmenityCatalog for its icon; anything not found (a legacy
/// string, a future custom host-entered amenity, etc.) still renders
/// fine with a generic checkmark icon and its own text as the label.
///
/// The full-list sheet triggered by [onShowAllTap] isn't built yet — this
/// only renders the preview grid and exposes the tap callback.
class AmenitiesSection extends StatelessWidget {
  final List<String> amenities;
  final VoidCallback? onShowAllTap;

  const AmenitiesSection({
    super.key,
    required this.amenities,
    this.onShowAllTap,
  });

  @override
  Widget build(BuildContext context) {
    final preview = amenities.take(6).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'What this place offers',
          style: TextStyle(
            color: Color(0xFF2A1B12),
            fontSize: 24,
            fontFamily: 'CormorantGaramond',
            fontWeight: FontWeight.w700,
            height: 1.0,
          ),
        ),
        const SizedBox(height: 6),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: preview.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 4.2,
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
          ),
          itemBuilder: (context, index) {
            final raw = preview[index];
            final def = AmenityCatalog.find(raw);
            final icon = def?.icon ?? Icons.check_circle_outline;
            final label = def?.label ?? raw;

            return Row(
              children: [
                Icon(icon, size: 20, color: const Color(0xFF2A1B12)),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    label,
                    style: const TextStyle(
                      color: Color(0xFF2A1B12),
                      fontSize: 14,
                      fontFamily: 'HenkenGrotesk',
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            );
          },
        ),
        if (amenities.isNotEmpty) ...[
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: onShowAllTap,
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Color(0xFF2A1B12)),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              child: Text(
                'Show all ${amenities.length} amenities',
                style: const TextStyle(
                  color: Color(0xFF2A1B12),
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'HenkenGrotesk',
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }
}