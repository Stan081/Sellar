import { body } from 'express-validator';

export const validateSendOTP = [
  body('identifier').notEmpty().withMessage('Email or phone required'),
  body('type').isIn(['LOGIN', 'REGISTRATION', 'PAYMENT']).withMessage('Valid OTP type required'),
];
