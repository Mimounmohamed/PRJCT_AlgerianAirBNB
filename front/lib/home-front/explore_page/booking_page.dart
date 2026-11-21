import 'package:flutter/material.dart';
import '../widgets/availability_calendar.dart';
import '../../services/booking_service.dart';
import '../../services/auth_service.dart';
import '../../services/user_session.dart';
import '../../bookings/booking_result_page.dart';
import '../../bookings/booking_ui.dart';
import '../../chat/conversation.dart';

/// Booking Overview page — shown after tapping "Book now" on Listing Detail.
///
/// - The calendar shows REAL availability (GET /api/listings/:id/availability):
///   nights blocked by the host or taken by other guests can't be picked,
///   and each day shows its real price (custom calendar prices included).
/// - Every time dates or guests change, the server quotes the stay
///   (POST /api/bookings/quote): it checks min/max stay, advance notice,
///   guest count and the calendar, and computes the authoritative price
///   (custom prices, weekly/monthly discount, fee, tax). Problems are shown
///   inline ("Minimum stay is 2 nights.").
/// - The main button creates the booking (POST /api/bookings):
///   "Book now" when the listing has Instant Book (confirmed right away),
///   "Request to book" otherwise (the host has 24h to answer).
/// - "Text" opens a chat with the host; the phone icon still shows the
///   host's number for guests who prefer calling.
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
  final String? hostPhoneCountryCode;
  final String? hostPhoneNumber;
  final String checkInTimeFrom;
  final String checkInTimeTo;
  final String checkOutTimeFrom;
  final String checkOutTimeTo;
  final String checkOutTime;
  final bool instantBook;
  final String hostId;
  final String hostName;

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
    this.hostPhoneCountryCode,
    this.hostPhoneNumber,
    this.checkInTimeFrom = '14:00',
    this.checkInTimeTo = '22:00',
    this.checkOutTimeFrom = '11:00',
    this.checkOutTimeTo = '12:00',
    this.checkOutTime = '11:00',
    this.instantBook = false,
    this.hostId = '',
    this.hostName = 'Host',
  });

  @override
  State<BookingPage> createState() => _BookingPageState();
}

class _BookingPageState extends State<BookingPage> {
  DateTime? _rangeStart;
  DateTime? _rangeEnd;
  late int _guests = widget.maxGuests >= 2 ? 2 : 1;

  static const Color _teal = Color(0xFF006972);

  // Real calendar (12 months loaded up front).
  GuestAvailability? _availability;
  bool _loadingAvailability = true;

  // Server quote for the current dates + guests.
  StayQuote? _quote;
  String? _quoteError;
  bool _quoting = false;
  int _quoteRequest = 0;

  bool _booking = false;
  bool _openingChat = false;

  String? get _token => UserSession.instance.token;

  @override
  void initState() {
    super.initState();
    _loadAvailability();
  }

  Future<void> _loadAvailability() async {
    try {
      final availability = await BookingService.fetchGuestAvailability(listingId: widget.listingId, from: DateTime.now());
      if (!mounted) return;
      setState(() {
        _availability = availability;
        _loadingAvailability = false;
      });
    } catch (_) {
      // Calendar falls back to "everything available"; the server quote
      // still refuses taken dates.
      if (mounted) setState(() => _loadingAvailability = false);
    }
  }

  int get _nights {
    if (_rangeStart == null || _rangeEnd == null) return 0;
    return DateTime.utc(_rangeEnd!.year, _rangeEnd!.month, _rangeEnd!.day)
        .difference(DateTime.utc(_rangeStart!.year, _rangeStart!.month, _rangeStart!.day))
        .inDays;
  }

  // Local estimate, shown only until the server quote arrives.
  double get _subtotal => _quote?.subtotal ?? _nights * widget.pricePerNight;
  double get _serviceFee => _quote?.serviceFee ?? _subtotal * widget.serviceFeePercent / 100;
  double get _touristTax => _quote?.touristTax ?? _subtotal * widget.touristTaxPercent / 100;
  double get _total => _quote?.total ?? _subtotal + _serviceFee + _touristTax;

  bool get _canBook => _nights > 0 && _quote != null && _quoteError == null && !_quoting && !_booking;

  /// Asks the server to check and price the current dates + guests.
  Future<void> _requote() async {
    final token = _token;
    if (_rangeStart == null || _rangeEnd == null) {
      setState(() {
        _quote = null;
        _quoteError = null;
      });
      return;
    }
    if (token == null) {
      setState(() => _quoteError = 'Please log in to book.');
      return;
    }
    final request = ++_quoteRequest;
    setState(() {
      _quoting = true;
      _quoteError = null;
    });
    try {
      final quote = await BookingService.quote(
        token: token,
        listingId: widget.listingId,
        checkIn: _rangeStart!,
        checkOut: _rangeEnd!,
        guests: _guests,
      );
      if (!mounted || request != _quoteRequest) return;
      setState(() {
        _quote = quote;
        _quoting = false;
      });
    } catch (e) {
      if (!mounted || request != _quoteRequest) return;
      setState(() {
        _quote = null;
        _quoteError = '$e';
        _quoting = false;
      });
    }
  }

  Future<void> _book() async {
    final token = _token;
    if (token == null || !_canBook) return;
    setState(() => _booking = true);
    try {
      final booking = await BookingService.create(
        token: token,
        listingId: widget.listingId,
        checkIn: _rangeStart!,
        checkOut: _rangeEnd!,
        guests: _guests,
      );
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => BookingResultPage(booking: booking)),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _booking = false;
        _quoteError = '$e';
        _quote = null;
      });
      // Dates may have just been taken — refresh the calendar.
      _loadAvailability();
    }
  }

  Future<void> _messageHost() async {
    final token = _token;
    final myId = UserSession.instance.currentUser?.id ?? '';
    if (token == null || widget.hostId.isEmpty || widget.hostId == myId) return;
    setState(() => _openingChat = true);
    try {
      final result = await AuthService.startConversation(
        token: token,
        recipientId: widget.hostId,
        listingId: widget.listingId,
        content: _rangeStart != null && _rangeEnd != null
            ? 'Hi, I\'m interested in "${widget.title}" for ${BookingUi.range(_rangeStart!, _rangeEnd!)}.'
            : 'Hi, I\'m interested in your listing "${widget.title}".',
      );
      final conv = result['conversation'] as Map<String, dynamic>? ?? result;
      final conversationId = (conv['_id'] ?? conv['id'] ?? '').toString();
      if (!mounted || conversationId.isEmpty) return;
      await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => ChatScreen(
            conversationId: conversationId,
            otherUserName: widget.hostName,
            otherUserInitials: BookingUi.initials(widget.hostName),
            listingName: widget.title,
            listingLocation: widget.locationLabel,
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Could not open chat: $e')));
    } finally {
      if (mounted) setState(() => _openingChat = false);
    }
  }

  String? get _hostPhoneFormatted {
    if (widget.hostPhoneNumber == null || widget.hostPhoneNumber!.isEmpty) return null;
    final code = widget.hostPhoneCountryCode ?? '';
    return '$code ${widget.hostPhoneNumber}'.trim();
  }

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

  /// Real availability for one month, from the data loaded in initState.
  /// Unavailable nights show as "Booked" without saying whether the host
  /// blocked them or another guest booked them.
  Map<DateTime, DayAvailability> _monthAvailability(DateTime month) {
    final availability = _availability;
    final base = availability?.basePrice ?? widget.pricePerNight;
    final daysInMonth = DateTime(month.year, month.month + 1, 0).day;
    final result = <DateTime, DayAvailability>{};
    for (int day = 1; day <= daysInMonth; day++) {
      final date = DateTime(month.year, month.month, day);
      final unavailable = availability?.unavailable.contains(date) ?? false;
      result[date] = DayAvailability(
        status: unavailable ? DayStatus.booked : DayStatus.available,
        price: availability?.prices[date] ?? base,
      );
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
                    if (_loadingAvailability)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 60),
                        child: CircularProgressIndicator(color: _teal),
                      )
                    else
                      AvailabilityCalendar(
                        initialMonth: tempStart ?? DateTime.now(),
                        initialStart: tempStart,
                        initialEnd: tempEnd,
                        availabilityForMonth: _monthAvailability,
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
                          _requote();
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
                    _requote();
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

  void _showCallDialog() {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: const Color(0xFFFBF3E7),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text(
            'Contact Host',
            style: TextStyle(
              color: Color(0xFF2A1B12),
              fontFamily: 'CormorantGaramond',
              fontSize: 22,
              fontWeight: FontWeight.w600,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (_hostPhoneFormatted != null) ...[
                const Text(
                  'Questions before you book? Call the host',
                  style: TextStyle(color: Color(0xFF8A7B6E), fontSize: 13),
                ),
                const SizedBox(height: 8),
                Text(
                  _hostPhoneFormatted!,
                  style: const TextStyle(
                    color: Color(0xFF006972),
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ] else
                const Text(
                  'This host hasn\'t added a phone number yet.',
                  style: TextStyle(color: Color(0xFF8A7B6E), fontSize: 14),
                ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Close', style: TextStyle(color: Color(0xFF006972))),
            ),
          ],
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
            fontSize: 29,
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
              fontSize: 13,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Confirm Details',
            style: TextStyle(
              color: Color(0xFF2A1B12),
              fontSize: 28,
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
                          fontSize: 18,
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
                          const Icon(Icons.star, size: 16, color: Color(0xFFB8860B)),
                          const SizedBox(width: 4),
                          Text(
                            '${widget.ratingOverall.toStringAsFixed(2)} (${widget.reviewCount} reviews)',
                            style: const TextStyle(color: Color(0xFF2A1B12), fontSize: 14, fontWeight: FontWeight.w600),
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
                  title: const Text('DATES', style: TextStyle(color: Color(0xFF8A7B6E), fontSize: 13, fontWeight: FontWeight.w700, letterSpacing: 1.0)),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(_datesLabel, style: const TextStyle(color: Color(0xFF2A1B12), fontSize: 16, fontWeight: FontWeight.w600)),
                  ),
                  trailing: TextButton(
                    onPressed: _openCalendarSheet,
                    child: const Text('Edit', style: TextStyle(color: _teal, fontWeight: FontWeight.w600)),
                  ),
                ),
                const Divider(height: 1, color: Color(0xFFE7DCCB), indent: 16, endIndent: 16),
                ListTile(
                  title: const Text('GUESTS', style: TextStyle(color: Color(0xFF8A7B6E), fontSize: 13, fontWeight: FontWeight.w700, letterSpacing: 1.0)),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text('$_guests Guests', style: const TextStyle(color: Color(0xFF2A1B12), fontSize: 16, fontWeight: FontWeight.w600)),
                  ),
                  trailing: TextButton(
                    onPressed: _openGuestsDialog,
                    child: const Text('Edit', style: TextStyle(color: _teal, fontWeight: FontWeight.w600)),
                  ),
                ),
                const Divider(height: 1, color: Color(0xFFE7DCCB), indent: 16, endIndent: 16),
                ListTile(
                  title: const Text('CHECK-IN / CHECK-OUT', style: TextStyle(color: Color(0xFF8A7B6E), fontSize: 13, fontWeight: FontWeight.w700, letterSpacing: 1.0)),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      'Check-in: ${widget.checkInTimeFrom} – ${widget.checkInTimeTo}\nCheck-out: ${widget.checkOutTimeFrom} – ${widget.checkOutTimeTo}',
                      style: const TextStyle(color: Color(0xFF2A1B12), fontSize: 15, fontWeight: FontWeight.w600, height: 1.35),
                    ),
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
          if (_nights == 0)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 6),
              child: Text('Pick your dates to see the price.', style: TextStyle(color: Color(0xFF8A7B6E), fontSize: 14)),
            )
          else ...[
            _priceRow(
              '${(_quote?.nightlyRate ?? widget.pricePerNight).round()} DZD x $_nights night${_nights == 1 ? '' : 's'}',
              _formatMoney(_subtotal + (_quote?.discount ?? 0)),
            ),
            if ((_quote?.discount ?? 0) > 0) _priceRow('Long-stay discount', '− ${_formatMoney(_quote!.discount)}'),
            _priceRow('Service fee', _formatMoney(_serviceFee)),
            _priceRow('Tourist tax', _formatMoney(_touristTax)),
            const Divider(height: 24, color: Color(0xFFE7DCCB)),
            _priceRow('Total (${widget.currency})', _formatMoney(_total), isTotal: true),
          ],
          if (_quoting)
            const Padding(
              padding: EdgeInsets.only(top: 8),
              child: Row(
                children: [
                  SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2, color: _teal)),
                  SizedBox(width: 8),
                  Text('Checking availability…', style: TextStyle(color: Color(0xFF8A7B6E), fontSize: 12)),
                ],
              ),
            ),
          if (_quoteError != null)
            Container(
              margin: const EdgeInsets.only(top: 10),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: const Color(0xFFB3261E).withValues(alpha: 0.08), borderRadius: BorderRadius.circular(12)),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.error_outline, size: 18, color: Color(0xFFB3261E)),
                  const SizedBox(width: 8),
                  Expanded(child: Text(_quoteError!, style: const TextStyle(color: Color(0xFF2A1B12), fontSize: 13, height: 1.35))),
                ],
              ),
            ),
          const SizedBox(height: 20),

          // ── Cancellation info banner (real deadline from the quote) ───
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFFDCEEF0),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.info_outline, size: 18, color: _teal),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    _quote?.freeCancellationUntil != null
                        ? 'Free cancellation until ${BookingUi.dateTime(_quote!.freeCancellationUntil!)} (${_quote!.cancellationPolicy} policy). After that, no refund.'
                        : 'Free cancellation depends on the host\'s policy — pick your dates to see the exact deadline.',
                    style: const TextStyle(color: Color(0xFF2A1B12), fontSize: 14, height: 1.4),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 28),

          // ── Main action: Book now / Request to book ──────────────────
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _canBook ? _book : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: _teal,
                disabledBackgroundColor: _teal.withValues(alpha: 0.4),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: _booking
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(widget.instantBook ? Icons.flash_on : Icons.send_rounded, color: Colors.white, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          widget.instantBook ? 'Book now' : 'Request to book',
                          style: const TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w700),
                        ),
                      ],
                    ),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            widget.instantBook
                ? 'Instant Book — your stay is confirmed right away.'
                : '${widget.hostName.split(' ').first} has 24 hours to accept. Nothing is charged until then.',
            textAlign: TextAlign.center,
            style: const TextStyle(color: Color(0xFF8A7B6E), fontSize: 12),
          ),
          const SizedBox(height: 16),

          // ── Secondary: message / call the host ───────────────────────
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _openingChat ? null : _messageHost,
                  icon: const Icon(Icons.chat_bubble_outline, size: 20, color: _teal),
                  label: const Text('Text', style: TextStyle(color: _teal, fontSize: 15, fontWeight: FontWeight.w700)),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: _teal),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                    padding: const EdgeInsets.symmetric(vertical: 13),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _showCallDialog,
                  icon: const Icon(Icons.call, size: 20, color: _teal),
                  label: const Text('Call', style: TextStyle(color: _teal, fontSize: 15, fontWeight: FontWeight.w700)),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: _teal),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                    padding: const EdgeInsets.symmetric(vertical: 13),
                  ),
                ),
              ),
            ],
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