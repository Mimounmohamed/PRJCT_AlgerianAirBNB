import 'package:flutter/material.dart';
import '../../../services/user_session.dart'; // adjust path to match your actual location
import 'personal_info.dart';
import 'Login & Security/Login_&Security.dart';
import '../authentication-front/Login_screens/courtyard.dart';
import 'Notification_settings.dart';
import 'how_works.dart';
class ProfileSettingsScreen extends StatelessWidget {
  const ProfileSettingsScreen({
    super.key,
    this.onSettingsTap,
    this.onLogout,
    this.appVersion = '1.0.0',
  });

  /// Called when the gear icon in the top-right is tapped.
  final VoidCallback? onSettingsTap;

  /// Called when "Log out" is confirmed. If null, just clears the session.
  final VoidCallback? onLogout;

  final String appVersion;

  static const _bg = Color(0xFFFBF3E7);
  static const _cardFill = Color(0xFFFFFCF5);
  static const _dark = Color(0xFF1A1A1A);
  static const _muted = Color(0xFF9A9188);
  static const _teal = Color(0xFF006972);
  static const _logoutRed = Color(0xFFC1440E);

  void _handleLogout(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (dialogContext) => Dialog(
        backgroundColor: _cardFill,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        insetPadding: const EdgeInsets.symmetric(horizontal: 40),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Icon
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: const Color(0xFF2A1B12),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.logout_rounded,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(height: 20),
              // Title
              const Text(
                'Log out of AKRILI?',
                style: TextStyle(
                  fontFamily: 'CormorantGaramond',
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF23130A),
                ),
              ),
              const SizedBox(height: 10),
              // Description
              const Text(
                'Are you sure you want to log out? You\'ll need to sign back in to manage your stays and messages.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'HankenGrotesk',
                  fontSize: 14,
                  color: Color(0xFF4F4540),
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 24),
              // Log Out button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(dialogContext).pop();
                    UserSession.instance.clear();
                    if (onLogout != null) {
                      onLogout!();
                    } else {
                      Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(builder: (_) => const AuthScreen()),
                        (route) => false,
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF006972),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text(
                    'Log Out',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontFamily: 'HankenGrotesk',
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              // Stay Logged In button
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () => Navigator.of(dialogContext).pop(),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Color(0xFFD3C3BD)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text(
                    'Stay Logged In',
                    style: TextStyle(
                      color: Color(0xFF23130A),
                      fontSize: 15,
                      fontFamily: 'HankenGrotesk',
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: _bg,
      child: SafeArea(
        bottom: false,
        child: ListenableBuilder(
          listenable: UserSession.instance,
          builder: (context, _) {
            final user = UserSession.instance.currentUser;
            return SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Profile',
                        style: TextStyle(
                          fontFamily: 'CormorantGaramond',
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                          color: _dark,
                        ),
                      ),
                      IconButton(
                        onPressed: onSettingsTap,
                        icon: const Icon(Icons.settings_outlined, color: _dark),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Center(
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(4), // white ring
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white,
                            boxShadow: [
                              BoxShadow(
                                color: Color(0x408B6A4A), // warm brown, tighter
                                blurRadius: 14,
                                spreadRadius: 1,
                              ),
                              BoxShadow(
                                color: Color(0x1F8B6A4A),
                                blurRadius: 22,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                          child: CircleAvatar(
                            radius: 44,
                            backgroundColor: const Color(0xFFEFE6D6),
                            backgroundImage: user?.profilePhotoUrl != null
                                ? NetworkImage(user!.profilePhotoUrl!)
                                : null,
                            child: user?.profilePhotoUrl == null
                                ? const Icon(Icons.person, size: 40, color: _muted)
                                : null,
                          ),
                        ),
                        const SizedBox(height: 18),
                        Text(
                          user?.name.isNotEmpty == true ? user!.name : 'Guest',
                          style: const TextStyle(
                            fontFamily: 'CormorantGaramond',
                            fontSize: 38,
                            fontWeight: FontWeight.w700,
                            color: _dark,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 28),
                  const _SectionLabel('Account Settings'),
                  _SectionCard(
                    tiles: [
                      _SettingsTile(
                        icon: Icons.person_outline,
                        label: 'Personal info',
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => PersonalInfoScreen(
                                token: UserSession.instance.token ?? '',
                              ),
                            ),
                          );
                        },
                      ),
                      _SettingsTile(
                        icon: Icons.shield_outlined,
                        label: 'Login & security',
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => LoginSecurityScreen(
                                token: UserSession.instance.token ?? '',
                              ),
                            ),
                          );
                        },
                      ),
                      _SettingsTile(
                        icon: Icons.notifications_none_rounded,
                        label: 'Notification settings',
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const NotificationsScreen(),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  const _SectionLabel('Hosting'),
                  _SectionCard(
                    tiles: [
                      _SettingsTile(
                        icon: Icons.storefront_outlined,
                        label: 'List your place',
                        onTap: () {}, // TODO: navigate to hosting flow
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  const _SectionLabel('Support'),
                  _SectionCard(
                    tiles: [
                      _SettingsTile(
                        icon: Icons.help_outline_rounded,
                        label: 'Help Center',
                        onTap: () {}, // TODO: navigate to help center
                      ),
                      _SettingsTile(
                        icon: Icons.menu_book_outlined,
                        label: 'How AKRILI works',
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const HowItWorksScreen(),
                            ),
                          );
                        },
                      ),
                      _SettingsTile(
                        icon: Icons.support_agent_outlined,
                        label: 'Get help with a safety issue',
                        onTap: () {}, // TODO: navigate to safety help
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  const _SectionLabel('Legal'),
                  _SectionCard(
                    tiles: [
                      _SettingsTile(
                        icon: Icons.gavel_outlined,
                        label: 'Terms of Service',
                        onTap: () {}, // TODO: navigate to terms
                      ),
                      _SettingsTile(
                        icon: Icons.privacy_tip_outlined,
                        label: 'Privacy Policy',
                        onTap: () {}, // TODO: navigate to privacy policy
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                  Center(
                    child: OutlinedButton(
                      onPressed: () => _handleLogout(context),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: _logoutRed,
                        side: const BorderSide(color: _logoutRed),
                        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      child: const Text(
                        'Log out',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Center(
                    child: Text(
                      'Version $appVersion',
                      style: const TextStyle(fontSize: 12, color: _muted),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 13, left: 4),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: ProfileSettingsScreen._dark,
        ),
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.tiles});
  final List<_SettingsTile> tiles;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: ProfileSettingsScreen._cardFill,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          for (int i = 0; i < tiles.length; i++) ...[
            tiles[i],
            if (i != tiles.length - 1)
              // CHANGED — indent/endIndent both set to 16 (matches the
              // tile's own horizontal padding) instead of trying to align
              // under the text. This guarantees a symmetric gap regardless
              // of icon glyph width differences.
              const Divider(
                height: 1,
                indent: 16,
                endIndent: 16,
                color: Color(0xFFE3D8C0),
              ),
          ],
        ],
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  const _SettingsTile({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Icon(icon, size: 20, color: ProfileSettingsScreen._dark),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  fontSize: 17,
                  color: ProfileSettingsScreen._dark,
                ),
              ),
            ),
            const Icon(Icons.chevron_right_rounded,
                size: 20, color: ProfileSettingsScreen._muted),
          ],
        ),
      ),
    );
  }
}