"use client";

import { useEffect, useState } from "react";
import {
  products as productsApi,
  links as linksApi,
  customers as customersApi,
  Product,
  PaymentLink,
  Customer,
  ApiError,
  linkViewCount,
  linkPaymentCount,
} from "@/lib/api";
import { useAuth } from "@/lib/auth-context";
import {
  Package,
  Link2,
  Users,
  TrendingUp,
  Eye,
  ShoppingCart,
  RefreshCw,
  DollarSign,
} from "lucide-react";

function StatCard({
  icon: Icon,
  label,
  value,
  sub,
  color = "indigo",
}: {
  icon: React.ElementType;
  label: string;
  value: string | number;
  sub?: string;
  color?: "indigo" | "emerald" | "amber" | "violet";
}) {
  const colors = {
    indigo: "bg-indigo-50 text-indigo-600",
    emerald: "bg-emerald-50 text-emerald-600",
    amber: "bg-amber-50 text-amber-600",
    violet: "bg-violet-50 text-violet-600",
  };
  return (
    <div className="bg-white rounded-xl border border-slate-200 p-5">
      <div className={`w-10 h-10 rounded-lg flex items-center justify-center mb-3 ${colors[color]}`}>
        <Icon size={20} />
      </div>
      <p className="text-2xl font-bold text-slate-900">{value}</p>
      <p className="text-sm font-medium text-slate-700 mt-0.5">{label}</p>
      {sub && <p className="text-xs text-slate-400 mt-0.5">{sub}</p>}
    </div>
  );
}

type Tab = "overview" | "products" | "links" | "customers";

export default function AnalyticsPage() {
  const { vendor } = useAuth();
  const [productsList, setProducts] = useState<Product[]>([]);
  const [linksList, setLinks] = useState<PaymentLink[]>([]);
  const [customersList, setCustomers] = useState<Customer[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState("");
  const [tab, setTab] = useState<Tab>("overview");

  async function load() {
    setLoading(true);
    setError("");
    try {
      const [pRes, lRes, cRes] = await Promise.all([
        productsApi.list(),
        linksApi.list(),
        customersApi.list(),
      ]);
      setProducts(pRes.data);
      setLinks(lRes.data);
      setCustomers(cRes.data);
    } catch (err) {
      setError(err instanceof ApiError ? err.message : "Failed to load analytics.");
    } finally {
      setLoading(false);
    }
  }

  useEffect(() => { load(); }, []);

  // Computed metrics
  const totalProducts = productsList.length;
  const activeProducts = productsList.filter((p) => p.isActive).length;
  const inactiveProducts = productsList.filter((p) => !p.isActive).length;
  const lowStock = productsList.filter((p) => p.quantity != null && p.quantity <= 3).length;

  const totalLinks = linksList.length;
  const activeLinks = linksList.filter((l) => l.isActive && !(l.expiresAt && new Date(l.expiresAt) < new Date())).length;
  const totalViews = linksList.reduce((s, l) => s + linkViewCount(l), 0);
  const totalPayments = linksList.reduce((s, l) => s + linkPaymentCount(l), 0);
  const totalRevenue = linksList.reduce((s, l) => s + l.amount * linkPaymentCount(l), 0);

  const totalCustomers = customersList.length;
  const customerRevenue = customersList.reduce((s, c) => s + c.totalSpent, 0);

  const convRate = totalViews > 0 ? ((totalPayments / totalViews) * 100).toFixed(1) : "0";

  const tabs: { key: Tab; label: string }[] = [
    { key: "overview", label: "Overview" },
    { key: "products", label: "Products" },
    { key: "links", label: "Links" },
    { key: "customers", label: "Customers" },
  ];

  const fmt = (n: number, currency = "USD") =>
    new Intl.NumberFormat("en-US", { style: "currency", currency }).format(n);

  return (
    <div>
      <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-4 mb-6">
        <div>
          <h1 className="text-xl sm:text-2xl font-bold text-slate-900">Analytics</h1>
          <p className="text-slate-500 text-sm">{vendor?.businessName}</p>
        </div>
        <button onClick={load} className="p-2 rounded-lg border border-slate-300 text-slate-500 hover:text-slate-700">
          <RefreshCw size={16} />
        </button>
      </div>

      <div className="flex gap-1 mb-6 border-b border-slate-200">
        {tabs.map((t) => (
          <button key={t.key} onClick={() => setTab(t.key)}
            className={`px-4 py-2 text-sm font-medium border-b-2 -mb-px transition-colors
              ${tab === t.key ? "border-indigo-500 text-indigo-600" : "border-transparent text-slate-500 hover:text-slate-700"}`}>
            {t.label}
          </button>
        ))}
      </div>

      {loading ? (
        <div className="flex justify-center py-20">
          <div className="w-8 h-8 border-4 border-indigo-500 border-t-transparent rounded-full animate-spin" />
        </div>
      ) : error ? (
        <div className="text-center py-20">
          <p className="text-red-500 font-medium mb-3">{error}</p>
          <button onClick={load} className="text-sm text-indigo-600 hover:underline">Retry</button>
        </div>
      ) : (
        <>
          {tab === "overview" && (
            <div className="space-y-6">
              <div className="grid grid-cols-2 sm:grid-cols-4 gap-4">
                <StatCard icon={DollarSign} label="Total Revenue" value={fmt(totalRevenue)} color="emerald" />
                <StatCard icon={Users} label="Customers" value={totalCustomers} color="violet" />
                <StatCard icon={Eye} label="Link Views" value={totalViews} color="amber" />
                <StatCard icon={ShoppingCart} label="Payments" value={totalPayments} sub={`${convRate}% conversion`} color="indigo" />
              </div>
              <div className="grid grid-cols-1 sm:grid-cols-3 gap-4">
                <div className="bg-white rounded-xl border border-slate-200 p-5">
                  <p className="text-sm font-semibold text-slate-700 mb-3 flex items-center gap-2"><Package size={16} className="text-indigo-500" /> Products</p>
                  <div className="space-y-2 text-sm">
                    <Row label="Total" value={totalProducts} />
                    <Row label="Active" value={activeProducts} />
                    <Row label="Inactive" value={inactiveProducts} />
                    {lowStock > 0 && <Row label="Low stock" value={lowStock} warn />}
                  </div>
                </div>
                <div className="bg-white rounded-xl border border-slate-200 p-5">
                  <p className="text-sm font-semibold text-slate-700 mb-3 flex items-center gap-2"><Link2 size={16} className="text-indigo-500" /> Links</p>
                  <div className="space-y-2 text-sm">
                    <Row label="Total" value={totalLinks} />
                    <Row label="Active" value={activeLinks} />
                    <Row label="Views" value={totalViews} />
                    <Row label="Payments" value={totalPayments} />
                  </div>
                </div>
                <div className="bg-white rounded-xl border border-slate-200 p-5">
                  <p className="text-sm font-semibold text-slate-700 mb-3 flex items-center gap-2"><TrendingUp size={16} className="text-indigo-500" /> Revenue</p>
                  <div className="space-y-2 text-sm">
                    <Row label="From links" value={fmt(totalRevenue)} />
                    <Row label="Customer spend" value={fmt(customerRevenue)} />
                    <Row label="Conversion" value={`${convRate}%`} />
                  </div>
                </div>
              </div>
            </div>
          )}

          {tab === "products" && (
            <div className="space-y-4">
              <div className="grid grid-cols-2 sm:grid-cols-4 gap-4">
                <StatCard icon={Package} label="Total" value={totalProducts} />
                <StatCard icon={Package} label="Active" value={activeProducts} color="emerald" />
                <StatCard icon={Package} label="Inactive" value={inactiveProducts} color="amber" />
                <StatCard icon={Package} label="Low Stock" value={lowStock} color="violet" />
              </div>
              <div className="bg-white rounded-xl border border-slate-200 overflow-x-auto">
                <table className="w-full text-sm min-w-[500px]">
                  <thead className="bg-slate-50 border-b border-slate-200">
                    <tr>
                      <th className="text-left px-4 py-3 text-slate-600 font-semibold">Product</th>
                      <th className="text-left px-4 py-3 text-slate-600 font-semibold">Category</th>
                      <th className="text-right px-4 py-3 text-slate-600 font-semibold">Price</th>
                      <th className="text-right px-4 py-3 text-slate-600 font-semibold">Qty</th>
                      <th className="text-left px-4 py-3 text-slate-600 font-semibold">Status</th>
                    </tr>
                  </thead>
                  <tbody className="divide-y divide-slate-100">
                    {productsList.map((p) => (
                      <tr key={p.id} className="hover:bg-slate-50">
                        <td className="px-4 py-3 font-medium text-slate-900 truncate max-w-[180px]">{p.name}</td>
                        <td className="px-4 py-3 text-slate-500">{p.category}</td>
                        <td className="px-4 py-3 text-right text-indigo-700 font-semibold">
                          {fmt(p.price, p.currency)}
                        </td>
                        <td className={`px-4 py-3 text-right font-semibold ${(p.quantity ?? 0) <= 3 ? "text-amber-600" : "text-slate-700"}`}>
                          {p.quantity ?? "—"}
                        </td>
                        <td className="px-4 py-3">
                          <span className={`text-xs px-2 py-0.5 rounded-full font-semibold ${
                            p.isActive ? "bg-emerald-100 text-emerald-700" : "bg-slate-100 text-slate-500"
                          }`}>
                            {p.isActive ? "Active" : "Inactive"}
                          </span>
                        </td>
                      </tr>
                    ))}
                  </tbody>
                </table>
                {productsList.length === 0 && (
                  <p className="text-center text-slate-400 py-8 text-sm">No products yet</p>
                )}
              </div>
            </div>
          )}

          {tab === "links" && (
            <div className="space-y-4">
              <div className="grid grid-cols-2 sm:grid-cols-4 gap-4">
                <StatCard icon={Link2} label="Total Links" value={totalLinks} />
                <StatCard icon={Eye} label="Total Views" value={totalViews} color="amber" />
                <StatCard icon={ShoppingCart} label="Payments" value={totalPayments} color="emerald" />
                <StatCard icon={TrendingUp} label="Conversion" value={`${convRate}%`} color="violet" />
              </div>
              <div className="bg-white rounded-xl border border-slate-200 overflow-x-auto">
                <table className="w-full text-sm min-w-[600px]">
                  <thead className="bg-slate-50 border-b border-slate-200">
                    <tr>
                      <th className="text-left px-4 py-3 text-slate-600 font-semibold">Short Code</th>
                      <th className="text-left px-4 py-3 text-slate-600 font-semibold">Product</th>
                      <th className="text-right px-4 py-3 text-slate-600 font-semibold">Amount</th>
                      <th className="text-right px-4 py-3 text-slate-600 font-semibold">Views</th>
                      <th className="text-right px-4 py-3 text-slate-600 font-semibold">Payments</th>
                      <th className="text-left px-4 py-3 text-slate-600 font-semibold">Status</th>
                    </tr>
                  </thead>
                  <tbody className="divide-y divide-slate-100">
                    {linksList.map((l) => {
                      const isExpired = l.expiresAt ? new Date(l.expiresAt) < new Date() : false;
                      const isLive = l.isActive && !isExpired;
                      return (
                        <tr key={l.id} className="hover:bg-slate-50">
                          <td className="px-4 py-3 font-mono text-xs text-slate-600">{l.shortCode}</td>
                          <td className="px-4 py-3 text-slate-500">{l.product?.name ?? "—"}</td>
                          <td className="px-4 py-3 text-right font-semibold text-indigo-700">
                            {fmt(l.amount, l.currency)}
                          </td>
                          <td className="px-4 py-3 text-right text-slate-700">{linkViewCount(l)}</td>
                          <td className="px-4 py-3 text-right text-slate-700">{linkPaymentCount(l)}</td>
                          <td className="px-4 py-3">
                            <span className={`text-xs px-2 py-0.5 rounded-full font-semibold ${
                              isLive ? "bg-emerald-100 text-emerald-700" : "bg-slate-100 text-slate-500"
                            }`}>
                              {isLive ? "Active" : isExpired ? "Expired" : "Inactive"}
                            </span>
                          </td>
                        </tr>
                      );
                    })}
                  </tbody>
                </table>
                {linksList.length === 0 && (
                  <p className="text-center text-slate-400 py-8 text-sm">No links yet</p>
                )}
              </div>
            </div>
          )}

          {tab === "customers" && (
            <div className="space-y-4">
              <div className="grid grid-cols-2 sm:grid-cols-3 gap-4">
                <StatCard icon={Users} label="Total Customers" value={totalCustomers} />
                <StatCard icon={DollarSign} label="Customer Revenue" value={fmt(customerRevenue)} color="emerald" />
                <StatCard icon={ShoppingCart} label="Avg. Spend" value={totalCustomers > 0 ? fmt(customerRevenue / totalCustomers) : "$0"} color="violet" />
              </div>
              <div className="bg-white rounded-xl border border-slate-200 overflow-x-auto">
                <table className="w-full text-sm min-w-[500px]">
                  <thead className="bg-slate-50 border-b border-slate-200">
                    <tr>
                      <th className="text-left px-4 py-3 text-slate-600 font-semibold">Customer</th>
                      <th className="text-left px-4 py-3 text-slate-600 font-semibold">Contact</th>
                      <th className="text-right px-4 py-3 text-slate-600 font-semibold">Orders</th>
                      <th className="text-right px-4 py-3 text-slate-600 font-semibold">Total Spent</th>
                    </tr>
                  </thead>
                  <tbody className="divide-y divide-slate-100">
                    {customersList
                      .sort((a, b) => b.totalSpent - a.totalSpent)
                      .map((c) => (
                        <tr key={c.id} className="hover:bg-slate-50">
                          <td className="px-4 py-3 font-medium text-slate-900">
                            {c.name ?? "Anonymous"}
                          </td>
                          <td className="px-4 py-3 text-slate-500 text-xs">
                            {c.email ?? c.phone ?? "—"}
                          </td>
                          <td className="px-4 py-3 text-right text-slate-700">{c.purchaseCount}</td>
                          <td className="px-4 py-3 text-right font-semibold text-indigo-700">
                            {fmt(c.totalSpent)}
                          </td>
                        </tr>
                      ))}
                  </tbody>
                </table>
                {customersList.length === 0 && (
                  <p className="text-center text-slate-400 py-8 text-sm">No customers yet</p>
                )}
              </div>
            </div>
          )}
        </>
      )}
    </div>
  );
}

function Row({ label, value, warn }: { label: string; value: string | number; warn?: boolean }) {
  return (
    <div className="flex justify-between">
      <span className="text-slate-500">{label}</span>
      <span className={`font-semibold ${warn ? "text-amber-600" : "text-slate-900"}`}>{value}</span>
    </div>
  );
}
