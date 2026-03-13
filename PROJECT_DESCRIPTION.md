# Sellar Mobile App — Functional Requirements Document (Flutter Implementation)

## 1. Overview

**Project Name:** Sellar  
**Platform:** Mobile (Flutter — Android & iOS)  
**Purpose:** Empower micro and small-scale businesses to sell products securely, collect payments, and gain customer insights without needing a full e-commerce website.  
**Core Philosophy:** Simple. Secure. Insightful.  

---

## 2. Core Objectives

1. Enable **vendors** to easily upload, organize, and manage product catalogs.  
2. Allow vendors to generate **secure payment links** — both public and private (OTP-verified).  
3. Facilitate **seamless payment integration** with major payment processors (Stripe, Paystack, Flutterwave, etc.).  
4. Provide **lightweight analytics** to vendors for data-driven growth.  
5. Build a **mobile-first, modern Flutter app** with adaptive theming and smooth UX.  

---

## 3. Target Users

| User Type | Description | Access Level |
|------------|--------------|--------------|
| Vendor | Small or micro business owner managing their catalog and payment links | Full access |
| Customer | Buyer who receives a payment link and verifies via OTP to complete payment | Limited access |

---

## 4. Functional Requirements

### 4.1. Authentication & Onboarding

**Purpose:** Securely authenticate vendors and allow OTP-based verification for customers.

**Requirements:**
- Vendor authentication via **email, phone number, or Google account**.
- OTP-based login/registration (Firebase Auth or similar).
- Basic vendor profile setup: Name, Business Name, Country, Currency.
- Store vendor metadata locally (secure storage) for quick relogin.
- Biometric authentication for returning sessions (optional).
- Customer OTP verification workflow for private payment links.

---

### 4.2. Product Management Module

**Purpose:** Allow vendors to manage product catalogs efficiently.

**Features:**
- Add/Edit/Delete product entries.
- Product fields:
  - Name
  - Description
  - Category/Tags
  - Price
  - Quantity (optional)
  - Images (multiple)
- Upload product images to cloud storage (Firebase Storage or Supabase).
- Search and filter products by name, tag, or category.
- Display product cards with image, name, price, and quick-action buttons (edit, delete, share link).
- Offline cache for product data (Hive or Drift local DB).

**UI/UX Notes:**
- Modern grid layout with image thumbnails.
- Soft shadow cards, rounded corners, and color-coded categories.
- Floating Action Button (FAB) for “Add Product.”

---

### 4.3. Payment Link Generation Module

**Purpose:** Allow vendors to generate secure, trackable payment links.

**Features:**
- **Public Link:** Accessible to anyone (for mass sharing via social apps).
- **Private Link:** Customer-specific, OTP-verified before payment.
- Choose between one-time link or reusable link.
- Generate shareable URL (Sellar shortlink or vendor domain).
- QR Code generation for each link.
- Optional link expiry date/time.
- “Copy Link” and “Share via WhatsApp/Telegram/Email” options.

**Workflow:**
1. Vendor selects a product or multiple products.
2. Sets amount, payment type (one-time / open), and recipient contact.
3. System generates link and stores metadata (link ID, status, expiry).
4. Link appears in “Active Links” dashboard with tracking info.

---

### 4.4. Payment Processing Integration

**Purpose:** Enable customers to complete payments seamlessly through trusted gateways.

**Requirements:**
- Integrate with **Stripe**, **Paystack**, and **Flutterwave** SDKs.
- API-driven handoff — no payment data stored on Sellar’s servers.
- Vendor can select preferred gateway.
- Payment success/failure callback updates Sellar backend.
- Display transaction status and confirmation page to both customer and vendor.

**UI/UX Notes:**
- Clean embedded payment webview or in-app flow.
- Show vendor logo and product summary before checkout.
- “Secure Checkout” emphasized visually.

---

### 4.5. Analytics Dashboard

**Purpose:** Provide actionable insights to vendors.

**Features:**
- Basic metrics:
  - Total sales
  - Number of successful payments
  - Repeat customers
  - Top-selling products
  - Monthly/Weekly revenue trends
- Visualized via bar and pie charts (Recharts or Flutter Charts).
- Option to export summary (CSV or PDF).
- “Activity Feed” view for recent transactions.

**UI/UX Notes:**
- Use light/dark themes with dynamic chart colors.
- Use cards and charts for modular layout.
- Animations for data refresh transitions.

---

### 4.6. Customer Management

**Purpose:** Manage and analyze buyer interactions.

**Features:**
- Store minimal customer data (email/phone only).
- Map purchases to unique customer identifiers.
- Restrict edit/delete access to comply with data protection.
- Show repeat customer badges or insights.

---

### 4.7. Notifications & Alerts

**Purpose:** Keep users updated in real time.

**Features:**
- Push notifications for:
  - Payment success
  - Link expiry alerts
  - Product low-stock alerts
- Local in-app notifications when offline.
- Notification preferences per user.

---

### 4.8. Settings & Preferences

**Purpose:** Allow personalization and control.

**Features:**
- Change theme (Light/Dark/System Adaptive).
- Update profile and preferred payment gateway.
- Currency and region configuration.
- Logout & session management.
- Privacy and Terms links.

---

## 5. Design System

### 5.1. Theming

- **Material 3 (You):** Dynamic color theming based on device palette.  
- **Primary Palette:** Teal / Emerald variants for branding.  
- **Accent Colors:** Adaptive per mode (soft purple/amber for highlights).  
- **Typography:** Google Fonts — “Poppins” or “Inter.”  
- **Dark Mode:** Auto-switch based on system preference.  
- **Rounded Corners:** 2xl radii for modern card design.  
- **Elevations:** Subtle shadows; focus on flat, fluid surfaces.

### 5.2. Interaction Patterns

- Bottom Navigation for core tabs: **Products**, **Links**, **Analytics**, **Settings**.
- Floating Action Button (FAB) for primary actions.
- Smooth transitions using **Hero animations** and **motion widgets**.
- Consistent padding (8–16px) and touch-friendly controls.

---

## 6. Non-Functional Requirements

| Category | Requirement |
|-----------|--------------|
| **Performance** | 60fps smooth scrolling, optimized images, lazy loading |
| **Security** | OTP-based auth, HTTPS everywhere, no card data stored |
| **Reliability** | Graceful offline support with sync-on-reconnect |
| **Scalability** | Modular architecture ready for future web version |
| **Localization** | Multi-language support (English, French, Swahili planned) |
| **Accessibility** | Color contrast compliance, font scaling support |
| **Analytics** | Firebase Analytics / Mixpanel integration |

---

## 7. Technology Stack

| Layer | Technology |
|-------|-------------|
| Frontend | Flutter (Dart) |
| Backend (API) | Supabase / Firebase / NestJS (microservices ready) |
| Database | PostgreSQL or Firestore |
| Authentication | Firebase Auth / OTP service |
| Payment | Stripe, Paystack, Flutterwave SDKs |
| Analytics | Firebase Analytics / Mixpanel |
| Storage | Firebase Storage / Supabase Storage |
| State Management | Riverpod or Bloc |
| Local Storage | Hive / Drift |

---

## 8. Deliverables (MVP Scope)

1. Vendor onboarding & authentication flow  
2. Product management (CRUD + media upload)  
3. Public & private payment link generation  
4. OTP verification for private transactions  
5. Payment gateway integration (Paystack initial)  
6. Basic analytics dashboard  
7. Themed UI with light/dark support  
8. Local caching and offline resilience  

---

## 9. Future Enhancements (Post-MVP)

- AI-powered sales recommendations  
- Customer messaging (via WhatsApp API integration)  
- Advanced analytics & cohort segmentation  
- Vendor store mini-site (web view)  
- Loyalty programs and coupon codes  

---

## 10. UX Moodboard Reference (Guidelines)

- **Inspiration Apps:** FlutterFlow, Revolut, Paystack Merchant, Notion.  
- **Tone:** Professional yet friendly — bright accents, minimalistic spacing, and clear typography.  
- **Illustrations:** Use Lottie animations for empty states.  
- **Icons:** Fluent or Feather icons (consistent weight).

---

## 11. Versioning & Documentation

- Use Git for version control.  
- Document all APIs in Swagger / Postman.  
- Maintain architecture overview (README + diagrams).  
- CI/CD: GitHub Actions for build testing.

---

## 12. Summary

Sellar enables small businesses to sell smarter — combining simplicity, security, and insight in a single mobile-first experience.  
This document defines the **minimum viable feature set**, **design principles**, and **technical guidelines** necessary to implement Sellar’s core functionality using **Flutter** while maintaining scalability and modern UX standards.
