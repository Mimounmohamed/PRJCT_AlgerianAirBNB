import 'package:flutter/material.dart';
import '../../../services/user_session.dart'; // adjust path to match your actual location
import 'personal_info.dart';
import 'Login & Security/Login_&Security.dart';
import '../authentication-front/Login_screens/courtyard.dart';
import 'Notification_settings.dart';
import 'terms_of_service.dart';
import 'privacy_policy.dart';
import 'help_center.dart';
import 'how_works.dart';
import 'Get help with sfety issues/safety_guide.dart';
import 'Settings.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import '../services/auth_service.dart';

class ProfileSettingsScreen extends StatefulWidget {
  const ProfileSettingsScreen({
    super.key,
    this.onSettingsTap,
    this.onLogout,
    this.appVersion = '1.0.0',
  });

  final VoidCallback? onSettingsTap;
  final VoidCallback? onLogout;
  final String appVersion;

  // Shared color constants accessible by private helper widgets in this file
  static const _bg        = Color(0xFFFBF3E7);
  static const _cardFill  = Color(0xFFFFFCF5);
  static const _dark      = Color(0xFF1A1A1A);
  static const _muted     = Color(0xFF9A9188);
  static const _teal      = Color(0xFF006972);
  static const _logoutRed = Color(0xFFC1440E);

  @override
  State<ProfileSettingsScreen> createState() => _ProfileSettingsScreenState();
}

class _ProfileSettingsScreenState extends State<ProfileSettingsScreen> {

  // Alias for convenience inside this State
  static const _bg        = ProfileSettingsScreen._bg;
  static const _cardFill  = ProfileSettingsScreen._cardFill;
  static const _dark      = ProfileSettingsScreen._dark;
  static const _muted     = ProfileSettingsScreen._muted;
  static const _teal      = ProfileSettingsScreen._teal;
  static const _logoutRed = ProfileSettingsScreen._logoutRed;


  bool _uploadingPhoto = false;

  Future<void> _pickAndUploadPhoto(ImageSource source) async {
    Navigator.of(context).pop(); // close bottom sheet
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: source, imageQuality: 85);
    if (picked == null) return;

    setState(() => _uploadingPhoto = true);
    try {
      final url = await AuthService.uploadToCloudinary(File(picked.path));
      final token = UserSession.instance.token ?? '';
      // Use PUT /users/me — the correct endpoint for logged-in users
      await AuthService.updateProfile(token: token, fields: {'profilePhoto': url});
      UserSession.instance.updateProfilePhoto(url);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update photo: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _uploadingPhoto = false);
    }
  }

  Future<void> _removePhoto() async {
    Navigator.of(context).pop();
    setState(() => _uploadingPhoto = true);
    try {
      final token = UserSession.instance.token ?? '';
      // Clear the photo via PUT /users/me
      await AuthService.updateProfile(token: token, fields: {'profilePhoto': null});
      UserSession.instance.updateProfilePhoto(null);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to remove photo: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _uploadingPhoto = false);
    }
  }

  void _showPhotoOptions() {
    final user = UserSession.instance.currentUser;
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        decoration: const BoxDecoration(
          color: Color(0xFFFFFCF5),
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40, height: 4,
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: const Color(0xFFD3C3BD),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const Text(
              'Profile Photo',
              style: TextStyle(
                fontFamily: 'CormorantGaramond',
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: Color(0xFF23130A),
              ),
            ),
            const SizedBox(height: 20),
            _PhotoOption(
              icon: Icons.camera_alt_outlined,
              label: 'Take a photo',
              onTap: () => _pickAndUploadPhoto(ImageSource.camera),
            ),
            const SizedBox(height: 12),
            _PhotoOption(
              icon: Icons.photo_library_outlined,
              label: 'Choose from gallery',
              onTap: () => _pickAndUploadPhoto(ImageSource.gallery),
            ),
            if (user?.profilePhotoUrl != null) ...[
              const SizedBox(height: 12),
              _PhotoOption(
                icon: Icons.delete_outline,
                label: 'Remove photo',
                color: const Color(0xFFC1440E),
                onTap: _removePhoto,
              ),
            ],
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

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
              Container(
                width: 52, height: 52,
                decoration: const BoxDecoration(
                  color: Color(0xFF2A1B12),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.logout_rounded, color: Colors.white, size: 24),
              ),
              const SizedBox(height: 20),
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
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(dialogContext).pop();
                    UserSession.instance.clear();
                    if (widget.onLogout != null) {
                      widget.onLogout!();
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
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const SettingsScreen(),
                            ),
                          );
                        },
                        icon: const Icon(Icons.settings_outlined, color: _dark),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Center(
                    child: Column(
                      children: [
                        GestureDetector(
                          onTap: _uploadingPhoto ? null : _showPhotoOptions,
                          child: Stack(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(4),
                                decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.white,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Color(0x408B6A4A),
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
                                child: _uploadingPhoto
                                    ? const SizedBox(
                                        width: 88,
                                        height: 88,
                                        child: CircularProgressIndicator(
                                          color: _teal,
                                          strokeWidth: 2.5,
                                        ),
                                      )
                                    : CircleAvatar(
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
                              // Camera badge
                              if (!_uploadingPhoto)
                                Positioned(
                                  bottom: 2,
                                  right: 2,
                                  child: Container(
                                    width: 28,
                                    height: 28,
                                    decoration: const BoxDecoration(
                                      color: Color(0xFF006972),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.camera_alt,
                                      color: Colors.white,
                                      size: 15,
                                    ),
                                  ),
                                ),
                            ],
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
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const HelpCenterScreen(),
                            ),
                          );
                        },
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
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const SafetyGuideScreen(),
                            ),
                          );
                        },
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
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const TermsOfServiceScreen(),
                            ),
                          );
                        },
                      ),
                      _SettingsTile(
                        icon: Icons.privacy_tip_outlined,
                        label: 'Privacy Policy',
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const PrivacyPolicyScreen(),
                            ),
                          );
                        },
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
                      'Version ${widget.appVersion}',
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

class _PhotoOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? color;

  const _PhotoOption({
    required this.icon,
    required this.label,
    required this.onTap,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final c = color ?? const Color(0xFF2A1B12);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: const Color(0xFFFFF8F0),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFEADDCD).withOpacity(0.5)),
        ),
        child: Row(
          children: [
            Icon(icon, color: c, size: 22),
            const SizedBox(width: 14),
            Text(
              label,
              style: TextStyle(
                color: c,
                fontSize: 15,
                fontFamily: 'HankenGrotesk',
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}