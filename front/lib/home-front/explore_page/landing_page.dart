import 'package:flutter/material.dart';
import '../../authentication-front/widgets/complete_profile_dialog.dart';
import '../../services/user_session.dart';
import '../widgets/landing_app_bar.dart';
import '../nav_bar/nav_bar.dart';
import '../widgets/landing_profile_side_panel.dart';
import '../../settings/Profile_&_Settings.dart';

class LandingPage extends StatefulWidget {
  const LandingPage({super.key});

  @override
  State<LandingPage> createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showCompleteProfileDialog();
    });
  }

  void _showCompleteProfileDialog() {
    showGeneralDialog(
      context: context,
      barrierDismissible: false,
      barrierLabel: '',
      barrierColor: Colors.black45,
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (_, _, _) {
        return const CompleteProfileDialog();
      },
    );
  }

  Widget _buildTabBody() {
    switch (_currentIndex) {
      case 4:
        return const ProfileSettingsScreen();
      case 0:
      case 1:
      case 3:
      default:
        // TODO: swap in the real Explore / Saved / Messages screens
        // once they exist.
        return const SizedBox.shrink();
    }
  }

  @override
  Widget build(BuildContext context) {
    // NEW — the Profile tab renders its own header, so the shared
    // LandingAppBar only shows on the other tabs.
    final showLandingAppBar = _currentIndex != 4;

    return Scaffold(
      backgroundColor: const Color(0xFFFBF3E7),
      endDrawer: const ProfileSidePanel(),
      body: SafeArea(
        child: Column(
          children: [
            if (showLandingAppBar) // CHANGED — was always shown
              ListenableBuilder(
                listenable: UserSession.instance,
                builder: (context, _) {
                  return LandingAppBar(
                    profilePhotoUrl: UserSession.instance.currentUser?.profilePhotoUrl,
                  );
                },
              ),
            Expanded(child: _buildTabBody()),
          ],
        ),
      ),
      bottomNavigationBar: AkriliNavBar(
        currentIndex: _currentIndex,
        onTap: (i) => setState(() => _currentIndex = i),
      ),
    );
  }
}