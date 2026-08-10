import 'package:flutter/material.dart';
import '../../authentication-front/widgets/complete_profile_dialog.dart';
import '../widgets/landing_app_bar.dart';
import '../nav_bar/nav_bar.dart';
import '../widgets/landing_profile_side_panel.dart';

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFBF3E7),
      endDrawer: const ProfileSidePanel(),
      body: SafeArea(
        child: Column(
          children: [
            // TODO: pass the logged-in user's real profilePhotoUrl once
            // session/auth state is wired up.
            const LandingAppBar(profilePhotoUrl: null),
            // TODO: fill this in per tab once the real screens exist.
            const Expanded(child: SizedBox.shrink()),
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