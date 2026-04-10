import type { Metadata, Viewport } from "next";
import { Geist } from "next/font/google";
import "./globals.css";
import { AuthProvider } from "@/lib/auth-context";

const geistSans = Geist({
  variable: "--font-geist-sans",
  subsets: ["latin"],
});

const APP_URL = process.env.NEXT_PUBLIC_APP_URL ?? "https://sellar.app";

export const metadata: Metadata = {
  metadataBase: new URL(APP_URL),
  title: {
    default: "Sellar — Sell Anything, Anywhere",
    template: "%s | Sellar",
  },
  description:
    "Create payment links in seconds, share them anywhere, and get paid instantly. The simplest way for entrepreneurs to accept payments online.",
  keywords: [
    "payment links",
    "sell online",
    "entrepreneurs",
    "Africa payments",
    "Paystack",
    "Flutterwave",
    "ecommerce",
  ],
  authors: [{ name: "Sellar" }],
  creator: "Sellar",
  openGraph: {
    type: "website",
    locale: "en_US",
    url: APP_URL,
    siteName: "Sellar",
    title: "Sellar — Sell Anything, Anywhere",
    description:
      "Create payment links in seconds, share them anywhere, and get paid instantly.",
  },
  twitter: {
    card: "summary_large_image",
    title: "Sellar — Sell Anything, Anywhere",
    description:
      "Create payment links in seconds, share them anywhere, and get paid instantly.",
    creator: "@sellarapp",
  },
  robots: {
    index: true,
    follow: true,
  },
};

export const viewport: Viewport = {
  width: "device-width",
  initialScale: 1,
  themeColor: "#6366f1",
};

export default function RootLayout({
  children,
}: Readonly<{
  children: React.ReactNode;
}>) {
  return (
    <html lang="en" className={`${geistSans.variable} h-full antialiased`}>
      <body className="min-h-full flex flex-col bg-white text-slate-900">
        <AuthProvider>{children}</AuthProvider>
      </body>
    </html>
  );
}
