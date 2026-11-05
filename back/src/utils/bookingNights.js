const Booking = require('../models/Booking');

// Bookings that occupy their dates. Cancelled/rejected ones free the dates
// again; completed ones are in the past.
const ACTIVE_BOOKING_STATUSES = ['pending', 'confirmed'];

const MS_PER_DAY = 24 * 60 * 60 * 1000;

// "2026-11-05" → Date at 2026-11-05T00:00:00.000Z, or null if invalid.
// Calendar days are always stored/compared as UTC midnight.
function parseDay(dayStr) {
  if (typeof dayStr !== 'string' || !/^\d{4}-\d{2}-\d{2}$/.test(dayStr)) return null;
  const date = new Date(`${dayStr}T00:00:00.000Z`);
  return Number.isNaN(date.getTime()) || date.toISOString().slice(0, 10) !== dayStr ? null : date;
}

// Date → "YYYY-MM-DD" (its UTC calendar day).
function dayKey(date) {
  return new Date(date).toISOString().slice(0, 10);
}

// UTC midnight of the day a Date falls on.
function startOfUtcDay(date) {
  const d = new Date(date);
  return new Date(Date.UTC(d.getUTCFullYear(), d.getUTCMonth(), d.getUTCDate()));
}

// Map of "YYYY-MM-DD" → booking, for every night of an active booking on
// this listing that falls in [rangeStart, rangeEnd). A booking from the
// 3rd to the 6th occupies the nights of the 3rd, 4th and 5th — the
// check-out day stays free for the next guest.
async function bookedNightsInRange(listingId, rangeStart, rangeEnd) {
  const bookings = await Booking.find({
    listingId,
    status: { $in: ACTIVE_BOOKING_STATUSES },
    checkIn: { $lt: rangeEnd },
    checkOut: { $gt: rangeStart },
  }).select('_id status checkIn checkOut');

  const nights = new Map();
  for (const booking of bookings) {
    const firstNight = startOfUtcDay(booking.checkIn);
    const checkOutDay = startOfUtcDay(booking.checkOut);
    for (let t = firstNight.getTime(); t < checkOutDay.getTime(); t += MS_PER_DAY) {
      if (t >= rangeStart.getTime() && t < rangeEnd.getTime()) {
        nights.set(dayKey(t), booking);
      }
    }
  }
  return nights;
}

module.exports = {
  ACTIVE_BOOKING_STATUSES,
  MS_PER_DAY,
  parseDay,
  dayKey,
  startOfUtcDay,
  bookedNightsInRange,
};
