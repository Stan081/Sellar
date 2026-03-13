import { prisma } from '../utils/database';

export class ProductRepository {
  async findAllByVendor(vendorId: string) {
    return prisma.product.findMany({
      where: { vendorId },
      orderBy: { createdAt: 'desc' },
    });
  }

  async findOneByVendor(id: string, vendorId: string) {
    return prisma.product.findFirst({ where: { id, vendorId } });
  }

  async create(vendorId: string, data: {
    name: string;
    description: string;
    category: string;
    tags: string[];
    price: number;
    quantity?: number | null;
    images: string[];
  }) {
    return prisma.product.create({ data: { vendorId, ...data } });
  }

  async update(id: string, data: {
    name?: string;
    description?: string;
    category?: string;
    tags?: string[];
    price?: number;
    quantity?: number | null;
    images?: string[];
    isActive?: boolean;
  }) {
    return prisma.product.update({ where: { id }, data });
  }

  async delete(id: string) {
    return prisma.product.delete({ where: { id } });
  }
}
