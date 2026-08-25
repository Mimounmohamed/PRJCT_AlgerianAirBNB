const dns = require('dns');
if (process.env.NODE_ENV !== 'production') {
  dns.setServers(['1.1.1.1', '8.8.8.8']);
}

const express    = require('express');
const http       = require('http');
const { Server } = require('socket.io');
const mongoose   = require('mongoose');
const cors       = require('cors');
const jwt        = require('jsonwebtoken');
require('dotenv').config();

const app    = express();
const server = http.createServer(app);
const io     = new Server(server, {
  cors: { origin: '*', methods: ['GET', 'POST'] },
});

// ─── Expose io to routes ──────────────────────────────────
app.set('io', io);

// ─── Middleware ────────────────────────────────────────────
app.use(cors());
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

app.use((req, res, next) => {
  console.log(`[INCOMING] ${req.method} ${req.originalUrl}`);
  next();
});

// ─── Routes ───────────────────────────────────────────────
app.use('/api/auth',          require('./routes/auth.routes'));
app.use('/api/users',         require('./routes/user.routes'));
app.use('/api/listings',      require('./routes/listing.routes'));
app.use('/api/bookings',      require('./routes/booking.routes'));
app.use('/api/reviews',       require('./routes/review.routes'));
app.use('/api/messages',      require('./routes/message.routes'));
app.use('/api/saved',         require('./routes/saved.routes'));
app.use('/api/availability',  require('./routes/availability.routes'));
app.use('/api/notifications', require('./routes/notification.routes'));
app.use('/api/host',          require('./routes/host.routes'));
app.use('/api/incidents',     require('./routes/incident.routes'));

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
  res.status(err.status || 500).json({ error: err.message || 'Internal Server Error' });
});

// ─── Socket.io ────────────────────────────────────────────
io.use((socket, next) => {
  // Authenticate the socket connection using the JWT token
  const token = socket.handshake.auth?.token || socket.handshake.query?.token;
  if (!token) return next(new Error('Authentication required'));
  try {
    const decoded = jwt.verify(token, process.env.JWT_SECRET);
    socket.userId = decoded.id || decoded._id || decoded.userId;
    next();
  } catch {
    next(new Error('Invalid token'));
  }
});

io.on('connection', (socket) => {
  const userId = socket.userId;
  console.log(`🔌 Socket connected: user ${userId}`);

  // Each user joins their own room so we can push messages to them
  socket.join(userId);

  // Client joins a specific conversation room to receive live messages
  socket.on('join_conversation', (conversationId) => {
    socket.join(`conv_${conversationId}`);
  });

  socket.on('leave_conversation', (conversationId) => {
    socket.leave(`conv_${conversationId}`);
  });

  socket.on('disconnect', () => {
    console.log(`🔌 Socket disconnected: user ${userId}`);
  });
});

// ─── Connect to MongoDB & Start Server ────────────────────
const PORT = process.env.PORT || 5000;

mongoose
  .connect(process.env.MONGODB_URI)
  .then(() => {
    console.log('✅ Connected to MongoDB Atlas');
    server.listen(PORT, () => {
      console.log(`🚀 Server running on http://localhost:${PORT}`);
    });
  })
  .catch((err) => {
    console.error('❌ MongoDB connection error:', err.message);
    process.exit(1);
  });