const jwt = require('jsonwebtoken');
const User = require('../models/User');

const protect = async (req, res, next) => {
  try {
    // 1. Get token from header
    const authHeader = req.headers.authorization;
    if (!authHeader || !authHeader.startsWith('Bearer ')) {
      return res.status(401).json({ error: 'Not authorized. No token provided.' });
    }

    const token = authHeader.split(' ')[1];

    // 2. Verify token
    const decoded = jwt.verify(token, process.env.JWT_SECRET);

    // 3. Check if user still exists
    const user = await User.findById(decoded.id).select('-passwordHash');
    if (!user) {
      return res.status(401).json({ error: 'User no longer exists.' });
    }

    // 4. Check if account is active
    if (user.accountStatus !== 'active') {
      return res.status(403).json({ error: 'Account is deactivated or suspended.' });
    }

    req.user = user;
    next();
  } catch (err) {
    return res.status(401).json({ error: 'Invalid or expired token.' });
  }
};

// Middleware: same as protect, but never rejects the request — if there's
// no token, or it's invalid/expired, or the user no longer exists/is
// inactive, req.user is just left undefined and the request continues.
// Used on routes that behave differently for logged-in vs anonymous
// requesters but shouldn't require login (e.g. view-count tracking on a
// public listing detail route).
const optionalAuth = async (req, res, next) => {
  try {
    const authHeader = req.headers.authorization;
    if (!authHeader || !authHeader.startsWith('Bearer ')) {
      return next();
    }

    const token = authHeader.split(' ')[1];
    const decoded = jwt.verify(token, process.env.JWT_SECRET);

    const user = await User.findById(decoded.id).select('-passwordHash');
    if (user && user.accountStatus === 'active') {
      req.user = user;
    }
    next();
  } catch (err) {
    // Invalid/expired token on an optional-auth route — treat as anonymous
    // rather than rejecting the request.
    next();
  }
};

// Middleware: require host role
const requireHost = (req, res, next) => {
  if (!req.user.isHost) {
    return res.status(403).json({ error: 'Access denied. Host account required.' });
  }
  next();
};

// Utility: generate JWT
const generateToken = (userId) => {
  return jwt.sign({ id: userId }, process.env.JWT_SECRET, {
    expiresIn: process.env.JWT_EXPIRES_IN || '30d',
  });
};

module.exports = { protect, optionalAuth, requireHost, generateToken };