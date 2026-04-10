"use client";

import { useState, useEffect, useRef } from "react";
import { useParams } from "next/navigation";
import Link from "next/link";
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
  Package,
  RefreshCw,
} from "lucide-react";
import Logo from "@/components/Logo";

const API = process.env.NEXT_PUBLIC_API_URL ?? "";

interface Product {
  id: string;
  name: string;
  description: string | null;
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

type Step = "info" | "payment" | "success";

function formatCurrency(amount: number, currency: string) {
  return new Intl.NumberFormat("en-US", {
    style: "currency",
    currency,
  }).format(amount);
}

export default function CheckoutPage() {
  const params = useParams();
  const linkId = params.linkId as string;

  const [link, setLink] = useState<PaymentLink | null>(null);
  const [loading, setLoading] = useState(true);
  const [fetchError, setFetchError] = useState<string | null>(null);
  const [step, setStep] = useState<Step>("info");
  const [isPrivateLink, setIsPrivateLink] = useState(false);
  const [codeVerified, setCodeVerified] = useState(false);
  const [accessCode, setAccessCode] = useState("");
  const [codeError, setCodeError] = useState<string | null>(null);
  const [verifyingCode, setVerifyingCode] = useState(false);
  const [submitting, setSubmitting] = useState(false);
  const [submitError, setSubmitError] = useState<string | null>(null);
  const [orderId, setOrderId] = useState<string | null>(null);

  const [customerData, setCustomerData] = useState<CustomerData>({
    name: "",
    email: "",
    phone: "",
    address: "",
    city: "",
    country: "",
  });
  const [fieldErrors, setFieldErrors] = useState<Partial<CustomerData>>({});

  const hasFetched = useRef(false);

  useEffect(() => {
    if (!hasFetched.current) {
      hasFetched.current = true;
      fetchLinkDetails();
    }
  // eslint-disable-next-line react-hooks/exhaustive-deps
  }, []);

  async function fetchLinkDetails() {
    setLoading(true);
    setFetchError(null);
    try {
      const res = await fetch(`${API}/api/checkout/${linkId}`);
      if (res.status === 404 || res.status === 410) {
        const body = await res.json().catch(() => ({}));
        throw new Error(body.message ?? "Payment link not found or has expired");
      }
      if (!res.ok) throw new Error("Failed to load payment details. Please try again.");
      const { data } = await res.json();
      setLink(data);
      setIsPrivateLink(data.type === "PRIVATE");
    } catch (err: unknown) {
      setFetchError(err instanceof Error ? err.message : "Something went wrong");
    } finally {
      setLoading(false);
    }
  }

  async function verifyAccessCode() {
    setCodeError(null);
    setVerifyingCode(true);
    try {
      const res = await fetch(`${API}/api/checkout/${linkId}/verify`, {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ code: accessCode }),
      });
      if (res.ok) {
        setCodeVerified(true);
      } else {
        const body = await res.json().catch(() => ({}));
        setCodeError(body.message ?? "Invalid access code. Please check your email.");
      }
    } catch {
      setCodeError("Unable to verify code. Check your connection and try again.");
    } finally {
      setVerifyingCode(false);
    }
  }

  function validateForm(): boolean {
    const errs: Partial<CustomerData> = {};
    if (!customerData.name.trim()) errs.name = "Name is required";
    if (!customerData.email.trim()) {
      errs.email = "Email is required";
    } else if (!/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(customerData.email)) {
      errs.email = "Please enter a valid email";
    }
    if (!customerData.phone.trim()) errs.phone = "Phone number is required";
    if (!customerData.address.trim()) errs.address = "Address is required";
    if (!customerData.city.trim()) errs.city = "City is required";
    if (!customerData.country.trim()) errs.country = "Country is required";
    setFieldErrors(errs);
    return Object.keys(errs).length === 0;
  }

  function handleSubmitInfo(e: React.FormEvent) {
    e.preventDefault();
    if (validateForm()) setStep("payment");
  }

  async function handlePayment() {
    setSubmitting(true);
    setSubmitError(null);
    try {
      const res = await fetch(`${API}/api/checkout/${linkId}/pay`, {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ customer: customerData }),
      });
      if (!res.ok) {
        const body = await res.json().catch(() => ({}));
        throw new Error(body.message ?? "Payment failed. Please try again.");
      }
      const { data } = await res.json();
      setOrderId(data.orderId ?? null);
      setStep("success");
    } catch (err: unknown) {
      setSubmitError(err instanceof Error ? err.message : "Payment failed. Please try again.");
    } finally {
      setSubmitting(false);
    }
  }

  // ── Loading ──────────────────────────────────────────────────────────────
  if (loading) {
    return (
      <div className="min-h-screen bg-slate-50 flex items-center justify-center">
        <div className="text-center">
          <Loader2 className="w-10 h-10 text-indigo-500 animate-spin mx-auto mb-4" />
          <p className="text-slate-600">Loading checkout&hellip;</p>
        </div>
      </div>
    );
  }

  // ── Fetch error ───────────────────────────────────────────────────────────
  if (fetchError) {
    return (
      <div className="min-h-screen bg-slate-50 flex items-center justify-center p-4">
        <div className="bg-white rounded-2xl shadow-lg p-8 max-w-md w-full text-center">
          <div className="w-16 h-16 bg-red-100 rounded-full flex items-center justify-center mx-auto mb-4">
            <AlertCircle className="w-8 h-8 text-red-500" />
          </div>
          <h1 className="text-2xl font-bold text-slate-900 mb-2">Link Unavailable</h1>
          <p className="text-slate-600 mb-6">{fetchError}</p>
          <div className="flex flex-col gap-3">
            <button
              onClick={() => { hasFetched.current = false; fetchLinkDetails(); }}
              className="inline-flex items-center justify-center gap-2 bg-indigo-500 hover:bg-indigo-600 text-white px-6 py-3 rounded-xl font-semibold transition-colors"
            >
              <RefreshCw className="w-4 h-4" /> Try Again
            </button>
            <Link
              href="/"
              className="inline-flex items-center justify-center gap-2 text-slate-600 hover:text-slate-900 font-medium"
            >
              Go to Homepage <ChevronRight className="w-4 h-4" />
            </Link>
          </div>
        </div>
      </div>
    );
  }

  // ── Private link gate ─────────────────────────────────────────────────────
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
              This is a private payment link. Enter the access code sent to your email.
            </p>
          </div>

          <div className="space-y-4">
            <div>
              <label className="block text-sm font-medium text-slate-700 mb-2">Access Code</label>
              <input
                type="text"
                value={accessCode}
                onChange={(e) => { setAccessCode(e.target.value.toUpperCase()); setCodeError(null); }}
                placeholder="ABC123"
                maxLength={6}
                className="w-full px-4 py-3 border border-slate-200 rounded-xl text-slate-900 placeholder:text-slate-400 focus:ring-2 focus:ring-indigo-500 focus:border-transparent text-center text-2xl tracking-widest font-mono uppercase"
              />
            </div>

            {codeError && (
              <p className="text-red-500 text-sm text-center">{codeError}</p>
            )}

            <button
              onClick={verifyAccessCode}
              disabled={verifyingCode || accessCode.length < 6}
              className="w-full bg-indigo-500 hover:bg-indigo-600 disabled:opacity-50 disabled:cursor-not-allowed text-white py-3 rounded-xl font-semibold transition-colors flex items-center justify-center gap-2"
            >
              {verifyingCode ? (
                <><Loader2 className="w-5 h-5 animate-spin" /> Verifying&hellip;</>
              ) : "Verify Code"}
            </button>
          </div>
        </div>
      </div>
    );
  }

  // ── Success ───────────────────────────────────────────────────────────────
  if (step === "success") {
    return (
      <div className="min-h-screen bg-slate-50 flex items-center justify-center p-4">
        <div className="bg-white rounded-2xl shadow-lg p-8 max-w-md w-full text-center">
          <div className="w-20 h-20 bg-emerald-100 rounded-full flex items-center justify-center mx-auto mb-6">
            <Check className="w-10 h-10 text-emerald-500" />
          </div>
          <h1 className="text-2xl font-bold text-slate-900 mb-2">Order Placed!</h1>
          <p className="text-slate-600 mb-6">
            Thank you for your purchase. A confirmation will be sent to{" "}
            <strong>{customerData.email}</strong>.
          </p>

          <div className="bg-slate-50 rounded-xl p-4 mb-6 text-left space-y-2">
            {orderId && (
              <div className="flex items-center justify-between">
                <span className="text-slate-500 text-sm">Order ID</span>
                <span className="font-mono text-slate-900 text-sm">{orderId}</span>
              </div>
            )}
            <div className="flex items-center justify-between">
              <span className="text-slate-500 text-sm">Amount</span>
              <span className="font-semibold text-slate-900">
                {formatCurrency(link?.amount ?? 0, link?.currency ?? "USD")}
              </span>
            </div>
            <div className="flex items-center justify-between">
              <span className="text-slate-500 text-sm">Sold by</span>
              <span className="text-slate-900 text-sm">{link?.vendor.businessName}</span>
            </div>
          </div>

          <div className="flex items-start gap-3 p-4 bg-indigo-50 rounded-xl text-left">
            <Truck className="w-5 h-5 text-indigo-600 mt-0.5 shrink-0" />
            <div>
              <p className="font-medium text-slate-900 text-sm">Delivery update</p>
              <p className="text-xs text-slate-600 mt-0.5">
                You will receive tracking information once your order ships.
              </p>
            </div>
          </div>

          <Link
            href="/"
            className="mt-6 inline-flex items-center gap-2 text-indigo-600 hover:text-indigo-700 text-sm font-medium"
          >
            Back to Homepage <ChevronRight className="w-4 h-4" />
          </Link>
        </div>
      </div>
    );
  }

  // ── Checkout form ─────────────────────────────────────────────────────────
  return (
    <div className="min-h-screen bg-slate-50">
      <header className="bg-white border-b border-slate-100 py-4 px-4">
        <div className="max-w-6xl mx-auto flex items-center justify-between">
          <Logo size="sm" />
          <div className="flex items-center gap-2 text-sm text-slate-600">
            <ShieldCheck className="w-4 h-4 text-emerald-500" />
            Secure Checkout
          </div>
        </div>
      </header>

      <main className="max-w-6xl mx-auto px-4 py-8">
        <div className="grid lg:grid-cols-2 gap-8">
          {/* Order Summary */}
          <div className="order-2 lg:order-1">
            <div className="bg-white rounded-2xl shadow-sm p-6 lg:sticky top-8">
              <h2 className="text-lg font-semibold text-slate-900 mb-4">Order Summary</h2>

              {link?.product && (
                <div className="flex gap-4 pb-4 border-b border-slate-100">
                  <div className="w-24 h-24 bg-slate-100 rounded-xl overflow-hidden shrink-0">
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
                  <div className="flex-1 min-w-0">
                    <h3 className="font-semibold text-slate-900 truncate">{link.product.name}</h3>
                    {link.product.description && (
                      <p className="text-sm text-slate-500 mt-1 line-clamp-2">
                        {link.product.description}
                      </p>
                    )}
                    <p className="text-xs text-slate-400 mt-1">{link.product.category}</p>
                  </div>
                </div>
              )}

              <div className="py-4 space-y-2 text-sm">
                <div className="flex justify-between">
                  <span className="text-slate-500">Subtotal</span>
                  <span className="text-slate-900">
                    {formatCurrency(link?.amount ?? 0, link?.currency ?? "USD")}
                  </span>
                </div>
                <div className="flex justify-between">
                  <span className="text-slate-500">Shipping</span>
                  <span className="text-emerald-600 font-medium">Free</span>
                </div>
              </div>

              <div className="pt-4 border-t border-slate-100 flex items-center justify-between">
                <span className="font-semibold text-slate-900">Total</span>
                <span className="text-2xl font-bold text-slate-900">
                  {formatCurrency(link?.amount ?? 0, link?.currency ?? "USD")}
                </span>
              </div>

              {link?.vendor && (
                <p className="mt-4 text-xs text-slate-400">
                  Sold by <span className="text-slate-600 font-medium">{link.vendor.businessName}</span>
                </p>
              )}

              <div className="mt-6 flex items-center justify-center gap-6 text-xs text-slate-400">
                <span className="flex items-center gap-1">
                  <ShieldCheck className="w-3.5 h-3.5 text-emerald-500" /> Secure Payment
                </span>
                <span className="flex items-center gap-1">
                  <Lock className="w-3.5 h-3.5 text-emerald-500" /> SSL Encrypted
                </span>
              </div>
            </div>
          </div>

          {/* Checkout Form */}
          <div className="order-1 lg:order-2">
            {/* Step indicator */}
            <div className="flex items-center gap-4 mb-6">
              <div className="flex items-center gap-2 text-indigo-600">
                <div className={`w-8 h-8 rounded-full flex items-center justify-center text-sm font-semibold ${
                  step === "info" ? "bg-indigo-600 text-white" : "bg-emerald-500 text-white"
                }`}>
                  {step === "payment" ? <Check className="w-4 h-4" /> : "1"}
                </div>
                <span className={`font-medium text-sm ${
                  step === "info" ? "text-indigo-600" : "text-slate-400"
                }`}>Your Info</span>
              </div>
              <div className="flex-1 h-px bg-slate-200">
                <div className={`h-full bg-indigo-500 transition-all duration-300 ${
                  step === "payment" ? "w-full" : "w-0"
                }`} />
              </div>
              <div className="flex items-center gap-2">
                <div className={`w-8 h-8 rounded-full flex items-center justify-center text-sm font-semibold ${
                  step === "payment" ? "bg-indigo-600 text-white" : "bg-slate-200 text-slate-500"
                }`}>
                  2
                </div>
                <span className={`font-medium text-sm ${
                  step === "payment" ? "text-indigo-600" : "text-slate-400"
                }`}>Payment</span>
              </div>
            </div>

            {step === "info" && (
              <form onSubmit={handleSubmitInfo} className="bg-white rounded-2xl shadow-sm p-6 space-y-4">
                <h2 className="text-xl font-semibold text-slate-900">Contact Information</h2>

                <Field label="Full Name" error={fieldErrors.name}>
                  <input
                    type="text"
                    value={customerData.name}
                    onChange={(e) => setCustomerData((d) => ({ ...d, name: e.target.value }))}
                    className={inputCls(!!fieldErrors.name)}
                    placeholder="Jane Doe"
                  />
                </Field>

                <div className="grid sm:grid-cols-2 gap-4">
                  <Field label="Email Address" error={fieldErrors.email}>
                    <input
                      type="email"
                      value={customerData.email}
                      onChange={(e) => setCustomerData((d) => ({ ...d, email: e.target.value }))}
                      className={inputCls(!!fieldErrors.email)}
                      placeholder="jane@example.com"
                    />
                  </Field>
                  <Field label="Phone Number" error={fieldErrors.phone}>
                    <input
                      type="tel"
                      value={customerData.phone}
                      onChange={(e) => setCustomerData((d) => ({ ...d, phone: e.target.value }))}
                      className={inputCls(!!fieldErrors.phone)}
                      placeholder="+234 800 000 0000"
                    />
                  </Field>
                </div>

                <div className="pt-3 border-t border-slate-100">
                  <h3 className="font-semibold text-slate-800 mb-3">Shipping Address</h3>
                  <div className="space-y-4">
                    <Field label="Street Address" error={fieldErrors.address}>
                      <input
                        type="text"
                        value={customerData.address}
                        onChange={(e) => setCustomerData((d) => ({ ...d, address: e.target.value }))}
                        className={inputCls(!!fieldErrors.address)}
                        placeholder="12 Main Street"
                      />
                    </Field>
                    <div className="grid sm:grid-cols-2 gap-4">
                      <Field label="City" error={fieldErrors.city}>
                        <input
                          type="text"
                          value={customerData.city}
                          onChange={(e) => setCustomerData((d) => ({ ...d, city: e.target.value }))}
                          className={inputCls(!!fieldErrors.city)}
                          placeholder="Lagos"
                        />
                      </Field>
                      <Field label="Country" error={fieldErrors.country}>
                        <input
                          type="text"
                          value={customerData.country}
                          onChange={(e) => setCustomerData((d) => ({ ...d, country: e.target.value }))}
                          className={inputCls(!!fieldErrors.country)}
                          placeholder="Nigeria"
                        />
                      </Field>
                    </div>
                  </div>
                </div>

                <button
                  type="submit"
                  className="w-full bg-indigo-500 hover:bg-indigo-600 text-white py-4 rounded-xl font-semibold text-lg transition-colors flex items-center justify-center gap-2"
                >
                  Continue to Payment <ChevronRight className="w-5 h-5" />
                </button>
              </form>
            )}

            {step === "payment" && (
              <div className="bg-white rounded-2xl shadow-sm p-6 space-y-4">
                <h2 className="text-xl font-semibold text-slate-900">Payment Method</h2>

                <div className="border-2 border-indigo-500 rounded-xl p-4 bg-indigo-50">
                  <div className="flex items-center gap-3">
                    <div className="w-5 h-5 rounded-full border-2 border-indigo-500 flex items-center justify-center">
                      <div className="w-2.5 h-2.5 rounded-full bg-indigo-500" />
                    </div>
                    <CreditCard className="w-5 h-5 text-slate-600" />
                    <span className="font-medium text-slate-900">Credit / Debit Card</span>
                  </div>
                </div>

                <div className="p-4 bg-slate-50 rounded-xl text-center">
                  <p className="text-sm text-slate-500">
                    Payment gateway integration (Stripe / Paystack / Flutterwave) coming soon.
                  </p>
                </div>

                <div className="pt-3 border-t border-slate-100">
                  <div className="flex justify-between items-center mb-2">
                    <span className="text-sm text-slate-500">Shipping to</span>
                    <button
                      onClick={() => setStep("info")}
                      className="text-indigo-600 text-sm font-medium hover:text-indigo-700"
                    >
                      Edit
                    </button>
                  </div>
                  <p className="text-sm text-slate-700">
                    {customerData.name}<br />
                    {customerData.address}, {customerData.city}<br />
                    {customerData.country}
                  </p>
                </div>

                {submitError && (
                  <div className="flex items-start gap-2 p-3 bg-red-50 rounded-xl">
                    <AlertCircle className="w-4 h-4 text-red-500 mt-0.5 shrink-0" />
                    <p className="text-red-600 text-sm">{submitError}</p>
                  </div>
                )}

                <button
                  onClick={handlePayment}
                  disabled={submitting}
                  className="w-full bg-indigo-500 hover:bg-indigo-600 disabled:opacity-50 disabled:cursor-not-allowed text-white py-4 rounded-xl font-semibold text-lg transition-colors flex items-center justify-center gap-2"
                >
                  {submitting ? (
                    <><Loader2 className="w-5 h-5 animate-spin" /> Processing&hellip;</>
                  ) : (
                    <>Pay {formatCurrency(link?.amount ?? 0, link?.currency ?? "USD")} <Lock className="w-4 h-4" /></>
                  )}
                </button>

                <p className="text-xs text-slate-400 text-center">
                  By completing this purchase you agree to our{" "}
                  <Link href="/terms" className="underline hover:text-slate-600">Terms of Service</Link>{" "}
                  and{" "}
                  <Link href="/privacy" className="underline hover:text-slate-600">Privacy Policy</Link>.
                </p>
              </div>
            )}
          </div>
        </div>
      </main>
    </div>
  );
}

// ── helpers ────────────────────────────────────────────────────────────────

function inputCls(hasError: boolean) {
  return `w-full px-4 py-3 border rounded-xl text-slate-900 placeholder:text-slate-400 focus:outline-none focus:ring-2 focus:ring-indigo-500 focus:border-transparent transition-colors ${
    hasError ? "border-red-300 bg-red-50" : "border-slate-200"
  }`;
}

function Field({
  label,
  error,
  children,
}: {
  label: string;
  error?: string;
  children: React.ReactNode;
}) {
  return (
    <div>
      <label className="block text-sm font-medium text-slate-700 mb-1">
        {label} <span className="text-red-400">*</span>
      </label>
      {children}
      {error && <p className="text-red-500 text-xs mt-1">{error}</p>}
    </div>
  );
}
