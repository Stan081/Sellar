import type { Metadata } from "next";
import Link from "next/link";
import Logo from "@/components/Logo";
import { ArrowLeft } from "lucide-react";

export const metadata: Metadata = {
  title: "Terms of Service",
  description: "Terms and conditions for using the Sellar platform.",
};

export default function TermsPage() {
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
        <h1 className="text-4xl font-bold text-slate-900 mb-2">Terms of Service</h1>
        <p className="text-slate-500 mb-10">Last updated: April 2026</p>

        <div className="prose prose-slate max-w-none space-y-8">
          <section>
            <h2 className="text-2xl font-semibold text-slate-900 mb-3">1. Acceptance of Terms</h2>
            <p className="text-slate-600 leading-relaxed">
              By downloading the Sellar mobile application, accessing our web platform, or using any of our
              services (collectively, the &ldquo;Service&rdquo;), you agree to be bound by these Terms of Service
              (&ldquo;Terms&rdquo;). If you do not agree to these Terms, please do not use the Service.
            </p>
          </section>

          <section>
            <h2 className="text-2xl font-semibold text-slate-900 mb-3">2. Description of Service</h2>
            <p className="text-slate-600 leading-relaxed">
              Sellar is a commerce platform that allows vendors (sellers) to create payment links, manage
              products, and receive payments from customers. Vendors manage their accounts exclusively through the
              Sellar mobile application. The web platform serves as an informational site and a checkout
              experience for customers following a vendor&apos;s payment link.
            </p>
          </section>

          <section>
            <h2 className="text-2xl font-semibold text-slate-900 mb-3">3. Account Registration</h2>
            <ul className="list-disc list-inside text-slate-600 space-y-2">
              <li>
                Vendor accounts may only be created via the Sellar mobile application. Web-based
                registration is not available.
              </li>
              <li>You must provide accurate, complete, and current information during registration.</li>
              <li>You are responsible for maintaining the confidentiality of your login credentials.</li>
              <li>You must be at least 18 years old to create a vendor account.</li>
              <li>
                One person or business entity may not maintain more than one active vendor account without
                prior written consent from Sellar.
              </li>
            </ul>
          </section>

          <section>
            <h2 className="text-2xl font-semibold text-slate-900 mb-3">4. Vendor Obligations</h2>
            <p className="text-slate-600 leading-relaxed mb-3">As a vendor you agree to:</p>
            <ul className="list-disc list-inside text-slate-600 space-y-2">
              <li>Only list and sell legal products and services.</li>
              <li>Accurately describe products — including price, condition, and availability.</li>
              <li>Fulfil orders in a timely manner and keep delivery status up to date.</li>
              <li>Respond to customer queries and resolve disputes promptly and in good faith.</li>
              <li>
                Comply with all applicable laws and regulations, including consumer protection and tax laws.
              </li>
              <li>
                Not use the platform for fraudulent transactions, money laundering, or any illegal activity.
              </li>
            </ul>
          </section>

          <section>
            <h2 className="text-2xl font-semibold text-slate-900 mb-3">5. Prohibited Products and Services</h2>
            <p className="text-slate-600 leading-relaxed mb-3">The following are strictly prohibited on Sellar:</p>
            <ul className="list-disc list-inside text-slate-600 space-y-1">
              <li>Illegal goods or services of any kind</li>
              <li>Counterfeit or fraudulent products</li>
              <li>Weapons, firearms, or ammunition</li>
              <li>Controlled substances or prescription drugs</li>
              <li>Adult content or services</li>
              <li>Gambling services</li>
              <li>Pyramid schemes or multi-level marketing programs</li>
            </ul>
          </section>

          <section>
            <h2 className="text-2xl font-semibold text-slate-900 mb-3">6. Fees and Payments</h2>
            <ul className="list-disc list-inside text-slate-600 space-y-2">
              <li>
                Sellar charges a platform fee of <strong>1.5% per completed transaction</strong>, plus any
                applicable payment processor fees.
              </li>
              <li>There are no setup fees, monthly subscriptions, or hidden charges.</li>
              <li>Payouts are processed based on the schedule of the integrated payment processor.</li>
              <li>
                Sellar reserves the right to adjust pricing with 30 days&apos; notice to active vendors.
              </li>
              <li>
                Disputed or reversed transactions may result in temporary holds on payouts while under
                investigation.
              </li>
            </ul>
          </section>

          <section>
            <h2 className="text-2xl font-semibold text-slate-900 mb-3">7. Customer Purchases</h2>
            <p className="text-slate-600 leading-relaxed">
              Customers who make purchases through Sellar payment links enter into a direct transaction with the
              vendor. Sellar acts as a technology facilitator and is not a party to the sale. All disputes
              regarding product quality, delivery, or refunds must be resolved between the customer and the
              vendor. Sellar may, at its discretion, assist in mediating disputes.
            </p>
          </section>

          <section>
            <h2 className="text-2xl font-semibold text-slate-900 mb-3">8. Private Payment Links</h2>
            <p className="text-slate-600 leading-relaxed">
              Vendors may create private payment links that require an access code for checkout. Access codes are
              delivered via email to the intended recipient. Vendors are responsible for ensuring access codes are
              shared only with authorised buyers. Misuse of private links may result in account suspension.
            </p>
          </section>

          <section>
            <h2 className="text-2xl font-semibold text-slate-900 mb-3">9. Intellectual Property</h2>
            <p className="text-slate-600 leading-relaxed">
              All content, features, and functionality of the Sellar platform — including but not limited to the
              logo, design, code, and text — are the exclusive property of Sellar and its licensors. You may not
              copy, reproduce, modify, distribute, or create derivative works without prior written consent. By
              uploading product content, you grant Sellar a limited, non-exclusive licence to display that
              content within the Service.
            </p>
          </section>

          <section>
            <h2 className="text-2xl font-semibold text-slate-900 mb-3">10. Termination</h2>
            <p className="text-slate-600 leading-relaxed">
              Sellar reserves the right to suspend or terminate any account at its sole discretion, with or
              without notice, for violation of these Terms or for any conduct deemed harmful to the platform,
              other users, or third parties. Upon termination, your right to use the Service ceases immediately.
              Pending payouts will be processed subject to any applicable holds or investigations.
            </p>
          </section>

          <section>
            <h2 className="text-2xl font-semibold text-slate-900 mb-3">11. Limitation of Liability</h2>
            <p className="text-slate-600 leading-relaxed">
              To the maximum extent permitted by law, Sellar shall not be liable for any indirect, incidental,
              special, consequential, or punitive damages arising from your use of the Service. Our total
              liability to you for any claim arising from these Terms shall not exceed the fees paid by you to
              Sellar in the three months preceding the claim.
            </p>
          </section>

          <section>
            <h2 className="text-2xl font-semibold text-slate-900 mb-3">12. Changes to Terms</h2>
            <p className="text-slate-600 leading-relaxed">
              We may revise these Terms at any time. We will notify active users via email or in-app notification
              at least 14 days before material changes take effect. Continued use of the Service after the
              effective date constitutes acceptance of the revised Terms.
            </p>
          </section>

          <section>
            <h2 className="text-2xl font-semibold text-slate-900 mb-3">13. Governing Law</h2>
            <p className="text-slate-600 leading-relaxed">
              These Terms are governed by and construed in accordance with applicable law. Any disputes shall
              first be attempted to be resolved through good-faith negotiation. If unresolved, disputes shall be
              submitted to binding arbitration.
            </p>
          </section>

          <section>
            <h2 className="text-2xl font-semibold text-slate-900 mb-3">14. Contact</h2>
            <p className="text-slate-600 leading-relaxed">
              For questions about these Terms, please contact us at:
            </p>
            <div className="mt-3 p-4 bg-slate-50 rounded-xl text-slate-700">
              <p className="font-medium">Sellar</p>
              <p>
                Email:{" "}
                <a href="mailto:legal@sellar.app" className="text-indigo-600 hover:text-indigo-700">
                  legal@sellar.app
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
            <Link href="/privacy" className="hover:text-slate-700 transition-colors">Privacy Policy</Link>
            <Link href="/terms" className="text-indigo-600 font-medium">Terms of Service</Link>
          </div>
          <p className="text-sm text-slate-500">© {new Date().getFullYear()} Sellar</p>
        </div>
      </footer>
    </div>
  );
}
