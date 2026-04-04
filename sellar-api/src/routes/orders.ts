import { Router } from 'express';
import { authenticate } from '../middleware/auth';
import {
  getOrders,
  getOrder,
  updateOrderStatus,
  updateDeliveryStatus,
  updateOrderNotes,
  getOrderStats,
} from '../controllers/orderController';

const router = Router();

// Apply authentication middleware to all routes
router.use(authenticate);

// GET /api/orders - Get all orders for the vendor
router.get('/', getOrders);

// GET /api/orders/stats - Get order statistics
router.get('/stats', getOrderStats);

// GET /api/orders/:id - Get a single order
router.get('/:id', getOrder);

// PUT /api/orders/:id/status - Update order status
router.put('/:id/status', updateOrderStatus);

// PUT /api/orders/:id/delivery - Update delivery status
router.put('/:id/delivery', updateDeliveryStatus);

// PUT /api/orders/:id/notes - Update order notes
router.put('/:id/notes', updateOrderNotes);

export default router;
