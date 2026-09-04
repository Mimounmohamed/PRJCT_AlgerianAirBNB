import 'package:flutter/material.dart';
import '../../services/host_service.dart'; // adjust path to match your project structure
import '../../models/host_dashboard_model.dart';
import '../../models/host_listing_summary_model.dart';
import '../widgets/host_stats_grid.dart';
import 'all_listings_page.dart'; // adjust path if you placed this elsewhere
import '../widgets/host_listing_row.dart';
import 'create_listing_intro_page.dart'; // adjust path if you placed this elsewhere
import 'manage_listing_page.dart'; // adjust path if you placed this elsewhere

/// Real Host dashboard — shown once the user is confirmed to be a host.
/// Fetches GET /api/host/dashboard (stats) and GET /api/host/listings
/// (the listing rows) in parallel.
class HostDashboardPage extends StatefulWidget {
  final String authToken;
  final String hostFirstName; // for "Marhaban, <name>"

  const HostDashboardPage({
    super.key,
    required this.authToken,
    required this.hostFirstName,
  });

  @override
  State<HostDashboardPage> createState() => _HostDashboardPageState();
}

class _HostDashboardPageState extends State<HostDashboardPage> {
  HostDashboardModel? _dashboard;
  List<HostListingSummaryModel> _listings = [];
  bool _isLoading = true;
  String? _error;

  static const Color _teal = Color(0xFF006972);
  static const Color _dark = Color(0xFF2A1B12);

  @override
  void initState() {
    super.initState();
    _fetchAll();
  }

  Future<void> _fetchAll() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final results = await Future.wait([
        HostService.fetchDashboard(authToken: widget.authToken),
        HostService.fetchHostListings(authToken: widget.authToken),
      ]);
      if (!mounted) return;
      setState(() {
        _dashboard = results[0] as HostDashboardModel?;
        _listings = results[1] as List<HostListingSummaryModel>;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator(color: _teal));
    }

    if (_error != null || _dashboard == null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text("Couldn't load your dashboard.", style: TextStyle(color: _dark, fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              Text(_error ?? '', textAlign: TextAlign.center, style: const TextStyle(color: Color(0xFF8A7B6E), fontSize: 12)),
              const SizedBox(height: 16),
              TextButton(onPressed: _fetchAll, child: const Text('Retry', style: TextStyle(color: _teal))),
            ],
          ),
        ),
      );
    }

    final dashboard = _dashboard!;

    return Stack(
      children: [
        RefreshIndicator(
          onRefresh: _fetchAll,
          color: _teal,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 96),
            children: [
              const Text(
                'HOST DASHBOARD',
                style: TextStyle(color: Color(0xFF8A7B6E), fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 1.2),
          ),
          const SizedBox(height: 4),
          Text(
            'Marhaban, ${widget.hostFirstName}',
            style: const TextStyle(color: _dark, fontSize: 26, fontFamily: 'CormorantGaramond', fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 20),

          HostStatsGrid(
            formattedEarnings: dashboard.formattedEarnings,
            activeListings: dashboard.activeListings,
            avgRating: dashboard.avgRating,
            formattedViews: dashboard.formattedViews,
          ),
          const SizedBox(height: 20),

          // ── Get verified banner ───────────────────────────────────────
          // TODO: wire to a real verification submission flow
          // (POST /api/host/verify needs documentType + documentImageUrl,
          // meaning a document picker + upload UI that doesn't exist yet).
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF00363B), Color(0xFF12A0AA)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Get verified to benefit from\nexclusive features',
                  style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600, height: 1.3),
                ),
                const SizedBox(height: 28),
                OutlinedButton(
                  onPressed: () {
                    // TODO: push real verification flow
                  },
                  style: OutlinedButton.styleFrom(
                    backgroundColor: Colors.white,
                    side: BorderSide.none,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  ),
                  child: const Text(
                    'START VERIFICATION',
                    style: TextStyle(color: _teal, fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 0.5),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // ── Your listings ──────────────────────────────────────────────
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Your listings',
                style: TextStyle(color: _dark, fontSize: 20, fontFamily: 'CormorantGaramond', fontWeight: FontWeight.w600),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => AllListingsPage(
                      listings: _listings,
                      authToken: widget.authToken,
                    ),
                  ),
                ),
                child: const Text('View all', style: TextStyle(color: _teal, fontWeight: FontWeight.w600)),
              ),
            ],
          ),
          const SizedBox(height: 12),

          if (_listings.isEmpty)
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
              child: const Text(
                "You haven't listed a place yet.",
                style: TextStyle(color: Color(0xFF8A7B6E)),
              ),
            )
          else
            ..._listings.map((listing) => HostListingRow(
                  listing: listing,
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => ManageListingPage(
                        authToken: widget.authToken,
                        listingId: listing.id,
                      ),
                    ),
                  ),
                )),
            ],
          ),
        ),
        // ── Floating "List a new place" button ──────────────────────────
        // Right-corner floating pill, sized down, with generous bottom
        // clearance so it never touches the nav bar's center button.
        Positioned(
          right: 20,
          bottom: 44,
          child: ElevatedButton.icon(
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const CreateListingIntroPage()),
            ),
            icon: const Icon(Icons.add, color: Colors.white, size: 16),
            label: const Text(
              'LIST A NEW PLACE',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 12),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: _teal,
              elevation: 6,
              shadowColor: Colors.black.withOpacity(0.3),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
          ),
        ),
      ],
    );
  }
}