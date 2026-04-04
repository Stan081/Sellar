import Link from "next/link";
import { 
  Zap, 
  Shield, 
  TrendingUp, 
  CreditCard, 
  Users, 
  BarChart3,
  ArrowRight,
  Check,
  Star,
  Globe,
  Smartphone,
  Lock
} from "lucide-react";

export default function Home() {
  return (
    <div className="min-h-screen bg-white">
      {/* Navigation */}
      <nav className="fixed top-0 left-0 right-0 z-50 bg-white/80 backdrop-blur-md border-b border-slate-100">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
          <div className="flex items-center justify-between h-16">
            <div className="flex items-center gap-2">
              <div className="w-8 h-8 bg-gradient-to-br from-indigo-500 to-violet-500 rounded-lg flex items-center justify-center">
                <span className="text-white font-bold text-sm">S</span>
              </div>
              <span className="text-xl font-bold text-slate-900">Sellar</span>
            </div>
            <div className="hidden md:flex items-center gap-8">
              <a href="#features" className="text-slate-600 hover:text-slate-900 transition-colors">Features</a>
              <a href="#how-it-works" className="text-slate-600 hover:text-slate-900 transition-colors">How it Works</a>
              <a href="#pricing" className="text-slate-600 hover:text-slate-900 transition-colors">Pricing</a>
            </div>
            <div className="flex items-center gap-4">
              <span className="hidden sm:inline text-slate-600 text-sm">
                Login via mobile app
              </span>
              <Link 
                href="#download-app" 
                className="bg-indigo-500 hover:bg-indigo-600 text-white px-4 py-2 rounded-lg font-medium transition-colors"
              >
                Get the App
              </Link>
            </div>
          </div>
        </div>
      </nav>

      {/* Hero Section */}
      <section className="pt-32 pb-20 px-4 sm:px-6 lg:px-8">
        <div className="max-w-7xl mx-auto">
          <div className="text-center max-w-4xl mx-auto">
            <div className="inline-flex items-center gap-2 bg-indigo-50 text-indigo-700 px-4 py-2 rounded-full text-sm font-medium mb-6">
              <Zap className="w-4 h-4" />
              Trusted by 10,000+ entrepreneurs
            </div>
            <h1 className="text-5xl sm:text-6xl lg:text-7xl font-bold text-slate-900 leading-tight mb-6">
              Sell Anything,{" "}
              <span className="bg-gradient-to-r from-indigo-500 to-violet-500 bg-clip-text text-transparent">
                Anywhere
              </span>
            </h1>
            <p className="text-xl text-slate-600 mb-8 max-w-2xl mx-auto">
              Create payment links in seconds, share them anywhere, and get paid instantly. 
              The simplest way for entrepreneurs to accept payments online.
            </p>
            <div className="flex flex-col sm:flex-row items-center justify-center gap-4">
              <Link 
                href="#download-app" 
                className="w-full sm:w-auto bg-indigo-500 hover:bg-indigo-600 text-white px-8 py-4 rounded-xl font-semibold text-lg transition-all hover:shadow-lg hover:shadow-indigo-500/25 flex items-center justify-center gap-2"
              >
                Start on Mobile
                <ArrowRight className="w-5 h-5" />
              </Link>
              <a 
                href="#how-it-works" 
                className="w-full sm:w-auto border border-slate-200 hover:border-slate-300 text-slate-700 px-8 py-4 rounded-xl font-semibold text-lg transition-colors flex items-center justify-center"
              >
                See How It Works
              </a>
            </div>
            <div className="mt-8 flex items-center justify-center gap-6 text-sm text-slate-500">
              <div className="flex items-center gap-2">
                <Check className="w-4 h-4 text-emerald-500" />
                No setup fees
              </div>
              <div className="flex items-center gap-2">
                <Check className="w-4 h-4 text-emerald-500" />
                No monthly fees
              </div>
              <div className="flex items-center gap-2">
                <Check className="w-4 h-4 text-emerald-500" />
                Instant payouts
              </div>
            </div>
          </div>

          {/* Hero Image/Mockup */}
          <div className="mt-16 relative">
            <div className="absolute inset-0 bg-gradient-to-t from-white via-transparent to-transparent z-10 pointer-events-none" />
            <div className="bg-gradient-to-br from-indigo-100 via-violet-50 to-rose-50 rounded-3xl p-8 shadow-2xl shadow-indigo-500/10">
              <div className="bg-white rounded-2xl shadow-xl p-6">
                <div className="flex items-center gap-4 mb-6">
                  <div className="w-12 h-12 bg-indigo-100 rounded-xl flex items-center justify-center">
                    <CreditCard className="w-6 h-6 text-indigo-600" />
                  </div>
                  <div>
                    <h3 className="font-semibold text-slate-900">Payment Link Created</h3>
                    <p className="text-sm text-slate-500">Premium Headphones • $299.99</p>
                  </div>
                  <div className="ml-auto">
                    <span className="bg-emerald-100 text-emerald-700 px-3 py-1 rounded-full text-sm font-medium">Active</span>
                  </div>
                </div>
                <div className="bg-slate-50 rounded-xl p-4 flex items-center gap-3">
                  <Globe className="w-5 h-5 text-slate-400" />
                  <code className="text-sm text-slate-600 flex-1">sellar.app/pay/abc123xyz</code>
                  <button className="text-indigo-600 font-medium text-sm hover:text-indigo-700">Copy</button>
                </div>
              </div>
            </div>
          </div>
        </div>
      </section>

      {/* Features Section */}
      <section id="features" className="py-20 px-4 sm:px-6 lg:px-8 bg-slate-50">
        <div className="max-w-7xl mx-auto">
          <div className="text-center mb-16">
            <h2 className="text-3xl sm:text-4xl font-bold text-slate-900 mb-4">
              Everything you need to sell online
            </h2>
            <p className="text-lg text-slate-600 max-w-2xl mx-auto">
              Powerful features designed for entrepreneurs who want to focus on their business, not payment infrastructure.
            </p>
          </div>

          <div className="grid md:grid-cols-2 lg:grid-cols-3 gap-8">
            {[
              {
                icon: <CreditCard className="w-6 h-6" />,
                title: "Instant Payment Links",
                description: "Create shareable payment links in seconds. No coding required, no complex setup."
              },
              {
                icon: <Shield className="w-6 h-6" />,
                title: "Secure Transactions",
                description: "Bank-level encryption and fraud protection. Your customers' data is always safe."
              },
              {
                icon: <Users className="w-6 h-6" />,
                title: "Customer Management",
                description: "Track your customers, their purchases, and build lasting relationships."
              },
              {
                icon: <BarChart3 className="w-6 h-6" />,
                title: "Real-time Analytics",
                description: "Understand your sales with detailed insights and performance metrics."
              },
              {
                icon: <Smartphone className="w-6 h-6" />,
                title: "Mobile-First Design",
                description: "Manage your business from anywhere with our powerful mobile app."
              },
              {
                icon: <Lock className="w-6 h-6" />,
                title: "Private Links",
                description: "Create exclusive links with code authentication for VIP customers."
              }
            ].map((feature, index) => (
              <div key={index} className="bg-white rounded-2xl p-6 shadow-sm hover:shadow-md transition-shadow">
                <div className="w-12 h-12 bg-indigo-100 rounded-xl flex items-center justify-center text-indigo-600 mb-4">
                  {feature.icon}
                </div>
                <h3 className="text-xl font-semibold text-slate-900 mb-2">{feature.title}</h3>
                <p className="text-slate-600">{feature.description}</p>
              </div>
            ))}
          </div>
        </div>
      </section>

      {/* How It Works Section */}
      <section id="how-it-works" className="py-20 px-4 sm:px-6 lg:px-8">
        <div className="max-w-7xl mx-auto">
          <div className="text-center mb-16">
            <h2 className="text-3xl sm:text-4xl font-bold text-slate-900 mb-4">
              Start selling in 3 simple steps
            </h2>
            <p className="text-lg text-slate-600 max-w-2xl mx-auto">
              Get up and running in minutes, not days. No technical skills required.
            </p>
          </div>

          <div className="grid md:grid-cols-3 gap-8">
            {[
              {
                step: "01",
                title: "Add Your Products",
                description: "Upload your products with images, descriptions, and pricing. Organize them into categories."
              },
              {
                step: "02",
                title: "Generate Payment Links",
                description: "Create unique payment links for each product. Customize them with your branding."
              },
              {
                step: "03",
                title: "Share & Get Paid",
                description: "Share links on social media, WhatsApp, or email. Receive payments directly to your account."
              }
            ].map((item, index) => (
              <div key={index} className="relative">
                <div className="text-7xl font-bold text-indigo-100 mb-4">{item.step}</div>
                <h3 className="text-xl font-semibold text-slate-900 mb-2">{item.title}</h3>
                <p className="text-slate-600">{item.description}</p>
              </div>
            ))}
          </div>
        </div>
      </section>

      {/* Social Proof Section */}
      <section className="py-20 px-4 sm:px-6 lg:px-8 bg-gradient-to-br from-indigo-500 to-violet-600">
        <div className="max-w-7xl mx-auto text-center">
          <div className="flex items-center justify-center gap-1 mb-4">
            {[...Array(5)].map((_, i) => (
              <Star key={i} className="w-6 h-6 text-yellow-400 fill-yellow-400" />
            ))}
          </div>
          <blockquote className="text-2xl sm:text-3xl font-medium text-white mb-6 max-w-3xl mx-auto">
            &ldquo;Sellar transformed my side hustle into a real business. I went from struggling with payments to processing $10k/month in just 3 months.&rdquo;
          </blockquote>
          <div className="flex items-center justify-center gap-3">
            <div className="w-12 h-12 bg-white/20 rounded-full flex items-center justify-center text-white font-semibold">
              AO
            </div>
            <div className="text-left">
              <div className="text-white font-semibold">Adaeze Okonkwo</div>
              <div className="text-indigo-200 text-sm">Fashion Entrepreneur, Lagos</div>
            </div>
          </div>
        </div>
      </section>

      {/* Pricing Section */}
      <section id="pricing" className="py-20 px-4 sm:px-6 lg:px-8">
        <div className="max-w-7xl mx-auto">
          <div className="text-center mb-16">
            <h2 className="text-3xl sm:text-4xl font-bold text-slate-900 mb-4">
              Simple, transparent pricing
            </h2>
            <p className="text-lg text-slate-600 max-w-2xl mx-auto">
              No hidden fees. No monthly subscriptions. Pay only when you get paid.
            </p>
          </div>

          <div className="max-w-lg mx-auto">
            <div className="bg-white rounded-3xl shadow-xl border border-slate-200 overflow-hidden">
              <div className="p-8 text-center border-b border-slate-100">
                <h3 className="text-2xl font-bold text-slate-900 mb-2">Pay As You Go</h3>
                <div className="flex items-baseline justify-center gap-1">
                  <span className="text-5xl font-bold text-slate-900">1.5%</span>
                  <span className="text-slate-500">per transaction</span>
                </div>
                <p className="text-slate-500 mt-2">+ payment processor fees</p>
              </div>
              <div className="p-8">
                <ul className="space-y-4">
                  {[
                    "Unlimited payment links",
                    "Unlimited products",
                    "Customer management",
                    "Real-time analytics",
                    "Mobile app access",
                    "Email support",
                    "Instant payouts"
                  ].map((feature, index) => (
                    <li key={index} className="flex items-center gap-3">
                      <Check className="w-5 h-5 text-emerald-500 flex-shrink-0" />
                      <span className="text-slate-700">{feature}</span>
                    </li>
                  ))}
                </ul>
                <Link 
                  href="#download-app" 
                  className="mt-8 w-full bg-indigo-500 hover:bg-indigo-600 text-white py-4 rounded-xl font-semibold text-lg transition-colors flex items-center justify-center gap-2"
                >
                  Download Mobile App
                  <ArrowRight className="w-5 h-5" />
                </Link>
              </div>
            </div>
          </div>
        </div>
      </section>

      <section id="download-app" className="py-16 px-4 sm:px-6 lg:px-8 bg-indigo-50">
        <div className="max-w-4xl mx-auto text-center">
          <h3 className="text-2xl sm:text-3xl font-bold text-slate-900 mb-3">
            Account setup and login are mobile-app only
          </h3>
          <p className="text-slate-600 mb-6">
            Vendors create and manage Sellar accounts from the mobile app. The web experience is for product info and customer checkout.
          </p>
          <div className="flex flex-col sm:flex-row justify-center gap-3">
            <a href="#" className="bg-slate-900 text-white px-6 py-3 rounded-xl font-medium hover:bg-slate-800 transition-colors">Download on App Store</a>
            <a href="#" className="bg-white text-slate-900 px-6 py-3 rounded-xl font-medium border border-slate-200 hover:bg-slate-50 transition-colors">Get it on Google Play</a>
          </div>
        </div>
      </section>

      {/* CTA Section */}
      <section className="py-20 px-4 sm:px-6 lg:px-8 bg-slate-900">
        <div className="max-w-4xl mx-auto text-center">
          <h2 className="text-3xl sm:text-4xl font-bold text-white mb-4">
            Ready to start selling?
          </h2>
          <p className="text-lg text-slate-400 mb-8">
            Join thousands of entrepreneurs who trust Sellar to power their business.
          </p>
          <Link 
            href="#download-app" 
            className="inline-flex items-center gap-2 bg-white hover:bg-slate-100 text-slate-900 px-8 py-4 rounded-xl font-semibold text-lg transition-colors"
          >
            Download the Mobile App
            <ArrowRight className="w-5 h-5" />
          </Link>
        </div>
      </section>

      {/* Footer */}
      <footer className="py-12 px-4 sm:px-6 lg:px-8 border-t border-slate-100">
        <div className="max-w-7xl mx-auto">
          <div className="flex flex-col md:flex-row items-center justify-between gap-6">
            <div className="flex items-center gap-2">
              <div className="w-8 h-8 bg-gradient-to-br from-indigo-500 to-violet-500 rounded-lg flex items-center justify-center">
                <span className="text-white font-bold text-sm">S</span>
              </div>
              <span className="text-xl font-bold text-slate-900">Sellar</span>
            </div>
            <div className="flex items-center gap-8 text-sm text-slate-600">
              <a href="#" className="hover:text-slate-900 transition-colors">Privacy Policy</a>
              <a href="#" className="hover:text-slate-900 transition-colors">Terms of Service</a>
              <a href="#" className="hover:text-slate-900 transition-colors">Contact</a>
            </div>
            <div className="text-sm text-slate-500">
              © {new Date().getFullYear()} Sellar. All rights reserved.
            </div>
          </div>
        </div>
      </footer>
    </div>
  );
}
