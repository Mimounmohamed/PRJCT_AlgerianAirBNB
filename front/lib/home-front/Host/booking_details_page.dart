import 'package:flutter/material.dart';
import '../../authentication-front/widgets/app_bar.dart'; // adjust path to match your project structure
import '../../services/host_service.dart';
import '../../services/availability_service.dart';

/// "Booking Details" — opened from Manage Calendar when the host taps a
/// night taken by a guest booking. Loads the booking that covers that
/// night (GET /api/host/listings/:id/bookings/on/:date) and shows the
/// guest, stay dates, status and price breakdown.
class BookingDetailsPage extends StatefulWidget {
  final String authToken;
  final String listingId;
  final DateTime date;

  const BookingDetailsPage({
    super.key,
    required this.authToken,
    required this.listingId,
    required this.date,
  });

  @override
  State<BookingDetailsPage> createState() => _BookingDetailsPageState();
}

class _BookingDetailsPageState extends State<BookingDetailsPage> {
  static const Color _cream = Color(0xFFFBF3E7);
  static const Color _dark = Color(0xFF2A1B12);
  static const Color _teal = Color(0xFF006972);
  static const Color _muted = Color(0xFF8A7B6E);
  static const Color _border = Color(0xFFE7DCCB);
  static const Color _gold = Color(0xFFB8860B);

  static const List<String> _months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
  ];
  static const List<String> _weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

  late Future<Map<String, dynamic>?> _future;

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() {
    _future = HostService.fetchBookingOnDate(
      authToken: widget.authToken,
      listingId: widget.listingId,
      date: AvailabilityService.dayString(widget.date),
    );
  }

  // Booking dates are stored as UTC days — show that calendar day.
  String _formatDate(String? iso) {
    if (iso == null) return '—';
    final d = DateTime.tryParse(iso)?.toUtc();
    if (d == null) return '—';
    return '${_weekdays[d.weekday - 1]}, ${_months[d.month - 1]} ${d.day}, ${d.year}';
  }

  String _formatMoney(num? amount, String currency) {
    if (amount == null) return '—';
    final digits = amount.round().toString();
    final grouped = digits.replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (_) => ' ');
    return '$grouped $currency';
  }

  ({String label, Color color}) _statusStyle(String? status) {
    switch (status) {
      case 'confirmed':
        return (label: 'Confirmed', color: _teal);
      case 'pending':
        return (label: 'Waiting for your approval', color: _gold);
      default:
        return (label: status ?? 'Unknown', color: _muted);
    }
  }

  Widget _card({required Widget child}) => Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        margin: const EdgeInsets.only(bottom: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: _border),
        ),
        child: child,
      );

  Widget _row(String label, String value, {bool bold = false}) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: TextStyle(color: bold ? _dark : _muted, fontSize: 13, fontWeight: bold ? FontWeight.w700 : FontWeight.w400)),
            Text(value, style: TextStyle(color: _dark, fontSize: 13, fontWeight: bold ? FontWeight.w800 : FontWeight.w600)),
          ],
        ),
      );

  Widget _message({required IconData icon, required String title, required String body, bool retry = false}) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: const BoxDecoration(color: _border, shape: BoxShape.circle),
              child: Icon(icon, color: _muted, size: 30),
            ),
            const SizedBox(height: 16),
            Text(title, style: const TextStyle(color: _dark, fontSize: 18, fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            Text(body, textAlign: TextAlign.center, style: const TextStyle(color: _muted, fontSize: 13, height: 1.4)),
            if (retry) ...[
              const SizedBox(height: 12),
              TextButton(
                onPressed: () => setState(_load),
                child: const Text('Retry', style: TextStyle(color: _teal, fontWeight: FontWeight.w700)),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _details(Map<String, dynamic> booking) {
    final guest = booking['guestId'] is Map ? Map<String, dynamic>.from(booking['guestId'] as Map) : <String, dynamic>{};
    final guestName = guest['fullName'] as String? ?? 'Guest';
    final guestPhoto = guest['profilePhoto'] as String?;
    final pricing = booking['pricing'] is Map ? Map<String, dynamic>.from(booking['pricing'] as Map) : <String, dynamic>{};
    final currency = pricing['currency'] as String? ?? 'DZD';
    final nights = (booking['nights'] as num?)?.toInt() ?? 0;
    final guests = (booking['guestsCount'] as num?)?.toInt() ?? 1;
    final status = _statusStyle(booking['status'] as String?);
    final total = pricing['totalDZD'] as num?;
    final serviceFee = pricing['serviceFee'] as num?;
    final touristTax = pricing['touristTax'] as num?;
    final subtotal = pricing['subtotal'] as num?;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Booking Details',
            style: TextStyle(color: _dark, fontSize: 26, fontFamily: 'CormorantGaramond', fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 16),

          // ── Guest ───────────────────────────────
          _card(
            child: Row(
              children: [
                CircleAvatar(
                  radius: 26,
                  backgroundColor: _border,
                  backgroundImage: guestPhoto != null && guestPhoto.isNotEmpty ? NetworkImage(guestPhoto) : null,
                  child: guestPhoto == null || guestPhoto.isEmpty ? const Icon(Icons.person, color: _muted) : null,
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(guestName, style: const TextStyle(color: _dark, fontSize: 16, fontWeight: FontWeight.w700)),
                      const SizedBox(height: 2),
                      Text('$guests ${guests == 1 ? 'guest' : 'guests'}', style: const TextStyle(color: _muted, fontSize: 12)),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: status.color.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(status.label, style: TextStyle(color: status.color, fontSize: 11, fontWeight: FontWeight.w700)),
                ),
              ],
            ),
          ),

          // ── Stay ────────────────────────────────
          _card(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Stay', style: TextStyle(color: _dark, fontSize: 15, fontWeight: FontWeight.w700)),
                const SizedBox(height: 8),
                _row('Check-in', _formatDate(booking['checkIn'] as String?)),
                _row('Check-out', _formatDate(booking['checkOut'] as String?)),
                _row('Length', '$nights ${nights == 1 ? 'night' : 'nights'}'),
                if (booking['cancellationPolicy'] != null) _row('Cancellation policy', booking['cancellationPolicy'].toString()),
              ],
            ),
          ),

          // ── Price ───────────────────────────────
          _card(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Price', style: TextStyle(color: _dark, fontSize: 15, fontWeight: FontWeight.w700)),
                const SizedBox(height: 8),
                _row(
                  '${_formatMoney(pricing['nightlyRate'] as num?, currency)} × $nights ${nights == 1 ? 'night' : 'nights'}',
                  _formatMoney(subtotal, currency),
                ),
                _row('Service fee', _formatMoney(serviceFee, currency)),
                _row('Tourist tax', _formatMoney(touristTax, currency)),
                const Divider(color: _border, height: 18),
                _row('Guest pays', _formatMoney(total, currency), bold: true),
              ],
            ),
          ),

          if (booking['status'] == 'pending')
            const Text(
              'This booking request is waiting for your approval. Turn on Instant Book in Listing settings → '
              'Booking preferences to have future bookings confirmed automatically.',
              style: TextStyle(color: _muted, fontSize: 11, height: 1.35),
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
          child: AkriliAppBar(title: 'AKRILI', onBack: () => Navigator.of(context).maybePop()),
        ),
      ),
      body: FutureBuilder<Map<String, dynamic>?>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: _teal));
          }
          if (snapshot.hasError) {
            return _message(
              icon: Icons.error_outline,
              title: "Couldn't load this booking",
              body: snapshot.error.toString().replaceFirst('Exception: ', ''),
              retry: true,
            );
          }
          final booking = snapshot.data;
          if (booking == null) {
            return _message(
              icon: Icons.event_busy_outlined,
              title: 'No booking on this date',
              body: 'The booking may have been cancelled. Go back and refresh the calendar.',
            );
          }
          return _details(booking);
        },
      ),
    );
  }
}
