import 'package:flutter/material.dart';
import '../../authentication-front/widgets/app_bar.dart'; // adjust path to match your project structure
import '../../services/host_service.dart'; // adjust path to match your project structure
import '../../models/host_listing_detail_model.dart'; // adjust path to match your project structure

/// "Listing Settings" — reached from Manage Listing's "Listing settings"
/// quick action. Groups five real, backend-backed settings:
/// bookingPreferences, checkInInstructions, houseRules,
/// cancellationPolicy, and visibility — each opens in a bottom sheet
/// (same technique as Edit Listing Details' amenities sheet), and one
/// "Save Changes" button commits everything in a single PUT.
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
  late String _checkOutTime;

  late String? _checkInInstructions;

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
      _checkOutTime = listing.checkOutTime;

      _checkInInstructions = listing.checkInInstructions;

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

  // ── Time helpers ─────────────────────────────────────────

  TimeOfDay _parseTime(String value) {
    final parts = value.split(':');
    return TimeOfDay(hour: int.tryParse(parts[0]) ?? 0, minute: int.tryParse(parts.length > 1 ? parts[1] : '0') ?? 0);
  }

  String _fmtTime(TimeOfDay t) => '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';

  TimeOfDay? _parseCurfewStart(String? curfewTime) {
    if (curfewTime == null || !curfewTime.contains(' - ')) return null;
    return _parseTime(curfewTime.split(' - ')[0]);
  }

  TimeOfDay? _parseCurfewEnd(String? curfewTime) {
    if (curfewTime == null || !curfewTime.contains(' - ')) return null;
    return _parseTime(curfewTime.split(' - ')[1]);
  }

  // ── Save (whole page) ─────────────────────────────────────

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
            'checkOutTime': _checkOutTime,
          },
          if (_checkInInstructions != null) 'checkInInstructions': _checkInInstructions,
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

  // ── Save (booking preferences sheet only) ─────────────────

  Future<void> _saveBookingPreferences(BuildContext sheetContext) async {
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
            'checkOutTime': _checkOutTime,
          },
        },
      );
      if (!mounted) return;
      Navigator.of(sheetContext).pop();
      await _showSavedPopup();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e')));
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

  // ── Shared bottom-sheet chrome (used by every sheet except Booking Preferences) ──

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

  // ── Shared toggle row (same pattern as create_listing_review_page.dart) ──

  Widget _toggleRow({
    required IconData icon,
    required String title,
    String? subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
    bool showDivider = true,
  }) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, size: 20, color: _dark),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: const TextStyle(color: _dark, fontSize: 14, fontWeight: FontWeight.w600)),
                    if (subtitle != null) ...[
                      const SizedBox(height: 2),
                      Text(subtitle, style: const TextStyle(color: _muted, fontSize: 12, height: 1.3)),
                    ],
                  ],
                ),
              ),
              Switch(
                value: value,
                onChanged: onChanged,
                activeColor: Colors.white,
                activeTrackColor: _teal,
                inactiveTrackColor: _border,
              ),
            ],
          ),
        ),
        if (showDivider) const Divider(height: 1, color: _border),
      ],
    );
  }

  Widget _timePickerField({required String label, required String time, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: _border)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(color: _muted, fontSize: 10, fontWeight: FontWeight.w700)),
            const SizedBox(height: 2),
            Text(time, style: const TextStyle(color: _dark, fontSize: 15, fontWeight: FontWeight.w700)),
          ],
        ),
      ),
    );
  }

  // ── Stepper card + button (Minimum/Maximum Stay in Booking Preferences) ──

  Widget _stayStepperCard({
    required String label,
    required int value,
    required VoidCallback onDecrement,
    required VoidCallback onIncrement,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: _border)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(color: _muted, fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 0.4)),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _stepperButton(icon: Icons.remove, onTap: onDecrement),
              Column(
                children: [
                  Text('$value', style: const TextStyle(color: _dark, fontSize: 20, fontFamily: 'CormorantGaramond', fontWeight: FontWeight.w700)),
                  const SizedBox(height: 2),
                  const Text('NIGHTS', style: TextStyle(color: _muted, fontSize: 10, fontWeight: FontWeight.w700, letterSpacing: 0.6)),
                ],
              ),
              _stepperButton(icon: Icons.add, onTap: onIncrement),
            ],
          ),
        ],
      ),
    );
  }

  Widget _stepperButton({required IconData icon, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: _border), color: Colors.white),
        child: Icon(icon, size: 18, color: _teal),
      ),
    );
  }

  // ── Sheet: Booking preferences (custom full-height layout, matches design) ──

  void _openBookingPreferencesSheet() {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return DraggableScrollableSheet(
          initialChildSize: 0.92,
          minChildSize: 0.5,
          maxChildSize: 0.96,
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
                        padding: const EdgeInsets.fromLTRB(4, 10, 20, 10),
                        child: Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.arrow_back, color: _dark),
                              onPressed: () => Navigator.of(sheetContext).pop(),
                            ),
                            const SizedBox(width: 2),
                            const Text(
                              'Booking preferences',
                              style: TextStyle(color: _dark, fontSize: 24, fontFamily: 'CormorantGaramond', fontWeight: FontWeight.w700),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: SingleChildScrollView(
                          controller: scrollController,
                          padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Instant Book
                              Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: _border)),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          const Text('Instant Book', style: TextStyle(color: _dark, fontSize: 15, fontWeight: FontWeight.w700)),
                                          const SizedBox(height: 4),
                                          Text(
                                            _instantBook
                                                ? 'Guests can book your place instantly without sending a request. This usually increases your booking rate.'
                                                : 'Guests must send a request before booking your place.',
                                            style: const TextStyle(color: _muted, fontSize: 12, height: 1.35),
                                          ),
                                          const SizedBox(height: 6),
                                          const Text(
                                            'Any change you make here needs admin approval before it goes live — once approved, your listing keeps its Verified badge.',
                                            style: TextStyle(color: _teal, fontSize: 11, height: 1.3, fontWeight: FontWeight.w600),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Switch(
                                      value: _instantBook,
                                      onChanged: (v) => sheetSetState(() => setState(() => _instantBook = v)),
                                      activeColor: Colors.white,
                                      activeTrackColor: _teal,
                                      inactiveTrackColor: _border,
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 16),

                              // Minimum stay
                              _stayStepperCard(
                                label: 'MINIMUM STAY',
                                value: _minStayNights,
                                onDecrement: () => sheetSetState(() => setState(() {
                                      if (_minStayNights > 1) _minStayNights--;
                                      if (_maxStayNights < _minStayNights) _maxStayNights = _minStayNights;
                                    })),
                                onIncrement: () => sheetSetState(() => setState(() {
                                      _minStayNights++;
                                      if (_maxStayNights < _minStayNights) _maxStayNights = _minStayNights;
                                    })),
                              ),
                              const SizedBox(height: 16),

                              // Maximum stay
                              _stayStepperCard(
                                label: 'MAXIMUM STAY',
                                value: _maxStayNights,
                                onDecrement: () => sheetSetState(() => setState(() {
                                      if (_maxStayNights > _minStayNights) _maxStayNights--;
                                    })),
                                onIncrement: () => sheetSetState(() => setState(() {
                                      _maxStayNights++;
                                    })),
                              ),
                              const SizedBox(height: 16),

                              // Check-in window
                              const Text('CHECK-IN WINDOW', style: TextStyle(color: _teal, fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 0.4)),
                              const SizedBox(height: 6),
                              Row(
                                children: [
                                  Expanded(
                                    child: _timePickerField(
                                      label: 'From',
                                      time: _checkInTimeFrom,
                                      onTap: () async {
                                        final picked = await showTimePicker(context: context, initialTime: _parseTime(_checkInTimeFrom));
                                        if (picked != null) sheetSetState(() => setState(() => _checkInTimeFrom = _fmtTime(picked)));
                                      },
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: _timePickerField(
                                      label: 'To',
                                      time: _checkInTimeTo,
                                      onTap: () async {
                                        final picked = await showTimePicker(context: context, initialTime: _parseTime(_checkInTimeTo));
                                        if (picked != null) sheetSetState(() => setState(() => _checkInTimeTo = _fmtTime(picked)));
                                      },
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),

                              // Check-out time
                              const Text('CHECK-OUT TIME', style: TextStyle(color: _teal, fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 0.4)),
                              const SizedBox(height: 6),
                              _timePickerField(
                                label: 'Check-out',
                                time: _checkOutTime,
                                onTap: () async {
                                  final picked = await showTimePicker(context: context, initialTime: _parseTime(_checkOutTime));
                                  if (picked != null) sheetSetState(() => setState(() => _checkOutTime = _fmtTime(picked)));
                                },
                              ),
                              const SizedBox(height: 20),

                              // Info note
                              Container(
                                padding: const EdgeInsets.all(14),
                                decoration: BoxDecoration(color: _tealTint, borderRadius: BorderRadius.circular(14)),
                                child: const Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Icon(Icons.info_outline, size: 18, color: _teal),
                                    SizedBox(width: 10),
                                    Expanded(
                                      child: Text(
                                        'Setting a minimum stay of 2-3 nights can help reduce cleaning costs and turn-over frequency in your Algerian home.',
                                        style: TextStyle(color: _dark, fontSize: 12, height: 1.35),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 24),

                              // Save
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  onPressed: () => _saveBookingPreferences(sheetContext),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: _teal,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                                    padding: const EdgeInsets.symmetric(vertical: 16),
                                  ),
                                  child: const Text('Save Preferences', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 16)),
                                ),
                              ),
                            ],
                          ),
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

  // ── Sheet: Check-in instructions ──────────────────────────

  void _openCheckInInstructionsSheet() {
    final controller = TextEditingController(text: _checkInInstructions ?? '');
    _openSheet(
      title: 'Check-in instructions',
      contentBuilder: (context, sheetSetState) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Tell guests how to get in — key lockbox code, doorman, building access, etc.',
              style: TextStyle(color: _muted, fontSize: 12, height: 1.3),
            ),
            const SizedBox(height: 12),
            Container(
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), border: Border.all(color: _border)),
              padding: const EdgeInsets.symmetric(horizontal: 14),
              child: TextField(
                controller: controller,
                maxLines: 6,
                minLines: 4,
                onChanged: (v) => setState(() => _checkInInstructions = v),
                style: const TextStyle(color: _dark, fontSize: 14, height: 1.4),
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  isDense: true,
                  contentPadding: EdgeInsets.symmetric(vertical: 14),
                  hintText: 'e.g. The key is in a lockbox by the door, code 4821...',
                  hintStyle: TextStyle(color: _muted),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  // ── Sheet: House rules ─────────────────────────────────────

  void _openHouseRulesSheet() {
    final rulesController = TextEditingController(text: _additionalRules ?? '');
    _openSheet(
      title: 'House rules',
      contentBuilder: (context, sheetSetState) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _toggleRow(
              icon: Icons.pets_outlined,
              title: 'Pets allowed',
              value: _petsAllowed,
              onChanged: (v) => sheetSetState(() => setState(() => _petsAllowed = v)),
            ),
            _toggleRow(
              icon: Icons.smoking_rooms_outlined,
              title: 'Smoking allowed',
              value: _smokingAllowed,
              onChanged: (v) => sheetSetState(() => setState(() => _smokingAllowed = v)),
            ),
            _toggleRow(
              icon: Icons.celebration_outlined,
              title: 'Events allowed',
              value: _eventsAllowed,
              onChanged: (v) => sheetSetState(() => setState(() => _eventsAllowed = v)),
            ),
            _toggleRow(
              icon: Icons.no_adult_content,
              title: 'Adults only',
              value: _adultOnly,
              onChanged: (v) => sheetSetState(() => setState(() => _adultOnly = v)),
            ),
            _toggleRow(
              icon: Icons.family_restroom_outlined,
              title: 'Family booklet required',
              subtitle: 'Only married couples can book without providing a family booklet.',
              value: _familyBookletRequired,
              onChanged: (v) => sheetSetState(() => setState(() => _familyBookletRequired = v)),
              showDivider: false,
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.nightlight_outlined, size: 20, color: _dark),
                const SizedBox(width: 12),
                const Expanded(child: Text('Quiet hours', style: TextStyle(color: _dark, fontSize: 14, fontWeight: FontWeight.w600))),
                Switch(
                  value: _curfew,
                  activeColor: Colors.white,
                  activeTrackColor: _teal,
                  inactiveTrackColor: _border,
                  onChanged: (v) => sheetSetState(() => setState(() {
                    _curfew = v;
                    if (v && _curfewTime == null) _curfewTime = '22:00 - 08:00';
                  })),
                ),
              ],
            ),
            if (_curfew) ...[
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: _timePickerField(
                      label: 'From',
                      time: _parseCurfewStart(_curfewTime)?.let(_fmtTime) ?? '22:00',
                      onTap: () async {
                        final start = _parseCurfewStart(_curfewTime) ?? const TimeOfDay(hour: 22, minute: 0);
                        final picked = await showTimePicker(context: context, initialTime: start);
                        if (picked != null) {
                          final end = _parseCurfewEnd(_curfewTime) ?? const TimeOfDay(hour: 8, minute: 0);
                          sheetSetState(() => setState(() => _curfewTime = '${_fmtTime(picked)} - ${_fmtTime(end)}'));
                        }
                      },
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _timePickerField(
                      label: 'To',
                      time: _parseCurfewEnd(_curfewTime)?.let(_fmtTime) ?? '08:00',
                      onTap: () async {
                        final end = _parseCurfewEnd(_curfewTime) ?? const TimeOfDay(hour: 8, minute: 0);
                        final picked = await showTimePicker(context: context, initialTime: end);
                        if (picked != null) {
                          final start = _parseCurfewStart(_curfewTime) ?? const TimeOfDay(hour: 22, minute: 0);
                          sheetSetState(() => setState(() => _curfewTime = '${_fmtTime(start)} - ${_fmtTime(picked)}'));
                        }
                      },
                    ),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 20),
            const Text('ADDITIONAL RULES', style: TextStyle(color: _teal, fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 0.4)),
            const SizedBox(height: 6),
            Container(
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), border: Border.all(color: _border)),
              padding: const EdgeInsets.symmetric(horizontal: 14),
              child: TextField(
                controller: rulesController,
                maxLines: 4,
                minLines: 2,
                onChanged: (v) => setState(() => _additionalRules = v),
                style: const TextStyle(color: _dark, fontSize: 14, height: 1.4),
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  isDense: true,
                  contentPadding: EdgeInsets.symmetric(vertical: 14),
                  hintText: 'Anything else guests should know...',
                  hintStyle: TextStyle(color: _muted),
                ),
              ),
            ),
          ],
        );
      },
    );
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
                            _settingsRow(icon: Icons.event_available_outlined, title: 'Booking preferences', onTap: _openBookingPreferencesSheet),
                            _settingsRow(icon: Icons.vpn_key_outlined, title: 'Check-in instructions', onTap: _openCheckInInstructionsSheet),
                            _settingsRow(icon: Icons.rule_outlined, title: 'House rules', onTap: _openHouseRulesSheet),
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

/// Tiny convenience extension so `x?.let(fn)` reads like a null-safe
/// map — used only for formatting a nullable TimeOfDay above.
extension _Let<T> on T {
  R let<R>(R Function(T) fn) => fn(this);
}