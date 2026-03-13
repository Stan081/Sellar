import { Response } from 'express';
import { AuthRequest } from '../middleware/auth';
import { ProductService } from '../services/productService';

const service = new ProductService();

export const getProducts = async (req: AuthRequest, res: Response) => {
  try {
    const data = await service.listProducts(req.vendor!.id);
    res.json({ data });
  } catch (err: any) {
    res.status(500).json({ error: err.message ?? 'Failed to fetch products' });
  }
};

export const getProduct = async (req: AuthRequest, res: Response) => {
  try {
    const data = await service.getProduct(req.params.id, req.vendor!.id);
    res.json({ data });
  } catch (err: any) {
    const status = err.message === 'Product not found' ? 404 : 500;
    res.status(status).json({ error: err.message });
  }
};

export const createProduct = async (req: AuthRequest, res: Response) => {
  try {
    const data = await service.createProduct(req.vendor!.id, req.body);
    res.status(201).json({ message: 'Product created', data });
  } catch (err: any) {
    const status = err.message.includes('required') ? 400 : 500;
    res.status(status).json({ error: err.message });
  }
};

export const updateProduct = async (req: AuthRequest, res: Response) => {
  try {
    const data = await service.updateProduct(req.params.id, req.vendor!.id, req.body);
    res.json({ message: 'Product updated', data });
  } catch (err: any) {
    const status = err.message === 'Product not found' ? 404 : 500;
    res.status(status).json({ error: err.message });
  }
};

export const deleteProduct = async (req: AuthRequest, res: Response) => {
  try {
    await service.deleteProduct(req.params.id, req.vendor!.id);
    res.json({ message: 'Product deleted' });
  } catch (err: any) {
    const status = err.message === 'Product not found' ? 404 : 500;
    res.status(status).json({ error: err.message });
  }
};
