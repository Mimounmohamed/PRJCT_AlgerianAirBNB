import 'package:flutter/material.dart';
import '../../authentication-front/widgets/app_bar.dart'; // adjust path to match your project structure
import '../../services/availability_service.dart'; // adjust path to match your project structure
import '../../models/availability_day_model.dart';
import 'booking_details_page.dart'; // adjust path if you placed this elsewhere

/// "Manage Calendar" — shown from the Manage Listing page's "Manage
/// calendar" quick action. The host browses month by month, selects dates
/// (tap = one day, long-press = the whole range since the last tapped
/// day; the selection survives switching months), and marks them
/// available / booked offline / blocked.
///
/// Data comes from GET /api/host/listings/:id/calendar, which merges the
/// host's own marks with REAL guest bookings. Nights taken by a guest
/// booking can't be selected or changed here (the backend refuses them
/// too) — tapping one opens its Booking Details instead.
///
/// Prices: marking days Available with a price different from the base
/// price stores it as a per-day override; the base price itself clears
/// any override, so those days follow future base-price changes.
/// Booked/Blocked leave existing overrides untouched.
///
/// Pops with `true` when anything was changed, so Manage Listing reloads.
class ManageCalendarPage extends StatefulWidget {
  final String authToken;
  final String listingId;
  final double basePricePerNight;
  final String rentalPeriod; // 'nightly' | 'monthly'

  const ManageCalendarPage({
    super.key,
    required this.authToken,
    required this.listingId,
    required this.basePricePerNight,
    this.rentalPeriod = 'nightly',
  });

  @override
  State<ManageCalendarPage> createState() => _ManageCalendarPageState();
}

class _ManageCalendarPageState extends State<ManageCalendarPage> {
  static const Color _cream = Color(0xFFFBF3E7);
  static const Color _dark = Color(0xFF2A1B12);
  static const Color _teal = Color(0xFF006972);
  static const Color _muted = Color(0xFF8A7B6E);
  static const Color _border = Color(0xFFE7DCCB);
  static const Color _guestBookedBg = Color(0xFFCFE4E6);
  static const Color _bookedBg = Color(0xFFF0DCC9);
  static const Color _blockedBg = Color(0xFFE3E0DA);

  static const List<String> _weekdayLabels = ['S', 'M', 'T', 'W', 'T', 'F', 'S'];
  static const List<String> _shortMonths = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
  ];
  static const List<String> _longMonths = [
    'January', 'February', 'March', 'April', 'May', 'June',
    'July', 'August', 'September', 'October', 'November', 'December'
  ];

  late DateTime _visibleMonth; // always the 1st of the month
  // Every loaded day so far, across months (key: yyyy-mm-dd) — kept so a
  // selection spanning several months still knows each day's state.
  final Map<String, AvailabilityDayModel> _byDate = {};
  bool _isLoading = true;
  bool _isSaving = false;
  bool _didChange = false;
  String? _error;

  final Set<DateTime> _selected = {};
  DateTime? _anchor; // last tapped day — start of a long-press range
  // 'available' | 'booked' | 'blocked' — applied to the selection on Update.
  String _pendingStatus = 'available';
  late final TextEditingController _priceController;

  bool get _isMonthly => widget.rentalPeriod == 'monthly';
  String get _unit => _isMonthly ? 'month' : 'night';

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _visibleMonth = DateTime(now.year, now.month, 1);
    _priceController = TextEditingController(text: widget.basePricePerNight.round().toString());
    _loadMonth();
  }

  @override
  void dispose() {
    _priceController.dispose();
    super.dispose();
  }

  String _key(DateTime d) => AvailabilityService.dayString(d);

  DateTime get _today {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day);
  }

  /// Days since epoch for a local calendar date — DST-safe day arithmetic.
  int _dayNumber(DateTime d) => DateTime.utc(d.year, d.month, d.day).millisecondsSinceEpoch ~/ Duration.millisecondsPerDay;

  Future<void> _loadMonth() async {
    final month = _visibleMonth;
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final days = await AvailabilityService.fetchHostMonth(
        authToken: widget.authToken,
        listingId: widget.listingId,
        month: month.month,
        year: month.year,
      );
      if (!mounted || month != _visibleMonth) return; // user already moved to another month
      setState(() {
        _byDate.removeWhere((key, d) => d.date.year == month.year && d.date.month == month.month);
        for (final d in days) {
          _byDate[_key(d.date)] = d;
        }
        // A day selected earlier that turns out to have a guest booking
        // can't be edited — drop it from the selection.
        _selected.removeWhere((d) => _byDate[_key(d)]?.hasGuestBooking ?? false);
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted || month != _visibleMonth) return;
      setState(() {
        _error = e.toString().replaceFirst('Exception: ', '');
        _isLoading = false;
      });
    }
  }

  void _changeMonth(int delta) {
    setState(() => _visibleMonth = DateTime(_visibleMonth.year, _visibleMonth.month + delta, 1));
    _loadMonth(); // selection is kept on purpose — ranges can span months
  }

  bool _isSelectable(DateTime day) {
    if (day.isBefore(_today)) return false;
    return !(_byDate[_key(day)]?.hasGuestBooking ?? false);
  }

  void _onDayTap(DateTime day) {
    final entry = _byDate[_key(day)];
    if (entry != null && entry.hasGuestBooking) {
      _openBookingDetails(day);
      return;
    }
    if (!_isSelectable(day)) return;
    setState(() {
      if (!_selected.remove(day)) _selected.add(day);
      _anchor = day;
    });
  }

  /// Long-press: select every selectable day between the last tapped day
  /// and this one (inclusive). Without an anchor it behaves like a tap.
  void _onDayLongPress(DateTime day) {
    if (!_isSelectable(day)) return;
    final anchor = _anchor;
    if (anchor == null) {
      _onDayTap(day);
      return;
    }
    final start = anchor.isBefore(day) ? anchor : day;
    final end = anchor.isBefore(day) ? day : anchor;
    setState(() {
      for (var d = start; !d.isAfter(end); d = DateTime(d.year, d.month, d.day + 1)) {
        if (_isSelectable(d)) _selected.add(d);
      }
      _anchor = day;
    });
  }

  void _clearSelection() => setState(() {
        _selected.clear();
        _anchor = null;
      });

  void _openBookingDetails(DateTime day) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => BookingDetailsPage(
          authToken: widget.authToken,
          listingId: widget.listingId,
          date: day,
        ),
      ),
    );
  }

  String _shortDate(DateTime d) {
    final label = '${_shortMonths[d.month - 1]} ${d.day}';
    return d.year == _today.year ? label : '$label, ${d.year}';
  }

  String get _selectionLabel {
    if (_selected.isEmpty) return 'No dates selected';
    final sorted = _selected.toList()..sort();
    if (sorted.length == 1) return _shortDate(sorted.first);

    var consecutive = true;
    for (var i = 1; i < sorted.length; i++) {
      if (_dayNumber(sorted[i]) - _dayNumber(sorted[i - 1]) != 1) {
        consecutive = false;
        break;
      }
    }
    final range = '${_shortDate(sorted.first)} – ${_shortDate(sorted.last)}';
    final count = sorted.length;
    return consecutive
        ? '$range · $count ${count == 1 ? 'night' : 'nights'}'
        : '$count dates between $range';
  }

  Future<void> _showResultDialog({required bool success, required String message}) {
    return showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: _cream,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: success ? _teal.withValues(alpha: 0.12) : Colors.red.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                success ? Icons.check_circle : Icons.error_outline,
                color: success ? _teal : Colors.red,
                size: 32,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              success ? 'Calendar updated' : 'Update failed',
              style: const TextStyle(color: _dark, fontSize: 17, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 6),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: _muted, fontSize: 13),
            ),
          ],
        ),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('OK', style: TextStyle(color: _teal, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }

  Future<void> _applyUpdate() async {
    if (_selected.isEmpty) return;

    double? priceOverride;
    var clearPriceOverride = false;
    if (_pendingStatus == 'available') {
      final text = _priceController.text.trim();
      final price = double.tryParse(text);
      if (text.isNotEmpty && (price == null || price <= 0)) {
        await _showResultDialog(success: false, message: 'Enter a valid price, or leave it empty to use your base price.');
        return;
      }
      // The base price (or nothing) clears custom prices, so these days
      // follow the listing's base price from now on.
      if (price == null || price.round() == widget.basePricePerNight.round()) {
        clearPriceOverride = true;
      } else {
        priceOverride = price;
      }
    }

    final dateCount = _selected.length;
    final statusLabel = _pendingStatus == 'booked' ? 'booked' : _pendingStatus;

    setState(() => _isSaving = true);
    try {
      await AvailabilityService.updateDates(
        authToken: widget.authToken,
        listingId: widget.listingId,
        dates: _selected.toList(),
        status: _pendingStatus,
        priceOverride: priceOverride,
        clearPriceOverride: clearPriceOverride,
      );
      if (!mounted) return;
      setState(() {
        _selected.clear();
        _anchor = null;
        _isSaving = false;
        _didChange = true;
      });
      await _loadMonth();
      if (!mounted) return;
      await _showResultDialog(
        success: true,
        message: '$dateCount ${dateCount == 1 ? 'date' : 'dates'} marked as $statusLabel.',
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _isSaving = false);
      await _showResultDialog(success: false, message: e.toString().replaceFirst('Exception: ', ''));
      _loadMonth(); // a 409 means the calendar changed underneath us — refresh it
    }
  }

  /// "6.5k" for thousands, plain otherwise — small price label per cell.
  String _shortPrice(double price) {
    if (price >= 1000) {
      return '${(price / 1000).toStringAsFixed(price % 1000 == 0 ? 0 : 1)}k';
    }
    return price.round().toString();
  }

  List<DateTime?> _daysGrid() {
    final daysInMonth = DateTime(_visibleMonth.year, _visibleMonth.month + 1, 0).day;
    final leadingBlanks = _visibleMonth.weekday % 7; // Sunday-first grid
    return [
      for (int i = 0; i < leadingBlanks; i++) null,
      for (int day = 1; day <= daysInMonth; day++) DateTime(_visibleMonth.year, _visibleMonth.month, day),
    ];
  }

  Widget _legendSwatch(Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(3),
            border: color == Colors.white ? Border.all(color: _border) : null,
          ),
        ),
        const SizedBox(width: 6),
        Text(label, style: const TextStyle(color: _muted, fontSize: 12)),
      ],
    );
  }

  Widget _statusPill(String value, String label) {
    final selected = _pendingStatus == value;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _pendingStatus = value),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: selected ? _teal : Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: selected ? _teal : _border),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: selected ? Colors.white : _dark,
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }

  Widget _dayCell(DateTime day) {
    final entry = _byDate[_key(day)];
    final status = entry?.status ?? 'available';
    final guestBooking = entry?.hasGuestBooking ?? false;
    final isSelected = _selected.contains(day);
    final isPast = day.isBefore(_today);

    Color bg = Colors.transparent;
    String? caption;
    if (guestBooking) {
      bg = _guestBookedBg;
      caption = entry!.bookingStatus == 'pending' ? 'Request' : 'Guest';
    } else if (status == 'booked') {
      bg = _bookedBg;
      caption = 'Booked';
    } else if (status == 'blocked') {
      bg = _blockedBg;
      caption = 'Blocked';
    }

    final price = entry?.priceOverride ?? widget.basePricePerNight;
    final hasCustomPrice = entry?.priceOverride != null;

    return GestureDetector(
      onTap: (isPast && !guestBooking) ? null : () => _onDayTap(day),
      onLongPress: _isSelectable(day) ? () => _onDayLongPress(day) : null,
      child: Container(
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: isSelected ? _teal : Colors.transparent, width: 1.5),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '${day.day}',
              style: TextStyle(
                color: isPast ? _muted.withValues(alpha: 0.5) : _dark,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            if (caption != null)
              Text(caption, style: TextStyle(color: guestBooking ? _teal : _muted, fontSize: 8, fontWeight: guestBooking ? FontWeight.w700 : FontWeight.w400))
            else if (!isPast)
              Text(
                _shortPrice(price),
                style: TextStyle(color: _teal, fontSize: 9, fontWeight: hasCustomPrice ? FontWeight.w800 : FontWeight.w400),
              ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) Navigator.of(context).pop(_didChange); // tell Manage Listing whether to reload
      },
      child: Scaffold(
        backgroundColor: _cream,
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(kToolbarHeight),
          child: Container(
            decoration: BoxDecoration(
              color: _cream,
              boxShadow: [
                BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 8, offset: const Offset(0, 2)),
              ],
            ),
            child: AkriliAppBar(title: 'AKRILI', onBack: () => Navigator.of(context).maybePop()),
          ),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Manage Calendar',
                style: TextStyle(color: _dark, fontSize: 26, fontFamily: 'CormorantGaramond', fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 16),

              // ── Month nav ────────────────────────────────
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${_longMonths[_visibleMonth.month - 1]} ${_visibleMonth.year}',
                    style: const TextStyle(color: _dark, fontSize: 18, fontWeight: FontWeight.w700),
                  ),
                  Row(
                    children: [
                      IconButton(
                        onPressed: _isLoading ? null : () => _changeMonth(-1),
                        icon: const Icon(Icons.chevron_left, color: _teal),
                      ),
                      IconButton(
                        onPressed: _isLoading ? null : () => _changeMonth(1),
                        icon: const Icon(Icons.chevron_right, color: _teal),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // ── Calendar grid ────────────────────────────
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: _border),
                ),
                child: _isLoading
                    ? const Padding(
                        padding: EdgeInsets.symmetric(vertical: 40),
                        child: Center(child: CircularProgressIndicator(color: _teal)),
                      )
                    : _error != null
                        ? Padding(
                            padding: const EdgeInsets.symmetric(vertical: 24),
                            child: Column(
                              children: [
                                Text(_error!, style: const TextStyle(color: _muted, fontSize: 12), textAlign: TextAlign.center),
                                const SizedBox(height: 8),
                                TextButton(onPressed: _loadMonth, child: const Text('Retry', style: TextStyle(color: _teal))),
                              ],
                            ),
                          )
                        : Builder(builder: (context) {
                            final grid = _daysGrid();
                            return Column(
                              children: [
                                Row(
                                  children: _weekdayLabels
                                      .map((l) => Expanded(
                                            child: Center(
                                              child: Text(l, style: const TextStyle(color: _muted, fontSize: 12, fontWeight: FontWeight.w700)),
                                            ),
                                          ))
                                      .toList(),
                                ),
                                const SizedBox(height: 8),
                                GridView.builder(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemCount: grid.length,
                                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 7,
                                    mainAxisSpacing: 4,
                                    crossAxisSpacing: 4,
                                    childAspectRatio: 0.85,
                                  ),
                                  itemBuilder: (context, index) {
                                    final day = grid[index];
                                    return day == null ? const SizedBox.shrink() : _dayCell(day);
                                  },
                                ),
                                const SizedBox(height: 14),
                                Wrap(
                                  alignment: WrapAlignment.center,
                                  spacing: 14,
                                  runSpacing: 6,
                                  children: [
                                    _legendSwatch(Colors.white, 'Available'),
                                    _legendSwatch(_guestBookedBg, 'Guest booking'),
                                    _legendSwatch(_bookedBg, 'Booked offline'),
                                    _legendSwatch(_blockedBg, 'Blocked'),
                                  ],
                                ),
                              ],
                            );
                          }),
              ),
              const SizedBox(height: 8),
              const Text(
                'Tap a day to select it, then long-press another day to select everything in between. '
                'Tap a guest booking to see its details.',
                style: TextStyle(color: _muted, fontSize: 11, height: 1.35),
              ),
              const SizedBox(height: 16),

              // ── Selection details ─────────────────────────
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: _border),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Selection details', style: TextStyle(color: _dark, fontSize: 15, fontWeight: FontWeight.w700)),
                        if (_selected.isNotEmpty)
                          TextButton(
                            onPressed: _clearSelection,
                            style: TextButton.styleFrom(padding: EdgeInsets.zero, minimumSize: Size.zero),
                            child: const Text('Clear', style: TextStyle(color: _teal, fontWeight: FontWeight.w600)),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(_selectionLabel, style: const TextStyle(color: _muted, fontSize: 13)),
                    const SizedBox(height: 18),

                    const Text('Mark as', style: TextStyle(color: _dark, fontSize: 14, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        _statusPill('available', 'Available'),
                        const SizedBox(width: 8),
                        _statusPill('booked', 'Booked\noffline'),
                        const SizedBox(width: 8),
                        _statusPill('blocked', 'Blocked'),
                      ],
                    ),
                    const SizedBox(height: 14),

                    if (_pendingStatus == 'available') ...[
                      Text(
                        _isMonthly ? 'Monthly price (DZD)' : 'Nightly price (DZD)',
                        style: const TextStyle(color: _muted, fontSize: 12, fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(
                          color: _cream,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: _border),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: _priceController,
                                keyboardType: TextInputType.number,
                                style: const TextStyle(color: _dark, fontSize: 16, fontWeight: FontWeight.w700),
                                decoration: InputDecoration(
                                  border: InputBorder.none,
                                  isDense: true,
                                  contentPadding: const EdgeInsets.symmetric(vertical: 14),
                                  hintText: widget.basePricePerNight.round().toString(),
                                ),
                              ),
                            ),
                            Text('/$_unit', style: const TextStyle(color: _muted, fontSize: 13)),
                          ],
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Your base price is ${widget.basePricePerNight.round()} DZD/$_unit. '
                        'Keep it to remove custom prices from these dates, or enter a different price for just these dates.',
                        style: const TextStyle(color: _muted, fontSize: 11, height: 1.35),
                      ),
                    ] else
                      Text(
                        _pendingStatus == 'booked'
                            ? 'For dates you booked outside AKRILI. Guests won\'t be able to book them. Custom prices are kept.'
                            : 'Guests won\'t be able to book these dates. Custom prices are kept for when you reopen them.',
                        style: const TextStyle(color: _muted, fontSize: 11, height: 1.35),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: (_selected.isEmpty || _isSaving) ? null : _applyUpdate,
                  icon: _isSaving
                      ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : const Icon(Icons.sync, color: Colors.white, size: 18),
                  label: Text(
                    _isSaving ? 'Updating...' : 'Update Calendar',
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 15),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _teal,
                    disabledBackgroundColor: _teal.withValues(alpha: 0.4),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
