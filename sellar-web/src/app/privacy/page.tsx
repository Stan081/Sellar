import type { Metadata } from "next";
import Link from "next/link";
import Logo from "@/components/Logo";
import { ArrowLeft } from "lucide-react";

export const metadata: Metadata = {
  title: "Privacy Policy",
  description: "How Sellar collects, uses, and protects your personal information.",
};

export default function PrivacyPage() {
  return (
    <div className="min-h-screen bg-white">
      <header className="border-b border-slate-100 py-4 px-6">
        <div className="max-w-4xl mx-auto flex items-center justify-between">
          <Logo />
          <Link
            href="/"
            className="flex items-center gap-2 text-sm text-slate-600 hover:text-slate-900 transition-colors"
          >
            <ArrowLeft className="w-4 h-4" />
            Back to Home
          </Link>
        </div>
      </header>

      <main className="max-w-4xl mx-auto px-6 py-12">
        <h1 className="text-4xl font-bold text-slate-900 mb-2">Privacy Policy</h1>
        <p className="text-slate-500 mb-10">Last updated: April 2026</p>

        <div className="prose prose-slate max-w-none space-y-8">
          <section>
            <h2 className="text-2xl font-semibold text-slate-900 mb-3">1. Introduction</h2>
            <p className="text-slate-600 leading-relaxed">
              Sellar (&ldquo;we&rdquo;, &ldquo;our&rdquo;, or &ldquo;us&rdquo;) is committed to protecting your privacy. This Privacy
              Policy explains how we collect, use, disclose, and safeguard your information when you use our
              mobile application and web platform (collectively, the &ldquo;Service&rdquo;).
            </p>
          </section>

          <section>
            <h2 className="text-2xl font-semibold text-slate-900 mb-3">2. Information We Collect</h2>
            <h3 className="text-lg font-medium text-slate-800 mb-2">Information you provide directly</h3>
            <ul className="list-disc list-inside text-slate-600 space-y-1 mb-4">
              <li>Account registration details (name, email address, phone number)</li>
              <li>Business information (business name, category, description)</li>
              <li>Product listings (name, description, price, images)</li>
              <li>Payment and banking information (processed securely via payment partners)</li>
              <li>Customer shipping addresses provided during checkout</li>
            </ul>
            <h3 className="text-lg font-medium text-slate-800 mb-2">Information collected automatically</h3>
            <ul className="list-disc list-inside text-slate-600 space-y-1">
              <li>Device information (device type, operating system)</li>
              <li>Usage data (features accessed, pages viewed, time spent)</li>
              <li>IP address and general location data</li>
              <li>Payment link view counts and access logs</li>
            </ul>
          </section>

          <section>
            <h2 className="text-2xl font-semibold text-slate-900 mb-3">3. How We Use Your Information</h2>
            <ul className="list-disc list-inside text-slate-600 space-y-2">
              <li>To provide, operate, and maintain the Service</li>
              <li>To process transactions and send related information (confirmations, invoices)</li>
              <li>To manage vendor and customer accounts</li>
              <li>To send transactional notifications (order updates, payment receipts)</li>
              <li>To provide access codes for private payment links</li>
              <li>To improve and personalise your experience</li>
              <li>To detect, prevent, and address fraud or security issues</li>
              <li>To comply with legal obligations</li>
            </ul>
          </section>

          <section>
            <h2 className="text-2xl font-semibold text-slate-900 mb-3">4. Sharing of Information</h2>
            <p className="text-slate-600 leading-relaxed mb-3">
              We do not sell your personal information. We may share information in the following circumstances:
            </p>
            <ul className="list-disc list-inside text-slate-600 space-y-2">
              <li>
                <strong>Payment processors:</strong> To process transactions securely (e.g. Paystack, Flutterwave, Stripe).
              </li>
              <li>
                <strong>Between vendors and customers:</strong> Order fulfilment information is shared between the
                relevant vendor and customer.
              </li>
              <li>
                <strong>Service providers:</strong> Third-party vendors who assist in operating the platform (cloud
                hosting, email delivery, analytics).
              </li>
              <li>
                <strong>Legal requirements:</strong> When required by applicable law, court order, or government authority.
              </li>
            </ul>
          </section>

          <section>
            <h2 className="text-2xl font-semibold text-slate-900 mb-3">5. Data Security</h2>
            <p className="text-slate-600 leading-relaxed">
              We implement industry-standard security measures including TLS encryption for data in transit,
              encrypted storage for sensitive data, and access controls. However, no method of transmission over
              the Internet is 100% secure. We encourage you to use a strong, unique password and to notify us
              immediately if you suspect unauthorised access.
            </p>
          </section>

          <section>
            <h2 className="text-2xl font-semibold text-slate-900 mb-3">6. Data Retention</h2>
            <p className="text-slate-600 leading-relaxed">
              We retain your personal data for as long as your account is active or as needed to provide the
              Service. Transaction records are retained for a minimum of 5 years to comply with financial
              regulations. You may request deletion of your account and associated data at any time, subject to
              legal retention requirements.
            </p>
          </section>

          <section>
            <h2 className="text-2xl font-semibold text-slate-900 mb-3">7. Your Rights</h2>
            <p className="text-slate-600 leading-relaxed mb-3">
              Depending on your jurisdiction, you may have the right to:
            </p>
            <ul className="list-disc list-inside text-slate-600 space-y-1">
              <li>Access the personal data we hold about you</li>
              <li>Request correction of inaccurate data</li>
              <li>Request deletion of your data</li>
              <li>Object to or restrict processing of your data</li>
              <li>Data portability (receive your data in a structured, machine-readable format)</li>
            </ul>
            <p className="text-slate-600 leading-relaxed mt-3">
              To exercise these rights, contact us at{" "}
              <a href="mailto:privacy@sellar.app" className="text-indigo-600 hover:text-indigo-700">
                privacy@sellar.app
              </a>.
            </p>
          </section>

          <section>
            <h2 className="text-2xl font-semibold text-slate-900 mb-3">8. Cookies</h2>
            <p className="text-slate-600 leading-relaxed">
              Our web platform uses essential cookies required for the Service to function (e.g. session management).
              We do not use advertising or tracking cookies. You can disable cookies in your browser settings,
              though this may affect Service functionality.
            </p>
          </section>

          <section>
            <h2 className="text-2xl font-semibold text-slate-900 mb-3">9. Changes to This Policy</h2>
            <p className="text-slate-600 leading-relaxed">
              We may update this Privacy Policy from time to time. We will notify you of significant changes via
              email or a prominent notice in the app. Continued use of the Service after changes take effect
              constitutes acceptance of the updated policy.
            </p>
          </section>

          <section>
            <h2 className="text-2xl font-semibold text-slate-900 mb-3">10. Contact Us</h2>
            <p className="text-slate-600 leading-relaxed">
              If you have any questions about this Privacy Policy or our data practices, please contact us at:
            </p>
            <div className="mt-3 p-4 bg-slate-50 rounded-xl text-slate-700">
              <p className="font-medium">Sellar</p>
              <p>
                Email:{" "}
                <a href="mailto:privacy@sellar.app" className="text-indigo-600 hover:text-indigo-700">
                  privacy@sellar.app
                </a>
              </p>
            </div>
          </section>
        </div>
      </main>

      <footer className="border-t border-slate-100 py-8 px-6 mt-12">
        <div className="max-w-4xl mx-auto flex flex-col sm:flex-row items-center justify-between gap-4">
          <Logo size="sm" />
          <div className="flex items-center gap-6 text-sm text-slate-500">
            <Link href="/privacy" className="text-indigo-600 font-medium">Privacy Policy</Link>
            <Link href="/terms" className="hover:text-slate-700 transition-colors">Terms of Service</Link>
          </div>
          <p className="text-sm text-slate-500">© {new Date().getFullYear()} Sellar</p>
        </div>
      </footer>
    </div>
  );
}
