import 'package:flutter/material.dart';
import '../../../authentication-front/widgets/app_bar.dart'; // adjust path to match your project structure
import 'create_listing_property_type_page.dart';
import '../widgets/create_listing_pattern_background.dart'; // adjust path if you placed this elsewhere
import '../widgets/create_listing_pattern_background.dart';

/// First screen of the Create Listing flow — marketing intro matching the
/// design (icon, heading, 3 numbered steps, showcase image, sticky CTA).
/// "Get Started" pushes into the actual wizard (property type selection).
class CreateListingIntroPage extends StatelessWidget {
  const CreateListingIntroPage({super.key});

  static const Color _dark = Color(0xFF2A1B12);
  static const Color _teal = Color(0xFF006972);
  static const Color _accent = Color(0xFFB5652B);

  Widget _stepRow(int number, String title, String description) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 28,
          height: 28,
          alignment: Alignment.center,
          decoration: const BoxDecoration(
            color: Color(0xFFF3EBDE),
            shape: BoxShape.circle,
          ),
          child: Text(
            '$number',
            style: const TextStyle(color: _dark, fontWeight: FontWeight.w700, fontSize: 13),
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(color: _dark, fontSize: 15, fontWeight: FontWeight.w700)),
              const SizedBox(height: 2),
              Text(description, style: const TextStyle(color: Color(0xFF8A7B6E), fontSize: 13, height: 1.4)),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFBF3E7),
      appBar: AkriliAppBar(
        title: 'AKRILI',
        onBack: () => Navigator.of(context).maybePop(),
      ),
      body: CreateListingPatternBackground(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF3D8C0),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.home_outlined, color: _accent, size: 22),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Share your Algerian home.',
                      style: TextStyle(
                        color: _dark,
                        fontSize: 26,
                        fontFamily: 'CormorantGaramond',
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Join a community of hosts showcasing the beauty of '
                      'Algerian hospitality. From the Casbah to the Saharan '
                      'oases, your space tells a story.',
                      style: TextStyle(color: Color(0xFF8A7B6E), fontSize: 14, height: 1.5),
                    ),
                    const SizedBox(height: 28),
                    _stepRow(1, 'Tell us about your place', 'Share basic info like location and how many guests can stay.'),
                    const SizedBox(height: 20),
                    _stepRow(2, 'Make it stand out', 'Add 5 or more photos plus a title and description of your authentic stay.'),
                    const SizedBox(height: 20),
                    _stepRow(3, 'Finish and publish', "Choose if you'd like to start with an experienced guest, then set your price."),
                    const SizedBox(height: 28),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: Stack(
                        children: [
                          AspectRatio(
                            aspectRatio: 1.4,
                            child: Image.network(
                              'https://images.unsplash.com/photo-1580746738099-9e0a4a03fd88',
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) =>
                                  Container(color: const Color(0xFFE7DCCB)),
                            ),
                          ),
                          Positioned(
                            left: 16,
                            bottom: 16,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'LOCAL INSPIRATION',
                                  style: TextStyle(color: Colors.white70, fontSize: 10, fontWeight: FontWeight.w700, letterSpacing: 1.0),
                                ),
                                const SizedBox(height: 2),
                                const Text(
                                  "Ghardaïa, M'Zab Valley",
                                  style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 20),
              decoration: const BoxDecoration(
                color: Color(0xFFFBF3E7),
                border: Border(top: BorderSide(color: Color(0xFFE7DCCB))),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('READY TO HOST?', style: TextStyle(color: Color(0xFF8A7B6E), fontSize: 10, fontWeight: FontWeight.w700, letterSpacing: 1.0)),
                        SizedBox(height: 2),
                        Text('Start your journey', style: TextStyle(color: _dark, fontSize: 15, fontWeight: FontWeight.w700)),
                      ],
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const CreateListingPropertyTypePage()),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _teal,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                    ),
                    child: const Text('Get Started', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}