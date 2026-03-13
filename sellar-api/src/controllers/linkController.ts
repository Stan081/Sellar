import { Response } from 'express';
import { AuthRequest } from '../middleware/auth';
import { LinkService } from '../services/linkService';

const service = new LinkService();

export const getLinks = async (req: AuthRequest, res: Response) => {
  try {
    res.json({ data: await service.listLinks(req.vendor!.id) });
  } catch (err: any) {
    res.status(500).json({ error: err.message ?? 'Failed to fetch links' });
  }
};

export const getLink = async (req: AuthRequest, res: Response) => {
  try {
    res.json({ data: await service.getLink(req.params.id, req.vendor!.id) });
  } catch (err: any) {
    const status = err.message === 'Link not found' ? 404 : 500;
    res.status(status).json({ error: err.message });
  }
};

export const createLink = async (req: AuthRequest, res: Response) => {
  try {
    const data = await service.createLink(req.vendor!.id, req.body);
    res.status(201).json({ message: 'Payment link created', data });
  } catch (err: any) {
    const status = err.message.includes('required') || err.message === 'Product not found' ? 400 : 500;
    res.status(status).json({ error: err.message });
  }
};

export const deactivateLink = async (req: AuthRequest, res: Response) => {
  try {
    const data = await service.deactivateLink(req.params.id, req.vendor!.id);
    res.json({ message: 'Link deactivated', data });
  } catch (err: any) {
    const status = err.message === 'Link not found' ? 404 : 500;
    res.status(status).json({ error: err.message });
  }
};

export const deleteLink = async (req: AuthRequest, res: Response) => {
  try {
    await service.deleteLink(req.params.id, req.vendor!.id);
    res.json({ message: 'Link deleted' });
  } catch (err: any) {
    const status = err.message === 'Link not found' ? 404 : 500;
    res.status(status).json({ error: err.message });
  }
};
