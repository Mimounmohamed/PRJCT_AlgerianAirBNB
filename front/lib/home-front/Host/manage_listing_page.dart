import 'package:flutter/material.dart';
import '../../authentication-front/widgets/app_bar.dart'; // adjust path to match your project structure
import '../../services/host_service.dart'; // adjust path to match your project structure
import '../../models/host_listing_detail_model.dart';
import '../explore_page/listing_detail_page.dart'; // adjust path if you placed this elsewhere
import '../explore_page/reviews_page.dart'; // adjust path if you placed this elsewhere
import 'edit_listing_details_page.dart';

/// "Manage Listing" — shown when a host taps MANAGE on one of their own
/// listings (from the Host dashboard or All Listings page). Shows real
/// performance data pulled straight from the listing document, quick
/// actions, and pause/delete controls.
///
/// NOTE: the "98% recommended" figure next to the rating is a STATIC
/// placeholder — no guest-recommendation-percentage tracking exists in
/// the schema yet. Replace with a real field once that's built
/// server-side; until then this is intentionally fake and should not be
/// trusted as real data (see the inline comment where it's rendered).
class ManageListingPage extends StatefulWidget {
  final String authToken;
  final String listingId;

  const ManageListingPage({
    super.key,
    required this.authToken,
    required this.listingId,
  });

  @override
  State<ManageListingPage> createState() => _ManageListingPageState();
}

class _ManageListingPageState extends State<ManageListingPage> {
  static const Color _cream = Color(0xFFFBF3E7);
  static const Color _dark = Color(0xFF2A1B12);
  static const Color _teal = Color(0xFF006972);
  static const Color _muted = Color(0xFF8A7B6E);
  static const Color _border = Color(0xFFE7DCCB);
  static const Color _gold = Color(0xFFB8860B);
  static const Color _danger = Color(0xFFB3261E);

  Future<HostListingDetailModel>? _future;
  bool _isBusy = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() {
    _future = HostService.fetchListingDetail(
      authToken: widget.authToken,
      listingId: widget.listingId,
    );
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'active': return _teal;
      case 'pending_review': return _gold;
      case 'inactive': return _muted;
      case 'rejected': return _danger;
      default: return _muted;
    }
  }

  Future<void> _confirmAndRun({
    required String title,
    required String message,
    required String confirmLabel,
    required Color confirmColor,
    required Future<void> Function() action,
  }) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: _cream,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(title, style: const TextStyle(color: _dark, fontWeight: FontWeight.w700)),
        content: Text(message, style: const TextStyle(color: _muted)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancel', style: TextStyle(color: _muted, fontWeight: FontWeight.w600)),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(confirmLabel, style: TextStyle(color: confirmColor, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() => _isBusy = true);
    try {
      await action();
      if (!mounted) return;
      setState(() {
        _load();
        _isBusy = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _isBusy = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('$e')),
      );
    }
  }

  Future<void> _pauseListing() => _confirmAndRun(
        title: 'Pause this listing?',
        message: "It'll be hidden from search results, but you can bring it back anytime from here.",
        confirmLabel: 'Pause',
        confirmColor: _danger,
        action: () => HostService.pauseListing(authToken: widget.authToken, listingId: widget.listingId),
      );

  Future<void> _deleteListing() => _confirmAndRun(
        title: 'Delete this listing?',
        message: 'This permanently removes it from AKRILI. This cannot be undone from the app.',
        confirmLabel: 'Delete',
        confirmColor: _danger,
        action: () async {
          await HostService.deleteListing(authToken: widget.authToken, listingId: widget.listingId);
          if (mounted) Navigator.of(context).pop(); // nothing left to manage — back out
        },
      );

  Widget _statBox({required String label, required Widget value}) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: _border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(color: _muted, fontSize: 11, fontWeight: FontWeight.w600, letterSpacing: 0.4)),
            const SizedBox(height: 6),
            value,
          ],
        ),
      ),
    );
  }

  Widget _quickAction({required IconData icon, required String label, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: _border),
        ),
        child: Row(
          children: [
            Icon(icon, size: 20, color: _dark),
            const SizedBox(width: 14),
            Expanded(child: Text(label, style: const TextStyle(color: _dark, fontSize: 14, fontWeight: FontWeight.w600))),
            const Icon(Icons.chevron_right, size: 18, color: _muted),
          ],
        ),
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
          child: AkriliAppBar(title: 'AKRILI', onBack: () => Navigator.of(context).maybePop()),
        ),
      ),
      body: FutureBuilder<HostListingDetailModel>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: _teal));
          }
          if (snapshot.hasError || !snapshot.hasData) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text("Couldn't load this listing.", style: TextStyle(color: _dark, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 8),
                    Text('${snapshot.error}', textAlign: TextAlign.center, style: const TextStyle(color: _muted, fontSize: 12)),
                    const SizedBox(height: 16),
                    TextButton(
                      onPressed: () => setState(_load),
                      child: const Text('Retry', style: TextStyle(color: _teal)),
                    ),
                  ],
                ),
              ),
            );
          }

          final listing = snapshot.data!;
          final statusColor = _statusColor(listing.status);

          return Stack(
            children: [
              SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 40),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Hero image ─────────────────────────
                    ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: Stack(
                        children: [
                          SizedBox(
                            height: 190,
                            width: double.infinity,
                            child: listing.coverPhotoUrl != null
                                ? Image.network(listing.coverPhotoUrl!, fit: BoxFit.cover)
                                : Container(color: _border),
                          ),
                          Positioned(
                            left: 12,
                            top: 12,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                              decoration: BoxDecoration(
                                color: statusColor,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                listing.statusLabel,
                                style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700),
                              ),
                            ),
                          ),
                          Positioned(
                            right: 12,
                            bottom: 12,
                            child: GestureDetector(
                              onTap: () => Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => ListingDetailPage(listingId: listing.id),
                                ),
                              ),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                                decoration: BoxDecoration(
                                  color: Colors.black.withValues(alpha: 0.55),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: const [
                                    Icon(Icons.remove_red_eye_outlined, size: 14, color: Colors.white),
                                    SizedBox(width: 5),
                                    Text('PREVIEW', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700)),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // ── Performance highlights ─────────────
                    const Text(
                      'Performance highlights',
                      style: TextStyle(color: _dark, fontSize: 20, fontFamily: 'CormorantGaramond', fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 12),

                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: _border),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('TOTAL REVENUE', style: TextStyle(color: _muted, fontSize: 11, fontWeight: FontWeight.w600, letterSpacing: 0.4)),
                              const SizedBox(height: 6),
                              Text(
                                listing.formattedEarnings,
                                style: const TextStyle(color: _teal, fontSize: 22, fontFamily: 'CormorantGaramond', fontWeight: FontWeight.w700),
                              ),
                            ],
                          ),
                          const Icon(Icons.account_balance_wallet_outlined, color: _teal),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),

                    Row(
                      children: [
                        _statBox(label: 'VIEWS', value: Text(listing.formattedViews, style: const TextStyle(color: _dark, fontSize: 18, fontWeight: FontWeight.w700))),
                        const SizedBox(width: 12),
                        _statBox(label: 'BOOKINGS', value: Text(listing.formattedBookings, style: const TextStyle(color: _dark, fontSize: 18, fontWeight: FontWeight.w700))),
                      ],
                    ),
                    const SizedBox(height: 12),

                    if (listing.reviewCount > 0)
                      GestureDetector(
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => ReviewsPage(
                              listingTitle: listing.title,
                              ratingOverall: listing.ratingOverall,
                              reviewCount: listing.reviewCount,
                            ),
                          ),
                        ),
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: _border),
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                decoration: BoxDecoration(color: _gold, borderRadius: BorderRadius.circular(20)),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(Icons.star, size: 14, color: _dark),
                                    const SizedBox(width: 4),
                                    Text(
                                      listing.ratingOverall.toStringAsFixed(2),
                                      style: const TextStyle(color: _dark, fontSize: 14, fontWeight: FontWeight.w700),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    if (listing.isGuestFavorite)
                                      const Text(
                                        'Guest Favorite',
                                        style: TextStyle(color: _dark, fontSize: 15, fontWeight: FontWeight.w700),
                                      ),
                                    Text(
                                      '${listing.reviewCount} reviews'
                                      // STATIC PLACEHOLDER — not a real tracked
                                      // stat, see class doc comment above.
                                      ' · 98% recommended',
                                      style: const TextStyle(color: _muted, fontSize: 12),
                                    ),
                                  ],
                                ),
                              ),
                              const Icon(Icons.chevron_right, size: 18, color: _muted),
                            ],
                          ),
                        ),
                      ),
                    const SizedBox(height: 28),

                    // ── Quick actions ───────────────────────
                    const Text(
                      'Quick actions',
                      style: TextStyle(color: _dark, fontSize: 20, fontFamily: 'CormorantGaramond', fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 12),
                    _quickAction(
                      icon: Icons.edit_outlined,
                      label: 'Edit listing details',
                      onTap: () async {
                        final saved = await Navigator.of(context).push<bool>(
                          MaterialPageRoute(
                            builder: (_) => EditListingDetailsPage(
                              authToken: widget.authToken,
                              listingId: widget.listingId,
                            ),
                          ),
                        );
                        if (saved == true) setState(_load); // refresh hero/stats after edit
                      },
                    ),
                    _quickAction(
                      icon: Icons.calendar_today_outlined,
                      label: 'Manage calendar',
                      onTap: () {
                        // TODO: availability management UI doesn't exist yet.
                      },
                    ),
                    _quickAction(
                      icon: Icons.rate_review_outlined,
                      label: 'Read all reviews',
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => ReviewsPage(
                            listingTitle: listing.title,
                            ratingOverall: listing.ratingOverall,
                            reviewCount: listing.reviewCount,
                          ),
                        ),
                      ),
                    ),
                    _quickAction(
                      icon: Icons.settings_outlined,
                      label: 'Listing settings',
                      onTap: () {
                        // TODO: no dedicated settings screen exists yet.
                      },
                    ),
                    const SizedBox(height: 24),

                    // ── Advanced controls ────────────────────
                    CustomPaint(
                      foregroundPainter: _DashedRectPainter(color: _danger.withValues(alpha: 0.4), radius: 16),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Advanced controls', style: TextStyle(color: _danger, fontSize: 15, fontWeight: FontWeight.w700)),
                            const SizedBox(height: 6),
                            const Text(
                              'Temporarily pause your listing to hide it from search results, or permanently delete it.',
                              style: TextStyle(color: _muted, fontSize: 12, height: 1.4),
                            ),
                            const SizedBox(height: 14),
                            Row(
                              children: [
                                Expanded(
                                  child: ElevatedButton(
                                    onPressed: _isBusy ? null : _deleteListing,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: _danger,
                                      elevation: 0,
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                                      padding: const EdgeInsets.symmetric(vertical: 12),
                                    ),
                                    child: const Text(
                                      'Delete',
                                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 13),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: OutlinedButton(
                                    onPressed: (_isBusy || listing.status == 'inactive') ? null : _pauseListing,
                                    style: OutlinedButton.styleFrom(
                                      side: const BorderSide(color: _border),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                                      padding: const EdgeInsets.symmetric(vertical: 12),
                                    ),
                                    child: Text(
                                      listing.status == 'inactive' ? 'Paused' : 'Pause Listing',
                                      style: const TextStyle(color: _dark, fontWeight: FontWeight.w700, fontSize: 13),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              if (_isBusy)
                Container(
                  color: Colors.black.withValues(alpha: 0.15),
                  child: const Center(child: CircularProgressIndicator(color: _teal)),
                ),
            ],
          );
        },
      ),
    );
  }
}

/// Draws a dashed rounded-rect border — used for the "Advanced controls"
/// box, matching the Figma reference's dashed outline. Same technique as
/// the dashed "Add photos" tile in create_listing_review_page.dart.
class _DashedRectPainter extends CustomPainter {
  final Color color;
  final double radius;
  static const double dashWidth = 5;
  static const double dashSpace = 4;
  static const double strokeWidth = 1.4;

  const _DashedRectPainter({
    required this.color,
    this.radius = 16,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    final rrect = RRect.fromRectAndRadius(
      Rect.fromLTWH(
        strokeWidth / 2,
        strokeWidth / 2,
        size.width - strokeWidth,
        size.height - strokeWidth,
      ),
      Radius.circular(radius),
    );

    final path = Path()..addRRect(rrect);
    for (final metric in path.computeMetrics()) {
      double distance = 0;
      while (distance < metric.length) {
        final next = distance + dashWidth;
        canvas.drawPath(
          metric.extractPath(distance, next.clamp(0, metric.length)),
          paint,
        );
        distance = next + dashSpace;
      }
    }
  }

  @override
  bool shouldRepaint(covariant _DashedRectPainter oldDelegate) => false;
}