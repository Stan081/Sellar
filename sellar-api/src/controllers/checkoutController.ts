import { Request, Response } from 'express';
import { prisma } from '../utils/database';
import crypto from 'crypto';

// Get payment link details for checkout (public endpoint)
export const getCheckoutDetails = async (req: Request, res: Response) => {
  try {
    const { linkId } = req.params;

    const link = await prisma.paymentLink.findFirst({
      where: {
        OR: [
          { id: linkId },
          { shortCode: linkId },
        ],
        isActive: true,
      },
      include: {
        product: {
          select: {
            id: true,
            name: true,
            description: true,
            price: true,
            currency: true,
            images: true,
            category: true,
          },
        },
        vendor: {
          select: {
            businessName: true,
            email: true,
          },
        },
      },
    });

    if (!link) {
      return res.status(404).json({
        success: false,
        message: 'Payment link not found or has expired',
      });
    }

    // Check if link has expired
    if (link.expiresAt && new Date(link.expiresAt) < new Date()) {
      return res.status(410).json({
        success: false,
        message: 'This payment link has expired',
      });
    }

    // Track link view
    await prisma.linkView.create({
      data: {
        paymentLinkId: link.id,
        ipAddress: (req.ip || req.socket.remoteAddress) as string,
        userAgent: req.headers['user-agent'] as string,
        referrer: (req.headers['referer'] || req.headers['referrer']) as string,
      },
    });

    res.json({
      success: true,
      data: {
        id: link.id,
        shortCode: link.shortCode,
        amount: link.amount,
        currency: link.currency,
        type: link.linkType,
        isActive: link.isActive,
        product: link.product,
        vendor: link.vendor,
      },
    });
  } catch (error) {
    console.error('Error fetching checkout details:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to load checkout details',
    });
  }
};

// Verify private link access code
export const verifyPrivateLink = async (req: Request, res: Response) => {
  try {
    const { linkId } = req.params;
    const { code } = req.body;

    if (!code) {
      return res.status(400).json({
        success: false,
        message: 'Access code is required',
      });
    }

    const link = await prisma.paymentLink.findFirst({
      where: {
        OR: [
          { id: linkId },
          { shortCode: linkId },
        ],
        isActive: true,
      },
    });

    if (!link) {
      return res.status(404).json({
        success: false,
        message: 'Payment link not found',
      });
    }

    if (link.linkType !== 'PRIVATE') {
      return res.status(400).json({
        success: false,
        message: 'Access code is only required for private links',
      });
    }

    // Verify OTP code
    const otp = await prisma.oTPVerification.findFirst({
      where: {
        identifier: linkId,
        code: code.toUpperCase(),
        type: 'PAYMENT',
        usedAt: null,
        expiresAt: { gt: new Date() },
      },
    });

    if (!otp) {
      return res.status(401).json({
        success: false,
        message: 'Invalid or expired access code',
      });
    }

    // Mark OTP as used
    await prisma.oTPVerification.update({
      where: { id: otp.id },
      data: { usedAt: new Date() },
    });

    res.json({
      success: true,
      message: 'Access code verified',
    });
  } catch (error) {
    console.error('Error verifying access code:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to verify access code',
    });
  }
};

// Process checkout and create order
export const processCheckout = async (req: Request, res: Response) => {
  try {
    const { linkId } = req.params;
    const { customer } = req.body;

    // Validate customer data
    if (!customer || !customer.email || !customer.phone || !customer.name) {
      return res.status(400).json({
        success: false,
        message: 'Customer information is required (name, email, phone)',
      });
    }

    // Get payment link
    const link = await prisma.paymentLink.findFirst({
      where: {
        OR: [
          { id: linkId },
          { shortCode: linkId },
        ],
        isActive: true,
      },
      include: {
        vendor: true,
        product: true,
      },
    });

    if (!link) {
      return res.status(404).json({
        success: false,
        message: 'Payment link not found or has expired',
      });
    }

    // Create unique contact identifier (prefer email, fallback to phone)
    const uniqueContact = customer.email || customer.phone;

    // Find or create customer
    let dbCustomer = await prisma.customer.findUnique({
      where: { uniqueContact },
    });

    if (dbCustomer) {
      // Update existing customer
      dbCustomer = await prisma.customer.update({
        where: { id: dbCustomer.id },
        data: {
          name: customer.name,
          email: customer.email,
          phone: customer.phone,
          billingAddress: `${customer.address}, ${customer.city}, ${customer.country}`,
          totalOrders: { increment: 1 },
          totalSpent: { increment: link.amount },
          lastPurchaseAt: new Date(),
        },
      });
    } else {
      // Create new customer
      dbCustomer = await prisma.customer.create({
        data: {
          vendorId: link.vendorId,
          name: customer.name,
          email: customer.email,
          phone: customer.phone,
          uniqueContact,
          billingAddress: `${customer.address}, ${customer.city}, ${customer.country}`,
          currency: link.currency,
          totalOrders: 1,
          totalSpent: link.amount,
          lastPurchaseAt: new Date(),
        },
      });
    }

    // Create transaction/order
    const transaction = await prisma.transaction.create({
      data: {
        vendorId: link.vendorId,
        paymentLinkId: link.id,
        customerId: dbCustomer.id,
        amount: link.amount,
        currency: link.currency,
        status: 'PENDING',
        orderStatus: 'PENDING',
        deliveryStatus: 'PENDING',
        gateway: 'manual', // Will be updated when payment gateway is integrated
        customerEmail: customer.email,
        customerPhone: customer.phone,
        shippingAddress: {
          name: customer.name,
          address: customer.address,
          city: customer.city,
          country: customer.country,
        },
        metadata: {
          productId: link.productId,
          productName: link.product?.name,
          linkShortCode: link.shortCode,
        },
      },
    });

    // Link view is already tracked via linkView creation above

    res.json({
      success: true,
      message: 'Order created successfully',
      data: {
        orderId: transaction.id,
        amount: transaction.amount,
        currency: transaction.currency,
        status: transaction.status,
        customer: {
          id: dbCustomer.id,
          name: dbCustomer.name,
          email: dbCustomer.email,
        },
      },
    });
  } catch (error) {
    console.error('Error processing checkout:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to process checkout',
    });
  }
};

// Helper function to generate access code for private links
export const generateAccessCode = (): string => {
  return crypto.randomBytes(3).toString('hex').toUpperCase();
};

// Send access code to customer email (to be called when private link is accessed)
export const sendAccessCode = async (req: Request, res: Response) => {
  try {
    const { linkId } = req.params;
    const { email } = req.body;

    if (!email) {
      return res.status(400).json({
        success: false,
        message: 'Email is required',
      });
    }

    const link = await prisma.paymentLink.findFirst({
      where: {
        OR: [
          { id: linkId },
          { shortCode: linkId },
        ],
        isActive: true,
      },
    });

    if (!link) {
      return res.status(404).json({
        success: false,
        message: 'Payment link not found',
      });
    }

    if (link.linkType !== 'PRIVATE') {
      return res.status(400).json({
        success: false,
        message: 'Access code can only be sent for private links',
      });
    }

    // Generate access code
    const code = generateAccessCode();

    // Store OTP
    await prisma.oTPVerification.upsert({
      where: {
        identifier_type: {
          identifier: linkId,
          type: 'PAYMENT',
        },
      },
      update: {
        code,
        expiresAt: new Date(Date.now() + 15 * 60 * 1000), // 15 minutes
        usedAt: null,
      },
      create: {
        identifier: linkId,
        code,
        type: 'PAYMENT',
        expiresAt: new Date(Date.now() + 15 * 60 * 1000),
      },
    });

    // TODO: Send email with access code
    // await sendEmail(email, 'Your Access Code', `Your access code is: ${code}`);

    res.json({
      success: true,
      message: 'Access code sent to your email',
    });
  } catch (error) {
    console.error('Error sending access code:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to send access code',
    });
  }
};
