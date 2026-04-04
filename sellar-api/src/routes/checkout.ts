import { Router } from 'express';
import {
  getCheckoutDetails,
  verifyPrivateLink,
  processCheckout,
} from '../controllers/checkoutController';

const router = Router();

// GET /api/checkout/:linkId - Get payment link details for checkout (public)
router.get('/:linkId', getCheckoutDetails);

// POST /api/checkout/:linkId/verify - Verify private link access code
router.post('/:linkId/verify', verifyPrivateLink);

// POST /api/checkout/:linkId/pay - Process checkout and create order
router.post('/:linkId/pay', processCheckout);

export default router;
