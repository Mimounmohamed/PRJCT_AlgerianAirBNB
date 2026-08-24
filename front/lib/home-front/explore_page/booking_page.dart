import 'package:flutter/material.dart';
import '../widgets/availability_calendar.dart';

/// Booking Overview page — shown after tapping "Book now" on Listing Detail.
///
/// Date selection and price calculation are fully real/working:
/// nights, subtotal, service fee, and tourist tax are all computed live
/// from the selected calendar range and the fee percentages passed in
/// from ListingDetailModel (price.serviceFeePercent / price.touristTaxPercent).
///
/// TODO: [_generateFakeMonth] stands in for real availability data until
/// the GET /api/availability/:listingId?month=... contract is confirmed —
/// only the DATA SOURCE needs swapping, not the selection/price logic.
/// TODO: the "Call" button and guest-count edit are not wired to anything yet.
class BookingPage extends StatefulWidget {
  final String listingId;
  final String title;
  final String? coverPhotoUrl;
  final String locationLabel; // e.g. "Algiers, Casbah District"
  final double ratingOverall;
  final int reviewCount;
  final double pricePerNight;
  final String currency;
  final double serviceFeePercent;
  final double touristTaxPercent;
  final int maxGuests;

  const BookingPage({
    super.key,
    required this.listingId,
    required this.title,
    required this.coverPhotoUrl,
    required this.locationLabel,
    required this.ratingOverall,
    required this.reviewCount,
    required this.pricePerNight,
    required this.currency,
    required this.serviceFeePercent,
    required this.touristTaxPercent,
    required this.maxGuests,
  });

  @override
  State<BookingPage> createState() => _BookingPageState();
}

class _BookingPageState extends State<BookingPage> {
  DateTime? _rangeStart;
  DateTime? _rangeEnd;
  int _guests = 2;

  static const Color _teal = Color(0xFF006972);

  int get _nights {
    if (_rangeStart == null || _rangeEnd == null) return 0;
    return _rangeEnd!.difference(_rangeStart!).inDays;
  }

  double get _subtotal => _nights * widget.pricePerNight;
  double get _serviceFee => _subtotal * widget.serviceFeePercent / 100;
  double get _touristTax => _subtotal * widget.touristTaxPercent / 100;
  double get _total => _subtotal + _serviceFee + _touristTax;

  String _formatMoney(double value) {
    final rounded = value.round().toString();
    final buffer = StringBuffer();
    for (int i = 0; i < rounded.length; i++) {
      final posFromEnd = rounded.length - i;
      buffer.write(rounded[i]);
      if (posFromEnd > 1 && posFromEnd % 3 == 1) buffer.write(' ');
    }
    final currencyLabel = widget.currency == 'DZD' ? 'DZD' : widget.currency;
    return '${buffer.toString()} $currencyLabel';
  }

  String _formatDate(DateTime d) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '${months[d.month - 1]} ${d.day}, ${d.year}';
  }

  String get _datesLabel {
    if (_rangeStart == null || _rangeEnd == null) return 'Select dates';
    return '${_formatDate(_rangeStart!)} – ${_formatDate(_rangeEnd!)}';
  }

  /// FAKE availability generator — replicates the demo pattern (a couple of
  /// booked days, a couple of blocked days, weekend vs weekday pricing) so
  /// the calendar is fully interactive today. Replace with a real fetch
  /// from GET /api/availability/:listingId?month=... once that contract
  /// is confirmed.
  Map<DateTime, DayAvailability> _generateFakeMonth(DateTime month) {
    final daysInMonth = DateTime(month.year, month.month + 1, 0).day;
    final result = <DateTime, DayAvailability>{};

    for (int day = 1; day <= daysInMonth; day++) {
      final date = DateTime(month.year, month.month, day);
      final weekday = date.weekday; // Mon=1 ... Sun=7

      DayStatus status = DayStatus.available;
      if (day == 4 || day == 5) status = DayStatus.booked;
      if (day == 15 || day == 16) status = DayStatus.blocked;

      // Fri(5), Sat(6), Sun(7) priced higher — matches the reference design.
      final isWeekend = weekday == DateTime.friday ||
          weekday == DateTime.saturday ||
          weekday == DateTime.sunday;
      final price = isWeekend ? widget.pricePerNight * 1.1 : widget.pricePerNight;

      result[date] = DayAvailability(status: status, price: price);
    }

    return result;
  }

  void _openCalendarSheet() {
    DateTime? tempStart = _rangeStart;
    DateTime? tempEnd = _rangeEnd;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              child: Container(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                decoration: const BoxDecoration(
                  color: Color(0xFFFBF3E7),
                  borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.close, color: Color(0xFF2A1B12)),
                          onPressed: () => Navigator.of(context).pop(),
                          splashRadius: 20,
                        ),
                        const Text(
                          'Select dates',
                          style: TextStyle(
                            color: Color(0xFF2A1B12),
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            fontFamily: 'HenkenGrotesk',
                          ),
                        ),
                        const SizedBox(width: 48), // balances the close button
                      ],
                    ),
                    const SizedBox(height: 8),
                    AvailabilityCalendar(
                      initialMonth: tempStart ?? DateTime.now(),
                      initialStart: tempStart,
                      initialEnd: tempEnd,
                      availabilityForMonth: _generateFakeMonth,
                      onRangeSelected: (start, end) {
                        setSheetState(() {
                          tempStart = start;
                          tempEnd = end;
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          setState(() {
                            _rangeStart = tempStart;
                            _rangeEnd = tempEnd;
                          });
                          Navigator.of(context).pop();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _teal,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        child: const Text(
                          'Confirm dates',
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
                        ),
                      ),
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

  void _openGuestsDialog() {
    showDialog(
      context: context,
      builder: (context) {
        int tempGuests = _guests;
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: const Color(0xFFFBF3E7),
              title: const Text('Guests', style: TextStyle(color: Color(0xFF2A1B12))),
              content: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    onPressed: tempGuests > 1
                        ? () => setDialogState(() => tempGuests--)
                        : null,
                    icon: const Icon(Icons.remove_circle_outline, color: _teal),
                  ),
                  Text('$tempGuests', style: const TextStyle(fontSize: 18, color: Color(0xFF2A1B12))),
                  IconButton(
                    onPressed: tempGuests < widget.maxGuests
                        ? () => setDialogState(() => tempGuests++)
                        : null,
                    icon: const Icon(Icons.add_circle_outline, color: _teal),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    setState(() => _guests = tempGuests);
                    Navigator.of(context).pop();
                  },
                  child: const Text('Done', style: TextStyle(color: _teal)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _priceRow(String label, String value, {bool isTotal = false}) {
    final style = TextStyle(
      color: const Color(0xFF2A1B12),
      fontSize: isTotal ? 17 : 14,
      fontWeight: isTotal ? FontWeight.w700 : FontWeight.w400,
      fontFamily: 'HenkenGrotesk',
    );
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: style.copyWith(fontWeight: isTotal ? FontWeight.w700 : FontWeight.w400,
              color: isTotal ? const Color(0xFF2A1B12) : const Color(0xFF8A7B6E))),
          Text(value, style: style),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFBF3E7),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFBF3E7),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: _teal),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Booking',
          style: TextStyle(
            color: Color(0xFF2A1B12),
            fontSize: 20,
            fontFamily: 'CormorantGaramond',
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text(
            'REVIEW YOUR STAY',
            style: TextStyle(
              color: Color(0xFF8A7B6E),
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Confirm Details',
            style: TextStyle(
              color: Color(0xFF2A1B12),
              fontSize: 26,
              fontFamily: 'CormorantGaramond',
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 20),

          // ── Listing summary card ─────────────────────────────────────
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
            ),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: SizedBox(
                    width: 64,
                    height: 64,
                    child: widget.coverPhotoUrl != null
                        ? Image.network(widget.coverPhotoUrl!, fit: BoxFit.cover)
                        : Container(color: const Color(0xFFE7DCCB)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.title,
                        style: const TextStyle(
                          color: Color(0xFF2A1B12),
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          fontFamily: 'HenkenGrotesk',
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        widget.locationLabel,
                        style: const TextStyle(color: Color(0xFF8A7B6E), fontSize: 13),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.star, size: 14, color: Color(0xFFB8860B)),
                          const SizedBox(width: 4),
                          Text(
                            '${widget.ratingOverall.toStringAsFixed(2)} (${widget.reviewCount} reviews)',
                            style: const TextStyle(color: Color(0xFF2A1B12), fontSize: 12, fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // ── Dates + Guests card ──────────────────────────────────────
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
            ),
            child: Column(
              children: [
                ListTile(
                  title: const Text('DATES', style: TextStyle(color: Color(0xFF8A7B6E), fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 1.0)),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(_datesLabel, style: const TextStyle(color: Color(0xFF2A1B12), fontSize: 15, fontWeight: FontWeight.w600)),
                  ),
                  trailing: TextButton(
                    onPressed: _openCalendarSheet,
                    child: const Text('Edit', style: TextStyle(color: _teal, fontWeight: FontWeight.w600)),
                  ),
                ),
                const Divider(height: 1, color: Color(0xFFE7DCCB), indent: 16, endIndent: 16),
                ListTile(
                  title: const Text('GUESTS', style: TextStyle(color: Color(0xFF8A7B6E), fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 1.0)),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text('$_guests Guests', style: const TextStyle(color: Color(0xFF2A1B12), fontSize: 15, fontWeight: FontWeight.w600)),
                  ),
                  trailing: TextButton(
                    onPressed: _openGuestsDialog,
                    child: const Text('Edit', style: TextStyle(color: _teal, fontWeight: FontWeight.w600)),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // ── Price details ────────────────────────────────────────────
          const Text(
            'Price Details',
            style: TextStyle(color: Color(0xFF2A1B12), fontSize: 16, fontWeight: FontWeight.w700, fontFamily: 'HenkenGrotesk'),
          ),
          const SizedBox(height: 8),
          _priceRow(
            '${widget.pricePerNight.round()} DZD x $_nights night${_nights == 1 ? '' : 's'}',
            _formatMoney(_subtotal),
          ),
          _priceRow('Service fee', _formatMoney(_serviceFee)),
          _priceRow('Tourist tax', _formatMoney(_touristTax)),
          const Divider(height: 24, color: Color(0xFFE7DCCB)),
          _priceRow('Total (${widget.currency})', _formatMoney(_total), isTotal: true),
          const SizedBox(height: 20),

          // ── Cancellation info banner ─────────────────────────────────
          // TODO: compute a real cutoff date from the listing's cancellationPolicy.
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFFDCEEF0),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.info_outline, size: 18, color: _teal),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Free cancellation before check-in. After that, cancellation policy applies.',
                    style: TextStyle(color: Color(0xFF2A1B12), fontSize: 13, height: 1.4),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 28),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _nights > 0
                  ? () {
                      // TODO: wire real call/booking-confirmation action
                    }
                  : null,
              icon: const Icon(Icons.call, color: Colors.white, size: 18),
              label: const Text('Call', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
              style: ElevatedButton.styleFrom(
                backgroundColor: _teal,
                disabledBackgroundColor: _teal.withOpacity(0.4),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Center(
            child: TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('CANCEL', style: TextStyle(color: Color(0xFF8A7B6E), fontWeight: FontWeight.w700, letterSpacing: 1.0)),
            ),
          ),
        ],
      ),
    );
  }
}