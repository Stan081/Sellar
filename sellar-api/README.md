# Sellar Backend API

Node.js/Express backend for the Sellar mobile application with Prisma ORM and PostgreSQL.

## 🚀 Features

- **Authentication**: JWT-based auth with OTP verification
- **Product Management**: CRUD operations for products
- **Payment Links**: Generate public/private payment links
- **Transaction Processing**: Handle payments via multiple gateways
- **Customer Management**: Track customer data and insights
- **Analytics**: Business metrics and reporting
- **Security**: Rate limiting, CORS, helmet protection

## 📋 Prerequisites

- Node.js 18+
- PostgreSQL 14+
- npm or yarn

## 🛠️ Installation

1. **Clone and install dependencies**
   ```bash
   cd backend
   npm install
   ```

2. **Environment setup**
   ```bash
   cp .env.example .env
   # Edit .env with your configuration
   ```

3. **Database setup**
   ```bash
   # Generate Prisma client
   npm run prisma:generate
   
   # Run database migrations
   npm run prisma:migrate --name init
   
   # Seed database with sample data
   npm run prisma:seed
   ```

4. **Start development server**
   ```bash
   npm run dev
   ```

## 🗄️ Database Schema

### Core Models

- **Vendor**: Business owners with authentication
- **Product**: Product catalog with images and pricing
- **PaymentLink**: Public/private payment links with QR codes
- **Transaction**: Payment records and status tracking
- **Customer**: Minimal customer data for insights
- **LinkView**: Analytics tracking for link views
- **OTPVerification**: Secure OTP system

## 🔐 Authentication

### Registration
```http
POST /api/auth/register
Content-Type: application/json

{
  "email": "vendor@example.com",
  "phone": "+12345678",
  "password": "password123",
  "businessName": "My",
  "firstName": "John",
  "lastName": "Doe",
  "country": "United States",
  "currency": "USD"
}
```

### Login
```http
POST /api/auth/login
Content-Type: application/json

{
  "identifier": "vendor@example.com",
  "password": "password123"
}
```

### OTP Verification
```http
POST /api/auth/send/send-otp
Content-Type: application/json

{
  "identifier": "vendor@example.com",
  "type": "LOGIN"
}
```

## 📊 API Endpoints

### Authentication
- `POST /api/auth/register` - Register new vendor
- `POST /api/auth/login` - Login vendor
- `POST /api/auth/send-otp` - Send OTP
- `POST /api/auth/verify-otp` - Verify OTP
- `GET /api/auth/profile` - Get vendor profile (protected)

### Products
- `GET /api/products` - List vendor products
- `POST /api/products` - Create product
- `GET /api/products/:id` - Get product details
- `PUT /api/products/:id` - Update product
- `DELETE /api/products/:id` - Delete product

### Payment Links
- `GET /api/links` - List payment links
- `POST /api/links` - Create payment link
- `GET /api/links/:id` - Get link details
- `PUT /api/links/:id` - update link
- `DELETE /api/links/:id` - Delete link

### Transactions
- `GET /api/transactions` - List transactions
- `GET /api/transactions/:id` - Get transaction details
- `POST /api/transactions/:id/status` - update transaction status

### Analytics
- `GET /api/analytics/overview` - Business overview
- `GET /api/analytics/products` - Product analytics
- `GET /api/analytics/links` - Link performance
- `GET /api/analytics/customers` - Customer insights

## 🔧 Development

### Available Scripts
```bash
npm run dev          # Start development server
npm run build        # Build for production
npm run start        # Start production server
npm run prisma:generate  # Generate Prisma client
npm run prisma:migrate    # Run database migrations
npm run prisma:studio     # Open Prisma Studio
npm run prisma:seed       # Seed database
```

### Database Management
```bash
# View database in browser
npm run prisma:studio

# Reset database
npx prisma migrate reset

# Deploy migrations
npx prisma migrate deploy
```

## 🧪 Testing

```bash
# Run tests
npm test

# Run with coverage
npm run test:coverage
```

## 📦 Production Deployment

1. **Build application**
   ```bash
   npm run build
   ```

2. **Set production environment**
   ```bash
   export NODE_ENV=production
   export DATABASE_URL="your-production-db-url"
   export JWT_SECRET="your-production-secret"
   ```

3. **Run database migrations**
   ```bash
   npm run prisma:migrate deploy
   ```

4. **Start server**
   ```bash
   npm start
   ```

## 🔒 Security Features

- **Rate Limiting**: 100 requests per 15 minutes per IP
- **CORS Protection**: Configurable origins
- **Helmet**: Security headers
- **JWT Authentication**: Secure token-based auth
- **Password Hashing**: bcrypt with salt rounds
- **Input Validation**: express-validator
- **SQL Injection Prevention**: Prisma ORM

## 🤝 Contributing

1. Fork the repository
2. Create feature branch (`git checkout -b feature/amazing-feature`)
3. Commit changes (`git commit -m 'Add amazing feature'`)
4. Push to branch (`git push origin feature/amazing-feature`)
5. Open Pull Request

## 📝 License

This project is licensed under the ISC License.

## 🆘 Support

For support and questions:
- Create an issue in the repository
- Email: support@sellar.app
