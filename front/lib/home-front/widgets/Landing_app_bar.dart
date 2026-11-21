import 'dart:async';
import 'package:flutter/material.dart';
import 'landing_notifications_screen.dart';
import '../../services/notification_service.dart';
import '../../services/push_notification_service.dart';
import '../../services/user_session.dart';

/// Bell with an unread-count badge. Refreshes when the screen opens, after
/// coming back from the Notifications screen, and on every push received
/// while the app is open.
class _NotificationBell extends StatefulWidget {
  const _NotificationBell();

  @override
  State<_NotificationBell> createState() => _NotificationBellState();
}

class _NotificationBellState extends State<_NotificationBell> {
  int _unread = 0;
  StreamSubscription? _pushSub;

  @override
  void initState() {
    super.initState();
    _refresh();
    _pushSub = PushNotificationService.instance.onForegroundMessage.listen((_) => _refresh());
  }

  @override
  void dispose() {
    _pushSub?.cancel();
    super.dispose();
  }

  Future<void> _refresh() async {
    final token = UserSession.instance.token;
    if (token == null) return;
    final count = await NotificationService.unreadCount(token: token);
    if (mounted) setState(() => _unread = count);
  }

  Future<void> _open() async {
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => const NotificationsScreen()),
    );
    _refresh();
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: _open,
      icon: Badge(
        isLabelVisible: _unread > 0,
        label: Text(_unread > 99 ? '99+' : '$_unread'),
        backgroundColor: const Color(0xFFB3261E),
        child: const Icon(Icons.notifications_none_rounded, color: Color(0xFF1A1A1A), size: 29),
      ),
    );
  }
}

class LandingAppBar extends StatelessWidget {
  const LandingAppBar({
    super.key,
    this.profilePhotoUrl,
  });

  /// The logged-in user's profile photo URL, fetched from the backend.
  /// Pass null (no photo yet / not loaded) to fall back to a placeholder icon.
  final String? profilePhotoUrl;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 4),
      child: Row(
        children: [
          Image.asset(
            'assets/images/logo.png',
            width: 39,
            height: 39,
          ),
          const SizedBox(width: 10),
          const Text(
            'AKRILI',
            style: TextStyle(
              fontFamily: 'CormorantGaramond',
              fontSize: 26,
              fontWeight: FontWeight.w700,
              letterSpacing: 2,
              color: Color(0xFF1A1A1A),
            ),
          ),
          const Spacer(),
          const _NotificationBell(),
          GestureDetector(
            onTap: () => Scaffold.of(context).openEndDrawer(),
            child: CircleAvatar(
              radius: 22,
              backgroundColor: const Color(0xFFEFE6D6),
              backgroundImage: profilePhotoUrl != null
                  ? NetworkImage(profilePhotoUrl!)
                  : null,
              child: profilePhotoUrl == null
                  ? const Icon(Icons.person, size: 20, color: Color(0xFF9A9188))
                  : null,
            ),
          ),
        ],
      ),
    );
  }
}