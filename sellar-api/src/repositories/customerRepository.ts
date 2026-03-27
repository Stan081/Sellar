import { prisma } from '../utils/database';

const customerInclude = {
  transactions: {
    include: {
      paymentLink: {
        include: {
          product: { select: { id: true, name: true } },
        },
      },
    },
    orderBy: { createdAt: 'desc' as const },
  },
  _count: { select: { transactions: true } },
} as const;

export class CustomerRepository {
  async findAllByVendor(vendorId: string) {
    return prisma.customer.findMany({
      where: { vendorId },
      include: {
        _count: { select: { transactions: true } },
      },
      orderBy: { createdAt: 'desc' },
    });
  }

  async findOneByVendor(id: string, vendorId: string) {
    return prisma.customer.findFirst({
      where: { id, vendorId },
      include: customerInclude,
    });
  }

  async findByContact(vendorId: string, uniqueContact: string) {
    return prisma.customer.findFirst({
      where: { vendorId, uniqueContact },
    });
  }

  async create(data: {
    vendorId: string;
    name?: string;
    email?: string;
    phone?: string;
    billingAddress?: string;
    currency?: string;
    uniqueContact: string;
  }) {
    return prisma.customer.create({ data });
  }

  async updateAfterPurchase(id: string, amount: number) {
    return prisma.customer.update({
      where: { id },
      data: {
        totalOrders: { increment: 1 },
        totalSpent: { increment: amount },
        lastPurchaseAt: new Date(),
      },
    });
  }

  async update(id: string, data: {
    name?: string;
    email?: string;
    phone?: string;
    billingAddress?: string;
  }) {
    return prisma.customer.update({ where: { id }, data });
  }
}
