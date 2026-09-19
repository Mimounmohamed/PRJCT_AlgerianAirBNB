import 'package:flutter/material.dart';
import '../../authentication-front/widgets/app_bar.dart'; // adjust path to match your project structure
import '../../services/host_service.dart'; // adjust path to match your project structure

/// Returned to the caller (ListingSettingsPage) after a successful save,
/// so it can keep its own in-memory copy of these fields in sync without
/// re-fetching the whole listing.
class HouseRulesResult {
  final bool petsAllowed;
  final bool smokingAllowed;
  final bool eventsAllowed;
  final bool curfew;
  final String? curfewTime;
  final String? additionalRules;

  const HouseRulesResult({
    required this.petsAllowed,
    required this.smokingAllowed,
    required this.eventsAllowed,
    required this.curfew,
    required this.curfewTime,
    required this.additionalRules,
  });
}

/// "House rules" — its own full page (pushed from Listing Settings),
/// not a bottom sheet. Edits petsAllowed, smokingAllowed, eventsAllowed,
/// curfew/curfewTime, and additionalRules.
///
/// adultOnly and familyBookletRequired have no UI control on this page
/// (per the current design) but are still accepted and sent back on
/// save unchanged, so the backend's shallow-merge PUT on houseRules
/// doesn't silently wipe them.
class HouseRulesPage extends StatefulWidget {
  final String authToken;
  final String listingId;
  final bool petsAllowed;
  final bool smokingAllowed;
  final bool eventsAllowed;
  final bool adultOnly;
  final bool familyBookletRequired;
  final bool curfew;
  final String? curfewTime;
  final String? additionalRules;

  /// Best-effort photo urls for the decorative pair at the bottom of the
  /// page (e.g. the listing's cover photo + one more). Pass however many
  /// you have (0, 1, or 2) — missing slots fall back to a placeholder tile.
  final List<String> photoUrls;

  const HouseRulesPage({
    super.key,
    required this.authToken,
    required this.listingId,
    required this.petsAllowed,
    required this.smokingAllowed,
    required this.eventsAllowed,
    required this.adultOnly,
    required this.familyBookletRequired,
    required this.curfew,
    required this.curfewTime,
    required this.additionalRules,
    this.photoUrls = const [],
  });

  @override
  State<HouseRulesPage> createState() => _HouseRulesPageState();
}

class _HouseRulesPageState extends State<HouseRulesPage> {
  static const Color _cream = Color(0xFFFBF3E7);
  static const Color _dark = Color(0xFF2A1B12);
  static const Color _teal = Color(0xFF006972);
  static const Color _tealTint = Color(0xFFE3F0F1);
  static const Color _muted = Color(0xFF4F4540);
  static const Color _border = Color(0xFFE7DCCB);

  late bool _petsAllowed;
  late bool _smokingAllowed;
  late bool _eventsAllowed;
  late bool _curfew;
  late String? _curfewTime;
  late TextEditingController _rulesController;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _petsAllowed = widget.petsAllowed;
    _smokingAllowed = widget.smokingAllowed;
    _eventsAllowed = widget.eventsAllowed;
    _curfew = widget.curfew;
    _curfewTime = widget.curfewTime;
    _rulesController = TextEditingController(text: widget.additionalRules ?? '');
  }

  @override
  void dispose() {
    _rulesController.dispose();
    super.dispose();
  }

  // ── Time helpers ─────────────────────────────────────────

  TimeOfDay _parseTime(String value) {
    final parts = value.split(':');
    return TimeOfDay(hour: int.tryParse(parts[0]) ?? 0, minute: int.tryParse(parts.length > 1 ? parts[1] : '0') ?? 0);
  }

  String _fmt24(TimeOfDay t) => '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';

  TimeOfDay? _curfewStart(String? curfewTime) {
    if (curfewTime == null || !curfewTime.contains(' - ')) return null;
    return _parseTime(curfewTime.split(' - ')[0]);
  }

  TimeOfDay? _curfewEnd(String? curfewTime) {
    if (curfewTime == null || !curfewTime.contains(' - ')) return null;
    return _parseTime(curfewTime.split(' - ')[1]);
  }

  /// Compact 12-hour label with no minutes shown when :00, e.g. "10PM", "7AM".
  String _fmt12(TimeOfDay t) {
    final period = t.hour >= 12 ? 'PM' : 'AM';
    var hour = t.hour % 12;
    if (hour == 0) hour = 12;
    return t.minute == 0 ? '$hour$period' : '$hour:${t.minute.toString().padLeft(2, '0')}$period';
  }

  String get _quietHoursLabel {
    final start = _curfewStart(_curfewTime);
    final end = _curfewEnd(_curfewTime);
    if (start == null || end == null) return 'Quiet hours';
    return 'Quiet hours (${_fmt12(start)} - ${_fmt12(end)})';
  }

  /// The "Quiet hours" popup dialog: its own Enable toggle + From/To time
  /// fields + Cancel/Save, all scoped to the dialog until Save is tapped.
  Future<void> _openQuietHoursDialog() async {
    bool dialogCurfew = _curfew;
    TimeOfDay dialogStart = _curfewStart(_curfewTime) ?? const TimeOfDay(hour: 22, minute: 0);
    TimeOfDay dialogEnd = _curfewEnd(_curfewTime) ?? const TimeOfDay(hour: 8, minute: 0);

    await showDialog<void>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.45),
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, dialogSetState) {
            Widget timeBox({required String label, required TimeOfDay time, required VoidCallback onTap}) {
              return Expanded(
                child: GestureDetector(
                  onTap: onTap,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), border: Border.all(color: _border)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(label, style: const TextStyle(color: _muted, fontSize: 11, fontWeight: FontWeight.w600)),
                        const SizedBox(height: 4),
                        Text(_fmt24(time), style: const TextStyle(color: _dark, fontSize: 16, fontWeight: FontWeight.w700)),
                      ],
                    ),
                  ),
                ),
              );
            }

            return Dialog(
              backgroundColor: _cream,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
              insetPadding: const EdgeInsets.symmetric(horizontal: 24),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 22, 20, 18),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Quiet hours', style: TextStyle(color: _dark, fontSize: 19, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 6),
                    const Text(
                      'Ask guests to keep noise down during these hours.',
                      style: TextStyle(color: _muted, fontSize: 13, height: 1.35),
                    ),
                    const SizedBox(height: 18),
                    Row(
                      children: [
                        const Expanded(
                          child: Text('Enable quiet hours', style: TextStyle(color: _dark, fontSize: 14, fontWeight: FontWeight.w600)),
                        ),
                        Switch(
                          value: dialogCurfew,
                          onChanged: (v) => dialogSetState(() => dialogCurfew = v),
                          activeColor: Colors.white,
                          activeTrackColor: _teal,
                          inactiveTrackColor: _border,
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        timeBox(
                          label: 'From',
                          time: dialogStart,
                          onTap: () async {
                            final picked = await showTimePicker(context: context, initialTime: dialogStart);
                            if (picked != null) dialogSetState(() => dialogStart = picked);
                          },
                        ),
                        const SizedBox(width: 12),
                        timeBox(
                          label: 'To',
                          time: dialogEnd,
                          onTap: () async {
                            final picked = await showTimePicker(context: context, initialTime: dialogEnd);
                            if (picked != null) dialogSetState(() => dialogEnd = picked);
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () => Navigator.of(dialogContext).pop(),
                          child: const Text('Cancel', style: TextStyle(color: _muted, fontWeight: FontWeight.w600)),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton(
                          onPressed: () {
                            setState(() {
                              _curfew = dialogCurfew;
                              _curfewTime = '${_fmt24(dialogStart)} - ${_fmt24(dialogEnd)}';
                            });
                            Navigator.of(dialogContext).pop();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _teal,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                          ),
                          child: const Text('Save', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  // ── Save ─────────────────────────────────────────────────

  Future<void> _save() async {
    setState(() => _isSaving = true);
    try {
      await HostService.updateListingDetails(
        authToken: widget.authToken,
        listingId: widget.listingId,
        updates: {
          'houseRules': {
            'petsAllowed': _petsAllowed,
            'smokingAllowed': _smokingAllowed,
            'eventsAllowed': _eventsAllowed,
            'adultOnly': widget.adultOnly,
            'curfew': _curfew,
            if (_curfewTime != null) 'curfewTime': _curfewTime,
            'additionalRules': _rulesController.text,
            'familyBookletRequired': widget.familyBookletRequired,
          },
        },
      );
      if (!mounted) return;
      await _showSavedPopup();
      if (!mounted) return;
      Navigator.of(context).pop(
        HouseRulesResult(
          petsAllowed: _petsAllowed,
          smokingAllowed: _smokingAllowed,
          eventsAllowed: _eventsAllowed,
          curfew: _curfew,
          curfewTime: _curfewTime,
          additionalRules: _rulesController.text,
        ),
      );
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

  // ── Rule card (one per rule, matches the mockup's separate cards) ────

  Widget _ruleCard({
    required IconData icon,
    required String title,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: _border)),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: const BoxDecoration(color: _tealTint, shape: BoxShape.circle),
            child: Icon(icon, size: 18, color: _teal),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(title, style: const TextStyle(color: _dark, fontSize: 14, fontWeight: FontWeight.w600)),
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
    );
  }

  /// Quiet hours gets its own row style — the whole card opens the
  /// "Quiet hours" popup dialog instead of toggling inline.
  Widget _quietHoursCard() {
    return InkWell(
      onTap: _openQuietHoursDialog,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: _border)),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: const BoxDecoration(color: _tealTint, shape: BoxShape.circle),
              child: const Icon(Icons.nightlight_outlined, size: 18, color: _teal),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Quiet hours', style: TextStyle(color: _dark, fontSize: 14, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 2),
                  Text(
                    _curfew ? _quietHoursLabel.replaceFirst('Quiet hours ', '') : 'Off',
                    style: const TextStyle(color: _muted, fontSize: 12),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, size: 18, color: _muted),
          ],
        ),
      ),
    );
  }

  Widget _photoTile(String url) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: AspectRatio(
        aspectRatio: 16 / 9,
        child: Image.network(url, fit: BoxFit.cover, width: double.infinity),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final photo1 = widget.photoUrls.isNotEmpty ? widget.photoUrls[0] : null;

    return Scaffold(
      backgroundColor: _cream,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: Container(
          decoration: BoxDecoration(
            color: _cream,
            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 8, offset: const Offset(0, 2))],
          ),
          child: AkriliAppBar(title: 'House rules', onBack: () => Navigator.of(context).maybePop()),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Set the expectations for your guests during their stay in Algeria.',
                    style: TextStyle(color: _muted, fontSize: 13, height: 1.35),
                  ),
                  const SizedBox(height: 18),

                  _ruleCard(
                    icon: Icons.pets_outlined,
                    title: 'Pets allowed',
                    value: _petsAllowed,
                    onChanged: (v) => setState(() => _petsAllowed = v),
                  ),
                  _ruleCard(
                    icon: Icons.smoking_rooms_outlined,
                    title: 'Smoking allowed',
                    value: _smokingAllowed,
                    onChanged: (v) => setState(() => _smokingAllowed = v),
                  ),
                  _ruleCard(
                    icon: Icons.celebration_outlined,
                    title: 'Events allowed',
                    value: _eventsAllowed,
                    onChanged: (v) => setState(() => _eventsAllowed = v),
                  ),
                  _quietHoursCard(),

                  const SizedBox(height: 12),
                  const Text(
                    'Additional rules',
                    style: TextStyle(
                      color: Color(0xFF3A271D),
                      fontFamily: 'CormorantGaramond',
                      fontSize: 24,
                      fontWeight: FontWeight.w600,
                      height: 1.2, // 28.8px line-height at 24px
                    ),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), border: Border.all(color: _border)),
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    child: TextField(
                      controller: _rulesController,
                      maxLines: 4,
                      minLines: 3,
                      maxLength: 500,
                      onChanged: (_) => setState(() {}),
                      style: const TextStyle(color: _dark, fontSize: 14, height: 1.4),
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        isDense: true,
                        contentPadding: const EdgeInsets.symmetric(vertical: 14),
                        hintText: 'Add anything else guests should know, like rules about footwear indoors or Casbah heritage preservation...',
                        hintStyle: const TextStyle(
                          color: Color.fromRGBO(129, 117, 111, 0.5),
                          fontFamily: 'HankenGrotesk',
                          fontSize: 15,
                          fontWeight: FontWeight.w400,
                          height: 1.5, // 22.5px line-height at 15px
                        ),
                        counterStyle: const TextStyle(color: _muted, fontSize: 11),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(color: _dark, borderRadius: BorderRadius.circular(16)),
                    child: const Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.info_outline, size: 16, color: Colors.white70),
                        SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            '"Please be mindful of the neighbors and the local cultural etiquette."',
                            style: TextStyle(color: Colors.white, fontSize: 13, height: 1.4, fontStyle: FontStyle.italic),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),

                  if (photo1 != null) ...[
                    _photoTile(photo1),
                    const SizedBox(height: 14),
                  ],

                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
                    decoration: BoxDecoration(color: _tealTint, borderRadius: BorderRadius.circular(16)),
                    child: const Text(
                      'Hospitality is our priority.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: _teal, fontSize: 14, fontWeight: FontWeight.w600),
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
                    : const Text('Save Rules', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 16)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}