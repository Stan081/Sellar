import { prisma } from '../utils/database';

const linkInclude = {
  product: { select: { id: true, name: true } },
  _count: { select: { transactions: true, linkViews: true } },
} as const;

export class LinkRepository {
  async findAllByVendor(vendorId: string) {
    return prisma.paymentLink.findMany({
      where: { vendorId },
      include: linkInclude,
      orderBy: { createdAt: 'desc' },
    });
  }

  async findOneByVendor(id: string, vendorId: string) {
    return prisma.paymentLink.findFirst({
      where: { id, vendorId },
      include: linkInclude,
    });
  }

  async create(data: {
    vendorId: string;
    productId?: string | null;
    amount: number;
    currency: string;
    linkType: 'PUBLIC' | 'PRIVATE';
    isReusable: boolean;
    expiresAt?: Date | null;
    shortCode: string;
  }) {
    return prisma.paymentLink.create({ data, include: linkInclude });
  }

  async deactivate(id: string) {
    return prisma.paymentLink.update({
      where: { id },
      data: { isActive: false },
    });
  }

  async delete(id: string) {
    return prisma.paymentLink.delete({ where: { id } });
  }
}
