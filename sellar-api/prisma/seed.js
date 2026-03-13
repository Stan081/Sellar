"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
const client_1 = require("@prisma/client");
const bcryptjs_1 = __importDefault(require("bcryptjs"));
const prisma = new client_1.PrismaClient();
async function main() {
    console.log('🌱 Starting database seed...');
    // Create a test vendor
    const hashedPassword = await bcryptjs_1.default.hash('password123', 12);
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
                description: 'Premium noise-canceling wireless headphones with 30-hour battery life.',
                category: 'Electronics',
                tags: ['audio', 'wireless', 'bluetooth'],
                price: 299.99,
                quantity: 50,
                images: [
                    'https://images.unsplash.com/photo-1505740420928-5e560c68d30a4?w=400',
                ],
            },
        }),
        prisma.product.create({
            data: {
                vendorId: testVendor.id,
                name: 'Leather Wallet',
                description: 'Genuine leather bifold wallet with RFID protection.',
                category: 'Accessories',
                tags: ['leather', 'wallet', 'rfid'],
                price: 89.99,
                quantity: 100,
                images: [
                    'https://images.unsplash.com/photo-1521096498797-5b6235f421a1?w=400',
                ],
            },
        }),
        prisma.product.create({
            data: {
                vendorId: testVendor.id,
                name: 'Running Shoes',
                description: 'Professional running shoes with advanced cushioning technology.',
                category: 'Footwear',
                tags: ['running', 'shoes', 'athletic'],
                price: 159.99,
                quantity: 75,
                images: [
                    'https://images.unsplash.com/photo-1542291026289-5a668e4c3dcbb?w=400',
                ],
            },
        }),
        prisma.product.create({
            data: {
                vendorId: testVendor.id,
                name: 'Smart Watch',
                description: 'Feature-rich smartwatch with health tracking and GPS.',
                category: 'Electronics',
                tags: ['smartwatch', 'fitness', 'gps'],
                price: 399.99,
                quantity: 30,
                images: [
                    'https://images.unsplash.com/photo-1523276975066-6e1b8e8a9b5c?w=400',
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
                productId: products[0].id, // Wireless Headphones
                linkType: 'PUBLIC',
                amount: 2999.99,
                currency: 'USD',
                isReusable: true,
                shortCode: 'headphones123',
                qrCode: 'data:image/png;base64,iVBORw0KGKG...',
            },
        }),
        prisma.paymentLink.create({
            data: {
                vendorId: testVendor.id,
                productId: products[1].id, // Leather Wallet
                linkType: 'PRIVATE',
                amount: 89.99,
                currency: 'USD',
                isReusable: false,
                shortCode: 'wallet123',
                qrCode: 'data:image/png;base64,iVBORw0fkg...',
                expiresAt: new Date(Date.now() + 30 * 24 * 60 * 60 * 1000), // 30 days
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
//# sourceMappingURL=seed.js.map