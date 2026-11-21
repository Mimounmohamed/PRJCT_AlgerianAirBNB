import 'package:flutter/material.dart';
import '../../../authentication-front/widgets/app_bar.dart'; // adjust path to match your project structure
import '../widgets/create_listing_pattern_background.dart'; // adjust path if you placed this elsewhere
// TODO: adjust this import to match your actual Listing Detail page's
// path/constructor — "Preview my listing" pushes to it below.
import '../explore_page/listing_detail_page.dart';

/// Shown after Publish, for both outcomes:
///  - [isLive] true  → Auto-publish was on: the listing skipped the
///    AKRILI team's review and is already in search results.
///  - [isLive] false → it went to 'pending_review' and an admin has to
///    approve it before it goes live.
/// Also tells the host how guest bookings will work ([instantBook]).
class CreateListingConfirmationPage extends StatelessWidget {
  final String listingId;
  final String title;
  final String? city;
  final String? wilaya;
  final String? coverPhotoUrl;
  final bool isLive;
  final bool instantBook;

  const CreateListingConfirmationPage({
    super.key,
    required this.listingId,
    required this.title,
    this.city,
    this.wilaya,
    this.coverPhotoUrl,
    this.isLive = false,
    this.instantBook = false,
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

  Widget _settingRow({required IconData icon, required String title, required String body}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: const BoxDecoration(color: _tealTint, shape: BoxShape.circle),
            child: Icon(icon, size: 18, color: _teal),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(color: _dark, fontSize: 14, fontWeight: FontWeight.w700)),
                const SizedBox(height: 3),
                Text(body, style: const TextStyle(color: _muted, fontSize: 12, height: 1.35)),
              ],
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
                  child: Icon(isLive ? Icons.celebration_outlined : Icons.check, color: _teal, size: 36),
                ),
                const SizedBox(height: 20),
                Text(
                  isLive ? 'Your listing is live!' : 'Your listing is in review',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
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
                    children: isLive
                        ? [
                            TextSpan(text: "'$title'", style: const TextStyle(fontWeight: FontWeight.w700, color: _dark)),
                            const TextSpan(text: ' is published and guests can already find it in search.'),
                          ]
                        : [
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
                              child: Text(
                                isLive ? 'STATUS: LIVE' : 'STATUS: IN REVIEW',
                                style: const TextStyle(color: _teal, fontSize: 10, fontWeight: FontWeight.w700, letterSpacing: 0.3),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),

                // ── How publishing / bookings work for this listing ──
                _settingRow(
                  icon: Icons.publish_outlined,
                  title: isLive ? 'Auto-publish is on' : 'Auto-publish is off',
                  body: isLive
                      ? 'Your listing skipped the AKRILI review. If you pause and resume it later, it goes straight back live.'
                      : 'The AKRILI team reviews your listing before it goes live, and again whenever you resume it after a pause.',
                ),
                const SizedBox(height: 10),
                _settingRow(
                  icon: Icons.flash_on_outlined,
                  title: instantBook ? 'Instant Book is on' : 'Instant Book is off',
                  body: instantBook
                      ? 'Guests can book right away — their bookings are confirmed automatically.'
                      : 'Guests send a request, and you accept or decline each booking.',
                ),
                const Padding(
                  padding: EdgeInsets.only(top: 6, left: 2),
                  child: Text(
                    'You can change both anytime in Manage Listing → Listing settings → Booking preferences.',
                    style: TextStyle(color: _muted, fontSize: 11, height: 1.35),
                  ),
                ),
                const SizedBox(height: 28),

                // ── Next steps ─────────────────────────────
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'NEXT STEPS',
                    style: TextStyle(color: _muted, fontSize: 15, fontWeight: FontWeight.w700, letterSpacing: 0.6),
                  ),
                ),
                const SizedBox(height: 14),
                if (isLive) ...[
                  _stepRow(context, number: 1, text: 'Open your calendar and block any dates you\'re not available.'),
                  _stepRow(context, number: 2, text: 'Keep an eye on messages and booking requests.'),
                  _stepRow(context, number: 3, text: 'Start welcoming guests and sharing your space.'),
                ] else ...[
                  _stepRow(context, number: 1, text: 'We verify your property details and identity.'),
                  _stepRow(context, number: 2, text: 'Your listing goes live on the AKRILI marketplace.'),
                  _stepRow(context, number: 3, text: 'Start welcoming guests and sharing your space.'),
                ],
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