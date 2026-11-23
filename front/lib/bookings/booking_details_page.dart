import 'package:flutter/material.dart';
import '../authentication-front/widgets/app_bar.dart';
import '../models/booking_model.dart';
import '../services/booking_service.dart';
import '../services/host_service.dart';
import '../services/user_session.dart';
import 'booking_ui.dart';
import '../home-front/widgets/add_review_sheet.dart';
import '../widgets/app_toast.dart';

/// One booking, for its guest or its host (the server says which via
/// viewerRole, and the actions follow):
///  - Host, pending request → Accept / Decline
///  - Guest, pending request → Withdraw request
///  - Either side, confirmed and not started → Cancel booking
///  - Always → Message the other person
///
/// Open it with a [bookingId], or — from Manage Calendar — with a
/// [listingId] + [date] to show the booking covering that night.
///
/// Pops with `true` if the booking was changed, so lists can refresh.
class BookingDetailsPage extends StatefulWidget {
  final String? bookingId;
  final String? listingId;
  final DateTime? date;

  const BookingDetailsPage({super.key, required String this.bookingId})
      : listingId = null,
        date = null;

  const BookingDetailsPage.onDate({super.key, required String this.listingId, required DateTime this.date})
      : bookingId = null;

  @override
  State<BookingDetailsPage> createState() => _BookingDetailsPageState();
}

class _BookingDetailsPageState extends State<BookingDetailsPage> {
  late Future<BookingModel?> _future;
  BookingModel? _booking;
  bool _isBusy = false;
  bool _changed = false;

  String get _token => UserSession.instance.token ?? '';

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<BookingModel?> _load() async {
    var id = widget.bookingId;
    if (id == null) {
      final raw = await HostService.fetchBookingOnDate(
        authToken: _token,
        listingId: widget.listingId!,
        date: BookingService.day(widget.date!),
      );
      if (raw == null) return null;
      id = raw['_id']?.toString();
      if (id == null) return null;
    }
    final booking = await BookingService.get(token: _token, bookingId: id);
    _booking = booking;
    return booking;
  }

  void _reload() => setState(() => _future = _load());

  Future<void> _run(Future<BookingModel> Function() action, String successMessage) async {
    setState(() => _isBusy = true);
    try {
      final updated = await action();
      if (!mounted) return;
      setState(() {
        _booking = updated;
        _future = Future.value(updated);
        _changed = true;
      });
      AppToast.show(context, successMessage, type: AppToastType.success);
    } catch (e) {
      if (!mounted) return;
      AppToast.show(context, '$e', type: AppToastType.error);
      _reload(); // e.g. the request expired meanwhile
    } finally {
      if (mounted) setState(() => _isBusy = false);
    }
  }

  /// Confirm dialog with an optional reason field. Returns null if dismissed.
  Future<String?> _confirmWithReason({
    required String title,
    required String message,
    required String confirmLabel,
    required String reasonHint,
  }) async {
    final controller = TextEditingController();
    final result = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: BookingUi.cream,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(title, style: const TextStyle(color: BookingUi.dark, fontWeight: FontWeight.w700)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(message, style: const TextStyle(color: BookingUi.muted, height: 1.4)),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: BookingUi.border)),
              child: TextField(
                controller: controller,
                maxLines: 2,
                maxLength: 300,
                decoration: InputDecoration(border: InputBorder.none, hintText: reasonHint, counterText: ''),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Back', style: TextStyle(color: BookingUi.muted, fontWeight: FontWeight.w600)),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(controller.text.trim()),
            child: Text(confirmLabel, style: const TextStyle(color: BookingUi.danger, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
    controller.dispose();
    return result;
  }

  Future<void> _accept(BookingModel b) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: BookingUi.cream,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Accept this booking?', style: TextStyle(color: BookingUi.dark, fontWeight: FontWeight.w700)),
        content: Text(
          '${b.guestName} · ${BookingUi.range(b.checkIn, b.checkOut)} · ${b.guestsCount} guest${b.guestsCount == 1 ? '' : 's'}.\n'
          'You earn ${BookingUi.money(b.hostPayout, b.currency)}. These dates will be blocked for this stay.',
          style: const TextStyle(color: BookingUi.muted, height: 1.4),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(dialogContext).pop(false), child: const Text('Back', style: TextStyle(color: BookingUi.muted))),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Accept', style: TextStyle(color: BookingUi.teal, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
    if (ok != true) return;
    await _run(() => BookingService.accept(token: _token, bookingId: b.id), 'Booking accepted. The guest has been notified.');
  }

  Future<void> _decline(BookingModel b) async {
    final reason = await _confirmWithReason(
      title: 'Decline this request?',
      message: "${b.guestName} will be told you can't host them, and the dates become free again.",
      confirmLabel: 'Decline',
      reasonHint: 'Reason (optional) — shared with the guest',
    );
    if (reason == null) return;
    await _run(() => BookingService.decline(token: _token, bookingId: b.id, reason: reason), 'Request declined.');
  }

  Future<void> _cancel(BookingModel b) async {
    final String message;
    if (b.isHostView) {
      message = '${b.guestName} gets a full refund and the dates become free again. Cancelling confirmed stays hurts guests\' trust — only do it if you really can\'t host.';
    } else if (b.isPending) {
      message = 'Your request will be withdrawn. Nothing is charged.';
    } else {
      final deadline = b.freeCancellationUntil;
      final free = deadline != null && DateTime.now().isBefore(deadline);
      message = free
          ? 'You\'re before the free-cancellation deadline (${BookingUi.dateTime(deadline)}), so you get a full refund of ${BookingUi.money(b.total, b.currency)}.'
          : 'The free-cancellation deadline has passed (${b.cancellationPolicy} policy), so this booking is not refundable.';
    }
    final reason = await _confirmWithReason(
      title: b.isPending && !b.isHostView ? 'Withdraw your request?' : 'Cancel this booking?',
      message: message,
      confirmLabel: b.isPending && !b.isHostView ? 'Withdraw' : 'Cancel booking',
      reasonHint: 'Reason (optional)',
    );
    if (reason == null) return;
    await _run(() => BookingService.cancel(token: _token, bookingId: b.id, reason: reason),
        b.isPending ? 'Request withdrawn.' : 'Booking cancelled.');
  }

  Future<void> _leaveReview(BookingModel b) async {
    final review = await AddReviewSheet.show(
      context,
      listingId: b.listingId,
      hostId: b.hostId,
      listingTitle: b.listingTitle,
      bookingId: b.id,
    );
    if (review == null || !mounted) return;
    _changed = true;
    AppToast.show(context, 'Thank you! Your review has been published.', type: AppToastType.success);
    _reload(); // the booking now has its review — the button goes away
  }

  // ── UI pieces ──────────────────────────────────────────

  Widget _card({required Widget child}) => Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        margin: const EdgeInsets.only(bottom: 14),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: BookingUi.border)),
        child: child,
      );

  Widget _row(String label, String value, {bool bold = false, Color? color}) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Text(label, style: TextStyle(color: bold ? BookingUi.dark : BookingUi.muted, fontSize: 13, fontWeight: bold ? FontWeight.w700 : FontWeight.w400)),
            ),
            const SizedBox(width: 12),
            Flexible(
              child: Text(
                value,
                textAlign: TextAlign.right,
                style: TextStyle(color: color ?? BookingUi.dark, fontSize: 13, fontWeight: bold ? FontWeight.w800 : FontWeight.w600),
              ),
            ),
          ],
        ),
      );

  Widget _sectionTitle(String text) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Text(text, style: const TextStyle(color: BookingUi.dark, fontSize: 15, fontWeight: FontWeight.w700)),
      );

  Widget _banner(IconData icon, String text, Color color) => Container(
        width: double.infinity,
        padding: const EdgeInsets.all(12),
        margin: const EdgeInsets.only(bottom: 14),
        decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(14)),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 18, color: color),
            const SizedBox(width: 10),
            Expanded(child: Text(text, style: const TextStyle(color: BookingUi.dark, fontSize: 12, height: 1.4))),
          ],
        ),
      );

  List<Widget> _statusBanners(BookingModel b) {
    final banners = <Widget>[];
    if (b.isPending) {
      final left = BookingUi.timeLeft(b.expiresAt);
      banners.add(_banner(
        Icons.hourglass_top_outlined,
        b.isHostView
            ? 'Accept or decline this request. ${left ?? ''}. If you don\'t answer within 24 hours, it expires automatically.'
            : 'Your request was sent. The host has 24 hours to answer${b.expiresAt != null ? ' (until ${BookingUi.dateTime(b.expiresAt!)})' : ''}.',
        BookingUi.gold,
      ));
    }
    if (b.status == 'rejected' && b.declineReason.isNotEmpty) {
      banners.add(_banner(Icons.info_outline, 'Host\'s message: "${b.declineReason}"', BookingUi.danger));
    }
    if ((b.status == 'cancelled_by_guest' || b.status == 'cancelled_by_host') && b.refundAmount != null) {
      banners.add(_banner(
        Icons.payments_outlined,
        'Refund: ${BookingUi.money(b.refundAmount!, b.currency)}${b.cancellationReason.isNotEmpty ? ' · Reason: "${b.cancellationReason}"' : ''}',
        BookingUi.muted,
      ));
    }
    if (b.status == 'expired') {
      banners.add(_banner(Icons.schedule, 'This request expired because the host didn\'t answer within 24 hours.', BookingUi.muted));
    }
    if (b.status == 'completed' && !b.isHostView) {
      banners.add(_banner(
        Icons.rate_review_outlined,
        b.canReview
            ? 'Your stay is complete. Thanks for staying with AKRILI! Tell future guests how it went.'
            : 'Your stay is complete and reviewed. Thanks for staying with AKRILI!',
        BookingUi.teal,
      ));
    }
    return banners;
  }

  Widget _details(BookingModel b) {
    final s = BookingUi.status(b);
    final freeUntil = b.freeCancellationUntil;

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
      children: [
        Row(
          children: [
            const Expanded(
              child: Text('Booking details', style: TextStyle(color: BookingUi.dark, fontSize: 26, fontFamily: 'CormorantGaramond', fontWeight: FontWeight.w600)),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(color: s.color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(20)),
              child: Text(s.label, style: TextStyle(color: s.color, fontSize: 11, fontWeight: FontWeight.w700)),
            ),
          ],
        ),
        const SizedBox(height: 14),
        ..._statusBanners(b),

        // Listing
        _card(
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: SizedBox(
                  width: 64,
                  height: 64,
                  child: b.listingPhotoUrl != null
                      ? Image.network(b.listingPhotoUrl!, fit: BoxFit.cover, errorBuilder: (_, _, _) => Container(color: BookingUi.border))
                      : Container(color: BookingUi.border),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(b.listingTitle, style: const TextStyle(color: BookingUi.dark, fontSize: 15, fontWeight: FontWeight.w700)),
                    if (b.location.isNotEmpty) Text(b.location, style: const TextStyle(color: BookingUi.muted, fontSize: 12)),
                    if (b.fullAddress != null && b.fullAddress!.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(b.fullAddress!, style: const TextStyle(color: BookingUi.dark, fontSize: 12, fontWeight: FontWeight.w600)),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),

        // The other person
        _card(
          child: Row(
            children: [
              BookingUi.avatar(b.otherPersonPhoto, radius: 24),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(b.isHostView ? 'GUEST' : 'HOST', style: const TextStyle(color: BookingUi.muted, fontSize: 10, fontWeight: FontWeight.w700, letterSpacing: 0.6)),
                    Text(b.otherPersonName, style: const TextStyle(color: BookingUi.dark, fontSize: 15, fontWeight: FontWeight.w700)),
                    if ((b.isHostView ? b.guestPhone : b.hostPhone) != null)
                      Text(b.isHostView ? b.guestPhone! : b.hostPhone!, style: const TextStyle(color: BookingUi.teal, fontSize: 12, fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
              OutlinedButton.icon(
                onPressed: () => BookingUi.openChat(context, b),
                icon: const Icon(Icons.chat_bubble_outline, size: 16, color: BookingUi.teal),
                label: const Text('Message', style: TextStyle(color: BookingUi.teal, fontWeight: FontWeight.w700)),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: BookingUi.teal),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                ),
              ),
            ],
          ),
        ),

        // Stay
        _card(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _sectionTitle('Stay'),
              _row('Check-in', '${BookingUi.longDate(b.checkIn)}\n${b.checkInTimeFrom} – ${b.checkInTimeTo}'),
              _row('Check-out', '${BookingUi.longDate(b.checkOut)}\n${b.checkOutTimeFrom} – ${b.checkOutTimeTo}'),
              _row('Length', '${b.nights} night${b.nights == 1 ? '' : 's'}'),
              _row('Guests', '${b.guestsCount}'),
              _row('Booking type', b.instantBook ? 'Instant Book' : 'Request'),
              _row('Cancellation policy', b.cancellationPolicy),
              if (freeUntil != null && (b.isPending || b.isConfirmed))
                _row('Free cancellation until', BookingUi.dateTime(freeUntil)),
              if (b.checkInInstructions != null && b.checkInInstructions!.isNotEmpty) ...[
                const SizedBox(height: 8),
                const Text('Check-in instructions', style: TextStyle(color: BookingUi.muted, fontSize: 12)),
                const SizedBox(height: 2),
                Text(b.checkInInstructions!, style: const TextStyle(color: BookingUi.dark, fontSize: 13, height: 1.4)),
              ],
            ],
          ),
        ),

        // Price
        _card(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _sectionTitle('Price'),
              _row('${b.nights} night${b.nights == 1 ? '' : 's'}', BookingUi.money(b.subtotal + b.discount, b.currency)),
              if (b.discount > 0) _row('Discount', '− ${BookingUi.money(b.discount, b.currency)}', color: BookingUi.teal),
              _row('Service fee', BookingUi.money(b.serviceFee, b.currency)),
              _row('Tourist tax', BookingUi.money(b.touristTax, b.currency)),
              const Divider(color: BookingUi.border, height: 18),
              _row(b.isHostView ? 'Guest pays' : 'Total', BookingUi.money(b.total, b.currency), bold: true),
              if (b.isHostView) _row('You earn', BookingUi.money(b.hostPayout, b.currency), bold: true, color: BookingUi.teal),
              const SizedBox(height: 6),
              const Text('Payment is arranged directly between guest and host for now.', style: TextStyle(color: BookingUi.muted, fontSize: 11)),
            ],
          ),
        ),

        // Actions
        if (b.canReview)
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => _leaveReview(b),
              icon: const Icon(Icons.rate_review_outlined, color: Colors.white, size: 20),
              label: const Text('Leave a review', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 15)),
              style: ElevatedButton.styleFrom(
                backgroundColor: BookingUi.teal,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                padding: const EdgeInsets.symmetric(vertical: 15),
              ),
            ),
          )
        else if (b.canHostRespond)
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: _isBusy ? null : () => _decline(b),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: BookingUi.danger),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                    padding: const EdgeInsets.symmetric(vertical: 15),
                  ),
                  child: const Text('Decline', style: TextStyle(color: BookingUi.danger, fontWeight: FontWeight.w700, fontSize: 15)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: _isBusy ? null : () => _accept(b),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: BookingUi.teal,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                    padding: const EdgeInsets.symmetric(vertical: 15),
                  ),
                  child: _isBusy
                      ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : const Text('Accept', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 15)),
                ),
              ),
            ],
          )
        else if (b.canCancel)
          Center(
            child: TextButton(
              onPressed: _isBusy ? null : () => _cancel(b),
              child: Text(
                b.isPending && !b.isHostView ? 'Withdraw request' : 'Cancel booking',
                style: const TextStyle(color: BookingUi.danger, fontWeight: FontWeight.w700, decoration: TextDecoration.underline),
              ),
            ),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) Navigator.of(context).pop(_changed);
      },
      child: Scaffold(
        backgroundColor: BookingUi.cream,
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(kToolbarHeight),
          child: Container(
            decoration: BoxDecoration(
              color: BookingUi.cream,
              boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 8, offset: const Offset(0, 2))],
            ),
            child: AkriliAppBar(title: 'AKRILI', onBack: () => Navigator.of(context).maybePop()),
          ),
        ),
        body: FutureBuilder<BookingModel?>(
          future: _future,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting && _booking == null) {
              return const Center(child: CircularProgressIndicator(color: BookingUi.teal));
            }
            if (snapshot.hasError) {
              return BookingListMessage(
                icon: Icons.error_outline,
                title: "Couldn't load this booking",
                body: '${snapshot.error}',
                onRetry: _reload,
              );
            }
            final booking = snapshot.data ?? _booking;
            if (booking == null) {
              return const BookingListMessage(
                icon: Icons.event_busy_outlined,
                title: 'No booking on this date',
                body: 'It may have been cancelled. Go back and refresh the calendar.',
              );
            }
            return RefreshIndicator(
              color: BookingUi.teal,
              onRefresh: () async {
                _reload();
                await _future;
              },
              child: _details(booking),
            );
          },
        ),
      ),
    );
  }
}
