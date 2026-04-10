"use client";

import { useEffect, useState } from "react";
import { customers as api, Customer, ApiError } from "@/lib/api";
import { Users, Search, RefreshCw, ChevronDown } from "lucide-react";

type SortKey = "recent" | "topSpenders" | "mostPurchases" | "alphabetical";

const SORT_OPTIONS: { key: SortKey; label: string }[] = [
  { key: "recent", label: "Most Recent" },
  { key: "topSpenders", label: "Top Spenders" },
  { key: "mostPurchases", label: "Most Purchases" },
  { key: "alphabetical", label: "Alphabetical" },
];

function displayName(c: Customer) {
  return c.name ?? c.email ?? c.phone ?? "Anonymous";
}

function initials(name: string) {
  const parts = name.trim().split(/\s+/);
  if (parts.length >= 2) return (parts[0][0] + parts[1][0]).toUpperCase();
  return name[0]?.toUpperCase() ?? "?";
}

function CustomerRow({ customer }: { customer: Customer }) {
  const name = displayName(customer);
  const spent = new Intl.NumberFormat("en-US", { style: "currency", currency: "USD" }).format(customer.totalSpent);

  return (
    <div className="bg-white rounded-xl border border-slate-200 p-4 flex items-center gap-4">
      <div className="w-10 h-10 rounded-full bg-indigo-100 flex items-center justify-center shrink-0">
        <span className="text-sm font-bold text-indigo-700">{initials(name)}</span>
      </div>
      <div className="flex-1 min-w-0">
        <p className="font-semibold text-slate-900 truncate">{name}</p>
        <div className="flex gap-3 text-xs text-slate-500 mt-0.5 flex-wrap">
          {customer.email && <span>{customer.email}</span>}
          {customer.phone && <span>{customer.phone}</span>}
        </div>
      </div>
      <div className="text-right shrink-0">
        <p className="font-bold text-indigo-700 text-sm">{spent}</p>
        <p className="text-xs text-slate-500">{customer.purchaseCount} orders</p>
      </div>
    </div>
  );
}

export default function CustomersPage() {
  const [allCustomers, setAllCustomers] = useState<Customer[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState("");
  const [search, setSearch] = useState("");
  const [sortBy, setSortBy] = useState<SortKey>("recent");

  async function load() {
    setLoading(true);
    setError("");
    try {
      const res = await api.list();
      setAllCustomers(res.data);
    } catch (err) {
      setError(err instanceof ApiError ? err.message : "Failed to load customers.");
    } finally {
      setLoading(false);
    }
  }

  useEffect(() => { load(); }, []);

  const filtered = allCustomers
    .filter((c) => {
      if (!search) return true;
      const q = search.toLowerCase();
      return (
        (c.name?.toLowerCase().includes(q) ?? false) ||
        (c.email?.toLowerCase().includes(q) ?? false) ||
        (c.phone?.includes(q) ?? false)
      );
    })
    .sort((a, b) => {
      switch (sortBy) {
        case "topSpenders": return b.totalSpent - a.totalSpent;
        case "mostPurchases": return b.purchaseCount - a.purchaseCount;
        case "alphabetical": return displayName(a).localeCompare(displayName(b));
        default: return new Date(b.createdAt).getTime() - new Date(a.createdAt).getTime();
      }
    });

  return (
    <div>
      <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-4 mb-6">
        <div>
          <h1 className="text-xl sm:text-2xl font-bold text-slate-900">Customers</h1>
          <p className="text-slate-500 text-sm">{allCustomers.length} total customers</p>
        </div>
        <button onClick={load} className="p-2 rounded-lg border border-slate-300 text-slate-500 hover:text-slate-700">
          <RefreshCw size={16} />
        </button>
      </div>

      <div className="flex flex-col sm:flex-row gap-3 mb-5">
        <div className="relative flex-1">
          <Search size={15} className="absolute left-3 top-1/2 -translate-y-1/2 text-slate-400" />
          <input
            value={search}
            onChange={(e) => setSearch(e.target.value)}
            placeholder="Search by name, email or phone…"
            className="w-full pl-9 pr-3 py-2 rounded-lg border border-slate-300 text-sm text-slate-900 placeholder:text-slate-400 focus:outline-none focus:ring-2 focus:ring-indigo-500"
          />
        </div>
        <div className="relative">
          <select
            value={sortBy}
            onChange={(e) => setSortBy(e.target.value as SortKey)}
            className="appearance-none pl-3 pr-8 py-2 rounded-lg border border-slate-300 text-sm focus:outline-none focus:ring-2 focus:ring-indigo-500 bg-white"
          >
            {SORT_OPTIONS.map((o) => (
              <option key={o.key} value={o.key}>{o.label}</option>
            ))}
          </select>
          <ChevronDown size={14} className="absolute right-2.5 top-1/2 -translate-y-1/2 pointer-events-none text-slate-400" />
        </div>
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
      ) : filtered.length === 0 ? (
        <div className="text-center py-20 text-slate-400">
          <Users size={48} className="mx-auto mb-3 opacity-40" />
          <p className="font-medium">
            {allCustomers.length === 0 ? "No customers yet" : "No results found"}
          </p>
          <p className="text-sm mt-1">
            {allCustomers.length === 0
              ? "Customers appear here after they make a purchase."
              : "Try a different search term."}
          </p>
        </div>
      ) : (
        <div className="space-y-3">
          {filtered.map((c) => (
            <CustomerRow key={c.id} customer={c} />
          ))}
        </div>
      )}
    </div>
  );
}
