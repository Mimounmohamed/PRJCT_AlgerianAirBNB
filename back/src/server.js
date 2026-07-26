const dns = require('dns');
dns.setServers(['1.1.1.1', '8.8.8.8']);

const express = require('express');
const mongoose = require('mongoose');
const cors = require('cors');
require('dotenv').config();

const app = express();

// ─── Middleware ────────────────────────────────────────────
app.use(cors());
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// 🔍 Debug Middleware: Log all incoming requests to the terminal
app.use((req, res, next) => {
  console.log(`[INCOMING] ${req.method} ${req.originalUrl}`);
  next();
});

// ─── Routes ───────────────────────────────────────────────
app.use('/api/auth',          require('./routes/auth.routes'));
app.use('/api/users',         require('./routes/user.routes'));
app.use('/api/listings',      require('./routes/listing.routes')); // Fixed filename (singular)
app.use('/api/bookings',      require('./routes/booking.routes'));
app.use('/api/reviews',       require('./routes/review.routes'));
app.use('/api/messages',      require('./routes/message.routes'));
app.use('/api/saved',         require('./routes/saved.routes'));
app.use('/api/availability',  require('./routes/availability.routes'));
app.use('/api/notifications', require('./routes/notification.routes'));
app.use('/api/host',          require('./routes/host.routes'));

// ─── Health Check ─────────────────────────────────────────
app.get('/', (req, res) => {
  res.json({ message: '🏡 AKRILI API is running', status: 'ok' });
});

// ─── 404 Handler ──────────────────────────────────────────
app.use((req, res) => {
  res.status(404).json({ error: 'Route not found' });
});

// ─── Global Error Handler ─────────────────────────────────
app.use((err, req, res, next) => {
  console.error(err.stack);
  res.status(err.status || 500).json({
    error: err.message || 'Internal Server Error'
  });
});

// ─── Connect to MongoDB & Start Server ────────────────────
const PORT = process.env.PORT || 5000;

mongoose
  .connect(process.env.MONGODB_URI)
  .then(() => {
    console.log('✅ Connected to MongoDB Atlas');
    app.listen(PORT, () => {
      console.log(`🚀 Server running on http://localhost:${PORT}`);
    });
  })
  .catch((err) => {
    console.error('❌ MongoDB connection error:', err.message);
    process.exit(1);
  });