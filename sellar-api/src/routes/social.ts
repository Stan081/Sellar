import { Router } from 'express';
import { authenticateToken } from '../middleware/auth';
import {
  connectFacebook,
  connectInstagram,
  oauthCallback,
  getConnections,
  disconnectPlatform,
  postToFacebook,
  postToInstagram,
} from '../controllers/socialController';

const router = Router();

// OAuth initiation — browser redirect, token passed as ?token= query param
router.get('/facebook/connect', connectFacebook);
router.get('/instagram/connect', connectInstagram);

// Unified OAuth callback — platform resolved from state param
router.get('/callback', oauthCallback);

// Connection management
router.get('/connections', authenticateToken, getConnections);
router.delete('/:platform/disconnect', authenticateToken, disconnectPlatform);

// Post endpoints
router.post('/facebook/post', authenticateToken, postToFacebook);
router.post('/instagram/post', authenticateToken, postToInstagram);

export default router;
