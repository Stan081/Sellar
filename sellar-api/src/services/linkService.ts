import { randomBytes } from 'crypto';
import { LinkRepository } from '../repositories/linkRepository';
import { ProductRepository } from '../repositories/productRepository';

const linkRepo = new LinkRepository();
const productRepo = new ProductRepository();

export class LinkService {
  async listLinks(vendorId: string) {
    return linkRepo.findAllByVendor(vendorId);
  }

  async getLink(id: string, vendorId: string) {
    const link = await linkRepo.findOneByVendor(id, vendorId);
    if (!link) throw new Error('Link not found');
    return link;
  }

  async createLink(vendorId: string, body: {
    productId?: string;
    amount: number | string;
    currency: string;
    linkType?: string;
    isReusable?: boolean;
    expiresAt?: string;
  }) {
    const { productId, amount, currency, linkType, isReusable, expiresAt } = body;

    if (!amount || !currency) throw new Error('amount and currency are required');

    if (productId) {
      const product = await productRepo.findOneByVendor(productId, vendorId);
      if (!product) throw new Error('Product not found');
    }

    return linkRepo.create({
      vendorId,
      productId: productId ?? null,
      amount: parseFloat(String(amount)),
      currency,
      linkType: linkType === 'PRIVATE' ? 'PRIVATE' : 'PUBLIC',
      isReusable: isReusable ?? false,
      expiresAt: expiresAt ? new Date(expiresAt) : null,
      shortCode: randomBytes(5).toString('hex'),
    });
  }

  async deactivateLink(id: string, vendorId: string) {
    const existing = await linkRepo.findOneByVendor(id, vendorId);
    if (!existing) throw new Error('Link not found');
    return linkRepo.deactivate(id);
  }

  async deleteLink(id: string, vendorId: string) {
    const existing = await linkRepo.findOneByVendor(id, vendorId);
    if (!existing) throw new Error('Link not found');
    return linkRepo.delete(id);
  }
}
