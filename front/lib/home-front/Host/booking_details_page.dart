import 'package:flutter/material.dart';
import '../../authentication-front/widgets/app_bar.dart'; // adjust path to match your project structure

/// "Booking Details" — placeholder for now. Reached from Manage Calendar
/// when a host taps "See booking details" on a booked date.
///
/// TODO: build out real content once there's a way to fetch the actual
/// Booking document for a given date/listing (guest info, check-in/out,
/// payout, messages link, etc.) — this page currently has nothing wired
/// to the backend, it's just the destination stub.
class BookingDetailsPage extends StatelessWidget {
  final String listingId;
  final DateTime date;

  const BookingDetailsPage({
    super.key,
    required this.listingId,
    required this.date,
  });

  static const Color _cream = Color(0xFFFBF3E7);
  static const Color _dark = Color(0xFF2A1B12);
  static const Color _muted = Color(0xFF8A7B6E);
  static const Color _border = Color(0xFFE7DCCB);

  @override
  Widget build(BuildContext context) {
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];

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
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(color: _border, shape: BoxShape.circle),
                child: const Icon(Icons.event_note_outlined, color: _muted, size: 30),
              ),
              const SizedBox(height: 20),
              const Text(
                'Booking Details',
                style: TextStyle(color: _dark, fontSize: 22, fontFamily: 'CormorantGaramond', fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 8),
              Text(
                '${months[date.month - 1]} ${date.day}, ${date.year}',
                style: const TextStyle(color: _muted, fontSize: 14, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 16),
              const Text(
                "This page isn't built yet — guest info, check-in/out times, and payout details will show up here.",
                textAlign: TextAlign.center,
                style: TextStyle(color: _muted, fontSize: 13, height: 1.4),
              ),
            ],
          ),
        ),
      ),
    );
  }
}