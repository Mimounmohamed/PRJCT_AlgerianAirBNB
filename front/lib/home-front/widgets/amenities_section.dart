import 'package:flutter/material.dart';
import '../../models/amenity_model.dart'; // adjust path to match your project structure

/// "What this place offers" section — a 2-column preview (first 6
/// amenities) built from manual rows (not GridView) so spacing is exact
/// and predictable, with a "Show all N amenities" button below that
/// always navigates to the full Amenities page.
class AmenitiesSection extends StatelessWidget {
  final List<AmenityModel> amenities;
  final VoidCallback? onShowAllTap;

  const AmenitiesSection({
    super.key,
    required this.amenities,
    this.onShowAllTap,
  });

  Widget _amenityItem(AmenityModel amenity) {
    return Row(
      children: [
        Icon(amenity.icon, size: 26, color: const Color(0xFF2A1B12)),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            amenity.name,
            style: const TextStyle(
              color: Color(0xFF2A1B12),
              fontSize: 16,
              fontFamily: 'HenkenGrotesk',
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final preview = amenities.take(6).toList();

    // Build pairs of two for a manual 2-column layout — full control over
    // spacing, no GridView aspect-ratio guessing.
    final rows = <Widget>[];
    for (int i = 0; i < preview.length; i += 2) {
      final left = preview[i];
      final right = i + 1 < preview.length ? preview[i + 1] : null;

      rows.add(
        Padding(
          padding: EdgeInsets.only(top: i == 0 ? 0 : 14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: _amenityItem(left)),
              const SizedBox(width: 12),
              Expanded(child: right != null ? _amenityItem(right) : const SizedBox()),
            ],
          ),
        ),
      );
    }

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
          ),
        ),
        const SizedBox(height: 18),
        ...rows,
        const SizedBox(height: 18),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            onPressed: onShowAllTap,
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: Color(0xFF2A1B12)),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: Text(
              'Show all ${amenities.length} amenities',
              style: const TextStyle(
                color: Color(0xFF2A1B12),
                fontSize: 16,
                fontWeight: FontWeight.w600,
                fontFamily: 'HenkenGrotesk',
              ),
            ),
          ),
        ),
      ],
    );
  }
}