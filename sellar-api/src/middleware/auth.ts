import { Request, Response, NextFunction } from 'express';
import jwt from 'jsonwebtoken';
import { prisma } from '../utils/database';

export interface AuthRequest extends Request {
  vendor?: {
    id: string;
    email: string;
    businessName: string;
  };
}

export const authenticateToken = async (
  req: AuthRequest,
  res: Response,
  next: NextFunction
) => {
  try {
    const authHeader = req.headers['authorization'];
    const token = authHeader && authHeader.split(' ')[1];

    if (!token) {
      return res.status(401).json({ error: 'Access token required' });
    }

    const decoded = jwt.verify(token, process.env.JWT_SECRET!) as any;
    
    // Verify vendor exists in database
    const vendor = await prisma.vendor.findUnique({
      where: { id: decoded.vendorId },
      select: {
        id: true,
        email: true,
        businessName: true,
      }
    });

    if (!vendor) {
      return res.status(401).json({ error: 'Invalid token - vendor not found' });
    }

    req.vendor = vendor;
    next();
  } catch (error) {
    return res.status(403).json({ error: 'Invalid or expired token' });
  }
};

// Export as authenticate for consistency with other route files
export const authenticate = authenticateToken;
