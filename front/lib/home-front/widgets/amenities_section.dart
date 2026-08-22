import 'package:flutter/material.dart';

/// "What this place offers" section — a 2-column grid of amenity icons +
/// labels (first 6 shown), with a "Show all N amenities" button.
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

  static IconData _iconFor(String amenity) {
    final lower = amenity.toLowerCase();
    if (lower.contains('wifi')) return Icons.wifi;
    if (lower.contains('sea view')) return Icons.deck_outlined;
    if (lower.contains('air condition')) return Icons.ac_unit;
    if (lower.contains('breakfast')) return Icons.free_breakfast_outlined;
    if (lower.contains('security')) return Icons.shield_outlined;
    if (lower.contains('kitchen')) return Icons.kitchen_outlined;
    if (lower.contains('parking')) return Icons.local_parking_outlined;
    if (lower.contains('washer')) return Icons.local_laundry_service_outlined;
    if (lower.contains('espresso') || lower.contains('coffee')) return Icons.coffee_outlined;
    if (lower.contains('terrace') || lower.contains('rooftop')) return Icons.roofing_outlined;
    if (lower.contains('courtyard')) return Icons.yard_outlined;
    return Icons.check_circle_outline;
  }

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
                Icon(_iconFor(amenity), size: 20, color: const Color(0xFF2A1B12)),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    amenity,
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