import 'package:flutter/material.dart';
import '../../models/amenity_model.dart'; // adjust path to match your project structure

/// Full "Amenities" page — replaces the old popup sheet. Groups the
/// listing's amenities by category with a header per section, and each
/// item shows its icon, name, and host-written description.
///
/// The footer highlight card reuses the listing's own cover photo and a
/// short blurb (no separate backend field for it) — static per-listing
/// content, not something the host writes separately.
class AmenitiesPage extends StatelessWidget {
  final String listingTitle;
  final List<AmenityModel> amenities;
  final String? footerPhotoUrl;
  final String footerBlurb;

  const AmenitiesPage({
    super.key,
    required this.listingTitle,
    required this.amenities,
    this.footerPhotoUrl,
    this.footerBlurb = '',
  });

  Map<String, List<AmenityModel>> _groupByCategory() {
    final grouped = <String, List<AmenityModel>>{};
    for (final amenity in amenities) {
      grouped.putIfAbsent(amenity.category, () => []).add(amenity);
    }
    return grouped;
  }

  @override
  Widget build(BuildContext context) {
    final grouped = _groupByCategory();
    final categories = grouped.keys.toList();

    return Scaffold(
      backgroundColor: const Color(0xFFFBF3E7),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFBF3E7),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF2A1B12)),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Amenities - $listingTitle',
          style: const TextStyle(
            color: Color(0xFF2A1B12),
            fontSize: 18,
            fontWeight: FontWeight.w600,
            fontFamily: 'HenkenGrotesk',
          ),
        ),
        centerTitle: true,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(20),
        itemCount: categories.length + 1, // +1 for the footer card
        itemBuilder: (context, index) {
          if (index == categories.length) {
            return Padding(
              padding: const EdgeInsets.only(top: 12),
              child: _FooterCard(photoUrl: footerPhotoUrl, blurb: footerBlurb),
            );
          }

          final category = categories[index];
          final items = grouped[category]!;

          return Padding(
            padding: const EdgeInsets.only(bottom: 28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  category,
                  style: const TextStyle(
                    color: Color(0xFF2A1B12),
                    fontSize: 24,
                    fontFamily: 'CormorantGaramond',
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                const Divider(height: 1, color: Color(0xFFE7DCCB)),
                const SizedBox(height: 16),
                ...items.map((amenity) => Padding(
                      padding: const EdgeInsets.only(bottom: 18),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(amenity.icon, size: 22, color: const Color(0xFF006972)),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  amenity.name,
                                  style: const TextStyle(
                                    color: Color(0xFF2A1B12),
                                    fontSize: 17,
                                    fontWeight: FontWeight.w700,
                                    fontFamily: 'HenkenGrotesk',
                                  ),
                                ),
                                if (amenity.description.isNotEmpty) ...[
                                  const SizedBox(height: 2),
                                  Text(
                                    amenity.description,
                                    style: const TextStyle(
                                      color: Color(0xFF8A7B6E),
                                      fontSize: 15,
                                      fontFamily: 'HenkenGrotesk',
                                      height: 1.4,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ],
                      ),
                    )),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _FooterCard extends StatelessWidget {
  final String? photoUrl;
  final String blurb;

  const _FooterCard({required this.photoUrl, required this.blurb});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: Container(
        color: Colors.white,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (photoUrl != null)
              AspectRatio(
                aspectRatio: 1.8,
                child: Image.network(
                  photoUrl!,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) =>
                      Container(color: const Color(0xFFE7DCCB)),
                ),
              ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Authentic Hospitality',
                    style: TextStyle(
                      color: Color(0xFF2A1B12),
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      fontFamily: 'HenkenGrotesk',
                    ),
                  ),
                  if (blurb.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Text(
                      blurb,
                      style: const TextStyle(
                        color: Color(0xFF8A7B6E),
                        fontSize: 15,
                        fontFamily: 'HenkenGrotesk',
                        height: 1.4,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}