import 'package:flutter/material.dart';
import '../../authentication-front/widgets/app_bar.dart'; // adjust path to match your project structure
import '../../services/host_service.dart'; // adjust path to match your project structure

/// Returned to Listing Settings after a successful save.
class ListingVisibilityResult {
  final String visibility; // 'listed' | 'unlisted' | 'snoozed'
  final DateTime? snoozedUntil;

  const ListingVisibilityResult({required this.visibility, this.snoozedUntil});
}

/// "Listing Visibility" — its own full page (pushed from Listing
/// Settings). Three options, saved via PUT /api/listings/:id:
///   - Listed:   in search results, bookable
///   - Unlisted: hidden from search; anyone who already has it (saved,
///               in a conversation) can still open it; bookings stand
///   - Snoozed:  hidden like Unlisted until a chosen date, then the
///               backend puts it back in search by itself
///
/// Visibility only applies to a live (active) listing — for a listing
/// that's paused, pending review or rejected the options are disabled and
/// the page explains why (the backend ignores the change too).
class ListingVisibilityPage extends StatefulWidget {
  final String authToken;
  final String listingId;
  final String status; // listing status — visibility needs 'active'
  final String visibility;
  final DateTime? snoozedUntil;

  const ListingVisibilityPage({
    super.key,
    required this.authToken,
    required this.listingId,
    required this.status,
    required this.visibility,
    this.snoozedUntil,
  });

  @override
  State<ListingVisibilityPage> createState() => _ListingVisibilityPageState();
}

class _ListingVisibilityPageState extends State<ListingVisibilityPage> {
  static const Color _cream = Color(0xFFFBF3E7);
  static const Color _card = Color(0xFFFFFBF5);
  static const Color _dark = Color(0xFF2A1B12);
  static const Color _teal = Color(0xFF006972);
  static const Color _tealTint = Color(0xFFE3F0F1);
  static const Color _muted = Color(0xFF4F4540);
  static const Color _border = Color(0xFFE7DCCB);

  static const List<String> _months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
  ];
  static const int _maxSnoozeDays = 365; // same limit as the backend

  late String _selected;
  DateTime? _snoozeEnd; // date the listing comes back (local, start of day)
  bool _isSaving = false;

  bool get _isLive => widget.status == 'active';

  DateTime get _tomorrow {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day + 1);
  }

  @override
  void initState() {
    super.initState();
    // An expired snooze is effectively "listed" already.
    final snoozeStillOn = widget.visibility == 'snoozed' &&
        widget.snoozedUntil != null &&
        widget.snoozedUntil!.isAfter(DateTime.now());
    _selected = widget.visibility == 'snoozed' && !snoozeStillOn ? 'listed' : widget.visibility;
    _snoozeEnd = snoozeStillOn
        ? DateTime(widget.snoozedUntil!.year, widget.snoozedUntil!.month, widget.snoozedUntil!.day)
        : null;
  }

  String _formatDate(DateTime d) => '${_months[d.month - 1]} ${d.day}, ${d.year}';

  String get _notLiveExplanation {
    switch (widget.status) {
      case 'pending_review':
        return "Your listing is waiting for the AKRILI team's review, so it isn't in search results yet. "
            "Visibility can be changed once it's approved and live.";
      case 'inactive':
        return "Your listing is paused, so it's hidden from search. Resume it from Manage Listing first — "
            "visibility can be changed once it's live again.";
      case 'rejected':
        return "Your listing wasn't approved, so it can't appear in search. Visibility can be changed once it's live.";
      default:
        return "Your listing isn't live yet. Visibility can be changed once it is.";
    }
  }

  Future<void> _pickSnoozeEnd() async {
    final firstDate = _tomorrow;
    final picked = await showDatePicker(
      context: context,
      initialDate: _snoozeEnd ?? DateTime(firstDate.year, firstDate.month, firstDate.day + 6),
      firstDate: firstDate,
      lastDate: DateTime(firstDate.year, firstDate.month, firstDate.day + _maxSnoozeDays - 1),
      helpText: 'RE-LIST ON',
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: Theme.of(context).colorScheme.copyWith(primary: _teal, onPrimary: Colors.white),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      setState(() {
        _snoozeEnd = DateTime(picked.year, picked.month, picked.day);
        _selected = 'snoozed';
      });
    }
  }

  Future<void> _selectOption(String value) async {
    if (!_isLive) return;
    setState(() => _selected = value);
    if (value == 'snoozed' && _snoozeEnd == null) await _pickSnoozeEnd();
  }

  Future<void> _save() async {
    if (_selected == 'snoozed' && _snoozeEnd == null) {
      await _pickSnoozeEnd();
      if (_snoozeEnd == null) return;
    }

    if (!mounted) return;
    final unchanged = _selected == widget.visibility &&
        (_selected != 'snoozed' || _snoozeEnd == widget.snoozedUntil);
    if (unchanged) {
      Navigator.of(context).pop();
      return;
    }

    setState(() => _isSaving = true);
    try {
      await HostService.updateListingDetails(
        authToken: widget.authToken,
        listingId: widget.listingId,
        updates: {
          'visibility': _selected,
          if (_selected == 'snoozed') 'snoozedUntil': _snoozeEnd!.toUtc().toIso8601String(),
        },
      );
      if (!mounted) return;
      await _showSavedPopup();
      if (!mounted) return;
      Navigator.of(context).pop(
        ListingVisibilityResult(visibility: _selected, snoozedUntil: _selected == 'snoozed' ? _snoozeEnd : null),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))));
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
          if (dialogContext.mounted && Navigator.of(dialogContext).canPop()) Navigator.of(dialogContext).pop();
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
                const Text('Visibility updated', style: TextStyle(color: _dark, fontSize: 16, fontWeight: FontWeight.w700)),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _optionCard({required String value, required String title, required String description, Widget? extra}) {
    final selected = _selected == value;
    return GestureDetector(
      onTap: _isLive ? () => _selectOption(value) : null,
      child: Opacity(
        opacity: _isLive ? 1 : 0.5,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          margin: const EdgeInsets.only(bottom: 14),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: selected ? _tealTint : _card,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: selected ? _teal : _border, width: selected ? 1.6 : 1),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 2),
                child: Icon(
                  selected ? Icons.radio_button_checked : Icons.radio_button_off,
                  color: selected ? _teal : _border,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: const TextStyle(color: _dark, fontSize: 17, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 4),
                    Text(description, style: const TextStyle(color: _muted, fontSize: 13, height: 1.4)),
                    ?extra,
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _snoozeDateRow() {
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: GestureDetector(
        onTap: _isLive ? _pickSnoozeEnd : null,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: _border),
          ),
          child: Row(
            children: [
              const Icon(Icons.event_outlined, size: 18, color: _teal),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  _snoozeEnd == null ? 'Choose when it comes back' : 'Back in search on ${_formatDate(_snoozeEnd!)}',
                  style: const TextStyle(color: _dark, fontSize: 13, fontWeight: FontWeight.w600),
                ),
              ),
              const Text('Change', style: TextStyle(color: _teal, fontSize: 12, fontWeight: FontWeight.w700)),
            ],
          ),
        ),
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
          child: AkriliAppBar(title: 'AKRILI', onBack: () => Navigator.of(context).maybePop()),
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
                  const Text(
                    'Listing Visibility',
                    style: TextStyle(color: _dark, fontSize: 28, fontFamily: 'CormorantGaramond', fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Control how guests discover your Algerian sanctuary. Changes reflect immediately in search results.',
                    style: TextStyle(color: _muted, fontSize: 13, height: 1.4),
                  ),
                  const SizedBox(height: 20),

                  if (!_isLive) ...[
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(14),
                      margin: const EdgeInsets.only(bottom: 14),
                      decoration: BoxDecoration(color: _border, borderRadius: BorderRadius.circular(14)),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.lock_outline, size: 18, color: _dark),
                          const SizedBox(width: 10),
                          Expanded(child: Text(_notLiveExplanation, style: const TextStyle(color: _dark, fontSize: 12, height: 1.4))),
                        ],
                      ),
                    ),
                  ],

                  _optionCard(
                    value: 'listed',
                    title: 'Listed',
                    description: 'Publicly visible to all travelers. Your home will appear in search results and can be booked normally.',
                  ),
                  _optionCard(
                    value: 'unlisted',
                    title: 'Unlisted',
                    description: 'Hidden from search results. Only travelers who already have the listing can view it. Confirmed bookings remain active.',
                  ),
                  _optionCard(
                    value: 'snoozed',
                    title: 'Snoozed',
                    description: 'Temporarily hidden for a specific period. Great for maintenance or personal travel. It will automatically re-list after the end date.',
                    extra: _selected == 'snoozed' ? _snoozeDateRow() : null,
                  ),
                  const SizedBox(height: 6),

                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: _tealTint,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: _teal.withValues(alpha: 0.15)),
                    ),
                    child: const Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.info_outline, size: 18, color: _teal),
                        SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'Guests with existing reservations or those currently messaging you will still be able to find your listing during unlisted or snoozed periods.',
                            style: TextStyle(color: _teal, fontSize: 12, height: 1.4),
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
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
            color: _cream,
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: (_isSaving || !_isLive) ? null : _save,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _teal,
                  disabledBackgroundColor: _teal.withValues(alpha: 0.4),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: _isSaving
                    ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text('Update Visibility', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 16)),
                          SizedBox(width: 8),
                          Icon(Icons.check_circle, color: Colors.white, size: 18),
                        ],
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
