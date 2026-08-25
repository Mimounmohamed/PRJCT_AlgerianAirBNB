import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../models/listing_detail_model.dart'; // adjust path to match your project structure

/// Bottom sheet shown when tapping the share button on Listing Detail.
///
/// "Copy link" is real — it copies a placeholder listing URL to the
/// clipboard (swap in a real web/deep-link scheme once one exists).
/// WhatsApp / Messenger / Instagram / Email / More / "Share directly with
/// contacts" are all static for now — wiring them up needs a share/deep-link
/// package (e.g. share_plus) which isn't in the project yet.
void showShareSheet(BuildContext context, ListingDetailModel listing) {
  final locationLabel = listing.neighborhood != null && listing.neighborhood!.isNotEmpty
      ? '${listing.neighborhood}, ${listing.city}'
      : listing.city;

  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (sheetContext) {
      return _ShareSheetContent(
        listingId: listing.id,
        title: listing.title,
        locationLabel: locationLabel,
        coverPhotoUrl: listing.photoUrls.isNotEmpty ? listing.photoUrls.first : null,
        ratingOverall: listing.ratingOverall,
        reviewCount: listing.reviewCount,
      );
    },
  );
}

class _ShareSheetContent extends StatelessWidget {
  final String listingId;
  final String title;
  final String locationLabel;
  final String? coverPhotoUrl;
  final double ratingOverall;
  final int reviewCount;

  const _ShareSheetContent({
    required this.listingId,
    required this.title,
    required this.locationLabel,
    required this.coverPhotoUrl,
    required this.ratingOverall,
    required this.reviewCount,
  });

  static const Color _dark = Color(0xFF2A1B12);

  void _copyLink(BuildContext context) {
    // TODO: replace with a real web/deep-link URL once one exists.
    final placeholderLink = 'https://akrili.app/listing/$listingId';
    Clipboard.setData(ClipboardData(text: placeholderLink));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Link copied')),
    );
  }

  Widget _shareOption({
    required BuildContext context,
    required IconData icon,
    required String label,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap ?? () {
        // TODO: wire real share action
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: const Color(0xFFF3EBDE),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 22, color: _dark),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: const TextStyle(color: _dark, fontSize: 12, fontFamily: 'HenkenGrotesk'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
        decoration: const BoxDecoration(
          color: Color(0xFFFBF3E7),
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Share this place',
                  style: TextStyle(
                    color: _dark,
                    fontSize: 22,
                    fontFamily: 'CormorantGaramond',
                    fontWeight: FontWeight.w600,
                  ),
                ),
                GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: const BoxDecoration(
                      color: Color(0xFFF3EBDE),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.close, size: 18, color: _dark),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // ── Listing mini card ──────────────────────────────────────
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: SizedBox(
                      width: 52,
                      height: 52,
                      child: coverPhotoUrl != null
                          ? Image.network(coverPhotoUrl!, fit: BoxFit.cover)
                          : Container(color: const Color(0xFFE7DCCB)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: const TextStyle(color: _dark, fontSize: 15, fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            const Icon(Icons.location_on_outlined, size: 12, color: Color(0xFF8A7B6E)),
                            const SizedBox(width: 2),
                            Text(
                              locationLabel,
                              style: const TextStyle(color: Color(0xFF8A7B6E), fontSize: 12),
                            ),
                          ],
                        ),
                        if (ratingOverall > 0) ...[
                          const SizedBox(height: 2),
                          Row(
                            children: [
                              const Icon(Icons.star, size: 12, color: Color(0xFFB8860B)),
                              const SizedBox(width: 2),
                              Text(
                                ratingOverall.toStringAsFixed(2),
                                style: const TextStyle(color: _dark, fontSize: 12, fontWeight: FontWeight.w700),
                              ),
                              Text(
                                ' ($reviewCount)',
                                style: const TextStyle(color: Color(0xFF8A7B6E), fontSize: 12),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // ── Share options grid ─────────────────────────────────────
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _shareOption(context: context, icon: Icons.link, label: 'Copy link', onTap: () => _copyLink(context)),
                _shareOption(context: context, icon: Icons.chat_bubble_outline, label: 'WhatsApp'),
                _shareOption(context: context, icon: Icons.forum_outlined, label: 'Messenger'),
                _shareOption(context: context, icon: Icons.camera_alt_outlined, label: 'Instagram'),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                _shareOption(context: context, icon: Icons.email_outlined, label: 'Email'),
                const SizedBox(width: 40),
                _shareOption(context: context, icon: Icons.more_horiz, label: 'More'),
              ],
            ),
            const SizedBox(height: 20),
            const Divider(height: 1, color: Color(0xFFE7DCCB)),
            const SizedBox(height: 16),

            // ── Share with contacts ─────────────────────────────────────
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  // TODO: wire real contact-share action (needs a share package)
                },
                icon: const Icon(Icons.ios_share, color: Colors.white, size: 18),
                label: const Text(
                  'Share directly with contacts',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _dark,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}