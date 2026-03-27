import { Response } from 'express';
import { AuthRequest } from '../middleware/auth';
import { CustomerService } from '../services/customerService';

const service = new CustomerService();

export const getCustomers = async (req: AuthRequest, res: Response) => {
  try {
    const data = await service.listCustomers(req.vendor!.id);
    res.json({ data });
  } catch (err: any) {
    res.status(500).json({ error: err.message ?? 'Failed to fetch customers' });
  }
};

export const getCustomer = async (req: AuthRequest, res: Response) => {
  try {
    const data = await service.getCustomer(req.params.id, req.vendor!.id);
    res.json({ data });
  } catch (err: any) {
    const status = err.message === 'Customer not found' ? 404 : 500;
    res.status(status).json({ error: err.message });
  }
};
