import 'package:flutter/material.dart';
import '../../services/host_service.dart'; // adjust path to match your project structure
import '../../models/host_dashboard_model.dart';
import '../../models/host_listing_summary_model.dart';
import '../widgets/host_stats_grid.dart';
import 'all_listings_page.dart'; // adjust path if you placed this elsewhere
import '../widgets/host_listing_row.dart';
import 'create_listing_intro_page.dart'; // adjust path if you placed this elsewhere
import 'manage_listing_page.dart'; // adjust path if you placed this elsewhere
import '../../models/booking_model.dart';
import '../../bookings/booking_ui.dart';
import '../../bookings/booking_details_page.dart';
import '../../bookings/bookings_list_page.dart';

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

  /// Pushes Manage Listing and refreshes the whole dashboard (stats +
  /// listing rows) if anything might have changed there — pause,
  /// delete, or a save from Edit Listing Details.
  Future<void> _openManageListing(HostListingSummaryModel listing) async {
    final changed = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => ManageListingPage(
          authToken: widget.authToken,
          listingId: listing.id,
        ),
      ),
    );
    if (changed == true) _fetchAll();
  }

  /// Pushes "View all" and refreshes the dashboard on return too — even
  /// though AllListingsPage refreshes its own internal list after an
  /// edit, this dashboard's stats grid and row list are separate state
  /// and won't otherwise know anything changed.
  Future<void> _openAllListings() async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => AllListingsPage(
          listings: _listings,
          authToken: widget.authToken,
        ),
      ),
    );
    _fetchAll();
  }

  Future<void> _openBooking(BookingModel booking) async {
    final changed = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (_) => BookingDetailsPage(bookingId: booking.id)),
    );
    if (changed == true) _fetchAll();
  }

  Future<void> _openReservations({int tab = 0}) async {
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => BookingsListPage.reservations(initialTab: tab)),
    );
    _fetchAll(); // stats and sections may have changed
  }

  Widget _sectionHeader(String title, {int? count, String? action, VoidCallback? onAction}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Text(title, style: const TextStyle(color: _dark, fontSize: 20, fontFamily: 'CormorantGaramond', fontWeight: FontWeight.w600)),
          if (count != null && count > 0) ...[
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(color: BookingUi.gold, borderRadius: BorderRadius.circular(12)),
              child: Text('$count', style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w800)),
            ),
          ],
          const Spacer(),
          if (action != null)
            TextButton(
              onPressed: onAction,
              child: Text(action, style: const TextStyle(color: _teal, fontWeight: FontWeight.w600)),
            ),
        ],
      ),
    );
  }

  Widget _emptyNote(String text) => Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
        child: Text(text, style: const TextStyle(color: Color(0xFF8A7B6E), fontSize: 13)),
      );

  /// Booking requests · Upcoming stays · History — the host's booking home.
  List<Widget> _bookingSections(HostDashboardModel dashboard) {
    return [
      // Requests waiting for an answer
      _sectionHeader(
        'Booking requests',
        count: dashboard.pendingRequestCount,
        action: dashboard.pendingRequestCount > dashboard.requests.length ? 'See all' : null,
        onAction: () => _openReservations(tab: 0),
      ),
      if (dashboard.requests.isEmpty)
        _emptyNote('No requests waiting. When a guest asks to book, you\'ll accept or decline it here.')
      else
        ...dashboard.requests.map((b) => BookingCard(booking: b, onTap: () => _openBooking(b))),
      const SizedBox(height: 14),

      // Next confirmed stays
      _sectionHeader('Upcoming stays', action: 'See all', onAction: () => _openReservations(tab: 1)),
      if (dashboard.upcoming.isEmpty)
        _emptyNote('No upcoming stays yet.')
      else
        ...dashboard.upcoming.map((b) => BookingCard(booking: b, onTap: () => _openBooking(b))),
      const SizedBox(height: 14),

      // Recent history
      _sectionHeader('Booking history', action: 'See all', onAction: () => _openReservations(tab: 2)),
      if (dashboard.history.isEmpty)
        _emptyNote('Completed and cancelled bookings will appear here.')
      else
        ...dashboard.history.map((b) => BookingCard(booking: b, onTap: () => _openBooking(b))),
      const SizedBox(height: 8),
      Align(
        alignment: Alignment.center,
        child: OutlinedButton.icon(
          onPressed: () => _openReservations(),
          icon: const Icon(Icons.event_note_outlined, size: 18, color: _teal),
          label: const Text('All reservations', style: TextStyle(color: _teal, fontWeight: FontWeight.w700)),
          style: OutlinedButton.styleFrom(
            side: const BorderSide(color: _teal),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          ),
        ),
      ),
      const SizedBox(height: 24),
    ];
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
              const SizedBox(height: 24),

              ..._bookingSections(dashboard),

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
                    onPressed: _openAllListings,
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
                      onTap: () => _openManageListing(listing),
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
              shadowColor: Colors.black.withValues(alpha: 0.3),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
          ),
        ),
      ],
    );
  }
}