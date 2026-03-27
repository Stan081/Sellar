import { Router } from 'express';
import { authenticateToken } from '../middleware/auth';
import { getCustomers, getCustomer } from '../controllers/customerController';

const router = Router();

router.use(authenticateToken);

router.get('/', getCustomers);
router.get('/:id', getCustomer);

export default router;
