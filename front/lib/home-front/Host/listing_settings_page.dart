import 'package:flutter/material.dart';
import '../../authentication-front/widgets/app_bar.dart'; // adjust path to match your project structure
import '../../services/host_service.dart'; // adjust path to match your project structure
import '../../models/host_listing_detail_model.dart'; // adjust path to match your project structure
import 'booking_preferences_page.dart'; // adjust path to match your project structure
import 'house_rules_page.dart'; // adjust path to match your project structure

/// "Listing Settings" — reached from Manage Listing's "Listing settings"
/// quick action. Groups four real, backend-backed settings:
/// bookingPreferences, houseRules, cancellationPolicy, and visibility.
///
/// Booking preferences and House rules are each their own full page
/// (pushed via Navigator) rather than bottom sheets, each with its own
/// dedicated Save button that PUTs just that section. Cancellation
/// policy and Visibility still open in a bottom sheet, and one
/// page-level "Save Changes" button commits everything in a single PUT
/// (including booking preferences / house rules again, using whatever
/// values are currently in this page's state — so nothing is lost if
/// the host only opens this page and taps Save Changes without visiting
/// those two sub-pages).
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

  Future<HostListingDetailModel>? _future;
  bool _isLoaded = false;
  bool _isSaving = false;

  // ── Working copies of everything this page edits ────────
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

      _title = listing.title;
      _coverPhotoUrl = listing.coverPhotoUrl;
      _shortLocation = listing.shortLocationLabel;

      _isLoaded = true;
    }
    return listing;
  }

  // ── Navigate to Booking Preferences page ──────────────────

  Future<void> _openBookingPreferencesPage() async {
    final result = await Navigator.of(context).push<BookingPreferencesResult>(
      MaterialPageRoute(
        builder: (_) => BookingPreferencesPage(
          authToken: widget.authToken,
          listingId: widget.listingId,
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
        _instantBook = result.instantBook;
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

  // ── Navigate to House Rules page ──────────────────────────

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
        _petsAllowed = result.petsAllowed;
        _smokingAllowed = result.smokingAllowed;
        _eventsAllowed = result.eventsAllowed;
        _curfew = result.curfew;
        _curfewTime = result.curfewTime;
        _additionalRules = result.additionalRules;
      });
    }
  }

  // ── Save (page-level — everything, including booking preferences and
  // house rules again using current state, so nothing is lost if the
  // host never opens those sub-pages) ────────────────────────

  Future<void> _save() async {
    setState(() => _isSaving = true);
    try {
      await HostService.updateListingDetails(
        authToken: widget.authToken,
        listingId: widget.listingId,
        updates: {
          'bookingPreferences': {
            'instantBook': _instantBook,
            'advanceNoticeHours': _advanceNoticeHours,
            'minStayNights': _minStayNights,
            'maxStayNights': _maxStayNights,
            'checkInTimeFrom': _checkInTimeFrom,
            'checkInTimeTo': _checkInTimeTo,
            'checkOutTimeFrom': _checkOutTimeFrom,
            'checkOutTimeTo': _checkOutTimeTo,
            'checkOutTime': _checkOutTime,
          },
          'houseRules': {
            'petsAllowed': _petsAllowed,
            'smokingAllowed': _smokingAllowed,
            'eventsAllowed': _eventsAllowed,
            'adultOnly': _adultOnly,
            'curfew': _curfew,
            if (_curfewTime != null) 'curfewTime': _curfewTime,
            if (_additionalRules != null) 'additionalRules': _additionalRules,
            'familyBookletRequired': _familyBookletRequired,
          },
          'cancellationPolicy': _cancellationPolicy,
          'visibility': _visibility,
        },
      );

      if (!mounted) return;
      await _showSavedPopup();
      if (!mounted) return;
      Navigator.of(context).pop(true); // true = Manage Listing should refresh
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e')));
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Future<void> _showSavedPopup() {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        Future.delayed(const Duration(milliseconds: 1400), () {
          if (Navigator.of(dialogContext).canPop()) Navigator.of(dialogContext).pop();
        });
        return Dialog(
          backgroundColor: _cream,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 28),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: const BoxDecoration(color: _teal, shape: BoxShape.circle),
                  child: const Icon(Icons.check, color: Colors.white, size: 32),
                ),
                const SizedBox(height: 16),
                const Text('Changes saved', style: TextStyle(color: _dark, fontSize: 16, fontWeight: FontWeight.w700)),
              ],
            ),
          ),
        );
      },
    );
  }

  // ── Shared bottom-sheet chrome (used by Cancellation/Visibility) ──

  Future<void> _openSheet({required String title, required Widget Function(BuildContext, StateSetter) contentBuilder}) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return DraggableScrollableSheet(
          initialChildSize: 0.6,
          minChildSize: 0.35,
          maxChildSize: 0.92,
          expand: false,
          builder: (context, scrollController) {
            return StatefulBuilder(
              builder: (context, sheetSetState) {
                return Container(
                  decoration: const BoxDecoration(
                    color: _cream,
                    borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                  ),
                  child: Column(
                    children: [
                      const SizedBox(height: 10),
                      Container(width: 36, height: 4, decoration: BoxDecoration(color: _border, borderRadius: BorderRadius.circular(4))),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(20, 14, 20, 10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(title, style: const TextStyle(color: _dark, fontSize: 18, fontWeight: FontWeight.w700)),
                            TextButton(
                              onPressed: () => Navigator.of(sheetContext).pop(),
                              child: const Text('Done', style: TextStyle(color: _teal, fontWeight: FontWeight.w700)),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: SingleChildScrollView(
                          controller: scrollController,
                          padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                          child: contentBuilder(context, sheetSetState),
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        );
      },
    ).then((_) {
      if (mounted) setState(() {});
    });
  }

  // ── Sheet: Cancellation policy ─────────────────────────────

  Widget _cancellationCard({required String value, required String title, required String description, required StateSetter sheetSetState}) {
    final selected = _cancellationPolicy == value;
    return GestureDetector(
      onTap: () => sheetSetState(() => setState(() => _cancellationPolicy = value)),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: selected ? _tealTint : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: selected ? _teal : _border, width: selected ? 1.6 : 1),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(selected ? Icons.radio_button_checked : Icons.radio_button_off, color: selected ? _teal : _muted, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(color: _dark, fontSize: 14, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 2),
                  Text(description, style: const TextStyle(color: _muted, fontSize: 12, height: 1.3)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _openCancellationPolicySheet() {
    _openSheet(
      title: 'Cancellation policy',
      contentBuilder: (context, sheetSetState) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _cancellationCard(value: 'Flexible', title: 'Flexible', description: 'Full refund 1 day prior to arrival.', sheetSetState: sheetSetState),
            _cancellationCard(value: 'Moderate', title: 'Moderate', description: 'Full refund 5 days prior to arrival.', sheetSetState: sheetSetState),
            _cancellationCard(value: 'Firm', title: 'Firm', description: 'Full refund if cancelled within 48 hours of booking.', sheetSetState: sheetSetState),
          ],
        );
      },
    );
  }

  // ── Sheet: Visibility ───────────────────────────────────────

  Widget _visibilityCard({required String value, required String title, required String description, required IconData icon, required StateSetter sheetSetState}) {
    final selected = _visibility == value;
    return GestureDetector(
      onTap: () => sheetSetState(() => setState(() => _visibility = value)),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: selected ? _tealTint : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: selected ? _teal : _border, width: selected ? 1.6 : 1),
        ),
        child: Row(
          children: [
            Icon(icon, color: selected ? _teal : _muted, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(color: _dark, fontSize: 14, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 2),
                  Text(description, style: const TextStyle(color: _muted, fontSize: 12, height: 1.3)),
                ],
              ),
            ),
            Icon(selected ? Icons.radio_button_checked : Icons.radio_button_off, color: selected ? _teal : _muted, size: 20),
          ],
        ),
      ),
    );
  }

  void _openVisibilitySheet() {
    _openSheet(
      title: 'Visibility',
      contentBuilder: (context, sheetSetState) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Note: pausing a listing from Manage Listing also unlists it, and resuming lists it again — this setting is here for finer control alongside that.',
              style: TextStyle(color: _muted, fontSize: 11, height: 1.3),
            ),
            const SizedBox(height: 12),
            _visibilityCard(
              value: 'listed',
              title: 'Listed',
              description: 'Visible to guests in search results.',
              icon: Icons.visibility_outlined,
              sheetSetState: sheetSetState,
            ),
            _visibilityCard(
              value: 'unlisted',
              title: 'Unlisted',
              description: 'Hidden from search — only reachable via direct link.',
              icon: Icons.visibility_off_outlined,
              sheetSetState: sheetSetState,
            ),
          ],
        );
      },
    );
  }

  // ── Rows ─────────────────────────────────────────────────

  Widget _settingsRow({required IconData icon, required String title, required VoidCallback onTap}) {
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
              decoration: BoxDecoration(color: _tealTint, shape: BoxShape.circle),
              child: Icon(icon, size: 24, color: _teal),
            ),
            const SizedBox(width: 14),
            Expanded(child: Text(title, style: const TextStyle(color: _dark, fontSize: 16, fontWeight: FontWeight.w500))),
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
    return Scaffold(
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

          return Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
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
                            _settingsRow(icon: Icons.policy_outlined, title: 'Cancellation policy', onTap: _openCancellationPolicySheet),
                            _settingsRow(icon: Icons.visibility_outlined, title: 'Visibility', onTap: _openVisibilitySheet),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.fromLTRB(35, 24, 35, 30),
                decoration: const BoxDecoration(color: _cream, border: Border(top: BorderSide(color: _border))),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isSaving ? null : _save,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _teal,
                      disabledBackgroundColor: _teal.withValues(alpha: 0.4),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: _isSaving
                        ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                        : const Text('Save Changes', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w400, fontSize: 18)),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}