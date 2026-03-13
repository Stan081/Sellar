import { PrismaClient } from '@prisma/client';
import bcrypt from 'bcryptjs';

const prisma = new PrismaClient();

async function main() {
  console.log('🌱 Starting database seed...');

  // Clean up existing test data
  const existing = await prisma.vendor.findUnique({ where: { email: 'test@sellar.app' } });
  if (existing) {
    await prisma.vendor.delete({ where: { email: 'test@sellar.app' } });
    console.log('🧹 Cleaned up existing test vendor');
  }

  // Create a test vendor
  const hashedPassword = await bcrypt.hash('password123', 12);
  
  const testVendor = await prisma.vendor.create({
    data: {
      email: 'test@sellar.app',
      phone: '+12345678',
      password: hashedPassword,
      businessName: 'Test Business',
      firstName: 'John',
      lastName: 'Doe',
      country: 'United States',
      currency: 'USD',
      isEmailVerified: true,
      isPhoneVerified: true,
    },
  });

  console.log('✅ Created test vendor:', testVendor.email);

  // Create sample products
  const products = await Promise.all([
    prisma.product.create({
      data: {
        vendorId: testVendor.id,
        name: 'Wireless Headphones',
        description: 'Premium noise-canceling wireless headphones with 30-hour battery life and superior sound quality.',
        category: 'Electronics',
        tags: ['audio', 'wireless', 'bluetooth'],
        price: 299.99,
        quantity: 50,
        images: [
          'https://picsum.photos/seed/headphones/400/400',
        ],
      },
    }),
    prisma.product.create({
      data: {
        vendorId: testVendor.id,
        name: 'Leather Wallet',
        description: 'Genuine leather bifold wallet with RFID protection and 6 card slots.',
        category: 'Accessories',
        tags: ['leather', 'wallet', 'rfid'],
        price: 89.99,
        quantity: 100,
        images: [
          'https://picsum.photos/seed/wallet/400/400',
        ],
      },
    }),
    prisma.product.create({
      data: {
        vendorId: testVendor.id,
        name: 'Running Shoes',
        description: 'Professional running shoes with advanced cushioning technology for all-day comfort.',
        category: 'Footwear',
        tags: ['running', 'shoes', 'athletic'],
        price: 159.99,
        quantity: 75,
        images: [
          'https://picsum.photos/seed/shoes/400/400',
        ],
      },
    }),
    prisma.product.create({
      data: {
        vendorId: testVendor.id,
        name: 'Smart Watch Pro',
        description: 'Feature-rich smartwatch with health tracking, GPS, and 5-day battery life.',
        category: 'Electronics',
        tags: ['smartwatch', 'fitness', 'gps'],
        price: 399.99,
        quantity: 30,
        images: [
          'https://picsum.photos/seed/smartwatch/400/400',
        ],
      },
    }),
    prisma.product.create({
      data: {
        vendorId: testVendor.id,
        name: 'Mechanical Keyboard',
        description: 'TKL mechanical keyboard with Cherry MX switches and RGB backlighting.',
        category: 'Electronics',
        tags: ['keyboard', 'mechanical', 'gaming'],
        price: 129.99,
        quantity: 40,
        images: [
          'https://picsum.photos/seed/keyboard/400/400',
        ],
      },
    }),
    prisma.product.create({
      data: {
        vendorId: testVendor.id,
        name: 'Yoga Mat Premium',
        description: 'Non-slip eco-friendly yoga mat with alignment lines, 6mm thickness.',
        category: 'Sports',
        tags: ['yoga', 'fitness', 'mat'],
        price: 49.99,
        quantity: 120,
        images: [
          'https://picsum.photos/seed/yogamat/400/400',
        ],
      },
    }),
    prisma.product.create({
      data: {
        vendorId: testVendor.id,
        name: 'Ceramic Coffee Mug',
        description: 'Handcrafted ceramic mug, 350ml, microwave and dishwasher safe.',
        category: 'Home & Kitchen',
        tags: ['coffee', 'mug', 'ceramic'],
        price: 24.99,
        quantity: 200,
        images: [
          'https://picsum.photos/seed/coffeemug/400/400',
        ],
      },
    }),
    prisma.product.create({
      data: {
        vendorId: testVendor.id,
        name: 'Sunglasses Polarized',
        description: 'UV400 polarized sunglasses with lightweight titanium frame.',
        category: 'Accessories',
        tags: ['sunglasses', 'polarized', 'uv'],
        price: 79.99,
        quantity: 60,
        images: [
          'https://picsum.photos/seed/sunglasses/400/400',
        ],
      },
    }),
  ]);

  console.log(`✅ Created ${products.length} sample products`);

  // Create sample payment links
  const paymentLinks = await Promise.all([
    prisma.paymentLink.create({
      data: {
        vendorId: testVendor.id,
        productId: products[0].id,
        linkType: 'PUBLIC',
        amount: products[0].price,
        currency: 'USD',
        isReusable: true,
        shortCode: 'headphones123',
      },
    }),
    prisma.paymentLink.create({
      data: {
        vendorId: testVendor.id,
        productId: products[1].id,
        linkType: 'PRIVATE',
        amount: products[1].price,
        currency: 'USD',
        isReusable: false,
        shortCode: 'wallet123',
        expiresAt: new Date(Date.now() + 30 * 24 * 60 * 60 * 1000),
      },
    }),
    prisma.paymentLink.create({
      data: {
        vendorId: testVendor.id,
        productId: products[2].id,
        linkType: 'PUBLIC',
        amount: products[2].price,
        currency: 'USD',
        isReusable: true,
        shortCode: 'shoes456',
      },
    }),
  ]);

  console.log(`✅ Created ${paymentLinks.length} sample payment links`);

  // Create sample transactions
  const transactions = await Promise.all([
    prisma.transaction.create({
      data: {
        vendorId: testVendor.id,
        paymentLinkId: paymentLinks[0].id,
        amount: 2999.99,
        currency: 'USD',
        status: 'COMPLETED',
        gateway: 'stripe',
        gatewayTxId: 'ch_123',
        customerEmail: 'customer1@example.com',
        completedAt: new Date(),
      },
    }),
    prisma.transaction.create({
      data: {
        vendorId: testVendor.id,
        paymentLinkId: paymentLinks[0].id,
        amount: 2999.99,
        currency: 'USD',
        status: 'COMPLETED',
        gateway: 'stripe',
        gatewayTxId: 'ch_124',
        customerEmail: 'customer2@example.com',
        completedAt: new Date(),
      },
    }),
  ]);

  console.log(`✅ Created ${transactions.length} sample transactions`);

  // Create sample customers
  const customers = await Promise.all([
    prisma.customer.create({
      data: {
        vendorId: testVendor.id,
        email: 'customer1@example.com',
        uniqueContact: 'customer1@example.com',
        totalOrders: 1,
        totalSpent: 2999.99,
      },
    }),
    prisma.customer.create({
      data: {
        vendorId: testVendor.id,
        email: 'customer2@example.com',
        uniqueContact: 'customer2@example.com',
        totalOrders: 1,
        totalSpent: 2999.99,
      },
    }),
  ]);

  console.log(`✅ Created ${customers.length} sample customers`);

  console.log('🎉 Database seed completed successfully!');
  console.log('');
  console.log('📧 Test vendor credentials:');
  console.log('   Email: test@sellar.app');
  console.log('   Phone: +12345678');
  console.log('   Password: password123');
  console.log('');
  console.log('🔗 Available endpoints:');
  console.log('   POST /api/auth/register - Register new vendor');
  console.log('   POST /api/auth/login - Login vendor');
  console.log('   POST /api/auth/send-otp - Send OTP');
  console.log('   POST /api/auth/verify-otp - Verify OTP');
  console.log('   GET  /api/auth/profile - Get vendor profile (protected)');
}

main()
  .catch((e) => {
    console.error('❌ Error seeding database:', e);
    process.exit(1);
  })
  .finally(async () => {
    await prisma.$disconnect();
  });
