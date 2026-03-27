import { Router } from 'express';
import {
  register,
  login,
  sendOTP,
  verifyOTP,
  getProfile,
  updateProfile,
  validateRegister,
  validateLogin,
  validateOTP,
} from '../controllers/authController';
import { validateSendOTP } from '../controllers/validationController';
import { authenticateToken } from '../middleware/auth';

const router = Router();

// Public routes
router.post('/register', validateRegister, register);
router.post('/login', validateLogin, login);
router.post('/send-otp', validateSendOTP, sendOTP);
router.post('/verify-otp', validateOTP, verifyOTP);

// Protected routes
router.get('/profile', authenticateToken, getProfile);
router.put('/profile', authenticateToken, updateProfile);

export default router;
