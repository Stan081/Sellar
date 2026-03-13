import { Router } from 'express';
import { authenticateToken } from '../middleware/auth';
import { upload, uploadImage, uploadMultipleImages } from '../controllers/uploadController';

const router = Router();

router.post('/image', authenticateToken, upload.single('image'), uploadImage);
router.post('/images', authenticateToken, upload.array('images', 10), uploadMultipleImages);

export default router;
