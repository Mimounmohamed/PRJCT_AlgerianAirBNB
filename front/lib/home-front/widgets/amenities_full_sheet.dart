import 'package:flutter/material.dart';
import '../../models/amenity_model.dart';

/// Opens the "What this place offers" full-list bottom sheet — every
/// amenity on the listing, each with its icon, label, and a description.
///
/// Descriptions currently come from the static [AmenityCatalog] (see
/// amenities_section.dart). Once hosts can write their own per-amenity
/// description for a listing, swap the `def?.description` lookup below
/// for whatever the host actually wrote, falling back to the catalog
/// default when a host hasn't customized it.
Future<void> showAmenitiesFullSheet(BuildContext context, List<AmenityModel> amenities) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (context) => _AmenitiesFullSheet(amenities: amenities),
  );
}

class _AmenitiesFullSheet extends StatelessWidget {
  final List<AmenityModel> amenities;

  const _AmenitiesFullSheet({required this.amenities});

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.85,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, scrollController) {
        return Column(
          children: [
            const SizedBox(height: 12),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFFE7DCCB),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 12, 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'What this place offers',
                    style: TextStyle(
                      color: Color(0xFF2A1B12),
                      fontSize: 22,
                      fontFamily: 'CormorantGaramond',
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close, color: Color(0xFF2A1B12)),
                  ),
                ],
              ),
            ),
            const Divider(height: 1, color: Color(0xFFE7DCCB)),
            Expanded(
              child: ListView.separated(
                controller: scrollController,
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
                itemCount: amenities.length,
                separatorBuilder: (_, __) => const SizedBox(height: 24),
                itemBuilder: (context, index) {
                  final amenity = amenities[index];
                  final icon = amenity.icon;
                  final label = amenity.name;
                  final description = amenity.description;

                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(icon, size: 24, color: const Color(0xFF2A1B12)),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              label,
                              style: const TextStyle(
                                color: Color(0xFF2A1B12),
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                fontFamily: 'HenkenGrotesk',
                              ),
                            ),
                            if (description.isNotEmpty) ...[
                              const SizedBox(height: 4),
                              Text(
                                description,
                                style: const TextStyle(
                                  color: Color(0xFF8A7B6E),
                                  fontSize: 13,
                                  fontFamily: 'HenkenGrotesk',
                                  height: 1.4,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
}