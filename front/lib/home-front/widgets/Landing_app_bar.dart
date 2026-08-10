import 'package:flutter/material.dart';
import 'landing_notifications_screen.dart';

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
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: const Color(0xFF2A1B12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.auto_awesome,
                color: Color(0xFFD9A441), size: 16),
          ),
          const SizedBox(width: 10),
          const Text(
            'AKRILI',
            style: TextStyle(
              fontFamily: 'CormorantGaramond',
              fontSize: 20,
              fontWeight: FontWeight.w700,
              letterSpacing: 2,
              color: Color(0xFF1A1A1A),
            ),
          ),
          const Spacer(),
          IconButton(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const NotificationsScreen(),
                ),
              );
            },
            icon: const Icon(Icons.notifications_none_rounded,
                color: Color(0xFF1A1A1A)),
          ),
          GestureDetector(
            onTap: () => Scaffold.of(context).openEndDrawer(),
            child: CircleAvatar(
              radius: 16,
              backgroundColor: const Color(0xFFEFE6D6),
              backgroundImage: profilePhotoUrl != null
                  ? NetworkImage(profilePhotoUrl!)
                  : null,
              child: profilePhotoUrl == null
                  ? const Icon(Icons.person, size: 18, color: Color(0xFF9A9188))
                  : null,
            ),
          ),
        ],
      ),
    );
  }
}