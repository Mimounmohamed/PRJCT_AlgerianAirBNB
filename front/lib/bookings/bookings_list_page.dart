import 'package:flutter/material.dart';
import '../authentication-front/widgets/app_bar.dart';
import '../models/booking_model.dart';
import '../services/booking_service.dart';
import '../services/user_session.dart';
import 'booking_details_page.dart';
import 'booking_ui.dart';

/// Tabbed list of bookings, in two flavours:
///  - [BookingsListPage.trips]        → the guest's "My trips"
///  - [BookingsListPage.reservations] → the host's "Reservations"
///
/// Tabs: Requests · Upcoming · Past · Cancelled (each one server-side
/// filtered). Tapping a booking opens Booking details; anything changed
/// there refreshes the list.
class BookingsListPage extends StatefulWidget {
  final bool isHost;
  final int initialTab;

  const BookingsListPage.trips({super.key, this.initialTab = 1}) : isHost = false;
  const BookingsListPage.reservations({super.key, this.initialTab = 0}) : isHost = true;

  @override
  State<BookingsListPage> createState() => _BookingsListPageState();
}

class _BookingsListPageState extends State<BookingsListPage> with SingleTickerProviderStateMixin {
  static const List<String> _groups = ['requests', 'upcoming', 'past', 'cancelled'];

  late final TabController _tabs = TabController(length: _groups.length, vsync: this, initialIndex: widget.initialTab);
  final Map<String, Future<List<BookingModel>>> _futures = {};
  bool _changed = false;

  String get _token => UserSession.instance.token ?? '';

  @override
  void initState() {
    super.initState();
    for (final group in _groups) {
      _futures[group] = _fetch(group);
    }
  }

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  Future<List<BookingModel>> _fetch(String group) => widget.isHost
      ? BookingService.hostReservations(token: _token, group: group)
      : BookingService.myTrips(token: _token, group: group);

  void _refreshAll() => setState(() {
        for (final group in _groups) {
          _futures[group] = _fetch(group);
        }
      });

  Future<void> _open(BookingModel booking) async {
    final changed = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (_) => BookingDetailsPage(bookingId: booking.id)),
    );
    if (changed == true) {
      _changed = true;
      _refreshAll();
    }
  }

  String _tabLabel(String group) {
    switch (group) {
      case 'requests':
        return 'Requests';
      case 'upcoming':
        return 'Upcoming';
      case 'past':
        return 'Past';
      default:
        return 'Cancelled';
    }
  }

  ({IconData icon, String title, String body}) _empty(String group) {
    switch (group) {
      case 'requests':
        return widget.isHost
            ? (icon: Icons.inbox_outlined, title: 'No requests waiting', body: 'When a guest asks to book one of your places, it shows up here for you to accept or decline.')
            : (icon: Icons.send_outlined, title: 'No requests waiting', body: 'Requests you send to hosts wait here until they answer.');
      case 'upcoming':
        return widget.isHost
            ? (icon: Icons.event_available_outlined, title: 'No upcoming stays', body: 'Confirmed bookings appear here.')
            : (icon: Icons.luggage_outlined, title: 'No upcoming trips', body: 'Find a place on Explore and book your next stay.');
      case 'past':
        return (icon: Icons.history, title: 'Nothing here yet', body: 'Completed stays appear here.');
      default:
        return (icon: Icons.event_busy_outlined, title: 'Nothing cancelled', body: 'Cancelled, declined and expired bookings appear here.');
    }
  }

  Widget _tab(String group) {
    return FutureBuilder<List<BookingModel>>(
      future: _futures[group],
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(color: BookingUi.teal));
        }
        if (snapshot.hasError) {
          return BookingListMessage(
            icon: Icons.error_outline,
            title: "Couldn't load bookings",
            body: '${snapshot.error}',
            onRetry: () => setState(() => _futures[group] = _fetch(group)),
          );
        }
        final bookings = snapshot.data ?? [];
        if (bookings.isEmpty) {
          final e = _empty(group);
          return RefreshIndicator(
            color: BookingUi.teal,
            onRefresh: () async => _refreshAll(),
            child: ListView(children: [SizedBox(height: 380, child: BookingListMessage(icon: e.icon, title: e.title, body: e.body))]),
          );
        }
        return RefreshIndicator(
          color: BookingUi.teal,
          onRefresh: () async {
            setState(() => _futures[group] = _fetch(group));
            await _futures[group];
          },
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
            children: [for (final b in bookings) BookingCard(booking: b, onTap: () => _open(b))],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) Navigator.of(context).pop(_changed);
      },
      child: Scaffold(
        backgroundColor: BookingUi.cream,
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(kToolbarHeight),
          child: Container(
            color: BookingUi.cream,
            child: AkriliAppBar(title: 'AKRILI', onBack: () => Navigator.of(context).maybePop()),
          ),
        ),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 4),
              child: Text(
                widget.isHost ? 'Reservations' : 'My trips',
                style: const TextStyle(color: BookingUi.dark, fontSize: 28, fontFamily: 'CormorantGaramond', fontWeight: FontWeight.w600),
              ),
            ),
            TabBar(
              controller: _tabs,
              isScrollable: true,
              tabAlignment: TabAlignment.start,
              labelColor: BookingUi.teal,
              unselectedLabelColor: BookingUi.muted,
              indicatorColor: BookingUi.teal,
              dividerColor: BookingUi.border,
              labelStyle: const TextStyle(fontWeight: FontWeight.w700),
              tabs: [for (final g in _groups) Tab(text: _tabLabel(g))],
            ),
            Expanded(
              child: TabBarView(controller: _tabs, children: [for (final g in _groups) _tab(g)]),
            ),
          ],
        ),
      ),
    );
  }
}
