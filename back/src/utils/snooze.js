const Listing = require('../models/Listing');

// Longest a host can snooze a listing for.
const MAX_SNOOZE_DAYS = 365;

// How often expired snoozes are flipped back to 'listed'. Search already
// treats an expired snooze as listed (see listedFilter), so this interval
// only affects what the stored document says, not what guests see.
const SNOOZE_SWEEP_INTERVAL_MS = 10 * 60 * 1000;

// Mongo filter for "shows up in search": listed, or snoozed with the
// snooze already over.
function listedFilter(now = new Date()) {
  return {
    $or: [
      { visibility: 'listed' },
      { visibility: 'snoozed', snoozedUntil: { $lte: now } },
    ],
  };
}

async function expireSnoozedListings() {
  try {
    const result = await Listing.updateMany(
      { visibility: 'snoozed', snoozedUntil: { $lte: new Date() } },
      { $set: { visibility: 'listed', snoozedUntil: null } }
    );
    if (result.modifiedCount > 0) {
      console.log(`[snooze] Re-listed ${result.modifiedCount} listing(s) whose snooze ended.`);
    }
  } catch (err) {
    console.warn('[snooze] sweep failed:', err.message);
  }
}

// Call once after the DB connects.
function startSnoozeSweeper() {
  expireSnoozedListings();
  setInterval(expireSnoozedListings, SNOOZE_SWEEP_INTERVAL_MS).unref();
}

module.exports = { MAX_SNOOZE_DAYS, listedFilter, expireSnoozedListings, startSnoozeSweeper };
