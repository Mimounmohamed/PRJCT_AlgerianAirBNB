import 'package:flutter/material.dart';
import '../../authentication-front/widgets/complete_profile_dialog.dart';
import '../../services/user_session.dart';
import '../../services/listing_service.dart';
import '../../models/listing_model.dart';
import '../widgets/landing_app_bar.dart';
import '../nav_bar/nav_bar.dart';
import '../widgets/landing_profile_side_panel.dart';
import '../../settings/Profile_&_Settings.dart';
import '../widgets/explore_search_bar.dart';
import '../widgets/explore_filter_bar.dart';
import 'listing_card.dart';
import 'listing_detail_page.dart'; // adjust path to match your project structure

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

  // ── Explore tab listings state ──────────────────────────────────────
  List<ListingModel> _listings = [];
  bool _isLoadingListings = true;
  String? _listingsError;

  @override
  void initState() {
    super.initState();

    if (widget.showCompleteProfileDialog) { // CHANGED — was unconditional
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showCompleteProfileDialog();
      });
    }

    _fetchListings();
  }

  Future<void> _fetchListings({String? category}) async {
    setState(() {
      _isLoadingListings = true;
      _listingsError = null;
    });

    try {
      final listings = await ListingService.fetchListings(category: category);
      if (!mounted) return;
      setState(() {
        _listings = listings;
        _isLoadingListings = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _listingsError = e.toString();
        _isLoadingListings = false;
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

  Widget _buildListingsBody() {
    if (_isLoadingListings) {
      return const Center(child: CircularProgressIndicator(color: Color(0xFF006972)));
    }

    if (_listingsError != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Couldn\'t load listings.',
                style: TextStyle(color: Color(0xFF2A1B12), fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              Text(
                _listingsError!,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Color(0xFF8A7B6E), fontSize: 12),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () => _fetchListings(),
                child: const Text('Retry', style: TextStyle(color: Color(0xFF006972))),
              ),
            ],
          ),
        ),
      );
    }

    if (_listings.isEmpty) {
      return const Center(
        child: Text(
          'No listings found.',
          style: TextStyle(color: Color(0xFF8A7B6E)),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.only(top: 8, bottom: 24),
      itemCount: _listings.length,
      itemBuilder: (context, index) {
        final listing = _listings[index];
        return ListingCard(
          listing: listing,
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => ListingDetailPage(listingId: listing.id),
            ),
          ),
        );
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
            _fetchListings(category: category);
          },
        ),
        const SizedBox(height: 8),
        Expanded(child: _buildListingsBody()),
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