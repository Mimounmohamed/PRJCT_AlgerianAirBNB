import 'package:flutter/material.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFBF3E7),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFBF3E7),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF006972)),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Settings',
          style: TextStyle(
            color: Color(0xFF2A1B12),
            fontSize: 28,
            fontFamily: 'CormorantGaramond',
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Preferences section
            const Text(
              'Preferences',
              style: TextStyle(
                color: Color(0xFF2A1B12),
                fontSize: 24,
                fontFamily: 'CormorantGaramond',
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFFFFFFFF),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE7DCCB)),
              ),
              child: Column(
                children: [
                  _SettingsItem(
                    icon: Icons.language_outlined,
                    iconColor: const Color(0xFF006972),
                    title: 'Language',
                    subtitle: 'ENGLISH',
                    onTap: () {},
                    showDivider: true,
                    trailing: const Icon(
                      Icons.chevron_right,
                      color: Color(0xFF8A7B6E),
                      size: 20,
                    ),
                  ),
                  _SettingsItem(
                    icon: Icons.currency_exchange_outlined,
                    iconColor: const Color(0xFF006972),
                    title: 'Currency',
                    subtitle: 'DZD',
                    onTap: () {},
                    showDivider: true,
                    trailing: const Icon(
                      Icons.chevron_right,
                      color: Color(0xFF8A7B6E),
                      size: 20,
                    ),
                  ),
                  _SettingsItem(
                    icon: Icons.public_outlined,
                    iconColor: const Color(0xFF006972),
                    title: 'Region',
                    subtitle: 'ALGERIA',
                    onTap: () {},
                    showDivider: false,
                    trailing: const Icon(
                      Icons.chevron_right,
                      color: Color(0xFF8A7B6E),
                      size: 20,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // About section
            const Text(
              'About',
              style: TextStyle(
                color: Color(0xFF2A1B12),
                fontSize: 24,
                fontFamily: 'CormorantGaramond',
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFFFFFFFF),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE7DCCB)),
              ),
              child: Column(
                children: [
                  _SettingsItem(
                    icon: Icons.info_outline,
                    iconColor: const Color(0xFF2A1B12),
                    title: 'Version',
                    subtitle: '2.4.0 (Build 892)',
                    onTap: null,
                    showDivider: true,
                    trailing: const SizedBox.shrink(),
                  ),
                  _SettingsItem(
                    icon: Icons.volunteer_activism_outlined,
                    iconColor: const Color(0xFF2A1B12),
                    title: 'Acknowledgments',
                    subtitle: null,
                    onTap: () {},
                    showDivider: true,
                    trailing: const Icon(
                      Icons.open_in_new,
                      color: Color(0xFF8A7B6E),
                      size: 18,
                    ),
                  ),
                  _SettingsItem(
                    icon: Icons.description_outlined,
                    iconColor: const Color(0xFF2A1B12),
                    title: 'Licenses',
                    subtitle: null,
                    onTap: () {},
                    showDivider: false,
                    trailing: const Icon(
                      Icons.chevron_right,
                      color: Color(0xFF8A7B6E),
                      size: 22,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Sign Out button
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      backgroundColor: const Color(0xFFfbefe5),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      title: const Text(
                        'Sign Out',
                        style: TextStyle(
                          color: Color(0xFFB3261E),
                          fontFamily: 'CormorantGaramond',
                          fontSize: 22,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      content: const Text(
                        'Are you sure you want to sign out?',
                        style: TextStyle(
                          color: Color(0xFF4F4540),
                          fontFamily: 'HankenGrotesk',
                          fontSize: 14,
                        ),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: const Text(
                            'Cancel',
                            style: TextStyle(
                              color: Color(0xFF8A7B6E),
                              fontFamily: 'HankenGrotesk',
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: const Text(
                            'Sign Out',
                            style: TextStyle(
                              color: Color(0xFFB5451B),
                              fontFamily: 'HankenGrotesk',
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Color(0x1AB23A3A)), // rgba(178,58,58,0.10)
                  backgroundColor: const Color(0x0DB3261E),         // rgba(178,58,58,0.05)
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text(
                  'Sign Out',
                  style: TextStyle(
                    color: Color(0xFFB5451B),
                    fontSize: 15,
                    fontFamily: 'HankenGrotesk',
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 32),

            // Footer
            const Center(
              child: Text(
                '© 2024 AKRILI STAYS. ALL RIGHTS RESERVED.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Color(0xFFE7DCCB),
                  fontSize: 10,
                  fontFamily: 'HankenGrotesk',
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1.2,
                ),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}

class _SettingsItem extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String? subtitle;
  final VoidCallback? onTap;
  final bool showDivider;
  final Widget trailing;

  const _SettingsItem({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.onTap,
    required this.showDivider,
    required this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: iconColor.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: iconColor, size: 22),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          color: Color(0xFF2A1B12),
                          fontSize: 16,
                          fontFamily: 'HankenGrotesk',
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      if (subtitle != null) ...[
                        const SizedBox(height: 2),
                        Text(
                          subtitle!,
                          style: const TextStyle(
                            color: Color(0xFF8A7B6E),
                            fontSize: 13,
                            fontFamily: 'HankenGrotesk',
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                trailing,
              ],
            ),
          ),
        ),
        if (showDivider)
          const Divider(
            height: 1,
            thickness: 0.7,
            color: Color(0xFFE7DCCB),
            indent: 16,
            endIndent: 16,
          ),
      ],
    );
  }
}