import { Request, Response } from 'express';
import { body, validationResult } from 'express-validator';
import { AuthService } from '../services/authService';
import { VendorRepository } from '../repositories/vendorRepository';

const vendorRepo = new VendorRepository();

const authService = new AuthService();

// Validation middleware
export const validateRegister = [
  body('email').isEmail().withMessage('Valid email required'),
  body('phone').optional().isMobilePhone('any').withMessage('Valid phone number required'),
  body('password').isLength({ min: 6 }).withMessage('Password must be at least 6 characters'),
  body('businessName').notEmpty().withMessage('Business name required'),
  body('firstName').notEmpty().withMessage('First name required'),
  body('lastName').notEmpty().withMessage('Last name required'),
  body('country').notEmpty().withMessage('Country required'),
];

export const validateLogin = [
  body('identifier').notEmpty().withMessage('Email or phone required'),
  body('password').notEmpty().withMessage('Password required'),
];

export const validateOTP = [
  body('identifier').notEmpty().withMessage('Email or phone required'),
  body('code').isLength({ min: 6, max: 6 }).withMessage('6-digit OTP required'),
  body('type').isIn(['LOGIN', 'REGISTRATION', 'PAYMENT']).withMessage('Valid OTP type required'),
];

// Controllers
export const register = async (req: Request, res: Response) => {
  try {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(400).json({ errors: errors.array() });
    }

    const { email, phone, password, businessName, firstName, lastName, country, currency } = req.body;

    const result = await authService.registerVendor({
      email,
      phone,
      password,
      businessName,
      firstName,
      lastName,
      country,
      currency,
    });

    res.status(201).json({
      message: 'Vendor registered successfully',
      data: result,
    });
  } catch (error: any) {
    res.status(400).json({ error: error.message });
  }
};

export const login = async (req: Request, res: Response) => {
  try {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(400).json({ errors: errors.array() });
    }

    const { identifier, password } = req.body;

    const result = await authService.loginVendor(identifier, password);

    res.json({
      message: 'Login successful',
      data: result,
    });
  } catch (error: any) {
    res.status(401).json({ error: error.message });
  }
};

export const sendOTP = async (req: Request, res: Response) => {
  try {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(400).json({ errors: errors.array() });
    }

    const { identifier, type } = req.body;

    const result = await authService.createOTPVerification(identifier, type);

    res.json({
      message: 'OTP sent successfully',
      data: result,
    });
  } catch (error: any) {
    res.status(400).json({ error: error.message });
  }
};

export const verifyOTP = async (req: Request, res: Response) => {
  try {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(400).json({ errors: errors.array() });
    }

    const { identifier, code, type } = req.body;

    const result = await authService.verifyOTP(identifier, code, type);

    res.json({
      message: 'OTP verified successfully',
      data: { verified: result },
    });
  } catch (error: any) {
    res.status(400).json({ error: error.message });
  }
};

export const getProfile = async (req: any, res: Response) => {
  try {
    const vendor = await vendorRepo.findById(req.vendor.id);
    res.json({ message: 'Profile retrieved successfully', data: vendor });
  } catch (error: any) {
    res.status(500).json({ error: error.message });
  }
};

export const updateProfile = async (req: any, res: Response) => {
  try {
    const allowedFields = [
      'businessName', 'firstName', 'lastName', 'phone',
      'country', 'currency', 'avatar', 'preferredGateway', 'theme',
    ];
    const data: Record<string, any> = {};
    for (const field of allowedFields) {
      if (req.body[field] !== undefined) {
        data[field] = req.body[field];
      }
    }

    if (Object.keys(data).length === 0) {
      return res.status(400).json({ error: 'No valid fields to update' });
    }

    const vendor = await vendorRepo.updateProfile(req.vendor.id, data);
    res.json({ message: 'Profile updated successfully', data: vendor });
  } catch (error: any) {
    res.status(500).json({ error: error.message });
  }
};
