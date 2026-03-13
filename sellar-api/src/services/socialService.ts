import { SocialRepository } from '../repositories/socialRepository';

const FB_GRAPH = 'https://graph.facebook.com/v19.0';
const repo = new SocialRepository();

type Platform = 'FACEBOOK' | 'INSTAGRAM' | 'WHATSAPP' | 'TIKTOK';

export class SocialService {
  listConnections(vendorId: string) {
    return repo.findAllByVendor(vendorId);
  }

  async disconnect(vendorId: string, platform: string) {
    await repo.deleteByVendorAndPlatform(vendorId, platform.toUpperCase() as Platform);
  }

  async handleOAuthCallback(params: {
    vendorId: string;
    platform: string;
    code: string;
    callbackUri: string;
  }): Promise<{ platform: string; username: string }> {
    const { vendorId, platform, code, callbackUri } = params;

    // Exchange code for short-lived token
    const tokenRes = await fetch(
      `${FB_GRAPH}/oauth/access_token?` +
        new URLSearchParams({
          client_id: process.env.FB_APP_ID ?? '',
          client_secret: process.env.FB_APP_SECRET ?? '',
          redirect_uri: callbackUri,
          code,
        })
    );
    const tokenData = (await tokenRes.json()) as { access_token?: string; error?: { message: string } };
    if (!tokenData.access_token) throw new Error(tokenData.error?.message ?? 'No access token');

    // Exchange for long-lived token
    const llRes = await fetch(
      `${FB_GRAPH}/oauth/access_token?` +
        new URLSearchParams({
          grant_type: 'fb_exchange_token',
          client_id: process.env.FB_APP_ID ?? '',
          client_secret: process.env.FB_APP_SECRET ?? '',
          fb_exchange_token: tokenData.access_token,
        })
    );
    const llData = (await llRes.json()) as { access_token?: string; expires_in?: number };
    const longLivedToken = llData.access_token ?? tokenData.access_token;
    const expiresAt = llData.expires_in ? new Date(Date.now() + llData.expires_in * 1000) : null;

    // Get user profile
    const meRes = await fetch(`${FB_GRAPH}/me?fields=id,name&access_token=${longLivedToken}`);
    const me = (await meRes.json()) as { id: string; name: string };

    if (platform === 'instagram') {
      return this._connectInstagram(vendorId, longLivedToken, expiresAt, me);
    }
    return this._connectFacebook(vendorId, longLivedToken, expiresAt, me);
  }

  private async _connectFacebook(
    vendorId: string,
    longLivedToken: string,
    expiresAt: Date | null,
    me: { id: string; name: string }
  ) {
    const pagesRes = await fetch(`${FB_GRAPH}/me/accounts?fields=id,name,access_token&access_token=${longLivedToken}`);
    const pagesData = (await pagesRes.json()) as { data?: Array<{ id: string; name: string; access_token: string }> };
    const firstPage = pagesData.data?.[0];

    await repo.upsertConnection({
      vendorId,
      platform: 'FACEBOOK',
      accessToken: longLivedToken,
      tokenExpiresAt: expiresAt,
      platformUserId: me.id,
      platformUsername: me.name,
      pageId: firstPage?.id ?? null,
      pageName: firstPage?.name ?? null,
      scopes: ['pages_manage_posts', 'pages_read_engagement'],
    });

    return { platform: 'facebook', username: me.name };
  }

  private async _connectInstagram(
    vendorId: string,
    longLivedToken: string,
    expiresAt: Date | null,
    me: { id: string; name: string }
  ) {
    const pagesRes = await fetch(
      `${FB_GRAPH}/me/accounts?fields=id,name,access_token,instagram_business_account&access_token=${longLivedToken}`
    );
    const pagesData = (await pagesRes.json()) as {
      data?: Array<{ id: string; name: string; access_token: string; instagram_business_account?: { id: string } }>;
    };
    const pageWithIG = pagesData.data?.find(p => p.instagram_business_account);
    const igUserId = pageWithIG?.instagram_business_account?.id ?? null;

    let igUsername = '';
    if (igUserId) {
      const igRes = await fetch(`${FB_GRAPH}/${igUserId}?fields=username&access_token=${longLivedToken}`);
      const igData = (await igRes.json()) as { username?: string };
      igUsername = igData.username ?? '';
    }

    await repo.upsertConnection({
      vendorId,
      platform: 'INSTAGRAM',
      accessToken: longLivedToken,
      tokenExpiresAt: expiresAt,
      platformUserId: igUserId,
      platformUsername: igUsername || pageWithIG?.name || me.name,
      pageId: pageWithIG?.id ?? null,
      scopes: ['instagram_content_publish'],
    });

    return { platform: 'instagram', username: igUsername || me.name };
  }

  async postToFacebook(vendorId: string, message: string, imageUrl?: string) {
    const conn = await repo.findConnection(vendorId, 'FACEBOOK');
    if (!conn || !conn.isActive) throw new Error('Facebook not connected');
    if (!conn.pageId) throw new Error('No Facebook Page linked — reconnect to choose a page');

    if (imageUrl) {
      const r = await fetch(`${FB_GRAPH}/${conn.pageId}/photos`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ url: imageUrl, caption: message, access_token: conn.accessToken }),
      });
      const data = (await r.json()) as { id?: string; error?: { message: string } };
      if (!data.id) throw new Error(data.error?.message ?? 'Post failed');
      return { postId: data.id };
    }

    const r = await fetch(`${FB_GRAPH}/${conn.pageId}/feed`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ message, access_token: conn.accessToken }),
    });
    const data = (await r.json()) as { id?: string; error?: { message: string } };
    if (!data.id) throw new Error(data.error?.message ?? 'Post failed');
    return { postId: data.id };
  }

  async postToInstagram(vendorId: string, caption: string, imageUrl: string) {
    if (!imageUrl) throw new Error('imageUrl is required for Instagram posts');

    const conn = await repo.findConnection(vendorId, 'INSTAGRAM');
    if (!conn || !conn.isActive) throw new Error('Instagram not connected');
    if (!conn.platformUserId) throw new Error('No Instagram Business account linked — reconnect');

    // Step 1: Create media container
    const containerRes = await fetch(`${FB_GRAPH}/${conn.platformUserId}/media`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ image_url: imageUrl, caption, access_token: conn.accessToken }),
    });
    const container = (await containerRes.json()) as { id?: string; error?: { message: string } };
    if (!container.id) throw new Error(container.error?.message ?? 'Failed to create media container');

    // Step 2: Wait briefly then publish
    await new Promise(r => setTimeout(r, 2000));

    const publishRes = await fetch(`${FB_GRAPH}/${conn.platformUserId}/media_publish`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ creation_id: container.id, access_token: conn.accessToken }),
    });
    const published = (await publishRes.json()) as { id?: string; error?: { message: string } };
    if (!published.id) throw new Error(published.error?.message ?? 'Failed to publish media');

    return { postId: published.id };
  }
}
