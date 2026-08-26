import 'package:flutter/material.dart';
import '../../authentication-front/widgets/complete_profile_dialog.dart';
import '../../services/user_session.dart';
import '../../services/auth_service.dart';
import '../../services/socket_service.dart';
import '../../services/listing_service.dart';
import '../../models/listing_model.dart';
import '../widgets/landing_app_bar.dart';
import '../widgets/explore_search_bar.dart';
import '../widgets/explore_filter_bar.dart';
import '../nav_bar/nav_bar.dart';
import '../widgets/landing_profile_side_panel.dart';
import '../explore_page/listing_card.dart';
import '../explore_page/listing_detail_page.dart';
import '../../settings/Profile_&_Settings.dart';
import '../../chat/msg_center.dart';

class LandingPage extends StatefulWidget {
  const LandingPage({
    super.key,
    this.showCompleteProfileDialog = false, // NEW
  });

  final bool showCompleteProfileDialog;

  @override
  State<LandingPage> createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> {
  int _currentIndex = 0;
  bool _hasUnreadMessages = false;

  List<ListingModel> _listings = [];
  bool _isLoadingListings = true;
  String? _listingsError;

  @override
  void initState() {
    super.initState();

    if (widget.showCompleteProfileDialog) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showCompleteProfileDialog();
      });
    }

    _fetchListings();
    _checkUnread();

    // Keep badge in sync when a new message arrives
    SocketService.instance.onConversationUpdated((_) => _checkUnread());
  }

  @override
  void dispose() {
    SocketService.instance.offConversationUpdated();
    super.dispose();
  }

  Future<void> _checkUnread() async {
    try {
      final token = UserSession.instance.token ?? '';
      if (token.isEmpty) return;
      final convs = await AuthService.getConversations(token: token);
      final myId = UserSession.instance.currentUser?.id ?? '';
      if (myId.isEmpty) return;
      bool hasUnread = false;
      for (final c in convs) {
        final unreadRaw = c['unreadCount'];
        if (unreadRaw == null) continue;
        if (unreadRaw is Map) {
          final val = unreadRaw[myId];
          if (val != null && (val as num) > 0) {
            hasUnread = true;
            break;
          }
        }
      }
      if (mounted) setState(() => _hasUnreadMessages = hasUnread);
    } catch (_) {}
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
      case 3:
        return const MessagesScreen();
      case 4:
        return const ProfileSettingsScreen();
      case 0:
        return _buildExploreTab();
      case 1:
      case 2:
      default:
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
        hasUnreadMessages: _hasUnreadMessages,
        onTap: (i) {
          setState(() {
            _currentIndex = i;
            // Clear badge when user opens Messages
            if (i == 3) _hasUnreadMessages = false;
          });
        },
      ),
    );
  }
}