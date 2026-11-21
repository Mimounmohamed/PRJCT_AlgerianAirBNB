const Booking = require('../models/Booking');
const Listing = require('../models/Listing');
const Availability = require('../models/Availability');
const Notification = require('../models/Notification');
const User = require('../models/User');
const { sendPushNotification } = require('../config/pushNotification');
const { MS_PER_DAY, parseDay, dayKey, bookedNightsInRange } = require('./bookingNights');

// Algeria is UTC+1 all year (no daylight saving). Calendar days are stored
// as UTC midnight; times like check-in "14:00" are Algerian local time.
const ALGERIA_UTC_OFFSET_MS = 60 * 60 * 1000;

// How long a host has to answer a booking request.
const REQUEST_EXPIRY_MS = 24 * 60 * 60 * 1000;

// Full refund if the guest cancels at least this long before check-in.
// Matches the Cancellation policy page (24h / 5 days / 30 days).
const POLICY_FREE_CANCEL_HOURS = { Flexible: 24, Moderate: 5 * 24, Firm: 30 * 24, Strict: 30 * 24 };

// A stay counts as completed this long after the start of its check-out day
// (≈ 13:00 in Algeria — after any check-out window).
const COMPLETE_AFTER_CHECKOUT_MS = 12 * 60 * 60 * 1000;

const SWEEP_INTERVAL_MS = 10 * 60 * 1000;

class BookingError extends Error {
  constructor(status, message, extra = {}) {
    super(message);
    this.status = status;
    this.extra = extra;
  }
}

// ── Time helpers ─────────────────────────────────────────────

// "14:00" on a given UTC-midnight day → the exact moment, in Algeria time.
function localTimeOnDay(day, hhmm = '00:00') {
  const [h, m] = String(hhmm).split(':').map((n) => parseInt(n, 10) || 0);
  return new Date(day.getTime() + (h * 60 + m) * 60 * 1000 - ALGERIA_UTC_OFFSET_MS);
}

// Today's calendar day in Algeria, as UTC midnight.
function todayInAlgeria() {
  const now = new Date(Date.now() + ALGERIA_UTC_OFFSET_MS);
  return new Date(Date.UTC(now.getUTCFullYear(), now.getUTCMonth(), now.getUTCDate()));
}

function formatDay(day) {
  return new Date(day).toLocaleDateString('en-GB', { day: 'numeric', month: 'short', year: 'numeric', timeZone: 'UTC' });
}

function formatNotice(hours) {
  if (hours <= 0) return 'same-day';
  if (hours % 24 === 0) return `${hours / 24} day${hours === 24 ? '' : 's'}`;
  return `${hours} hours`;
}

// ── Quote: every rule check + the authoritative price ─────────

// Validates a stay request against the listing's rules and calendar and
// computes the price. Throws BookingError (with an HTTP status and a
// message meant for the guest) when the stay isn't possible.
//
// Used by POST /bookings/quote (live check while the guest picks dates),
// POST /bookings (create) and PUT /bookings/:id/accept (re-check).
async function quoteStay({ listing, checkIn: checkInStr, checkOut: checkOutStr, guestsCount, guestId, excludeBookingId }) {
  if (!listing || listing.isDeleted) throw new BookingError(404, 'This listing no longer exists.');
  if (listing.status !== 'active') throw new BookingError(409, "This listing isn't taking bookings right now.");
  if (listing.visibility === 'snoozed' && listing.snoozedUntil && listing.snoozedUntil > new Date()) {
    throw new BookingError(409, "This listing isn't taking bookings right now.");
  }
  if (guestId && listing.hostId.toString() === guestId.toString()) {
    throw new BookingError(400, "You can't book your own listing.");
  }

  const checkIn = parseDay(checkInStr);
  const checkOut = parseDay(checkOutStr);
  if (!checkIn || !checkOut) throw new BookingError(400, 'Pick your check-in and check-out dates.');
  if (checkOut <= checkIn) throw new BookingError(400, 'Check-out must be after check-in.');

  const nights = Math.round((checkOut - checkIn) / MS_PER_DAY);
  const prefs = listing.bookingPreferences || {};
  const isMonthly = listing.price?.rentalPeriod === 'monthly';

  // Dates in the past / advance notice
  if (checkIn < todayInAlgeria()) throw new BookingError(400, 'Check-in can\'t be in the past.');
  const noticeHours = Number(prefs.advanceNoticeHours ?? 24);
  const checkInMoment = localTimeOnDay(checkIn, prefs.checkInTimeFrom || '14:00');
  if (Date.now() + noticeHours * 60 * 60 * 1000 > checkInMoment.getTime()) {
    throw new BookingError(400, noticeHours > 0
      ? `This host needs at least ${formatNotice(noticeHours)} notice before check-in.`
      : 'Check-in time for that day has already passed.');
  }

  // Guests
  const guests = parseInt(guestsCount, 10);
  const maxGuests = listing.capacity?.guests || 1;
  if (!(guests >= 1)) throw new BookingError(400, 'Choose how many guests are coming.');
  if (guests > maxGuests) throw new BookingError(400, `This place welcomes at most ${maxGuests} guest${maxGuests === 1 ? '' : 's'}.`);

  // Stay length (nightly: nights; monthly listings: months of 30 nights)
  const minStay = Number(prefs.minStayNights || 1);
  const maxStay = Number(prefs.maxStayNights || (isMonthly ? 12 : 365));
  const months = Math.ceil(nights / 30);
  if (isMonthly) {
    if (months < minStay) throw new BookingError(400, `Minimum stay is ${minStay} month${minStay === 1 ? '' : 's'}.`);
    if (months > maxStay) throw new BookingError(400, `Maximum stay is ${maxStay} month${maxStay === 1 ? '' : 's'}.`);
  } else {
    if (nights < minStay) throw new BookingError(400, `Minimum stay is ${minStay} night${minStay === 1 ? '' : 's'}.`);
    if (nights > maxStay) throw new BookingError(400, `Maximum stay is ${maxStay} night${maxStay === 1 ? '' : 's'}.`);
  }

  // Calendar: host's own marks (blocked / booked offline) on any night…
  const marks = await Availability.find({ listingId: listing._id, date: { $gte: checkIn, $lt: checkOut } });
  const unavailableMarks = marks.filter((m) => m.status !== 'available').map((m) => dayKey(m.date));
  // …and other guests' active bookings.
  const bookedNights = await bookedNightsInRange(listing._id, checkIn, checkOut, { excludeBookingId });
  const takenDates = [...new Set([...unavailableMarks, ...bookedNights.keys()])].sort();
  if (takenDates.length > 0) {
    throw new BookingError(409, `Some of these dates are no longer available (${takenDates.map((d) => formatDay(parseDay(d))).join(', ')}).`, { takenDates });
  }

  // Price
  const basePrice = Number(listing.price?.perNight || 0);
  let rawSubtotal;
  let discount = 0;
  if (isMonthly) {
    rawSubtotal = basePrice * months;
  } else {
    const overrides = new Map(marks.filter((m) => m.priceOverride != null).map((m) => [dayKey(m.date), m.priceOverride]));
    rawSubtotal = 0;
    for (let t = checkIn.getTime(); t < checkOut.getTime(); t += MS_PER_DAY) {
      rawSubtotal += overrides.get(dayKey(t)) ?? basePrice;
    }
    const weekly = Number(listing.price?.weeklyDiscountPercent || 0);
    const monthly = Number(listing.price?.monthlyDiscountPercent || 0);
    const discountPercent = nights >= 28 && monthly > 0 ? monthly : nights >= 7 ? weekly : 0;
    discount = Math.round(rawSubtotal * discountPercent / 100);
  }

  const subtotal = Math.round(rawSubtotal - discount);
  const serviceFee = Math.round(subtotal * Number(listing.price?.serviceFeePercent ?? 10) / 100);
  const touristTax = Math.round(subtotal * Number(listing.price?.touristTaxPercent ?? 5.5) / 100);

  return {
    checkIn,
    checkOut,
    nights,
    guestsCount: guests,
    instantBook: prefs.instantBook === true,
    cancellationPolicy: listing.cancellationPolicy || 'Moderate',
    freeCancellationUntil: freeCancellationDeadline(listing.cancellationPolicy, checkIn, prefs.checkInTimeFrom),
    pricing: {
      nightlyRate: nights > 0 ? Math.round(subtotal / nights) : basePrice,
      subtotal,
      discount,
      serviceFee,
      touristTax,
      totalDZD: subtotal + serviceFee + touristTax,
      hostPayout: subtotal - serviceFee,
      currency: listing.price?.currency || 'DZD',
    },
  };
}

// Last moment a guest can cancel for a full refund.
function freeCancellationDeadline(policy, checkIn, checkInTimeFrom = '14:00') {
  const hours = POLICY_FREE_CANCEL_HOURS[policy] ?? POLICY_FREE_CANCEL_HOURS.Moderate;
  return new Date(localTimeOnDay(checkIn, checkInTimeFrom).getTime() - hours * 60 * 60 * 1000);
}

// ── Refunds ────────────────────────────────────────────────────

// Informational refund (payment happens outside the app for now):
//  - a pending request withdrawn by the guest → nothing was owed
//  - host cancels → guest gets everything back
//  - guest cancels a confirmed stay → full refund before the policy
//    deadline, nothing after it
function computeRefund(booking, cancelledBy, listing) {
  const total = booking.pricing?.totalDZD || 0;
  if (booking.status === 'pending' || cancelledBy === 'host') return total;
  const deadline = freeCancellationDeadline(
    booking.cancellationPolicy,
    booking.checkIn,
    listing?.bookingPreferences?.checkInTimeFrom
  );
  return Date.now() <= deadline.getTime() ? total : 0;
}

// ── Stats ──────────────────────────────────────────────────────

// Listing.stats.totalBookings counts confirmed stays (incl. completed);
// totalEarnings is the host's payout from completed stays only.
async function onBookingConfirmed(booking) {
  await Listing.updateOne({ _id: booking.listingId }, { $inc: { 'stats.totalBookings': 1 } });
}

async function onConfirmedBookingCancelled(booking) {
  await Listing.updateOne({ _id: booking.listingId }, { $inc: { 'stats.totalBookings': -1 } });
}

async function onBookingCompleted(booking) {
  await Listing.updateOne(
    { _id: booking.listingId },
    { $inc: { 'stats.totalEarnings': booking.pricing?.hostPayout || 0 } }
  );
}

// ── Notifications ──────────────────────────────────────────────

// In-app notification + push (when the user has a device token and
// booking updates turned on). Never throws.
async function notifyUser(userId, { type, title, body, bookingId }) {
  try {
    await Notification.create({ userId, type, title, body, relatedId: bookingId, relatedType: 'booking' });
    const user = await User.findById(userId).select('fcmToken notificationSettings');
    if (user?.fcmToken && user.notificationSettings?.bookingUpdates !== false) {
      await sendPushNotification({
        fcmToken: user.fcmToken,
        title,
        body,
        data: { type, bookingId: String(bookingId) },
      });
    }
  } catch (err) {
    console.warn('[booking] notify failed:', err.message);
  }
}

function stayLabel(booking) {
  return `${formatDay(booking.checkIn)} – ${formatDay(booking.checkOut)}`;
}

// ── Background sweep: expire unanswered requests, complete stays ──

async function sweepBookings() {
  try {
    const now = new Date();

    const expiring = await Booking.find({ status: 'pending', expiresAt: { $ne: null, $lte: now } })
      .populate('listingId', 'title');
    for (const booking of expiring) {
      const updated = await Booking.findOneAndUpdate(
        { _id: booking._id, status: 'pending' },
        { $set: { status: 'expired' } },
        { new: true }
      );
      if (!updated) continue;
      const title = booking.listingId?.title || 'your stay';
      notifyUser(booking.guestId, {
        type: 'booking_expired',
        title: 'Booking request expired',
        body: `The host didn't answer your request for ${title} (${stayLabel(booking)}) in time. Those dates are free again.`,
        bookingId: booking._id,
      });
      notifyUser(booking.hostId, {
        type: 'booking_expired',
        title: 'A booking request expired',
        body: `You didn't answer the request for ${title} (${stayLabel(booking)}) within 24 hours.`,
        bookingId: booking._id,
      });
    }

    const finished = await Booking.find({
      status: 'confirmed',
      checkOut: { $lte: new Date(now.getTime() - COMPLETE_AFTER_CHECKOUT_MS) },
    }).populate('listingId', 'title');
    for (const booking of finished) {
      const updated = await Booking.findOneAndUpdate(
        { _id: booking._id, status: 'confirmed' },
        { $set: { status: 'completed', completedAt: now } },
        { new: true }
      );
      if (!updated) continue;
      await onBookingCompleted(updated);
      notifyUser(booking.guestId, {
        type: 'booking_completed',
        title: 'How was your stay?',
        body: `Thanks for staying at ${booking.listingId?.title || 'your stay'}. You can now leave a review.`,
        bookingId: booking._id,
      });
    }

    if (expiring.length || finished.length) {
      console.log(`[booking] sweep: ${expiring.length} expired, ${finished.length} completed`);
    }
  } catch (err) {
    console.warn('[booking] sweep failed:', err.message);
  }
}

function startBookingSweeper() {
  sweepBookings();
  setInterval(sweepBookings, SWEEP_INTERVAL_MS).unref();
}

module.exports = {
  BookingError,
  REQUEST_EXPIRY_MS,
  quoteStay,
  computeRefund,
  freeCancellationDeadline,
  onBookingConfirmed,
  onConfirmedBookingCancelled,
  onBookingCompleted,
  notifyUser,
  stayLabel,
  formatDay,
  sweepBookings,
  startBookingSweeper,
};
