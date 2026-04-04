import { prisma } from '../utils/database';

export interface OrderFilters {
  status?: string;
  orderStatus?: string;
  deliveryStatus?: string;
  startDate?: string;
  endDate?: string;
  search?: string;
}

export class OrderRepository {
  async findAllByVendor(vendorId: string, filters: OrderFilters = {}) {
    const where: any = { vendorId };

    // Apply filters
    if (filters.status) where.status = filters.status;
    if (filters.orderStatus) where.orderStatus = filters.orderStatus;
    if (filters.deliveryStatus) where.deliveryStatus = filters.deliveryStatus;
    
    // Date range filter
    if (filters.startDate || filters.endDate) {
      where.createdAt = {};
      if (filters.startDate) where.createdAt.gte = new Date(filters.startDate);
      if (filters.endDate) where.createdAt.lte = new Date(filters.endDate);
    }
    
    // Search filter
    if (filters.search) {
      where.OR = [
        { customerEmail: { contains: filters.search, mode: 'insensitive' } },
        { customerPhone: { contains: filters.search, mode: 'insensitive' } },
        { trackingNumber: { contains: filters.search, mode: 'insensitive' } },
        { paymentLink: { product: { name: { contains: filters.search, mode: 'insensitive' } } } },
      ];
    }

    return prisma.transaction.findMany({
      where,
      include: {
        customer: true,
        paymentLink: {
          include: {
            product: true,
          },
        },
      },
      orderBy: { createdAt: 'desc' },
    });
  }

  async findOneByVendor(id: string, vendorId: string) {
    return prisma.transaction.findFirst({
      where: { id, vendorId },
      include: {
        customer: true,
        paymentLink: {
          include: {
            product: true,
          },
        },
      },
    });
  }

  async updateOrderStatus(id: string, vendorId: string, orderStatus: string) {
    // First verify the transaction belongs to the vendor
    const transaction = await prisma.transaction.findFirst({
      where: { id, vendorId },
    });
    if (!transaction) throw new Error('Order not found');
    
    return prisma.transaction.update({
      where: { id },
      data: { orderStatus: orderStatus as any, updatedAt: new Date() },
    });
  }

  async updateDeliveryStatus(
    id: string, 
    vendorId: string, 
    deliveryStatus: string,
    trackingNumber?: string,
    estimatedDelivery?: Date
  ) {
    // First verify the transaction belongs to the vendor
    const transaction = await prisma.transaction.findFirst({
      where: { id, vendorId },
    });
    if (!transaction) throw new Error('Order not found');

    const data: any = { deliveryStatus: deliveryStatus as any, updatedAt: new Date() };
    if (trackingNumber) data.trackingNumber = trackingNumber;
    if (estimatedDelivery) data.estimatedDelivery = estimatedDelivery;
    if (deliveryStatus === 'DELIVERED') data.actualDelivery = new Date();

    return prisma.transaction.update({
      where: { id },
      data,
    });
  }

  async updateOrderNotes(id: string, vendorId: string, notes: string) {
    // First verify the transaction belongs to the vendor
    const transaction = await prisma.transaction.findFirst({
      where: { id, vendorId },
    });
    if (!transaction) throw new Error('Order not found');

    return prisma.transaction.update({
      where: { id },
      data: { notes, updatedAt: new Date() },
    });
  }

  async getOrderStats(vendorId: string) {
    // Get counts by status
    const pending = await prisma.transaction.count({
      where: { vendorId, orderStatus: 'PENDING' },
    });
    const processing = await prisma.transaction.count({
      where: { vendorId, orderStatus: 'PROCESSING' },
    });
    const shipped = await prisma.transaction.count({
      where: { vendorId, orderStatus: 'SHIPPED' },
    });
    const delivered = await prisma.transaction.count({
      where: { vendorId, orderStatus: 'DELIVERED' },
    });
    const cancelled = await prisma.transaction.count({
      where: { vendorId, orderStatus: 'CANCELLED' },
    });

    // Get total revenue
    const revenue = await prisma.transaction.aggregate({
      where: { vendorId, status: 'COMPLETED' },
      _sum: { amount: true },
    });

    return {
      pending,
      processing,
      shipped,
      delivered,
      cancelled,
      totalRevenue: revenue._sum.amount || 0,
    };
  }
}
