import { ProductRepository } from '../repositories/productRepository';

const repo = new ProductRepository();

export class ProductService {
  async listProducts(vendorId: string) {
    return repo.findAllByVendor(vendorId);
  }

  async getProduct(id: string, vendorId: string) {
    const product = await repo.findOneByVendor(id, vendorId);
    if (!product) throw new Error('Product not found');
    return product;
  }

  async createProduct(vendorId: string, body: {
    name: string;
    description?: string;
    category: string;
    tags?: string[];
    price: number | string;
    quantity?: number | string | null;
    images?: string[];
  }) {
    const { name, description, category, tags, price, quantity, images } = body;
    if (!name || !category || price == null) {
      throw new Error('name, category, and price are required');
    }
    return repo.create(vendorId, {
      name,
      description: description ?? '',
      category,
      tags: tags ?? [],
      price: parseFloat(String(price)),
      quantity: quantity != null ? parseInt(String(quantity)) : null,
      images: images ?? [],
    });
  }

  async updateProduct(id: string, vendorId: string, body: {
    name?: string;
    description?: string;
    category?: string;
    tags?: string[];
    price?: number | string;
    quantity?: number | string | null;
    images?: string[];
    isActive?: boolean;
  }) {
    const existing = await repo.findOneByVendor(id, vendorId);
    if (!existing) throw new Error('Product not found');

    const { name, description, category, tags, price, quantity, images, isActive } = body;
    return repo.update(id, {
      ...(name !== undefined && { name }),
      ...(description !== undefined && { description }),
      ...(category !== undefined && { category }),
      ...(tags !== undefined && { tags }),
      ...(price !== undefined && { price: parseFloat(String(price)) }),
      ...(quantity !== undefined && { quantity: quantity != null ? parseInt(String(quantity)) : null }),
      ...(images !== undefined && { images }),
      ...(isActive !== undefined && { isActive }),
    });
  }

  async deleteProduct(id: string, vendorId: string) {
    const existing = await repo.findOneByVendor(id, vendorId);
    if (!existing) throw new Error('Product not found');
    return repo.delete(id);
  }
}
