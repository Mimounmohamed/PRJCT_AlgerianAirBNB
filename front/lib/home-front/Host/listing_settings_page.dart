import 'package:flutter/material.dart';
import '../../authentication-front/widgets/app_bar.dart'; // adjust path to match your project structure
import '../../services/host_service.dart'; // adjust path to match your project structure
import '../../models/host_listing_detail_model.dart'; // adjust path to match your project structure
import 'booking_preferences_page.dart'; // adjust path to match your project structure
import 'house_rules_page.dart'; // adjust path to match your project structure
import 'cancellation_policy_page.dart';
import 'listing_visibility_page.dart';

/// "Listing Settings" — reached from Manage Listing's "Listing settings"
/// quick action. A menu of four real, backend-backed settings, each on its
/// own full page with its own Save (each PUTs only its own section):
/// Booking preferences, House rules, Cancellation policy, Visibility.
///
/// This page keeps an in-memory copy of every value so a sub-page always
/// opens with the latest saved state, and pops with `true` once any
/// sub-page saved, so Manage Listing knows to reload.
///
/// Deliberately does NOT include a "Deactivate Listing" control — pause
/// / resume / delete already live on the Manage Listing page's Advanced
/// Controls, so this page only owns guest-experience settings.
class ListingSettingsPage extends StatefulWidget {
  final String authToken;
  final String listingId;

  const ListingSettingsPage({
    super.key,
    required this.authToken,
    required this.listingId,
  });

  @override
  State<ListingSettingsPage> createState() => _ListingSettingsPageState();
}

class _ListingSettingsPageState extends State<ListingSettingsPage> {
  static const Color _cream = Color(0xFFFBF3E7);
  static const Color _dark = Color(0xFF2A1B12);
  static const Color _teal = Color(0xFF006972);
  static const Color _tealTint = Color(0xFFE3F0F1);
  static const Color _muted = Color(0xFF4F4540);
  static const Color _border = Color(0xFFE7DCCB);

  static const List<String> _months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
  ];

  Future<HostListingDetailModel>? _future;
  bool _isLoaded = false;
  // True once any sub-page saved — reported back to Manage Listing.
  bool _changed = false;

  // ── Latest saved values, handed to each sub-page ────────
  late bool _autoPublish;
  late bool _instantBook;
  late int _advanceNoticeHours;
  late int _minStayNights;
  late int _maxStayNights;
  late String _checkInTimeFrom;
  late String _checkInTimeTo;
  late String _checkOutTimeFrom;
  late String _checkOutTimeTo;
  late String _checkOutTime;

  late bool _petsAllowed;
  late bool _smokingAllowed;
  late bool _eventsAllowed;
  late bool _adultOnly;
  late bool _curfew;
  late String? _curfewTime;
  late String? _additionalRules;
  late bool _familyBookletRequired;

  late String _cancellationPolicy;
  late String _visibility;
  DateTime? _snoozedUntil;
  String _status = 'active';

  String _title = '';
  String? _coverPhotoUrl;
  String _shortLocation = '';

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<HostListingDetailModel> _load() async {
    final listing = await HostService.fetchListingDetail(
      authToken: widget.authToken,
      listingId: widget.listingId,
    );
    if (!_isLoaded) {
      _autoPublish = listing.autoPublish;
      _instantBook = listing.instantBook;
      _advanceNoticeHours = listing.advanceNoticeHours;
      _minStayNights = listing.minStayNights;
      _maxStayNights = listing.maxStayNights;
      _checkInTimeFrom = listing.checkInTimeFrom;
      _checkInTimeTo = listing.checkInTimeTo;
      _checkOutTimeFrom = listing.checkOutTimeFrom;
      _checkOutTimeTo = listing.checkOutTimeTo;
      _checkOutTime = listing.checkOutTime;

      _petsAllowed = listing.petsAllowed;
      _smokingAllowed = listing.smokingAllowed;
      _eventsAllowed = listing.eventsAllowed;
      _adultOnly = listing.adultOnly;
      _curfew = listing.curfew;
      _curfewTime = listing.curfewTime;
      _additionalRules = listing.additionalRules;
      _familyBookletRequired = listing.familyBookletRequired;

      _cancellationPolicy = listing.cancellationPolicy;
      _visibility = listing.visibility;
      _snoozedUntil = listing.snoozedUntil;
      _status = listing.status;

      _title = listing.title;
      _coverPhotoUrl = listing.coverPhotoUrl;
      _shortLocation = listing.shortLocationLabel;

      _isLoaded = true;
    }
    return listing;
  }

  // ── Sub-pages ────────────────────────────────────────────

  Future<void> _openBookingPreferencesPage() async {
    final result = await Navigator.of(context).push<BookingPreferencesResult>(
      MaterialPageRoute(
        builder: (_) => BookingPreferencesPage(
          authToken: widget.authToken,
          listingId: widget.listingId,
          autoPublish: _autoPublish,
          instantBook: _instantBook,
          advanceNoticeHours: _advanceNoticeHours,
          minStayNights: _minStayNights,
          maxStayNights: _maxStayNights,
          checkInTimeFrom: _checkInTimeFrom,
          checkInTimeTo: _checkInTimeTo,
          checkOutTimeFrom: _checkOutTimeFrom,
          checkOutTimeTo: _checkOutTimeTo,
          checkOutTime: _checkOutTime,
        ),
      ),
    );

    if (result != null && mounted) {
      setState(() {
        _changed = true;
        _autoPublish = result.autoPublish;
        _instantBook = result.instantBook;
        _advanceNoticeHours = result.advanceNoticeHours;
        _minStayNights = result.minStayNights;
        _maxStayNights = result.maxStayNights;
        _checkInTimeFrom = result.checkInTimeFrom;
        _checkInTimeTo = result.checkInTimeTo;
        _checkOutTimeFrom = result.checkOutTimeFrom;
        _checkOutTimeTo = result.checkOutTimeTo;
        _checkOutTime = result.checkOutTime;
      });
    }
  }

  Future<void> _openHouseRulesPage() async {
    final result = await Navigator.of(context).push<HouseRulesResult>(
      MaterialPageRoute(
        builder: (_) => HouseRulesPage(
          authToken: widget.authToken,
          listingId: widget.listingId,
          petsAllowed: _petsAllowed,
          smokingAllowed: _smokingAllowed,
          eventsAllowed: _eventsAllowed,
          adultOnly: _adultOnly,
          familyBookletRequired: _familyBookletRequired,
          curfew: _curfew,
          curfewTime: _curfewTime,
          additionalRules: _additionalRules,
          photoUrls: _coverPhotoUrl != null ? [_coverPhotoUrl!] : const [],
        ),
      ),
    );

    if (result != null && mounted) {
      setState(() {
        _changed = true;
        _petsAllowed = result.petsAllowed;
        _smokingAllowed = result.smokingAllowed;
        _eventsAllowed = result.eventsAllowed;
        _adultOnly = result.adultOnly;
        _familyBookletRequired = result.familyBookletRequired;
        _curfew = result.curfew;
        _curfewTime = result.curfewTime;
        _additionalRules = result.additionalRules;
      });
    }
  }

  Future<void> _openCancellationPolicyPage() async {
    final result = await Navigator.of(context).push<String>(
      MaterialPageRoute(
        builder: (_) => CancellationPolicyPage(
          authToken: widget.authToken,
          listingId: widget.listingId,
          cancellationPolicy: _cancellationPolicy,
        ),
      ),
    );

    if (result != null && mounted) {
      setState(() {
        _changed = true;
        _cancellationPolicy = result;
      });
    }
  }

  Future<void> _openVisibilityPage() async {
    final result = await Navigator.of(context).push<ListingVisibilityResult>(
      MaterialPageRoute(
        builder: (_) => ListingVisibilityPage(
          authToken: widget.authToken,
          listingId: widget.listingId,
          status: _status,
          visibility: _visibility,
          snoozedUntil: _snoozedUntil,
        ),
      ),
    );

    if (result != null && mounted) {
      setState(() {
        _changed = true;
        _visibility = result.visibility;
        _snoozedUntil = result.snoozedUntil;
      });
    }
  }

  // ── Current-value subtitles for the rows ─────────────────

  String get _visibilitySummary {
    if (_status != 'active') return 'Hidden — listing not live';
    switch (_visibility) {
      case 'listed':
        return 'Listed';
      case 'snoozed':
        final until = _snoozedUntil;
        if (until == null || !until.isAfter(DateTime.now())) return 'Listed';
        return 'Snoozed until ${_months[until.month - 1]} ${until.day}';
      default:
        return 'Unlisted';
    }
  }

  // ── Rows ─────────────────────────────────────────────────

  Widget _settingsRow({required IconData icon, required String title, String? subtitle, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 21),
        decoration: const BoxDecoration(
          border: Border(bottom: BorderSide(color: _border)),
        ),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: const BoxDecoration(color: _tealTint, shape: BoxShape.circle),
              child: Icon(icon, size: 24, color: _teal),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(color: _dark, fontSize: 16, fontWeight: FontWeight.w500)),
                  if (subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(subtitle, style: const TextStyle(color: _teal, fontSize: 12, fontWeight: FontWeight.w600)),
                  ],
                ],
              ),
            ),
            const Icon(Icons.chevron_right, size: 18, color: _muted),
          ],
        ),
      ),
    );
  }

  Widget _sectionLabel(String text) => Padding(
        padding: const EdgeInsets.only(left: 10, right: 20, bottom: 8, top: 24),
        child: Text(text.toUpperCase(), style: const TextStyle(color: _muted, fontSize: 14, fontWeight: FontWeight.w700, letterSpacing: 0.6)),
      );

  @override
  Widget build(BuildContext context) {
    // Back (app bar or system) reports whether anything was saved.
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) Navigator.of(context).pop(_changed);
      },
      child: Scaffold(
        backgroundColor: _cream,
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(kToolbarHeight),
          child: Container(
            decoration: BoxDecoration(
              color: _cream,
              boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 8, offset: const Offset(0, 2))],
            ),
            child: AkriliAppBar(title: 'Listing Settings', onBack: () => Navigator.of(context).maybePop()),
          ),
        ),
        body: FutureBuilder<HostListingDetailModel>(
          future: _future,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator(color: _teal));
            }
            if (snapshot.hasError || !snapshot.hasData) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text("Couldn't load this listing.", style: TextStyle(color: _dark, fontWeight: FontWeight.w600)),
                      const SizedBox(height: 8),
                      Text('${snapshot.error}', textAlign: TextAlign.center, style: const TextStyle(color: _muted, fontSize: 12)),
                      const SizedBox(height: 16),
                      TextButton(onPressed: () => setState(() => _future = _load()), child: const Text('Retry', style: TextStyle(color: _teal))),
                    ],
                  ),
                ),
              );
            }

            return SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 36, 20, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Current listing card ─────────────
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: _border)),
                    child: Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: SizedBox(
                            width: 92,
                            height: 92,
                            child: _coverPhotoUrl != null
                                ? Image.network(_coverPhotoUrl!, fit: BoxFit.cover)
                                : Container(color: _border),
                          ),
                        ),
                        const SizedBox(width: 18),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('CURRENT LISTING', style: TextStyle(color: Color(0xFFB3261E), fontSize: 12, fontWeight: FontWeight.w700, letterSpacing: 0.6)),
                              const SizedBox(height: 6),
                              Text(
                                _title,
                                style: const TextStyle(color: _dark, fontSize: 24, fontFamily: 'CormorantGaramond', fontWeight: FontWeight.w700),
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              Text(_shortLocation, style: const TextStyle(color: _muted, fontSize: 14)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  _sectionLabel('Guest experience'),
                  Container(
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: _border)),
                    child: Column(
                      children: [
                        _settingsRow(icon: Icons.event_available_outlined, title: 'Booking preferences', onTap: _openBookingPreferencesPage),
                        _settingsRow(icon: Icons.rule_outlined, title: 'House rules', onTap: _openHouseRulesPage),
                        _settingsRow(
                          icon: Icons.policy_outlined,
                          title: 'Cancellation policy',
                          subtitle: _cancellationPolicy,
                          onTap: _openCancellationPolicyPage,
                        ),
                        _settingsRow(
                          icon: Icons.visibility_outlined,
                          title: 'Visibility',
                          subtitle: _visibilitySummary,
                          onTap: _openVisibilityPage,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
