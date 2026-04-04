import { Response } from 'express';
import { OrderService } from '../services/orderService';
import { OrderRepository } from '../repositories/orderRepository';

const orderRepository = new OrderRepository();
const orderService = new OrderService(orderRepository);

// Get all orders for a vendor
export const getOrders = async (req: any, res: Response) => {
  try {
    const vendorId = req.vendor!.id;
    const { status, orderStatus, deliveryStatus, startDate, endDate, search } = req.query;

    const filters: any = {};
    if (status) filters.status = status;
    if (orderStatus) filters.orderStatus = orderStatus;
    if (deliveryStatus) filters.deliveryStatus = deliveryStatus;
    if (startDate) filters.startDate = startDate as string;
    if (endDate) filters.endDate = endDate as string;
    if (search) filters.search = search as string;

    const orders = await orderService.getOrders(vendorId, filters);
    
    res.json({
      success: true,
      data: orders,
    });
  } catch (error) {
    console.error('Error fetching orders:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to fetch orders',
    });
  }
};

// Get a single order
export const getOrder = async (req: any, res: Response) => {
  try {
    const vendorId = req.vendor!.id;
    const { id } = req.params;

    const order = await orderService.getOrder(id, vendorId);
    
    res.json({
      success: true,
      data: order,
    });
  } catch (error) {
    console.error('Error fetching order:', error);
    if (error instanceof Error && error.message === 'Order not found') {
      res.status(404).json({
        success: false,
        message: 'Order not found',
      });
    } else {
      res.status(500).json({
        success: false,
        message: 'Failed to fetch order',
      });
    }
  }
};

// Update order status
export const updateOrderStatus = async (req: any, res: Response) => {
  try {
    const vendorId = req.vendor!.id;
    const { id } = req.params;
    const { orderStatus } = req.body;

    if (!orderStatus) {
      return res.status(400).json({
        success: false,
        message: 'Order status is required',
      });
    }

    const order = await orderService.updateOrderStatus(id, vendorId, orderStatus);
    
    res.json({
      success: true,
      data: order,
      message: 'Order status updated successfully',
    });
  } catch (error) {
    console.error('Error updating order status:', error);
    if (error instanceof Error && error.message === 'Invalid order status') {
      res.status(400).json({
        success: false,
        message: 'Invalid order status',
      });
    } else {
      res.status(500).json({
        success: false,
        message: 'Failed to update order status',
      });
    }
  }
};

// Update delivery status
export const updateDeliveryStatus = async (req: any, res: Response) => {
  try {
    const vendorId = req.vendor!.id;
    const { id } = req.params;
    const { deliveryStatus, trackingNumber, estimatedDelivery } = req.body;

    if (!deliveryStatus) {
      return res.status(400).json({
        success: false,
        message: 'Delivery status is required',
      });
    }

    const order = await orderService.updateDeliveryStatus(
      id,
      vendorId,
      deliveryStatus,
      trackingNumber,
      estimatedDelivery ? new Date(estimatedDelivery) : undefined
    );
    
    res.json({
      success: true,
      data: order,
      message: 'Delivery status updated successfully',
    });
  } catch (error) {
    console.error('Error updating delivery status:', error);
    if (error instanceof Error && error.message === 'Invalid delivery status') {
      res.status(400).json({
        success: false,
        message: 'Invalid delivery status',
      });
    } else {
      res.status(500).json({
        success: false,
        message: 'Failed to update delivery status',
      });
    }
  }
};

// Update order notes
export const updateOrderNotes = async (req: any, res: Response) => {
  try {
    const vendorId = req.vendor!.id;
    const { id } = req.params;
    const { notes } = req.body;

    const order = await orderService.updateOrderNotes(id, vendorId, notes);
    
    res.json({
      success: true,
      data: order,
      message: 'Order notes updated successfully',
    });
  } catch (error) {
    console.error('Error updating order notes:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to update order notes',
    });
  }
};

// Get order statistics
export const getOrderStats = async (req: any, res: Response) => {
  try {
    const vendorId = req.vendor!.id;

    const stats = await orderService.getOrderStats(vendorId);
    
    res.json({
      success: true,
      data: stats,
    });
  } catch (error) {
    console.error('Error fetching order stats:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to fetch order statistics',
    });
  }
};
