import { prisma } from '../utils/database';

type Platform = 'FACEBOOK' | 'INSTAGRAM' | 'WHATSAPP' | 'TIKTOK';

export class SocialRepository {
  async findAllByVendor(vendorId: string) {
    return prisma.socialConnection.findMany({
      where: { vendorId, isActive: true },
      select: {
        platform: true,
        platformUsername: true,
        pageName: true,
        pageId: true,
        connectedAt: true,
        tokenExpiresAt: true,
      },
    });
  }

  async findConnection(vendorId: string, platform: Platform) {
    return prisma.socialConnection.findUnique({
      where: { vendorId_platform: { vendorId, platform } },
    });
  }

  async upsertConnection(data: {
    vendorId: string;
    platform: Platform;
    accessToken: string;
    tokenExpiresAt: Date | null;
    platformUserId: string | null;
    platformUsername: string | null;
    pageId: string | null;
    pageName?: string | null;
    scopes: string[];
  }) {
    const { vendorId, platform, ...rest } = data;
    return prisma.socialConnection.upsert({
      where: { vendorId_platform: { vendorId, platform } },
      create: { vendorId, platform, ...rest },
      update: { ...rest, isActive: true, updatedAt: new Date() },
    });
  }

  async deleteByVendorAndPlatform(vendorId: string, platform: Platform) {
    return prisma.socialConnection.deleteMany({ where: { vendorId, platform } });
  }
}
