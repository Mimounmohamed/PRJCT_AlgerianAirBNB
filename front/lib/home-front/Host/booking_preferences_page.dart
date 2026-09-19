import 'package:flutter/material.dart';
import '../../authentication-front/widgets/app_bar.dart'; // adjust path to match your project structure
import '../../services/host_service.dart'; // adjust path to match your project structure

/// Returned to the caller (ListingSettingsPage) after a successful save,
/// so it can keep its own in-memory copy of these fields in sync without
/// re-fetching the whole listing.
class BookingPreferencesResult {
  final bool instantBook;
  final int minStayNights;
  final int maxStayNights;
  final String checkInTimeFrom;
  final String checkInTimeTo;
  final String checkOutTimeFrom;
  final String checkOutTimeTo;
  final String checkOutTime;

  const BookingPreferencesResult({
    required this.instantBook,
    required this.minStayNights,
    required this.maxStayNights,
    required this.checkInTimeFrom,
    required this.checkInTimeTo,
    required this.checkOutTimeFrom,
    required this.checkOutTimeTo,
    this.checkOutTime = '11:00',
  });
}

/// "Booking preferences" — its own full page (pushed from Listing
/// Settings), not a bottom sheet. Edits instantBook, minStayNights,
/// maxStayNights, checkInTimeFrom/To, checkOutTimeFrom/To. advanceNoticeHours
/// is no longer editable here but is still sent back unchanged on save
/// so the field isn't wiped by the backend's shallow-merge PUT.
class BookingPreferencesPage extends StatefulWidget {
  final String authToken;
  final String listingId;
  final bool instantBook;
  final int advanceNoticeHours;
  final int minStayNights;
  final int maxStayNights;
  final String checkInTimeFrom;
  final String checkInTimeTo;
  final String checkOutTimeFrom;
  final String checkOutTimeTo;
  final String checkOutTime;

  const BookingPreferencesPage({
    super.key,
    required this.authToken,
    required this.listingId,
    required this.instantBook,
    required this.advanceNoticeHours,
    required this.minStayNights,
    required this.maxStayNights,
    required this.checkInTimeFrom,
    required this.checkInTimeTo,
    this.checkOutTimeFrom = '11:00',
    this.checkOutTimeTo = '12:00',
    this.checkOutTime = '11:00',
  });

  @override
  State<BookingPreferencesPage> createState() => _BookingPreferencesPageState();
}

class _BookingPreferencesPageState extends State<BookingPreferencesPage> {
  static const Color _cream = Color(0xFFFBF3E7);
  static const Color _dark = Color(0xFF2A1B12);
  static const Color _teal = Color(0xFF006972);
  static const Color _tealTint = Color(0xFFE3F0F1);
  static const Color _muted = Color(0xFF4F4540);
  static const Color _border = Color(0xFFE7DCCB);

  late bool _instantBook;
  late int _minStayNights;
  late int _maxStayNights;
  late String _checkInTimeFrom;
  late String _checkInTimeTo;
  late String _checkOutTimeFrom;
  late String _checkOutTimeTo;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _instantBook = widget.instantBook;
    _minStayNights = widget.minStayNights;
    _maxStayNights = widget.maxStayNights;
    _checkInTimeFrom = widget.checkInTimeFrom;
    _checkInTimeTo = widget.checkInTimeTo;
    _checkOutTimeFrom = widget.checkOutTimeFrom.isNotEmpty ? widget.checkOutTimeFrom : widget.checkOutTime;
    _checkOutTimeTo = widget.checkOutTimeTo.isNotEmpty ? widget.checkOutTimeTo : '12:00';
  }

  // ── Time helpers ─────────────────────────────────────────

  TimeOfDay _parseTime(String value) {
    final parts = value.split(':');
    return TimeOfDay(hour: int.tryParse(parts[0]) ?? 0, minute: int.tryParse(parts.length > 1 ? parts[1] : '0') ?? 0);
  }

  String _fmtTime(TimeOfDay t) => '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';

  // ── Save ─────────────────────────────────────────────────

  Future<void> _save() async {
    setState(() => _isSaving = true);
    try {
      await HostService.updateListingDetails(
        authToken: widget.authToken,
        listingId: widget.listingId,
        updates: {
          'bookingPreferences': {
            'instantBook': _instantBook,
            'advanceNoticeHours': widget.advanceNoticeHours,
            'minStayNights': _minStayNights,
            'maxStayNights': _maxStayNights,
            'checkInTimeFrom': _checkInTimeFrom,
            'checkInTimeTo': _checkInTimeTo,
            'checkOutTimeFrom': _checkOutTimeFrom,
            'checkOutTimeTo': _checkOutTimeTo,
            'checkOutTime': _checkOutTimeFrom,
          },
        },
      );
      if (!mounted) return;
      await _showSavedPopup();
      if (!mounted) return;
      Navigator.of(context).pop(
        BookingPreferencesResult(
          instantBook: _instantBook,
          minStayNights: _minStayNights,
          maxStayNights: _maxStayNights,
          checkInTimeFrom: _checkInTimeFrom,
          checkInTimeTo: _checkInTimeTo,
          checkOutTimeFrom: _checkOutTimeFrom,
          checkOutTimeTo: _checkOutTimeTo,
          checkOutTime: _checkOutTimeFrom,
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

  // ── Small building blocks ─────────────────────────────────

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
                  Text('$value', style: const TextStyle(color: _dark, fontSize: 32, fontFamily: 'CormorantGaramond', fontWeight: FontWeight.w700)),
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
          child: AkriliAppBar(title: 'Booking preferences', onBack: () => Navigator.of(context).maybePop()),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
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
                          onChanged: (v) => setState(() => _instantBook = v),
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
                    onDecrement: () => setState(() {
                      if (_minStayNights > 1) _minStayNights--;
                      if (_maxStayNights < _minStayNights) _maxStayNights = _minStayNights;
                    }),
                    onIncrement: () => setState(() {
                      _minStayNights++;
                      if (_maxStayNights < _minStayNights) _maxStayNights = _minStayNights;
                    }),
                  ),
                  const SizedBox(height: 16),

                  // Maximum stay
                  _stayStepperCard(
                    label: 'MAXIMUM STAY',
                    value: _maxStayNights,
                    onDecrement: () => setState(() {
                      if (_maxStayNights > _minStayNights) _maxStayNights--;
                    }),
                    onIncrement: () => setState(() => _maxStayNights++),
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
                            if (picked != null) setState(() => _checkInTimeFrom = _fmtTime(picked));
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
                            if (picked != null) setState(() => _checkInTimeTo = _fmtTime(picked));
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Check-out window
                  const Text('CHECK-OUT WINDOW', style: TextStyle(color: _teal, fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 0.4)),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Expanded(
                        child: _timePickerField(
                          label: 'From',
                          time: _checkOutTimeFrom,
                          onTap: () async {
                            final picked = await showTimePicker(context: context, initialTime: _parseTime(_checkOutTimeFrom));
                            if (picked != null) setState(() => _checkOutTimeFrom = _fmtTime(picked));
                          },
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _timePickerField(
                          label: 'To',
                          time: _checkOutTimeTo,
                          onTap: () async {
                            final picked = await showTimePicker(context: context, initialTime: _parseTime(_checkOutTimeTo));
                            if (picked != null) setState(() => _checkOutTimeTo = _fmtTime(picked));
                          },
                        ),
                      ),
                    ],
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
                    : const Text('Save Preferences', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 16)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}