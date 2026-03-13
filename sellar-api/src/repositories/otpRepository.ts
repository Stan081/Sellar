import { prisma } from '../utils/database';

type OtpType = 'LOGIN' | 'REGISTRATION' | 'PAYMENT';

export class OtpRepository {
  async deleteExisting(identifier: string, type: OtpType) {
    return prisma.oTPVerification.deleteMany({ where: { identifier, type } });
  }

  async create(identifier: string, code: string, type: OtpType, expiresAt: Date) {
    return prisma.oTPVerification.create({
      data: { identifier, code, type, expiresAt },
    });
  }

  async findValid(identifier: string, code: string, type: OtpType) {
    return prisma.oTPVerification.findFirst({
      where: {
        identifier,
        code,
        type,
        expiresAt: { gt: new Date() },
        usedAt: null,
      },
    });
  }

  async markUsed(id: string) {
    return prisma.oTPVerification.update({
      where: { id },
      data: { usedAt: new Date() },
    });
  }
}
