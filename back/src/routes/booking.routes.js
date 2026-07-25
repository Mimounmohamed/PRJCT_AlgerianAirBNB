const express = require('express');
const router = express.Router();
const { protect } = require('../middleware/auth.middleware');
const Booking = require('../models/Booking');
const Listing = require('../models/Listing');
const Availability = require('../models/Availability');

// POST /api/bookings — Create a booking
router.post('/', protect, async (req, res) => {
  try {
    const { listingId, checkIn, checkOut, guestsCount } = req.body;
    const listing = await Listing.findById(listingId);
    if (!listing) return res.status(404).json({ error: 'Listing not found.' });

    const checkInDate = new Date(checkIn);
    const checkOutDate = new Date(checkOut);
    const msPerDay = 1000 * 60 * 60 * 24;
    const nights = Math.ceil((checkOutDate - checkInDate) / msPerDay);

    // Check availability
    const blocked = await Availability.findOne({
      listingId,
      date: { $gte: checkInDate, $lt: checkOutDate },
      status: { $ne: 'available' },
    });
    if (blocked) return res.status(409).json({ error: 'Some dates are not available.' });

    // Compute pricing
    const subtotal = listing.price.perNight * nights;
    const serviceFee = Math.round(subtotal * listing.price.serviceFeePercent / 100);
    const touristTax = Math.round(subtotal * listing.price.touristTaxPercent / 100);

    const booking = await Booking.create({
      listingId,
      guestId: req.user._id,
      hostId: listing.hostId,
      checkIn: checkInDate,
      checkOut: checkOutDate,
      nights,
      guestsCount,
      pricing: {
        nightlyRate: listing.price.perNight,
        subtotal,
        serviceFee,
        touristTax,
        totalDZD: subtotal + serviceFee + touristTax,
      },
      status: listing.bookingPreferences.instantBook ? 'confirmed' : 'pending',
      instantBook: listing.bookingPreferences.instantBook,
      cancellationPolicy: listing.cancellationPolicy,
    });

    res.status(201).json(booking);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// GET /api/bookings/my — Get current user's bookings (as guest)
router.get('/my', protect, async (req, res) => {
  try {
    const bookings = await Booking.find({ guestId: req.user._id })
      .populate('listingId', 'title photos location price')
      .sort({ createdAt: -1 });
    res.json(bookings);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// GET /api/bookings/host — Get bookings for host's listings
router.get('/host', protect, async (req, res) => {
  try {
    const bookings = await Booking.find({ hostId: req.user._id })
      .populate('listingId', 'title photos')
      .populate('guestId', 'fullName profilePhoto')
      .sort({ createdAt: -1 });
    res.json(bookings);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// PUT /api/bookings/:id/cancel — Cancel a booking
router.put('/:id/cancel', protect, async (req, res) => {
  try {
    const booking = await Booking.findById(req.params.id);
    if (!booking) return res.status(404).json({ error: 'Booking not found.' });

    const isGuest = booking.guestId.toString() === req.user._id.toString();
    const isHost  = booking.hostId.toString() === req.user._id.toString();
    if (!isGuest && !isHost) return res.status(403).json({ error: 'Not authorized.' });

    booking.status = isGuest ? 'cancelled_by_guest' : 'cancelled_by_host';
    booking.cancelledAt = new Date();
    booking.cancelledBy = req.user._id;
    booking.cancellationReason = req.body.reason || '';
    await booking.save();

    // Free up availability dates
    await Availability.updateMany(
      { bookingId: booking._id },
      { status: 'available', bookingId: null }
    );

    res.json({ message: 'Booking cancelled.', booking });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

module.exports = router;
