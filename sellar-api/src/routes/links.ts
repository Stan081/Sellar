import { Router } from 'express';
import { authenticateToken } from '../middleware/auth';
import {
  getLinks,
  getLink,
  createLink,
  deactivateLink,
  deleteLink,
} from '../controllers/linkController';

const router = Router();

router.use(authenticateToken);

router.get('/', getLinks);
router.get('/:id', getLink);
router.post('/', createLink);
router.patch('/:id/deactivate', deactivateLink);
router.put('/:id/deactivate', deactivateLink);
router.delete('/:id', deleteLink);

export default router;
