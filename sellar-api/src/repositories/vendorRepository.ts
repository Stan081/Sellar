import { prisma } from '../utils/database';

export class VendorRepository {
  async findByEmailOrPhone(email: string, phone?: string) {
    return prisma.vendor.findFirst({
      where: {
        OR: [
          { email },
          ...(phone ? [{ phone }] : []),
        ],
      },
    });
  }

  async findByIdentifier(identifier: string) {
    return prisma.vendor.findFirst({
      where: {
        OR: [{ email: identifier }, { phone: identifier }],
      },
    });
  }

  async findById(id: string) {
    return prisma.vendor.findUnique({
      where: { id },
      select: {
        id: true,
        email: true,
        phone: true,
        businessName: true,
        firstName: true,
        lastName: true,
        country: true,
        currency: true,
        avatar: true,
        isEmailVerified: true,
        isPhoneVerified: true,
        preferredGateway: true,
        theme: true,
        createdAt: true,
        lastLoginAt: true,
      },
    });
  }

  async create(data: {
    email: string;
    phone?: string;
    password: string;
    businessName: string;
    firstName: string;
    lastName: string;
    country: string;
    currency?: string;
  }) {
    return prisma.vendor.create({
      data,
      select: {
        id: true,
        email: true,
        phone: true,
        businessName: true,
        firstName: true,
        lastName: true,
        country: true,
        currency: true,
        createdAt: true,
      },
    });
  }

  async updateLastLogin(id: string) {
    return prisma.vendor.update({
      where: { id },
      data: { lastLoginAt: new Date() },
    });
  }

  async updateProfile(id: string, data: {
    businessName?: string;
    firstName?: string;
    lastName?: string;
    phone?: string;
    country?: string;
    currency?: string;
    avatar?: string;
    preferredGateway?: string;
    theme?: string;
  }) {
    return prisma.vendor.update({
      where: { id },
      data,
      select: {
        id: true,
        email: true,
        phone: true,
        businessName: true,
        firstName: true,
        lastName: true,
        country: true,
        currency: true,
        avatar: true,
        isEmailVerified: true,
        isPhoneVerified: true,
        preferredGateway: true,
        theme: true,
        createdAt: true,
        lastLoginAt: true,
      },
    });
  }
}
