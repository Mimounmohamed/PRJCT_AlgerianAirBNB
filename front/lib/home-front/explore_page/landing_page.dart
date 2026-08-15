import 'package:flutter/material.dart';
import '../../authentication-front/widgets/complete_profile_dialog.dart';
import '../../services/user_session.dart';
import '../widgets/landing_app_bar.dart';
import '../nav_bar/nav_bar.dart';
import '../widgets/landing_profile_side_panel.dart';
import '../../settings/Profile_&_Settings.dart';
import '../widgets/explore_search_bar.dart';
import  '../widgets/explore_filter_bar.dart';

class LandingPage extends StatefulWidget {
  const LandingPage({
    super.key,
    this.showCompleteProfileDialog = false, // NEW
  });

  /// Set to true only when arriving right after signup — shows the
  /// "Complete Your Profile" nudge once. Login flows should leave this false.
  final bool showCompleteProfileDialog;

  @override
  State<LandingPage> createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();

    if (widget.showCompleteProfileDialog) { // CHANGED — was unconditional
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showCompleteProfileDialog();
      });
    }
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

  Widget _buildExploreTab() {
    return Column(
      children: [
        const SizedBox(height: 12),
        ExploreSearchBar(
          onFilterTap: () {
            // TODO: push full filter sheet
          },
        ),
        const SizedBox(height: 16),
        ExploreFilterBar(
          onCategorySelected: (category) {
            // TODO: trigger GET /api/listings?category=... here later
          },
        ),
        const SizedBox(height: 16),
        // TODO: listings list/grid goes here once ListingCard is built
        const Expanded(child: SizedBox.shrink()),
      ],
    );
  }

  Widget _buildTabBody() {
    switch (_currentIndex) {
      case 4:
        return const ProfileSettingsScreen();
      case 0:
        return _buildExploreTab();
      case 1:
      case 3:
      default:
        // TODO: swap in the real Saved / Messages screens once they exist.
        return const SizedBox.shrink();
    }
  }

  @override
  Widget build(BuildContext context) {
    final showLandingAppBar = _currentIndex != 4;

    return Scaffold(
      backgroundColor: const Color(0xFFFBF3E7),
      endDrawer: const ProfileSidePanel(),
      body: SafeArea(
        child: Column(
          children: [
            if (showLandingAppBar)
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