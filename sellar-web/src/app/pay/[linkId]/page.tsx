"use client";

import { useState, useEffect } from "react";
import { useParams } from "next/navigation";
import Image from "next/image";
import { 
  ShieldCheck, 
  Lock, 
  CreditCard, 
  Truck,
  ChevronRight,
  AlertCircle,
  Loader2,
  Check,
  Package
} from "lucide-react";

interface Product {
  id: string;
  name: string;
  description: string;
  price: number;
  currency: string;
  images: string[];
  category: string;
}

interface PaymentLink {
  id: string;
  shortCode: string;
  amount: number;
  currency: string;
  type: "PUBLIC" | "PRIVATE";
  isActive: boolean;
  product: Product | null;
  vendor: {
    businessName: string;
    email: string;
  };
}

interface CustomerData {
  name: string;
  email: string;
  phone: string;
  address: string;
  city: string;
  country: string;
}

export default function CheckoutPage() {
  const params = useParams();
  const linkId = params.linkId as string;

  const [link, setLink] = useState<PaymentLink | null>(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  const [step, setStep] = useState<"info" | "payment" | "success">("info");
  const [isPrivateLink, setIsPrivateLink] = useState(false);
  const [accessCode, setAccessCode] = useState("");
  const [codeVerified, setCodeVerified] = useState(false);
  const [verifyingCode, setVerifyingCode] = useState(false);
  const [submitting, setSubmitting] = useState(false);

  const [customerData, setCustomerData] = useState<CustomerData>({
    name: "",
    email: "",
    phone: "",
    address: "",
    city: "",
    country: "",
  });

  const [errors, setErrors] = useState<Partial<CustomerData>>({});

  useEffect(() => {
    fetchLinkDetails();
  }, [linkId]);

  const fetchLinkDetails = async () => {
    try {
      setLoading(true);
      // TODO: Replace with actual API call
      const response = await fetch(`${process.env.NEXT_PUBLIC_API_URL}/api/checkout/${linkId}`);
      
      if (!response.ok) {
        if (response.status === 404) {
          throw new Error("Payment link not found or has expired");
        }
        throw new Error("Failed to load payment details");
      }

      const data = await response.json();
      setLink(data.data);
      setIsPrivateLink(data.data.type === "PRIVATE");
    } catch (err) {
      // For demo, use mock data
      setLink({
        id: linkId,
        shortCode: linkId,
        amount: 299.99,
        currency: "USD",
        type: "PUBLIC",
        isActive: true,
        product: {
          id: "prod_1",
          name: "Premium Wireless Headphones",
          description: "High-quality noise-canceling wireless headphones with 30-hour battery life, premium sound quality, and comfortable over-ear design.",
          price: 299.99,
          currency: "USD",
          images: ["https://picsum.photos/seed/headphones/400/400"],
          category: "Electronics"
        },
        vendor: {
          businessName: "Tech Store",
          email: "support@techstore.com"
        }
      });
      setIsPrivateLink(false);
    } finally {
      setLoading(false);
    }
  };

  const verifyAccessCode = async () => {
    if (!accessCode.trim()) {
      return;
    }

    setVerifyingCode(true);
    try {
      // TODO: Replace with actual API call
      const response = await fetch(`${process.env.NEXT_PUBLIC_API_URL}/api/checkout/${linkId}/verify`, {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ code: accessCode }),
      });

      if (response.ok) {
        setCodeVerified(true);
      } else {
        setError("Invalid access code. Please check your email for the correct code.");
      }
    } catch (err) {
      // For demo, accept any 6-digit code
      if (accessCode.length === 6) {
        setCodeVerified(true);
      } else {
        setError("Invalid access code");
      }
    } finally {
      setVerifyingCode(false);
    }
  };

  const validateForm = (): boolean => {
    const newErrors: Partial<CustomerData> = {};

    if (!customerData.name.trim()) {
      newErrors.name = "Name is required";
    }

    if (!customerData.email.trim()) {
      newErrors.email = "Email is required";
    } else if (!/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(customerData.email)) {
      newErrors.email = "Please enter a valid email";
    }

    if (!customerData.phone.trim()) {
      newErrors.phone = "Phone number is required";
    }

    if (!customerData.address.trim()) {
      newErrors.address = "Address is required";
    }

    if (!customerData.city.trim()) {
      newErrors.city = "City is required";
    }

    if (!customerData.country.trim()) {
      newErrors.country = "Country is required";
    }

    setErrors(newErrors);
    return Object.keys(newErrors).length === 0;
  };

  const handleSubmitInfo = (e: React.FormEvent) => {
    e.preventDefault();
    if (validateForm()) {
      setStep("payment");
    }
  };

  const handlePayment = async () => {
    setSubmitting(true);
    try {
      // TODO: Replace with actual payment processing
      const response = await fetch(`${process.env.NEXT_PUBLIC_API_URL}/api/checkout/${linkId}/pay`, {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({
          customer: customerData,
          linkId: linkId,
        }),
      });

      // Simulate payment processing
      await new Promise(resolve => setTimeout(resolve, 2000));
      setStep("success");
    } catch (err) {
      // For demo, show success
      await new Promise(resolve => setTimeout(resolve, 2000));
      setStep("success");
    } finally {
      setSubmitting(false);
    }
  };

  const formatCurrency = (amount: number, currency: string) => {
    return new Intl.NumberFormat("en-US", {
      style: "currency",
      currency: currency,
    }).format(amount);
  };

  if (loading) {
    return (
      <div className="min-h-screen bg-slate-50 flex items-center justify-center">
        <div className="text-center">
          <Loader2 className="w-10 h-10 text-indigo-500 animate-spin mx-auto mb-4" />
          <p className="text-slate-600">Loading checkout...</p>
        </div>
      </div>
    );
  }

  if (error && !link) {
    return (
      <div className="min-h-screen bg-slate-50 flex items-center justify-center p-4">
        <div className="bg-white rounded-2xl shadow-lg p-8 max-w-md w-full text-center">
          <div className="w-16 h-16 bg-red-100 rounded-full flex items-center justify-center mx-auto mb-4">
            <AlertCircle className="w-8 h-8 text-red-500" />
          </div>
          <h1 className="text-2xl font-bold text-slate-900 mb-2">Link Not Found</h1>
          <p className="text-slate-600 mb-6">{error}</p>
          <a 
            href="/"
            className="inline-flex items-center gap-2 text-indigo-600 hover:text-indigo-700 font-medium"
          >
            Go to Homepage
            <ChevronRight className="w-4 h-4" />
          </a>
        </div>
      </div>
    );
  }

  // Private link code verification
  if (isPrivateLink && !codeVerified) {
    return (
      <div className="min-h-screen bg-slate-50 flex items-center justify-center p-4">
        <div className="bg-white rounded-2xl shadow-lg p-8 max-w-md w-full">
          <div className="text-center mb-6">
            <div className="w-16 h-16 bg-indigo-100 rounded-full flex items-center justify-center mx-auto mb-4">
              <Lock className="w-8 h-8 text-indigo-600" />
            </div>
            <h1 className="text-2xl font-bold text-slate-900 mb-2">Private Link</h1>
            <p className="text-slate-600">
              This is a private payment link. Please enter the access code sent to your email.
            </p>
          </div>

          <div className="space-y-4">
            <div>
              <label className="block text-sm font-medium text-slate-700 mb-2">
                Access Code
              </label>
              <input
                type="text"
                value={accessCode}
                onChange={(e) => setAccessCode(e.target.value.toUpperCase())}
                placeholder="Enter 6-digit code"
                maxLength={6}
                className="w-full px-4 py-3 border border-slate-200 rounded-xl focus:ring-2 focus:ring-indigo-500 focus:border-transparent text-center text-2xl tracking-widest font-mono"
              />
            </div>

            {error && (
              <p className="text-red-500 text-sm text-center">{error}</p>
            )}

            <button
              onClick={verifyAccessCode}
              disabled={verifyingCode || accessCode.length < 6}
              className="w-full bg-indigo-500 hover:bg-indigo-600 disabled:bg-slate-300 text-white py-3 rounded-xl font-semibold transition-colors flex items-center justify-center gap-2"
            >
              {verifyingCode ? (
                <>
                  <Loader2 className="w-5 h-5 animate-spin" />
                  Verifying...
                </>
              ) : (
                "Verify Code"
              )}
            </button>

            <p className="text-sm text-slate-500 text-center">
              Didn&apos;t receive a code?{" "}
              <button className="text-indigo-600 hover:text-indigo-700 font-medium">
                Resend
              </button>
            </p>
          </div>
        </div>
      </div>
    );
  }

  // Success state
  if (step === "success") {
    return (
      <div className="min-h-screen bg-slate-50 flex items-center justify-center p-4">
        <div className="bg-white rounded-2xl shadow-lg p-8 max-w-md w-full text-center">
          <div className="w-20 h-20 bg-emerald-100 rounded-full flex items-center justify-center mx-auto mb-6">
            <Check className="w-10 h-10 text-emerald-500" />
          </div>
          <h1 className="text-2xl font-bold text-slate-900 mb-2">Payment Successful!</h1>
          <p className="text-slate-600 mb-6">
            Thank you for your purchase. A confirmation email has been sent to {customerData.email}.
          </p>
          
          <div className="bg-slate-50 rounded-xl p-4 mb-6">
            <div className="flex items-center justify-between mb-2">
              <span className="text-slate-600">Order ID</span>
              <span className="font-mono text-slate-900">ORD-{Date.now().toString(36).toUpperCase()}</span>
            </div>
            <div className="flex items-center justify-between">
              <span className="text-slate-600">Amount Paid</span>
              <span className="font-semibold text-slate-900">
                {formatCurrency(link?.amount || 0, link?.currency || "USD")}
              </span>
            </div>
          </div>

          <div className="flex items-center gap-3 p-4 bg-indigo-50 rounded-xl text-left">
            <Truck className="w-6 h-6 text-indigo-600 flex-shrink-0" />
            <div>
              <p className="font-medium text-slate-900">Delivery Information</p>
              <p className="text-sm text-slate-600">
                You will receive tracking information once your order ships.
              </p>
            </div>
          </div>
        </div>
      </div>
    );
  }

  return (
    <div className="min-h-screen bg-slate-50">
      {/* Header */}
      <header className="bg-white border-b border-slate-100 py-4 px-4">
        <div className="max-w-6xl mx-auto flex items-center justify-between">
          <div className="flex items-center gap-2">
            <div className="w-8 h-8 bg-gradient-to-br from-indigo-500 to-violet-500 rounded-lg flex items-center justify-center">
              <span className="text-white font-bold text-sm">S</span>
            </div>
            <span className="text-lg font-bold text-slate-900">Sellar</span>
          </div>
          <div className="flex items-center gap-2 text-sm text-slate-600">
            <ShieldCheck className="w-4 h-4 text-emerald-500" />
            Secure Checkout
          </div>
        </div>
      </header>

      <main className="max-w-6xl mx-auto px-4 py-8">
        <div className="grid lg:grid-cols-2 gap-8">
          {/* Left: Product Info */}
          <div className="order-2 lg:order-1">
            <div className="bg-white rounded-2xl shadow-sm p-6 sticky top-8">
              <h2 className="text-lg font-semibold text-slate-900 mb-4">Order Summary</h2>
              
              {link?.product && (
                <div className="flex gap-4 pb-4 border-b border-slate-100">
                  <div className="w-24 h-24 bg-slate-100 rounded-xl overflow-hidden flex-shrink-0">
                    {link.product.images[0] ? (
                      <Image
                        src={link.product.images[0]}
                        alt={link.product.name}
                        width={96}
                        height={96}
                        className="w-full h-full object-cover"
                      />
                    ) : (
                      <div className="w-full h-full flex items-center justify-center">
                        <Package className="w-8 h-8 text-slate-400" />
                      </div>
                    )}
                  </div>
                  <div className="flex-1">
                    <h3 className="font-semibold text-slate-900">{link.product.name}</h3>
                    <p className="text-sm text-slate-500 mt-1 line-clamp-2">
                      {link.product.description}
                    </p>
                    <p className="text-sm text-slate-500 mt-1">
                      Category: {link.product.category}
                    </p>
                  </div>
                </div>
              )}

              <div className="py-4 space-y-3">
                <div className="flex items-center justify-between">
                  <span className="text-slate-600">Subtotal</span>
                  <span className="text-slate-900">
                    {formatCurrency(link?.amount || 0, link?.currency || "USD")}
                  </span>
                </div>
                <div className="flex items-center justify-between">
                  <span className="text-slate-600">Shipping</span>
                  <span className="text-slate-900">Free</span>
                </div>
              </div>

              <div className="pt-4 border-t border-slate-100">
                <div className="flex items-center justify-between">
                  <span className="text-lg font-semibold text-slate-900">Total</span>
                  <span className="text-2xl font-bold text-slate-900">
                    {formatCurrency(link?.amount || 0, link?.currency || "USD")}
                  </span>
                </div>
              </div>

              <div className="mt-6 p-4 bg-slate-50 rounded-xl">
                <p className="text-sm text-slate-600">
                  <span className="font-medium">Sold by:</span> {link?.vendor.businessName}
                </p>
              </div>

              {/* Trust badges */}
              <div className="mt-6 flex items-center justify-center gap-6 text-xs text-slate-500">
                <div className="flex items-center gap-1">
                  <ShieldCheck className="w-4 h-4 text-emerald-500" />
                  Secure Payment
                </div>
                <div className="flex items-center gap-1">
                  <Lock className="w-4 h-4 text-emerald-500" />
                  SSL Encrypted
                </div>
              </div>
            </div>
          </div>

          {/* Right: Checkout Form */}
          <div className="order-1 lg:order-2">
            {/* Progress Steps */}
            <div className="flex items-center gap-4 mb-8">
              <div className={`flex items-center gap-2 ${step === "info" ? "text-indigo-600" : "text-slate-400"}`}>
                <div className={`w-8 h-8 rounded-full flex items-center justify-center text-sm font-semibold ${
                  step === "info" ? "bg-indigo-600 text-white" : "bg-emerald-500 text-white"
                }`}>
                  {step === "payment" ? <Check className="w-4 h-4" /> : "1"}
                </div>
                <span className="font-medium">Your Info</span>
              </div>
              <div className="flex-1 h-0.5 bg-slate-200">
                <div className={`h-full bg-indigo-600 transition-all ${step === "payment" ? "w-full" : "w-0"}`} />
              </div>
              <div className={`flex items-center gap-2 ${step === "payment" ? "text-indigo-600" : "text-slate-400"}`}>
                <div className={`w-8 h-8 rounded-full flex items-center justify-center text-sm font-semibold ${
                  step === "payment" ? "bg-indigo-600 text-white" : "bg-slate-200"
                }`}>
                  2
                </div>
                <span className="font-medium">Payment</span>
              </div>
            </div>

            {step === "info" && (
              <form onSubmit={handleSubmitInfo} className="bg-white rounded-2xl shadow-sm p-6">
                <h2 className="text-xl font-semibold text-slate-900 mb-6">Contact Information</h2>

                <div className="space-y-4">
                  <div>
                    <label className="block text-sm font-medium text-slate-700 mb-1">
                      Full Name *
                    </label>
                    <input
                      type="text"
                      value={customerData.name}
                      onChange={(e) => setCustomerData({ ...customerData, name: e.target.value })}
                      className={`w-full px-4 py-3 border rounded-xl focus:ring-2 focus:ring-indigo-500 focus:border-transparent ${
                        errors.name ? "border-red-300" : "border-slate-200"
                      }`}
                      placeholder="John Doe"
                    />
                    {errors.name && <p className="text-red-500 text-sm mt-1">{errors.name}</p>}
                  </div>

                  <div className="grid sm:grid-cols-2 gap-4">
                    <div>
                      <label className="block text-sm font-medium text-slate-700 mb-1">
                        Email Address *
                      </label>
                      <input
                        type="email"
                        value={customerData.email}
                        onChange={(e) => setCustomerData({ ...customerData, email: e.target.value })}
                        className={`w-full px-4 py-3 border rounded-xl focus:ring-2 focus:ring-indigo-500 focus:border-transparent ${
                          errors.email ? "border-red-300" : "border-slate-200"
                        }`}
                        placeholder="john@example.com"
                      />
                      {errors.email && <p className="text-red-500 text-sm mt-1">{errors.email}</p>}
                    </div>

                    <div>
                      <label className="block text-sm font-medium text-slate-700 mb-1">
                        Phone Number *
                      </label>
                      <input
                        type="tel"
                        value={customerData.phone}
                        onChange={(e) => setCustomerData({ ...customerData, phone: e.target.value })}
                        className={`w-full px-4 py-3 border rounded-xl focus:ring-2 focus:ring-indigo-500 focus:border-transparent ${
                          errors.phone ? "border-red-300" : "border-slate-200"
                        }`}
                        placeholder="+1 234 567 8900"
                      />
                      {errors.phone && <p className="text-red-500 text-sm mt-1">{errors.phone}</p>}
                    </div>
                  </div>

                  <div className="pt-4 border-t border-slate-100">
                    <h3 className="text-lg font-semibold text-slate-900 mb-4">Shipping Address</h3>
                    
                    <div className="space-y-4">
                      <div>
                        <label className="block text-sm font-medium text-slate-700 mb-1">
                          Street Address *
                        </label>
                        <input
                          type="text"
                          value={customerData.address}
                          onChange={(e) => setCustomerData({ ...customerData, address: e.target.value })}
                          className={`w-full px-4 py-3 border rounded-xl focus:ring-2 focus:ring-indigo-500 focus:border-transparent ${
                            errors.address ? "border-red-300" : "border-slate-200"
                          }`}
                          placeholder="123 Main Street, Apt 4B"
                        />
                        {errors.address && <p className="text-red-500 text-sm mt-1">{errors.address}</p>}
                      </div>

                      <div className="grid sm:grid-cols-2 gap-4">
                        <div>
                          <label className="block text-sm font-medium text-slate-700 mb-1">
                            City *
                          </label>
                          <input
                            type="text"
                            value={customerData.city}
                            onChange={(e) => setCustomerData({ ...customerData, city: e.target.value })}
                            className={`w-full px-4 py-3 border rounded-xl focus:ring-2 focus:ring-indigo-500 focus:border-transparent ${
                              errors.city ? "border-red-300" : "border-slate-200"
                            }`}
                            placeholder="New York"
                          />
                          {errors.city && <p className="text-red-500 text-sm mt-1">{errors.city}</p>}
                        </div>

                        <div>
                          <label className="block text-sm font-medium text-slate-700 mb-1">
                            Country *
                          </label>
                          <input
                            type="text"
                            value={customerData.country}
                            onChange={(e) => setCustomerData({ ...customerData, country: e.target.value })}
                            className={`w-full px-4 py-3 border rounded-xl focus:ring-2 focus:ring-indigo-500 focus:border-transparent ${
                              errors.country ? "border-red-300" : "border-slate-200"
                            }`}
                            placeholder="United States"
                          />
                          {errors.country && <p className="text-red-500 text-sm mt-1">{errors.country}</p>}
                        </div>
                      </div>
                    </div>
                  </div>
                </div>

                <button
                  type="submit"
                  className="mt-6 w-full bg-indigo-500 hover:bg-indigo-600 text-white py-4 rounded-xl font-semibold text-lg transition-colors flex items-center justify-center gap-2"
                >
                  Continue to Payment
                  <ChevronRight className="w-5 h-5" />
                </button>
              </form>
            )}

            {step === "payment" && (
              <div className="bg-white rounded-2xl shadow-sm p-6">
                <h2 className="text-xl font-semibold text-slate-900 mb-6">Payment Method</h2>

                <div className="space-y-4">
                  {/* Payment method selection */}
                  <div className="border-2 border-indigo-500 rounded-xl p-4 bg-indigo-50">
                    <div className="flex items-center gap-3">
                      <div className="w-5 h-5 rounded-full border-2 border-indigo-500 flex items-center justify-center">
                        <div className="w-2.5 h-2.5 rounded-full bg-indigo-500" />
                      </div>
                      <CreditCard className="w-6 h-6 text-slate-600" />
                      <span className="font-medium text-slate-900">Credit / Debit Card</span>
                    </div>
                  </div>

                  {/* Card form placeholder */}
                  <div className="p-4 bg-slate-50 rounded-xl">
                    <p className="text-sm text-slate-600 text-center">
                      Card payment form will be integrated with your preferred payment gateway (Stripe, Paystack, Flutterwave)
                    </p>
                  </div>

                  {/* Order summary */}
                  <div className="pt-4 border-t border-slate-100">
                    <div className="flex items-center justify-between mb-2">
                      <span className="text-slate-600">Shipping to:</span>
                      <button 
                        onClick={() => setStep("info")}
                        className="text-indigo-600 text-sm font-medium hover:text-indigo-700"
                      >
                        Edit
                      </button>
                    </div>
                    <p className="text-slate-900">
                      {customerData.name}<br />
                      {customerData.address}<br />
                      {customerData.city}, {customerData.country}
                    </p>
                  </div>
                </div>

                <button
                  onClick={handlePayment}
                  disabled={submitting}
                  className="mt-6 w-full bg-indigo-500 hover:bg-indigo-600 disabled:bg-slate-300 text-white py-4 rounded-xl font-semibold text-lg transition-colors flex items-center justify-center gap-2"
                >
                  {submitting ? (
                    <>
                      <Loader2 className="w-5 h-5 animate-spin" />
                      Processing...
                    </>
                  ) : (
                    <>
                      Pay {formatCurrency(link?.amount || 0, link?.currency || "USD")}
                      <Lock className="w-4 h-4" />
                    </>
                  )}
                </button>

                <p className="mt-4 text-xs text-slate-500 text-center">
                  By completing this purchase, you agree to our Terms of Service and Privacy Policy.
                </p>
              </div>
            )}
          </div>
        </div>
      </main>
    </div>
  );
}
