import 'package:flutter/material.dart';
import '../models/booking_model.dart';
import '../services/auth_service.dart';
import '../services/user_session.dart';
import '../chat/conversation.dart';

/// Shared look & helpers for every booking screen (guest trips, host
/// reservations, booking details, dashboard sections).
class BookingUi {
  static const Color cream = Color(0xFFFBF3E7);
  static const Color dark = Color(0xFF2A1B12);
  static const Color teal = Color(0xFF006972);
  static const Color tealTint = Color(0xFFE3F0F1);
  static const Color muted = Color(0xFF8A7B6E);
  static const Color border = Color(0xFFE7DCCB);
  static const Color gold = Color(0xFFB8860B);
  static const Color danger = Color(0xFFB3261E);

  static const List<String> _months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
  static const List<String> _weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

  static String shortDate(DateTime d) => '${_months[d.month - 1]} ${d.day}';
  static String longDate(DateTime d) => '${_weekdays[d.weekday - 1]}, ${_months[d.month - 1]} ${d.day}, ${d.year}';

  static String range(DateTime a, DateTime b) =>
      a.year == b.year ? '${shortDate(a)} – ${shortDate(b)}, ${b.year}' : '${shortDate(a)}, ${a.year} – ${shortDate(b)}, ${b.year}';

  static String dateTime(DateTime d) {
    final h = d.hour.toString().padLeft(2, '0');
    final m = d.minute.toString().padLeft(2, '0');
    return '${shortDate(d)}, ${d.year} at $h:$m';
  }

  static String money(num amount, [String currency = 'DZD']) {
    final digits = amount.round().toString();
    final grouped = digits.replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (_) => ' ');
    return '$grouped $currency';
  }

  /// "Expires in 5h" for a pending request.
  static String? timeLeft(DateTime? expiresAt) {
    if (expiresAt == null) return null;
    final left = expiresAt.difference(DateTime.now());
    if (left.isNegative) return 'Expired';
    if (left.inHours >= 1) return '${left.inHours}h left to answer';
    return '${left.inMinutes.clamp(1, 59)} min left to answer';
  }

  /// Status chip text + color, worded for whoever is looking.
  static ({String label, Color color}) status(BookingModel b) {
    switch (b.status) {
      case 'pending':
        return (label: b.isHostView ? 'Request — needs your answer' : 'Waiting for the host', color: gold);
      case 'confirmed':
        return b.isCurrent ? (label: 'Checked in', color: teal) : (label: 'Confirmed', color: teal);
      case 'completed':
        return (label: 'Completed', color: muted);
      case 'cancelled_by_guest':
        return (label: b.isHostView ? 'Cancelled by guest' : 'You cancelled', color: danger);
      case 'cancelled_by_host':
        return (label: b.isHostView ? 'You cancelled' : 'Cancelled by host', color: danger);
      case 'rejected':
        return (label: 'Declined', color: danger);
      case 'expired':
        return (label: 'Expired', color: muted);
      default:
        return (label: b.status, color: muted);
    }
  }

  static Widget statusChip(BookingModel b) {
    final s = status(b);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(color: s.color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(20)),
      child: Text(s.label, style: TextStyle(color: s.color, fontSize: 11, fontWeight: FontWeight.w700)),
    );
  }

  static Widget avatar(String? url, {double radius = 20}) {
    final hasPhoto = url != null && url.isNotEmpty;
    return CircleAvatar(
      radius: radius,
      backgroundColor: border,
      backgroundImage: hasPhoto ? NetworkImage(url) : null,
      child: hasPhoto ? null : Icon(Icons.person, color: muted, size: radius),
    );
  }

  static String initials(String name) {
    final parts = name.trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty).toList();
    if (parts.length >= 2) return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    return parts.isNotEmpty ? parts[0][0].toUpperCase() : '?';
  }

  /// Opens (or creates) the conversation with the other person in this
  /// booking — reuses the existing chat (POST /api/messages/start).
  static Future<void> openChat(BuildContext context, BookingModel b) async {
    final token = UserSession.instance.token;
    if (token == null || b.otherPersonId.isEmpty) return;
    try {
      final result = await AuthService.startConversation(
        token: token,
        recipientId: b.otherPersonId,
        listingId: b.listingId,
        content: b.isHostView
            ? 'Hi ${b.guestName.split(' ').first}, about your stay at "${b.listingTitle}" (${range(b.checkIn, b.checkOut)}).'
            : 'Hi, about my booking at "${b.listingTitle}" (${range(b.checkIn, b.checkOut)}).',
      );
      final conv = result['conversation'] as Map<String, dynamic>? ?? result;
      final conversationId = (conv['_id'] ?? conv['id'] ?? '').toString();
      if (!context.mounted || conversationId.isEmpty) return;
      await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => ChatScreen(
            conversationId: conversationId,
            otherUserName: b.otherPersonName,
            otherUserInitials: initials(b.otherPersonName),
            listingName: b.listingTitle,
            listingLocation: b.location.isNotEmpty ? b.location : null,
          ),
        ),
      );
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Could not open chat: $e')));
    }
  }
}

/// One booking in a list (trips, reservations, dashboard sections).
class BookingCard extends StatelessWidget {
  final BookingModel booking;
  final VoidCallback onTap;

  const BookingCard({super.key, required this.booking, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final b = booking;
    final timeLeft = b.canHostRespond ? BookingUi.timeLeft(b.expiresAt) : null;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: b.canHostRespond ? BookingUi.gold.withValues(alpha: 0.6) : BookingUi.border),
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: SizedBox(
                width: 58,
                height: 58,
                child: b.listingPhotoUrl != null
                    ? Image.network(b.listingPhotoUrl!, fit: BoxFit.cover, errorBuilder: (_, _, _) => Container(color: BookingUi.border))
                    : Container(color: BookingUi.border, child: const Icon(Icons.home_outlined, color: BookingUi.muted)),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    b.isHostView ? b.guestName : b.listingTitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: BookingUi.dark, fontSize: 15, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    b.isHostView
                        ? '${b.listingTitle} · ${b.guestsCount} guest${b.guestsCount == 1 ? '' : 's'}'
                        : (b.location.isNotEmpty ? b.location : '${b.guestsCount} guests'),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: BookingUi.muted, fontSize: 12),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${BookingUi.range(b.checkIn, b.checkOut)} · ${b.nights} night${b.nights == 1 ? '' : 's'}',
                    style: const TextStyle(color: BookingUi.dark, fontSize: 12, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      BookingUi.statusChip(b),
                      if (timeLeft != null) ...[
                        const SizedBox(width: 8),
                        Flexible(
                          child: Text(timeLeft, overflow: TextOverflow.ellipsis, style: const TextStyle(color: BookingUi.gold, fontSize: 11, fontWeight: FontWeight.w600)),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  BookingUi.money(b.isHostView ? b.hostPayout : b.total, b.currency),
                  style: const TextStyle(color: BookingUi.teal, fontSize: 13, fontWeight: FontWeight.w800),
                ),
                if (b.isHostView) const Text('you earn', style: TextStyle(color: BookingUi.muted, fontSize: 10)),
                const SizedBox(height: 18),
                const Icon(Icons.chevron_right, size: 18, color: BookingUi.muted),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Simple empty / error state for booking lists.
class BookingListMessage extends StatelessWidget {
  final IconData icon;
  final String title;
  final String body;
  final VoidCallback? onRetry;

  const BookingListMessage({super.key, required this.icon, required this.title, required this.body, this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: const BoxDecoration(color: BookingUi.border, shape: BoxShape.circle),
              child: Icon(icon, color: BookingUi.muted, size: 28),
            ),
            const SizedBox(height: 14),
            Text(title, textAlign: TextAlign.center, style: const TextStyle(color: BookingUi.dark, fontSize: 16, fontWeight: FontWeight.w700)),
            const SizedBox(height: 6),
            Text(body, textAlign: TextAlign.center, style: const TextStyle(color: BookingUi.muted, fontSize: 13, height: 1.4)),
            if (onRetry != null) ...[
              const SizedBox(height: 10),
              TextButton(onPressed: onRetry, child: const Text('Retry', style: TextStyle(color: BookingUi.teal, fontWeight: FontWeight.w700))),
            ],
          ],
        ),
      ),
    );
  }
}
