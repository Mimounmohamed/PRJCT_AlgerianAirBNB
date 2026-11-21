import 'dart:async';
import 'package:flutter/material.dart';
import '../../authentication-front/widgets/app_bar.dart';
import '../../bookings/booking_details_page.dart';
import '../../services/notification_service.dart';
import '../../services/push_notification_service.dart';
import '../../services/user_session.dart';

/// The logged-in user's notifications (GET /api/notifications): booking
/// requests, confirmations, declines, cancellations, expiries, completed
/// stays…
///
/// - Unread ones have a tinted background and a dot.
/// - Tapping one marks it read and, for booking notifications, opens that
///   booking's details.
/// - "Mark all read" in the header; pull down to refresh; a push received
///   while this screen is open refreshes the list.
class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  static const Color _cream = Color(0xFFFBF3E7);
  static const Color _dark = Color(0xFF2A1B12);
  static const Color _teal = Color(0xFF006972);
  static const Color _tealTint = Color(0xFFE3F0F1);
  static const Color _muted = Color(0xFF8A7B6E);
  static const Color _border = Color(0xFFE7DCCB);
  static const Color _gold = Color(0xFFB8860B);
  static const Color _danger = Color(0xFFB3261E);

  List<AppNotification> _items = [];
  int _unread = 0;
  bool _loading = true;
  String? _error;
  StreamSubscription? _pushSub;

  String get _token => UserSession.instance.token ?? '';

  @override
  void initState() {
    super.initState();
    _load();
    _pushSub = PushNotificationService.instance.onForegroundMessage.listen((_) => _load(silent: true));
  }

  @override
  void dispose() {
    _pushSub?.cancel();
    super.dispose();
  }

  Future<void> _load({bool silent = false}) async {
    if (!silent) {
      setState(() {
        _loading = true;
        _error = null;
      });
    }
    try {
      final page = await NotificationService.fetch(token: _token, limit: 50);
      if (!mounted) return;
      setState(() {
        _items = page.notifications;
        _unread = page.unreadCount;
        _loading = false;
        _error = null;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        if (!silent) _error = e.toString().replaceFirst('Exception: ', '');
      });
    }
  }

  Future<void> _markAllRead() async {
    setState(() {
      _items = [for (final n in _items) n.read ? n : n.copyRead()];
      _unread = 0;
    });
    await NotificationService.markAllRead(token: _token);
  }

  Future<void> _open(AppNotification n) async {
    if (!n.read) {
      setState(() {
        _items = [for (final item in _items) item.id == n.id ? item.copyRead() : item];
        _unread = (_unread - 1).clamp(0, 1 << 30);
      });
      NotificationService.markRead(token: _token, id: n.id);
    }
    if (n.relatedType == 'booking' && n.relatedId != null) {
      await Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => BookingDetailsPage(bookingId: n.relatedId!)),
      );
    }
  }

  ({IconData icon, Color color}) _style(String type) {
    switch (type) {
      case 'booking_requested':
        return (icon: Icons.mark_email_unread_outlined, color: _gold);
      case 'booking_confirmed':
        return (icon: Icons.event_available_outlined, color: _teal);
      case 'booking_declined':
      case 'booking_cancelled':
        return (icon: Icons.event_busy_outlined, color: _danger);
      case 'booking_expired':
        return (icon: Icons.schedule, color: _muted);
      case 'booking_completed':
      case 'review_received':
        return (icon: Icons.star_outline_rounded, color: _gold);
      case 'new_message':
        return (icon: Icons.chat_bubble_outline, color: _teal);
      case 'listing_approved':
        return (icon: Icons.verified_outlined, color: _teal);
      case 'listing_rejected':
        return (icon: Icons.report_gmailerrorred_outlined, color: _danger);
      default:
        return (icon: Icons.notifications_none_rounded, color: _teal);
    }
  }

  String _ago(DateTime t) {
    final d = DateTime.now().difference(t);
    if (d.inMinutes < 1) return 'Just now';
    if (d.inMinutes < 60) return '${d.inMinutes} min ago';
    if (d.inHours < 24) return '${d.inHours}h ago';
    if (d.inDays < 7) return '${d.inDays}d ago';
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${months[t.month - 1]} ${t.day}';
  }

  Widget _tile(AppNotification n) {
    final s = _style(n.type);
    final tappable = n.relatedType == 'booking' && n.relatedId != null;
    return InkWell(
      onTap: () => _open(n),
      child: Container(
        padding: const EdgeInsets.fromLTRB(20, 14, 16, 14),
        decoration: BoxDecoration(
          color: n.read ? Colors.transparent : _tealTint.withValues(alpha: 0.6),
          border: const Border(bottom: BorderSide(color: _border)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(color: s.color.withValues(alpha: 0.12), shape: BoxShape.circle),
              child: Icon(s.icon, color: s.color, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          n.title,
                          style: TextStyle(color: _dark, fontSize: 14, fontWeight: n.read ? FontWeight.w600 : FontWeight.w800),
                        ),
                      ),
                      Text(_ago(n.createdAt), style: const TextStyle(color: _muted, fontSize: 11)),
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(n.body, style: const TextStyle(color: _muted, fontSize: 13, height: 1.35)),
                  if (tappable)
                    const Padding(
                      padding: EdgeInsets.only(top: 6),
                      child: Text('View booking', style: TextStyle(color: _teal, fontSize: 12, fontWeight: FontWeight.w700)),
                    ),
                ],
              ),
            ),
            if (!n.read)
              Padding(
                padding: const EdgeInsets.only(left: 8, top: 4),
                child: Container(width: 8, height: 8, decoration: const BoxDecoration(color: _teal, shape: BoxShape.circle)),
              ),
          ],
        ),
      ),
    );
  }

  Widget _message(IconData icon, String title, String body, {VoidCallback? onRetry}) {
    return ListView(
      children: [
        const SizedBox(height: 120),
        Icon(icon, size: 44, color: _muted),
        const SizedBox(height: 12),
        Text(title, textAlign: TextAlign.center, style: const TextStyle(color: _dark, fontSize: 16, fontWeight: FontWeight.w700)),
        const SizedBox(height: 6),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40),
          child: Text(body, textAlign: TextAlign.center, style: const TextStyle(color: _muted, fontSize: 13, height: 1.4)),
        ),
        if (onRetry != null)
          Center(child: TextButton(onPressed: onRetry, child: const Text('Retry', style: TextStyle(color: _teal)))),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    Widget body;
    if (_loading) {
      body = const Center(child: CircularProgressIndicator(color: _teal));
    } else if (_error != null) {
      body = _message(Icons.error_outline, "Couldn't load notifications", _error!, onRetry: _load);
    } else if (_items.isEmpty) {
      body = _message(
        Icons.notifications_none_rounded,
        'No notifications yet',
        'Booking requests, confirmations and other updates will show up here.',
      );
    } else {
      body = ListView.builder(itemCount: _items.length, itemBuilder: (_, i) => _tile(_items[i]));
    }

    return Scaffold(
      backgroundColor: _cream,
      appBar: AkriliAppBar(
        title: 'Notifications',
        onBack: () => Navigator.of(context).maybePop(),
      ),
      body: Column(
        children: [
          if (_unread > 0)
            Container(
              padding: const EdgeInsets.fromLTRB(20, 4, 8, 4),
              decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: _border))),
              child: Row(
                children: [
                  Text('$_unread unread', style: const TextStyle(color: _muted, fontSize: 13, fontWeight: FontWeight.w600)),
                  const Spacer(),
                  TextButton(
                    onPressed: _markAllRead,
                    child: const Text('Mark all read', style: TextStyle(color: _teal, fontWeight: FontWeight.w700)),
                  ),
                ],
              ),
            ),
          Expanded(
            child: RefreshIndicator(color: _teal, onRefresh: _load, child: body),
          ),
        ],
      ),
    );
  }
}
