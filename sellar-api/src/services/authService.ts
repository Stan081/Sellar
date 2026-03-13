import bcrypt from 'bcryptjs';
import jwt from 'jsonwebtoken';
import { VendorRepository } from '../repositories/vendorRepository';
import { OtpRepository } from '../repositories/otpRepository';

const vendorRepo = new VendorRepository();
const otpRepo = new OtpRepository();

export class AuthService {
  // Generate JWT token
  generateToken(vendorId: string): string {
    if (!process.env.JWT_SECRET) {
      throw new Error('JWT_SECRET environment variable is not set');
    }
    
    // Use any to bypass TypeScript strict typing for JWT
    return (jwt as any).sign(
      { vendorId },
      process.env.JWT_SECRET,
      { expiresIn: process.env.JWT_EXPIRES_IN || '7d' }
    );
  }

  // Hash password
  async hashPassword(password: string): Promise<string> {
    return bcrypt.hash(password, 12);
  }

  // Verify password
  async verifyPassword(password: string, hashedPassword: string): Promise<boolean> {
    return bcrypt.compare(password, hashedPassword);
  }

  // Generate OTP
  generateOTP(): string {
    return Math.floor(100000 + Math.random() * 900000).toString();
  }

  // Send OTP (mock implementation - integrate with SMS/Email service)
  async sendOTP(identifier: string, code: string, type: 'LOGIN' | 'REGISTRATION' | 'PAYMENT'): Promise<void> {
    console.log(`OTP for ${identifier} (${type}): ${code}`);
    // TODO: Integrate with SendGrid for email or Twilio for SMS
    // For now, we'll just log it
  }

  // Register new vendor
  async registerVendor(data: {
    email: string;
    phone?: string;
    password: string;
    businessName: string;
    firstName: string;
    lastName: string;
    country: string;
    currency?: string;
  }) {
    const existingVendor = await vendorRepo.findByEmailOrPhone(data.email, data.phone);
    if (existingVendor) {
      throw new Error('Vendor with this email or phone already exists');
    }

    const hashedPassword = await this.hashPassword(data.password);
    const vendor = await vendorRepo.create({ ...data, password: hashedPassword });
    const token = this.generateToken(vendor.id);
    return { vendor, token };
  }

  // Login vendor
  async loginVendor(identifier: string, password: string) {
    const vendor = await vendorRepo.findByIdentifier(identifier);

    if (!vendor || !vendor.password) {
      throw new Error('Invalid credentials');
    }

    const isValid = await this.verifyPassword(password, vendor.password);
    if (!isValid) {
      throw new Error('Invalid credentials');
    }

    await vendorRepo.updateLastLogin(vendor.id);
    const token = this.generateToken(vendor.id);

    return {
      vendor: {
        id: vendor.id,
        email: vendor.email,
        phone: vendor.phone,
        businessName: vendor.businessName,
        firstName: vendor.firstName,
        lastName: vendor.lastName,
        country: vendor.country,
        currency: vendor.currency,
        isEmailVerified: vendor.isEmailVerified,
        isPhoneVerified: vendor.isPhoneVerified,
      },
      token,
    };
  }

  // Create OTP verification
  async createOTPVerification(identifier: string, type: 'LOGIN' | 'REGISTRATION' | 'PAYMENT') {
    await otpRepo.deleteExisting(identifier, type);

    const code = this.generateOTP();
    const expiresAt = new Date(Date.now() + 10 * 60 * 1000);
    const otpVerification = await otpRepo.create(identifier, code, type, expiresAt);

    await this.sendOTP(identifier, code, type);
    return { id: otpVerification.id, expiresAt };
  }

  // Verify OTP
  async verifyOTP(identifier: string, code: string, type: 'LOGIN' | 'REGISTRATION' | 'PAYMENT') {
    const otpVerification = await otpRepo.findValid(identifier, code, type);
    if (!otpVerification) {
      throw new Error('Invalid or expired OTP');
    }
    await otpRepo.markUsed(otpVerification.id);
    return true;
  }
}
