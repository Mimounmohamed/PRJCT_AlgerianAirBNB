import 'package:flutter/material.dart';
import '../../authentication-front/widgets/complete_profile_dialog.dart';
import '../../services/user_session.dart';
import '../../services/auth_service.dart';
import '../../services/socket_service.dart';
import '../../services/listing_service.dart';
import '../../models/listing_model.dart';
import '../../models/explore_filters.dart';
import '../widgets/landing_app_bar.dart';
import '../widgets/explore_search_bar.dart';
import '../widgets/explore_filter_bar.dart';
import 'listing_card.dart';
import 'listing_detail_page.dart';
import 'filters_page.dart';
import 'search_discovery_page.dart';
import '../widgets/property_types.dart';
import '../Host/host_tab_entry.dart';
import '../nav_bar/nav_bar.dart';
import '../widgets/landing_profile_side_panel.dart';
import '../../settings/Profile_&_Settings.dart';
import '../../chat/msg_center.dart';
import '../saved/saved_page.dart';

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
  // Place (search screen) + Filters page + stay-type shortcut.
  ExploreFilters _filters = ExploreFilters.empty;
  // Ignores a slower, older response that finishes after a newer one.
  int _fetchRequest = 0;

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

  /// Loads the Explore list for [_filters] (pass [filters] to change them).
  Future<void> _fetchListings([ExploreFilters? filters]) async {
    final request = ++_fetchRequest;
    setState(() {
      if (filters != null) _filters = filters;
      _isLoadingListings = true;
      _listingsError = null;
    });
    try {
      final listings = await ListingService.fetchListings(filters: _filters);
      if (!mounted || request != _fetchRequest) return;
      setState(() {
        _listings = listings;
        _isLoadingListings = false;
      });
    } catch (e) {
      if (!mounted || request != _fetchRequest) return;
      setState(() {
        _listingsError = e.toString().replaceFirst('Exception: ', '');
        _isLoadingListings = false;
      });
    }
  }

  Future<void> _openSearch() async {
    final result = await SearchDiscoveryPage.open(context, _filters);
    if (result != null && mounted) _fetchListings(result);
  }

  Future<void> _openFilters() async {
    final result = await FiltersPage.open(context, _filters);
    if (result != null && mounted) _fetchListings(result);
  }

  /// "Anytime · Add guests", or what the filters ask for.
  String get _searchSubtitle {
    final parts = <String>['Anytime'];
    parts.add(_filters.guests > 0 ? '${_filters.guests}+ guests' : 'Add guests');
    final types = _filters.propertyTypes;
    final group = stayGroupFor(types);
    if (group != null) {
      parts.add(group.label);
    } else if (types.length == 1) {
      parts.add(types.first);
    } else if (types.length > 1) {
      parts.add('${types.length} types');
    }
    return parts.join(' · ');
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
      return const Center(
        child: CircularProgressIndicator(color: Color(0xFF006972)),
      );
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
                style: TextStyle(
                  color: Color(0xFF2A1B12),
                  fontWeight: FontWeight.w600,
                ),
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
                child: const Text(
                  'Retry',
                  style: TextStyle(color: Color(0xFF006972)),
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (_listings.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.search_off, size: 48, color: Color(0xFF8A7B6E)),
            const SizedBox(height: 12),
            Text(
              _filters.hasPlace || _filters.refinementCount > 0
                  ? 'No stays match your search.'
                  : 'No listings found.',
              textAlign: TextAlign.center,
              style: const TextStyle(color: Color(0xFF8A7B6E)),
            ),
            if (_filters.hasPlace || _filters.refinementCount > 0)
              TextButton(
                onPressed: () => _fetchListings(ExploreFilters.empty),
                child: const Text('Clear search and filters', style: TextStyle(color: Color(0xFF006972), fontWeight: FontWeight.w700)),
              ),
          ],
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
          place: _filters.placeText,
          subtitle: _searchSubtitle,
          activeFilters: _filters.refinementCount,
          onTap: _openSearch,
          onFilterTap: _openFilters,
          onClear: () => _fetchListings(_filters.clearPlace()),
        ),
        const SizedBox(height: 12),
        ExploreFilterBar(
          selectedTypes: _filters.propertyTypes,
          onSelected: (types) => _fetchListings(_filters.withPropertyTypes({...types})),
        ),
        const SizedBox(height: 8),
        Expanded(child: _buildListingsBody()),
      ],
    );
  }

  Widget _buildHostTab() {
    final token = UserSession.instance.token;
    if (token == null) {
      return const Center(
        child: Text(
          'Please log in again to access hosting.',
          style: TextStyle(color: Color(0xFF8A7B6E)),
        ),
      );
    }

    final fullName = UserSession.instance.currentUser?.name ?? '';
    final firstName = fullName.trim().isEmpty
        ? 'Host'
        : fullName.trim().split(RegExp(r'\s+')).first;

    return HostTabEntry(
      authToken: token,
      hostFirstName: firstName,
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
      case 2:
        return _buildHostTab();
      case 1:
        return const SavedPage();
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
                    profilePhotoUrl:
                        UserSession.instance.currentUser?.profilePhotoUrl,
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
          final cameFromHost = _currentIndex == 2;
          setState(() {
            _currentIndex = i;
            // Clear badge when user opens Messages
            if (i == 3) _hasUnreadMessages = false;
          });
          if (i == 0 && cameFromHost) {
            _fetchListings();
          }
        },
      ),
    );
  }
}
