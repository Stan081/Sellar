import { Request, Response } from 'express';
import { AuthRequest } from '../middleware/auth';
import { SocialService } from '../services/socialService';
import jwt from 'jsonwebtoken';

const service = new SocialService();

const vendorIdFromToken = (token?: string): string | null => {
  if (!token) return null;
  try {
    const decoded = jwt.verify(token, process.env.JWT_SECRET!) as any;
    return decoded.vendorId ?? null;
  } catch {
    return null;
  }
};

// ─── OAuth initiation ─────────────────────────────────────────────────────────

export const connectFacebook = (req: Request, res: Response) => {
  const vendorId = vendorIdFromToken(req.query.token as string);
  if (!vendorId) {
    return res.status(401).json({ error: 'Valid ?token= query param required' });
  }
  const state = Buffer.from(JSON.stringify({ vendorId, platform: 'facebook' })).toString('base64url');
  const params = new URLSearchParams({
    client_id: process.env.FB_APP_ID ?? '',
    redirect_uri: `${process.env.API_BASE_URL}/api/social/callback`,
    scope: 'email,public_profile,pages_show_list,pages_read_engagement,pages_manage_posts',
    response_type: 'code',
    state,
  });
  return res.redirect(`https://www.facebook.com/v19.0/dialog/oauth?${params}`);
};

export const connectInstagram = (req: Request, res: Response) => {
  const vendorId = vendorIdFromToken(req.query.token as string);
  if (!vendorId) {
    return res.status(401).json({ error: 'Valid ?token= query param required' });
  }
  const state = Buffer.from(JSON.stringify({ vendorId, platform: 'instagram' })).toString('base64url');
  const params = new URLSearchParams({
    client_id: process.env.FB_APP_ID ?? '',
    redirect_uri: `${process.env.API_BASE_URL}/api/social/callback`,
    scope: 'email,public_profile,pages_show_list,pages_read_engagement,pages_manage_posts,instagram_content_publish',
    response_type: 'code',
    state,
  });
  return res.redirect(`https://www.facebook.com/v19.0/dialog/oauth?${params}`);
};

// ─── OAuth callbacks ──────────────────────────────────────────────────────────

const decodeState = (state?: string): { vendorId?: string; platform?: string } => {
  try {
    return state ? JSON.parse(Buffer.from(state, 'base64url').toString('utf8')) : {};
  } catch {
    return {};
  }
};

export const oauthCallback = async (req: Request, res: Response) => {
  const { code, error, state } = req.query as Record<string, string>;
  const { vendorId, platform } = decodeState(state);
  const SCHEME = process.env.FLUTTER_APP_SCHEME ?? 'sellar';

  if (error || !code) {
    return res.redirect(`${SCHEME}://social/error?platform=${platform ?? 'unknown'}&error=${encodeURIComponent(error ?? 'cancelled')}`);
  }
  if (!vendorId) {
    return res.redirect(`${SCHEME}://social/error?platform=${platform ?? 'unknown'}&error=not_authenticated&hint=reconnect_from_app`);
  }

  try {
    const result = await service.handleOAuthCallback({
      vendorId,
      platform: platform ?? 'facebook',
      code,
      callbackUri: `${process.env.API_BASE_URL}/api/social/callback`,
    });
    res.redirect(`${SCHEME}://social/success?platform=${result.platform}&username=${encodeURIComponent(result.username)}`);
  } catch (err: any) {
    console.error('OAuth callback error:', err);
    res.redirect(`${SCHEME}://social/error?platform=${platform ?? 'unknown'}&error=${encodeURIComponent(err.message)}`);
  }
};

// ─── Get connection status ────────────────────────────────────────────────────

export const getConnections = async (req: AuthRequest, res: Response) => {
  try {
    res.json({ data: await service.listConnections(req.vendor!.id) });
  } catch {
    res.status(500).json({ error: 'Failed to fetch connections' });
  }
};

// ─── Disconnect ───────────────────────────────────────────────────────────────

export const disconnectPlatform = async (req: AuthRequest, res: Response) => {
  try {
    await service.disconnect(req.vendor!.id, req.params.platform);
    res.json({ message: `${req.params.platform} disconnected` });
  } catch {
    res.status(500).json({ error: 'Failed to disconnect' });
  }
};

// ─── Post to Facebook Page ────────────────────────────────────────────────────

export const postToFacebook = async (req: AuthRequest, res: Response) => {
  const { message, imageUrl } = req.body as { message: string; imageUrl?: string };
  try {
    const result = await service.postToFacebook(req.vendor!.id, message, imageUrl);
    res.json({ message: 'Posted to Facebook', ...result });
  } catch (err: any) {
    const status = err.message.includes('not connected') || err.message.includes('No Facebook') ? 400 : 500;
    res.status(status).json({ error: err.message });
  }
};

// ─── Post to Instagram ────────────────────────────────────────────────────────

export const postToInstagram = async (req: AuthRequest, res: Response) => {
  const { caption, imageUrl } = req.body as { caption: string; imageUrl: string };
  if (!imageUrl) return res.status(400).json({ error: 'imageUrl is required for Instagram posts' });
  try {
    const result = await service.postToInstagram(req.vendor!.id, caption, imageUrl);
    res.json({ message: 'Posted to Instagram', ...result });
  } catch (err: any) {
    const status = err.message.includes('not connected') || err.message.includes('No Instagram') ? 400 : 500;
    res.status(status).json({ error: err.message });
  }
};
