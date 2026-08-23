import 'package:flutter/material.dart';
import '../../models/amenity_model.dart'; // adjust path to match your project structure

/// "What this place offers" section — a 2-column grid preview (first 6
/// amenities), with a "Show all N amenities" button that navigates to the
/// full Amenities page.
class AmenitiesSection extends StatelessWidget {
  final List<AmenityModel> amenities;
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
            fontSize: 18,
            fontFamily: 'CormorantGaramond',
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: preview.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 4.2,
            mainAxisSpacing: 12,
          ),
          itemBuilder: (context, index) {
            final amenity = preview[index];
            return Row(
              children: [
                Icon(amenity.icon, size: 20, color: const Color(0xFF2A1B12)),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    amenity.name,
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
        if (amenities.length > preview.length) ...[
          const SizedBox(height: 16),
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