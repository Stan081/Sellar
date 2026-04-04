import { OrderRepository, OrderFilters } from '../repositories/orderRepository';

export class OrderService {
  constructor(private orderRepository: OrderRepository) {}

  async getOrders(vendorId: string, filters: OrderFilters = {}) {
    return this.orderRepository.findAllByVendor(vendorId, filters);
  }

  async getOrder(id: string, vendorId: string) {
    const order = await this.orderRepository.findOneByVendor(id, vendorId);
    if (!order) {
      throw new Error('Order not found');
    }
    return order;
  }

  async updateOrderStatus(id: string, vendorId: string, orderStatus: string) {
    // Validate order status
    const validStatuses = ['PENDING', 'PROCESSING', 'SHIPPED', 'DELIVERED', 'CANCELLED'];
    if (!validStatuses.includes(orderStatus)) {
      throw new Error('Invalid order status');
    }

    return this.orderRepository.updateOrderStatus(id, vendorId, orderStatus);
  }

  async updateDeliveryStatus(
    id: string,
    vendorId: string,
    deliveryStatus: string,
    trackingNumber?: string,
    estimatedDelivery?: Date
  ) {
    // Validate delivery status
    const validStatuses = ['PENDING', 'PREPARING', 'SHIPPED', 'IN_TRANSIT', 'DELIVERED'];
    if (!validStatuses.includes(deliveryStatus)) {
      throw new Error('Invalid delivery status');
    }

    return this.orderRepository.updateDeliveryStatus(
      id,
      vendorId,
      deliveryStatus,
      trackingNumber,
      estimatedDelivery
    );
  }

  async updateOrderNotes(id: string, vendorId: string, notes: string) {
    return this.orderRepository.updateOrderNotes(id, vendorId, notes);
  }

  async getOrderStats(vendorId: string) {
    return this.orderRepository.getOrderStats(vendorId);
  }

  async getOrdersByStatus(vendorId: string, status: 'pending' | 'processing' | 'completed') {
    let orderStatus: string;
    
    switch (status) {
      case 'pending':
        orderStatus = 'PENDING';
        break;
      case 'processing':
        orderStatus = 'PROCESSING';
        break;
      case 'completed':
        orderStatus = 'DELIVERED';
        break;
      default:
        throw new Error('Invalid status filter');
    }

    return this.orderRepository.findAllByVendor(vendorId, { orderStatus });
  }
}
