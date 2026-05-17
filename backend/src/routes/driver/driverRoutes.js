// routes/driverRoutes.js
const express = require('express');
const router = express.Router();
const {
  registerDriver,
  getDriverProfile,
  updateDriverStatus,
  getDriverBookings,
  updateBookingStatus,
  getDriverEarnings
} = require('../../controllers/driver/driverController')
const { protect } = require('../../middleware/authMiddleware');

// Public routes
router.post('/register', registerDriver);

// Protected routes (hanya untuk driver)
router.get('/profile', protect, getDriverProfile);
router.put('/status', protect, updateDriverStatus);
router.get('/bookings', protect, getDriverBookings);
router.put('/bookings/:bookingId/status', protect, updateBookingStatus);
router.get('/earnings', protect, getDriverEarnings);

module.exports = router;