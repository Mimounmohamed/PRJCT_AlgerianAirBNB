const express = require('express');
const router = express.Router();
const { protect } = require('../middleware/auth.middleware');
const Booking = require('../models/Booking');
const Listing = require('../models/Listing');
const Availability = require('../models/Availability');
const { bookedNightsInRange } = require('../utils/bookingNights');
const {
  BookingError,
  REQUEST_EXPIRY_MS,
  quoteStay,
  computeRefund,
  freeCancellationDeadline,
  onBookingConfirmed,
  onConfirmedBookingCancelled,
  notifyUser,
  stayLabel,
} = require('../utils/bookingService');

// Booking lifecycle — see models/Booking.js for the state diagram.

const LISTING_FIELDS =
  'title photos coverPhotoIndex location price cancellationPolicy bookingPreferences checkInInstructions houseRules hostId';
const PERSON_FIELDS = 'fullName profilePhoto phone';

// Groups used by the app's tabs.
const STATUS_GROUPS = {
  requests: ['pending'],
  upcoming: ['confirmed'],
  past: ['completed'],
  cancelled: ['cancelled_by_guest', 'cancelled_by_host', 'rejected', 'expired'],
};

function sendError(res, err) {
  if (err instanceof BookingError) return res.status(err.status).json({ error: err.message, ...err.extra });
  return res.status(500).json({ error: err.message });
}

// What a guest sees: the exact address, check-in instructions and the
// host's phone only once the stay is confirmed.
function forViewer(booking, viewerId) {
  const json = booking.toObject ? booking.toObject() : booking;
  const isHost = json.hostId && (json.hostId._id || json.hostId).toString() === viewerId.toString();
  const revealed = ['confirmed', 'completed'].includes(json.status);

  if (json.listingId && typeof json.listingId === 'object' && !isHost && !revealed) {
    if (json.listingId.location) delete json.listingId.location.fullAddress;
    delete json.listingId.checkInInstructions;
  }
  if (!revealed) {
    if (json.hostId && typeof json.hostId === 'object') delete json.hostId.phone;
    if (json.guestId && typeof json.guestId === 'object') delete json.guestId.phone;
  }

  json.viewerRole = isHost ? 'host' : 'guest';
  if (json.cancellationPolicy && json.checkIn) {
    json.freeCancellationUntil = freeCancellationDeadline(
      json.cancellationPolicy,
      new Date(json.checkIn),
      json.listingId?.bookingPreferences?.checkInTimeFrom
    );
  }
  return json;
}

function populateBooking(query) {
  return query
    .populate('listingId', LISTING_FIELDS)
    .populate('guestId', PERSON_FIELDS)
    .populate('hostId', PERSON_FIELDS);
}

// ── POST /api/bookings/quote — live check while the guest picks dates ──
// Body: { listingId, checkIn: "YYYY-MM-DD", checkOut, guestsCount }
// → { nights, pricing, instantBook, cancellationPolicy, freeCancellationUntil }
//   or { error } with 400/409 explaining what's wrong (min stay, taken dates…)
router.post('/quote', protect, async (req, res) => {
  try {
    const { listingId, checkIn, checkOut, guestsCount } = req.body || {};
    const listing = await Listing.findById(listingId);
    const quote = await quoteStay({ listing, checkIn, checkOut, guestsCount, guestId: req.user._id });
    res.json(quote);
  } catch (err) {
    sendError(res, err);
  }
});

// ── POST /api/bookings — Create a booking ──
// Instant Book on → 'confirmed' right away; off → 'pending' request the
// host has 24h to answer. The price is always computed here.
router.post('/', protect, async (req, res) => {
  try {
    const { listingId, checkIn, checkOut, guestsCount } = req.body || {};
    const listing = await Listing.findById(listingId);
    const quote = await quoteStay({ listing, checkIn, checkOut, guestsCount, guestId: req.user._id });

    const instant = quote.instantBook;
    const booking = await Booking.create({
      listingId: listing._id,
      guestId: req.user._id,
      hostId: listing.hostId,
      checkIn: quote.checkIn,
      checkOut: quote.checkOut,
      nights: quote.nights,
      guestsCount: quote.guestsCount,
      pricing: quote.pricing,
      status: instant ? 'confirmed' : 'pending',
      expiresAt: instant ? null : new Date(Date.now() + REQUEST_EXPIRY_MS),
      respondedAt: instant ? new Date() : null,
      instantBook: instant,
      cancellationPolicy: quote.cancellationPolicy,
    });

    // Two guests booking the same dates at the same moment can both pass
    // the check above — the later one gives way.
    const clash = await bookedNightsInRange(listing._id, quote.checkIn, quote.checkOut, { excludeBookingId: booking._id });
    const earlier = [...clash.values()].find((b) => b._id.toString() < booking._id.toString());
    if (earlier) {
      await Booking.deleteOne({ _id: booking._id });
      return res.status(409).json({ error: 'Someone just booked some of these dates. Please pick other dates.' });
    }

    const guestName = req.user.fullName || 'A guest';
    if (instant) {
      await onBookingConfirmed(booking);
      notifyUser(listing.hostId, {
        type: 'booking_confirmed',
        title: 'New booking',
        body: `${guestName} booked ${listing.title} for ${stayLabel(booking)}.`,
        bookingId: booking._id,
      });
    } else {
      notifyUser(listing.hostId, {
        type: 'booking_requested',
        title: 'New booking request',
        body: `${guestName} wants to stay at ${listing.title} (${stayLabel(booking)}). Answer within 24 hours.`,
        bookingId: booking._id,
      });
    }

    const populated = await populateBooking(Booking.findById(booking._id));
    res.status(201).json(forViewer(populated, req.user._id));
  } catch (err) {
    sendError(res, err);
  }
});

// ── GET /api/bookings/my?group=requests|upcoming|past|cancelled — guest's trips ──
router.get('/my', protect, async (req, res) => {
  try {
    const filter = { guestId: req.user._id };
    if (STATUS_GROUPS[req.query.group]) filter.status = { $in: STATUS_GROUPS[req.query.group] };
    const bookings = await populateBooking(Booking.find(filter).sort({ checkIn: -1 }));
    res.json(bookings.map((b) => forViewer(b, req.user._id)));
  } catch (err) {
    sendError(res, err);
  }
});

// ── GET /api/bookings/host?group=…&listingId=… — host's reservations ──
router.get('/host', protect, async (req, res) => {
  try {
    const filter = { hostId: req.user._id };
    if (STATUS_GROUPS[req.query.group]) filter.status = { $in: STATUS_GROUPS[req.query.group] };
    if (req.query.listingId) filter.listingId = req.query.listingId;
    const sort = req.query.group === 'past' || req.query.group === 'cancelled' ? { checkIn: -1 } : { checkIn: 1 };
    const bookings = await populateBooking(Booking.find(filter).sort(sort));
    res.json(bookings.map((b) => forViewer(b, req.user._id)));
  } catch (err) {
    sendError(res, err);
  }
});

// ── GET /api/bookings/:id — one booking (its guest or its host only) ──
router.get('/:id', protect, async (req, res) => {
  try {
    const booking = await populateBooking(Booking.findById(req.params.id));
    if (!booking) return res.status(404).json({ error: 'Booking not found.' });
    const me = req.user._id.toString();
    if (booking.guestId?._id?.toString() !== me && booking.hostId?._id?.toString() !== me) {
      return res.status(404).json({ error: 'Booking not found.' });
    }
    res.json(forViewer(booking, req.user._id));
  } catch (err) {
    sendError(res, err);
  }
});

// Loads a booking the requester hosts, still pending and not expired.
async function loadPendingForHost(req) {
  const booking = await Booking.findOne({ _id: req.params.id, hostId: req.user._id });
  if (!booking) throw new BookingError(404, 'Booking not found.');
  if (booking.status !== 'pending') throw new BookingError(409, 'This request has already been answered.');
  if (booking.expiresAt && booking.expiresAt <= new Date()) {
    throw new BookingError(409, 'This request has expired.');
  }
  return booking;
}

// ── PUT /api/bookings/:id/accept — host accepts a request ──
router.put('/:id/accept', protect, async (req, res) => {
  try {
    const booking = await loadPendingForHost(req);

    // Re-check the calendar: the host may have blocked some of these dates
    // since the request came in.
    const marks = await Availability.find({
      listingId: booking.listingId,
      date: { $gte: booking.checkIn, $lt: booking.checkOut },
      status: { $ne: 'available' },
    });
    const clash = await bookedNightsInRange(booking.listingId, booking.checkIn, booking.checkOut, { excludeBookingId: booking._id });
    if (marks.length > 0 || clash.size > 0) {
      throw new BookingError(409, 'Some of these dates are blocked or booked now. Unblock them in your calendar, or decline the request.');
    }

    const updated = await Booking.findOneAndUpdate(
      { _id: booking._id, status: 'pending' },
      { $set: { status: 'confirmed', respondedAt: new Date(), expiresAt: null } },
      { new: true }
    );
    if (!updated) throw new BookingError(409, 'This request has already been answered.');
    await onBookingConfirmed(updated);

    const listing = await Listing.findById(updated.listingId).select('title');
    notifyUser(updated.guestId, {
      type: 'booking_confirmed',
      title: 'Booking confirmed 🎉',
      body: `Your stay at ${listing?.title || 'the listing'} (${stayLabel(updated)}) is confirmed.`,
      bookingId: updated._id,
    });

    const populated = await populateBooking(Booking.findById(updated._id));
    res.json(forViewer(populated, req.user._id));
  } catch (err) {
    sendError(res, err);
  }
});

// ── PUT /api/bookings/:id/decline — host declines a request ── { reason? }
router.put('/:id/decline', protect, async (req, res) => {
  try {
    const booking = await loadPendingForHost(req);
    const reason = String(req.body?.reason || '').slice(0, 500);

    const updated = await Booking.findOneAndUpdate(
      { _id: booking._id, status: 'pending' },
      { $set: { status: 'rejected', respondedAt: new Date(), expiresAt: null, declineReason: reason } },
      { new: true }
    );
    if (!updated) throw new BookingError(409, 'This request has already been answered.');

    const listing = await Listing.findById(updated.listingId).select('title');
    notifyUser(updated.guestId, {
      type: 'booking_declined',
      title: 'Booking request declined',
      body: `The host couldn't accept your request for ${listing?.title || 'the listing'} (${stayLabel(updated)}).${reason ? ` "${reason}"` : ''}`,
      bookingId: updated._id,
    });

    const populated = await populateBooking(Booking.findById(updated._id));
    res.json(forViewer(populated, req.user._id));
  } catch (err) {
    sendError(res, err);
  }
});

// ── PUT /api/bookings/:id/cancel — guest or host cancels ── { reason? }
// Only pending or confirmed bookings, and only before check-in day starts.
// A guest withdrawing a pending request owes nothing; a host cancelling
// always refunds in full; a guest cancelling a confirmed stay gets a full
// refund before the policy deadline, none after.
router.put('/:id/cancel', protect, async (req, res) => {
  try {
    const booking = await Booking.findById(req.params.id);
    if (!booking) return res.status(404).json({ error: 'Booking not found.' });

    const me = req.user._id.toString();
    const isGuest = booking.guestId.toString() === me;
    const isHost = booking.hostId.toString() === me;
    if (!isGuest && !isHost) return res.status(404).json({ error: 'Booking not found.' });

    if (!['pending', 'confirmed'].includes(booking.status)) {
      throw new BookingError(409, 'This booking can no longer be cancelled.');
    }
    if (booking.checkIn <= new Date()) {
      throw new BookingError(409, 'This stay has already started and can no longer be cancelled here.');
    }
    if (isHost && booking.status === 'pending') {
      throw new BookingError(409, 'Use Decline to turn down a request.');
    }

    const listing = await Listing.findById(booking.listingId).select('title bookingPreferences');
    const wasConfirmed = booking.status === 'confirmed';
    const refundAmount = computeRefund(booking, isHost ? 'host' : 'guest', listing);

    const updated = await Booking.findOneAndUpdate(
      { _id: booking._id, status: booking.status },
      {
        $set: {
          status: isGuest ? 'cancelled_by_guest' : 'cancelled_by_host',
          cancelledAt: new Date(),
          cancelledBy: req.user._id,
          cancellationReason: String(req.body?.reason || '').slice(0, 500),
          refundAmount,
          expiresAt: null,
        },
      },
      { new: true }
    );
    if (!updated) throw new BookingError(409, 'This booking was just changed. Refresh and try again.');
    if (wasConfirmed) await onConfirmedBookingCancelled(updated);

    const title = listing?.title || 'the listing';
    if (isGuest) {
      notifyUser(updated.hostId, {
        type: 'booking_cancelled',
        title: wasConfirmed ? 'Booking cancelled' : 'Booking request withdrawn',
        body: `The guest cancelled their ${wasConfirmed ? 'booking' : 'request'} for ${title} (${stayLabel(updated)}). Those dates are free again.`,
        bookingId: updated._id,
      });
    } else {
      notifyUser(updated.guestId, {
        type: 'booking_cancelled',
        title: 'Your booking was cancelled',
        body: `The host cancelled your stay at ${title} (${stayLabel(updated)}). You'll get a full refund.`,
        bookingId: updated._id,
      });
    }

    const populated = await populateBooking(Booking.findById(updated._id));
    res.json(forViewer(populated, req.user._id));
  } catch (err) {
    sendError(res, err);
  }
});

module.exports = router;
