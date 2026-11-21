import 'package:flutter/material.dart';

enum DayStatus { available, booked, blocked }

class DayAvailability {
  final DayStatus status;
  final double price; // per-night price for this specific day

  const DayAvailability({required this.status, required this.price});
}

/// Month calendar showing per-day availability and price, with range
/// selection (tap a start day, then an end day). Booked/blocked days are
/// not selectable. Selecting a range calls [onRangeSelected] with the
/// chosen (start, end) dates so the parent can compute nights/price.
///
/// A range can't contain a taken night; its check-out day may itself be
/// taken (another guest checking in), since it isn't a night of the stay.
/// [availabilityForMonth] is fed from GET /api/listings/:id/availability
/// by the Booking page.
class AvailabilityCalendar extends StatefulWidget {
  final Map<DateTime, DayAvailability> Function(DateTime month) availabilityForMonth;
  final DateTime initialMonth;
  final DateTime? initialStart;
  final DateTime? initialEnd;
  final void Function(DateTime? start, DateTime? end) onRangeSelected;

  const AvailabilityCalendar({
    super.key,
    required this.availabilityForMonth,
    required this.initialMonth,
    required this.onRangeSelected,
    this.initialStart,
    this.initialEnd,
  });

  @override
  State<AvailabilityCalendar> createState() => _AvailabilityCalendarState();
}

class _AvailabilityCalendarState extends State<AvailabilityCalendar> {
  late DateTime _displayedMonth;
  DateTime? _rangeStart;
  DateTime? _rangeEnd;

  static const Color _teal = Color(0xFF006972);
  static const Color _bookedBg = Color(0xFFE8D4C4);
  static const Color _blockedBg = Color(0xFFEDEDED);

  @override
  void initState() {
    super.initState();
    _displayedMonth = DateTime(widget.initialMonth.year, widget.initialMonth.month);
    _rangeStart = widget.initialStart;
    _rangeEnd = widget.initialEnd;
  }

  DateTime _dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);

  bool _isBeforeToday(DateTime day) {
    final today = _dateOnly(DateTime.now());
    return day.isBefore(today);
  }

  DayStatus _statusOf(DateTime day) {
    final month = widget.availabilityForMonth(DateTime(day.year, day.month));
    return month[_dateOnly(day)]?.status ?? DayStatus.available;
  }

  /// True if every NIGHT from [start] up to (not including) [end] is free.
  bool _nightsFree(DateTime start, DateTime end) {
    for (var d = start; d.isBefore(end); d = DateTime(d.year, d.month, d.day + 1)) {
      if (_statusOf(d) != DayStatus.available) return false;
    }
    return true;
  }

  /// A day can be tapped as check-out even when it's unavailable itself
  /// (someone else checks in that day) — the check-out day isn't a night
  /// of this stay. Only the nights before it must be free.
  bool _canBeCheckOut(DateTime day) =>
      _rangeStart != null && _rangeEnd == null && day.isAfter(_rangeStart!) && _nightsFree(_rangeStart!, day);

  void _onDayTap(DateTime day, DayAvailability availability) {
    if (_isBeforeToday(day)) return;
    final isAvailable = availability.status == DayStatus.available;
    if (!isAvailable && !_canBeCheckOut(day)) return;

    setState(() {
      if (_rangeStart == null || (_rangeStart != null && _rangeEnd != null)) {
        _rangeStart = day;
        _rangeEnd = null;
      } else if (day.isBefore(_rangeStart!)) {
        _rangeStart = day;
        _rangeEnd = null;
      } else if (day.isAtSameMomentAs(_rangeStart!)) {
        _rangeStart = null;
        _rangeEnd = null;
      } else if (_nightsFree(_rangeStart!, day)) {
        _rangeEnd = day;
      } else {
        // A taken night sits between the two taps — start over from here.
        _rangeStart = isAvailable ? day : null;
        _rangeEnd = null;
      }
    });

    widget.onRangeSelected(_rangeStart, _rangeEnd);
  }

  void _changeMonth(int delta) {
    setState(() {
      _displayedMonth = DateTime(_displayedMonth.year, _displayedMonth.month + delta);
    });
  }

  String _monthLabel(DateTime month) {
    const names = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December',
    ];
    return '${names[month.month - 1]} ${month.year}';
  }

  String _compactPrice(double value) {
    if (value >= 1000) {
      final k = value / 1000;
      final isWhole = k == k.roundToDouble();
      return '${isWhole ? k.toStringAsFixed(0) : k.toStringAsFixed(1)}k';
    }
    return value.toStringAsFixed(0);
  }

  bool _isInRange(DateTime day) {
    if (_rangeStart == null || _rangeEnd == null) return false;
    return day.isAfter(_rangeStart!) && day.isBefore(_rangeEnd!);
  }

  bool _isRangeEdge(DateTime day) {
    if (_rangeStart != null && day.isAtSameMomentAs(_rangeStart!)) return true;
    if (_rangeEnd != null && day.isAtSameMomentAs(_rangeEnd!)) return true;
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final availability = widget.availabilityForMonth(_displayedMonth);
    final firstOfMonth = DateTime(_displayedMonth.year, _displayedMonth.month, 1);
    final daysInMonth = DateTime(_displayedMonth.year, _displayedMonth.month + 1, 0).day;
    final leadingBlanks = firstOfMonth.weekday % 7;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              _monthLabel(_displayedMonth),
              style: const TextStyle(
                color: Color(0xFF2A1B12),
                fontSize: 18,
                fontFamily: 'CormorantGaramond',
                fontWeight: FontWeight.w600,
              ),
            ),
            Row(
              children: [
                IconButton(
                  onPressed: () => _changeMonth(-1),
                  icon: const Icon(Icons.chevron_left, color: Color(0xFF2A1B12)),
                  splashRadius: 16,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                ),
                IconButton(
                  onPressed: () => _changeMonth(1),
                  icon: const Icon(Icons.chevron_right, color: Color(0xFF2A1B12)),
                  splashRadius: 16,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 4),
        Row(
          children: ['S', 'M', 'T', 'W', 'T', 'F', 'S']
              .map((d) => Expanded(
                    child: Center(
                      child: Text(
                        d,
                        style: const TextStyle(
                          color: Color(0xFF8A7B6E),
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ))
              .toList(),
        ),
        const SizedBox(height: 2),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: leadingBlanks + daysInMonth,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 7,
            mainAxisSpacing: 2,
            crossAxisSpacing: 2,
            childAspectRatio: 1.0,
          ),
          itemBuilder: (context, index) {
            if (index < leadingBlanks) return const SizedBox();

            final dayNum = index - leadingBlanks + 1;
            final day = DateTime(_displayedMonth.year, _displayedMonth.month, dayNum);
            final dayAvailability = availability[_dateOnly(day)] ??
                const DayAvailability(status: DayStatus.available, price: 0);
            final isPast = _isBeforeToday(day);
            final isEdge = _isRangeEdge(day);
            final inRange = _isInRange(day);

            final isSelectable = !isPast && (dayAvailability.status == DayStatus.available || _canBeCheckOut(day));

            Color bg = Colors.transparent;
            if (dayAvailability.status == DayStatus.booked) bg = _bookedBg;
            if (dayAvailability.status == DayStatus.blocked) bg = _blockedBg;
            if (inRange) bg = _teal.withOpacity(0.12);

            return GestureDetector(
              onTap: isSelectable ? () => _onDayTap(day, dayAvailability) : null,
              child: Container(
                margin: const EdgeInsets.all(1),
                decoration: BoxDecoration(
                  color: bg,
                  borderRadius: BorderRadius.circular(16),
                  border: isEdge ? Border.all(color: _teal, width: 1.6) : null,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '$dayNum',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: isPast || dayAvailability.status != DayStatus.available
                            ? const Color(0xFF9A8C7F)
                            : const Color(0xFF2A1B12),
                      ),
                    ),
                    if (dayAvailability.status == DayStatus.booked)
                      const Text('Booked',
                          style: TextStyle(fontSize: 7, color: Color(0xFF9A8C7F)))
                    else if (dayAvailability.status == DayStatus.blocked)
                      const Text('BLOCKED',
                          style: TextStyle(fontSize: 7, color: Color(0xFF9A8C7F)))
                    else if (!isPast)
                      Text(
                        _compactPrice(dayAvailability.price),
                        style: const TextStyle(fontSize: 9, color: _teal, fontWeight: FontWeight.w600),
                      ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}