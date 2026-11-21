import 'package:flutter/material.dart';
import '../models/booking_model.dart';
import 'booking_details_page.dart';
import 'booking_ui.dart';
import 'bookings_list_page.dart';

/// Shown right after the guest books:
///  - confirmed (Instant Book) → "You're booked!"
///  - pending                  → "Request sent", the host has 24h
class BookingResultPage extends StatelessWidget {
  final BookingModel booking;

  const BookingResultPage({super.key, required this.booking});

  @override
  Widget build(BuildContext context) {
    final b = booking;
    final confirmed = b.isConfirmed;

    return Scaffold(
      backgroundColor: BookingUi.cream,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(24, 40, 24, 24),
          children: [
            Center(
              child: Container(
                width: 84,
                height: 84,
                decoration: BoxDecoration(color: (confirmed ? BookingUi.teal : BookingUi.gold).withValues(alpha: 0.12), shape: BoxShape.circle),
                child: Icon(confirmed ? Icons.check_circle : Icons.send_rounded, color: confirmed ? BookingUi.teal : BookingUi.gold, size: 40),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              confirmed ? "You're booked!" : 'Request sent',
              textAlign: TextAlign.center,
              style: const TextStyle(color: BookingUi.dark, fontSize: 30, fontFamily: 'CormorantGaramond', fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            Text(
              confirmed
                  ? 'Your stay at ${b.listingTitle} is confirmed. ${b.hostName.split(' ').first} has been notified.'
                  : '${b.hostName.split(' ').first} has 24 hours to accept your request. We\'ll notify you as soon as they answer — nothing is charged until then.',
              textAlign: TextAlign.center,
              style: const TextStyle(color: BookingUi.muted, fontSize: 14, height: 1.5),
            ),
            const SizedBox(height: 24),
            BookingCard(
              booking: b,
              onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => BookingDetailsPage(bookingId: b.id))),
            ),
            const SizedBox(height: 8),
            if (b.freeCancellationUntil != null)
              Text(
                'Free cancellation until ${BookingUi.dateTime(b.freeCancellationUntil!)} (${b.cancellationPolicy} policy).',
                textAlign: TextAlign.center,
                style: const TextStyle(color: BookingUi.muted, fontSize: 12),
              ),
            const SizedBox(height: 28),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).popUntil((route) => route.isFirst);
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => BookingsListPage.trips(initialTab: confirmed ? 1 : 0)),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: BookingUi.teal,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text('See my trips', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 16)),
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () => BookingUi.openChat(context, b),
              child: const Text('Message the host', style: TextStyle(color: BookingUi.teal, fontWeight: FontWeight.w700)),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).popUntil((route) => route.isFirst),
              child: const Text('Back to Explore', style: TextStyle(color: BookingUi.muted, fontWeight: FontWeight.w600)),
            ),
          ],
        ),
      ),
    );
  }
}
