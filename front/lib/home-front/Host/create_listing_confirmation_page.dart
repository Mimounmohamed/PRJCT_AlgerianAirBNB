import 'package:flutter/material.dart';
import '../../../authentication-front/widgets/app_bar.dart'; // adjust path to match your project structure
import '../widgets/create_listing_pattern_background.dart'; // adjust path if you placed this elsewhere
// TODO: adjust this import to match your actual Listing Detail page's
// path/constructor — "Preview my listing" pushes to it below.
import '../explore_page/listing_detail_page.dart';

/// Shown after Publish for listings that are NOT instant-book — i.e.
/// ones that go into 'pending_review' and need admin approval before
/// they go live. Instant-book listings skip this page entirely and go
/// straight back to the Host dashboard (see create_listing_review_page's
/// _publish()).
class CreateListingConfirmationPage extends StatelessWidget {
  final String listingId;
  final String title;
  final String? city;
  final String? wilaya;
  final String? coverPhotoUrl;

  const CreateListingConfirmationPage({
    super.key,
    required this.listingId,
    required this.title,
    this.city,
    this.wilaya,
    this.coverPhotoUrl,
  });

  static const Color _dark = Color(0xFF2A1B12);
  static const Color _teal = Color(0xFF006972);
  static const Color _tealTint = Color(0xFFE3F0F1);
  static const Color _muted = Color(0xFF8A7B6E);
  static const Color _border = Color(0xFFE7DCCB);
  static const Color _cream = Color(0xFFFBF3E7);

  String get _locationLabel {
    if (city != null && wilaya != null) return '$city, $wilaya';
    return city ?? wilaya ?? '';
  }

  Widget _stepRow(BuildContext context, {required int number, required String text}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 42,
            height: 42,
            alignment: Alignment.center,
            decoration: const BoxDecoration(color: _tealTint, shape: BoxShape.circle),
            child: Text(
              '$number',
              style: const TextStyle(color: _teal, fontSize: 20, fontWeight: FontWeight.w700),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                text,
                style: const TextStyle(color: _dark, fontSize: 18, height: 1.4),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _cream,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: Container(
          decoration: BoxDecoration(
            color: _cream,
            boxShadow: [
              BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 8, offset: const Offset(0, 2)),
            ],
          ),
          child: const AkriliAppBar(title: 'AKRILI'),
        ),
      ),
      body: CreateListingPatternBackground(
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  width: 80,
                  height: 80,
                  alignment: Alignment.center,
                  decoration: const BoxDecoration(color: _tealTint, shape: BoxShape.circle),
                  child: const Icon(Icons.check, color: _teal, size: 36),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Your listing is in review',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: _dark,
                    fontSize: 24,
                    fontFamily: 'CormorantGaramond',
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                Text.rich(
                  TextSpan(
                    style: const TextStyle(color: _muted, fontSize: 14, height: 1.5),
                    children: [
                      const TextSpan(text: "We're reviewing "),
                      TextSpan(text: "'$title'", style: const TextStyle(fontWeight: FontWeight.w700, color: _dark)),
                      const TextSpan(text: ". You'll hear from us within 24 hours."),
                    ],
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),

                // ── Listing summary card ──────────────────
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: _border),
                  ),
                  child: Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: SizedBox(
                          width: 56,
                          height: 56,
                          child: coverPhotoUrl != null
                              ? Image.network(
                                  coverPhotoUrl!,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => Container(color: _border),
                                )
                              : Container(
                                  color: _border,
                                  child: const Icon(Icons.home_outlined, color: _muted),
                                ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              title,
                              style: const TextStyle(color: _dark, fontSize: 15, fontWeight: FontWeight.w700),
                            ),
                            if (_locationLabel.isNotEmpty) ...[
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  const Icon(Icons.location_on_outlined, size: 13, color: _muted),
                                  const SizedBox(width: 3),
                                  Expanded(
                                    child: Text(
                                      _locationLabel,
                                      style: const TextStyle(color: _muted, fontSize: 12),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: _tealTint,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: const Text(
                                'STATUS: IN REVIEW',
                                style: TextStyle(color: _teal, fontSize: 10, fontWeight: FontWeight.w700, letterSpacing: 0.3),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 28),

                // ── Next steps ─────────────────────────────
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'NEXT STEPS',
                    style: TextStyle(color: _muted, fontSize: 15, fontWeight: FontWeight.w700, letterSpacing: 0.6),
                  ),
                ),
                const SizedBox(height: 14),
                _stepRow(context, number: 1, text: 'We verify your property details and identity.'),
                _stepRow(context, number: 2, text: 'Your listing goes live on the AKRILI marketplace.'),
                _stepRow(context, number: 3, text: 'Start welcoming guests and sharing your space.'),
                const SizedBox(height: 24),

                // ── Actions ─────────────────────────────────
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.of(context).popUntil((route) => route.isFirst),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _teal,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text(
                      'Go to Host Dashboard',
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 19),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => ListingDetailPage(listingId: listingId),
                      ),
                    );
                  },
                  child: const Text(
                    'Preview my listing',
                    style: TextStyle(
                      color: _dark,
                      fontWeight: FontWeight.w700,
                      fontSize: 18,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}