"use client";

import { useEffect, useState } from "react";
import { links as api, products as productsApi, PaymentLink, Product, ApiError, linkViewCount, linkPaymentCount } from "@/lib/api";
import { Link2, Plus, Copy, Check, Trash2, PowerOff, RefreshCw, X } from "lucide-react";

const APP_URL = process.env.NEXT_PUBLIC_APP_URL ?? "https://sellar.app";
const CURRENCIES = ["USD", "EUR", "GBP", "NGN", "GHS", "KES", "ZAR"];

function getLinkUrl(link: PaymentLink) {
  return `${APP_URL}/pay/${link.shortCode}`;
}

function CopyButton({ text }: { text: string }) {
  const [copied, setCopied] = useState(false);
  function copy() {
    navigator.clipboard.writeText(text).then(() => {
      setCopied(true);
      setTimeout(() => setCopied(false), 2000);
    });
  }
  return (
    <button onClick={copy} className="p-1.5 rounded-md text-slate-400 hover:text-indigo-600 hover:bg-indigo-50 transition-colors">
      {copied ? <Check size={14} className="text-emerald-500" /> : <Copy size={14} />}
    </button>
  );
}

function LinkCard({ link, onDeactivate, onDelete }: {
  link: PaymentLink;
  onDeactivate: (id: string) => void;
  onDelete: (id: string) => void;
}) {
  const [deactivating, setDeactivating] = useState(false);
  const [deleting, setDeleting] = useState(false);
  const isExpired = link.expiresAt ? new Date(link.expiresAt) < new Date() : false;
  const isLive = link.isActive && !isExpired;
  const url = getLinkUrl(link);

  async function handleDeactivate() {
    if (!confirm("Deactivate this link?")) return;
    setDeactivating(true);
    try { await api.deactivate(link.id); onDeactivate(link.id); }
    catch { alert("Failed to deactivate."); }
    finally { setDeactivating(false); }
  }

  async function handleDelete() {
    if (!confirm("Delete this link permanently?")) return;
    setDeleting(true);
    try { await api.remove(link.id); onDelete(link.id); }
    catch { alert("Failed to delete."); }
    finally { setDeleting(false); }
  }

  const amount = new Intl.NumberFormat("en-US", { style: "currency", currency: link.currency }).format(link.amount);

  return (
    <div className="bg-white rounded-xl border border-slate-200 p-4">
      <div className="flex items-start justify-between gap-3 mb-3">
        <div className="flex-1 min-w-0">
          <div className="flex items-center gap-2 flex-wrap">
            <span className="font-bold text-slate-900">{amount}</span>
            <span className={`text-xs font-semibold px-2 py-0.5 rounded-full ${
              isLive ? "bg-emerald-100 text-emerald-700" : "bg-slate-100 text-slate-500"
            }`}>
              {isLive ? "Active" : isExpired ? "Expired" : "Inactive"}
            </span>
            <span className="text-xs px-2 py-0.5 rounded-full bg-indigo-50 text-indigo-600 font-medium">
              {link.linkType}
            </span>
          </div>
          {link.product && (
            <p className="text-xs text-slate-500 mt-1 truncate">{link.product.name}</p>
          )}
        </div>
      </div>

      <div className="flex items-center gap-1 bg-slate-50 border border-slate-200 rounded-lg px-3 py-2 mb-3">
        <span className="text-xs text-slate-600 truncate flex-1">{url}</span>
        <CopyButton text={url} />
      </div>

      <div className="flex items-center gap-4 text-xs text-slate-500 mb-3 flex-wrap">
        <span>{linkViewCount(link)} views</span>
        <span>{linkPaymentCount(link)} payments</span>
        {link.isReusable && <span className="text-indigo-500">Reusable</span>}
        {link.expiresAt && (
          <span>Expires {new Date(link.expiresAt).toLocaleDateString()}</span>
        )}
      </div>

      <div className="flex gap-2">
        {isLive && (
          <button onClick={handleDeactivate} disabled={deactivating}
            className="flex items-center gap-1.5 text-xs px-3 py-1.5 rounded-lg border border-slate-300 text-slate-600 hover:bg-slate-50 disabled:opacity-50 transition-colors">
            <PowerOff size={12} /> {deactivating ? "…" : "Deactivate"}
          </button>
        )}
        <button onClick={handleDelete} disabled={deleting}
          className="flex items-center gap-1.5 text-xs px-3 py-1.5 rounded-lg border border-red-200 text-red-500 hover:bg-red-50 disabled:opacity-50 transition-colors">
          <Trash2 size={12} /> {deleting ? "…" : "Delete"}
        </button>
      </div>
    </div>
  );
}

function CreateLinkModal({ onClose, onCreated }: { onClose: () => void; onCreated: (l: PaymentLink) => void }) {
  const [productsList, setProductsList] = useState<Product[]>([]);
  const [productId, setProductId] = useState("");
  const [amount, setAmount] = useState("");
  const [currency, setCurrency] = useState("USD");
  const [linkType, setLinkType] = useState<"PUBLIC" | "PRIVATE">("PUBLIC");
  const [isReusable, setIsReusable] = useState(false);
  const [expiresAt, setExpiresAt] = useState("");
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState("");

  useEffect(() => {
    productsApi.list().then((r) => setProductsList(r.data)).catch(() => {});
  }, []);

  async function handleSubmit(e: React.FormEvent) {
    e.preventDefault();
    setError("");
    const amt = parseFloat(amount);
    if (!amount || isNaN(amt) || amt <= 0) { setError("Enter a valid amount."); return; }
    setLoading(true);
    try {
      const res = await api.create({
        productId: productId || undefined,
        amount: amt,
        currency,
        linkType,
        isReusable,
        expiresAt: expiresAt || undefined,
      });
      onCreated(res.data);
      onClose();
    } catch (err) {
      setError(err instanceof ApiError ? err.message : "Failed to create link.");
    } finally {
      setLoading(false);
    }
  }

  return (
    <div className="fixed inset-0 z-50 flex items-center justify-center bg-black/40 px-4 py-4">
      <div className="bg-white rounded-2xl shadow-xl w-full max-w-md max-h-[90vh] overflow-y-auto">
        <div className="flex items-center justify-between px-6 py-4 border-b border-slate-100">
          <h2 className="font-bold text-slate-900">Create Payment Link</h2>
          <button onClick={onClose}><X size={20} className="text-slate-400 hover:text-slate-600" /></button>
        </div>
        <form onSubmit={handleSubmit} className="p-6 space-y-4">
          {error && <p className="text-sm text-red-600 bg-red-50 border border-red-200 rounded-lg px-3 py-2">{error}</p>}
          {productsList.length > 0 && (
            <div>
              <label className="block text-sm font-medium text-slate-700 mb-1">Product <span className="text-slate-400 font-normal">(optional)</span></label>
              <select value={productId} onChange={(e) => setProductId(e.target.value)}
                className="w-full px-3 py-2 rounded-lg border border-slate-300 text-sm focus:outline-none focus:ring-2 focus:ring-indigo-500 bg-white">
                <option value="">No product</option>
                {productsList.map((p) => <option key={p.id} value={p.id}>{p.name}</option>)}
              </select>
            </div>
          )}
          <div className="grid grid-cols-2 gap-3">
            <div>
              <label className="block text-sm font-medium text-slate-700 mb-1">Amount *</label>
              <input type="number" min="0" step="0.01" value={amount} onChange={(e) => setAmount(e.target.value)}
                placeholder="0.00"
                className="w-full px-3 py-2 rounded-lg border border-slate-300 text-sm focus:outline-none focus:ring-2 focus:ring-indigo-500" />
            </div>
            <div>
              <label className="block text-sm font-medium text-slate-700 mb-1">Currency</label>
              <select value={currency} onChange={(e) => setCurrency(e.target.value)}
                className="w-full px-3 py-2 rounded-lg border border-slate-300 text-sm focus:outline-none focus:ring-2 focus:ring-indigo-500 bg-white">
                {CURRENCIES.map((c) => <option key={c}>{c}</option>)}
              </select>
            </div>
          </div>
          <div>
            <label className="block text-sm font-medium text-slate-700 mb-1">Link Type</label>
            <div className="flex gap-3">
              {(["PUBLIC", "PRIVATE"] as const).map((t) => (
                <button key={t} type="button" onClick={() => setLinkType(t)}
                  className={`flex-1 py-2 rounded-lg text-sm font-medium border transition-colors ${
                    linkType === t ? "border-indigo-500 bg-indigo-50 text-indigo-700" : "border-slate-300 text-slate-600 hover:bg-slate-50"
                  }`}>
                  {t}
                </button>
              ))}
            </div>
          </div>
          <div className="flex items-center justify-between py-1">
            <span className="text-sm font-medium text-slate-700">Reusable</span>
            <button type="button" onClick={() => setIsReusable((v) => !v)}
              className={`w-11 h-6 rounded-full transition-colors relative ${isReusable ? "bg-indigo-500" : "bg-slate-200"}`}>
              <span className={`absolute top-0.5 w-5 h-5 bg-white rounded-full shadow transition-transform ${isReusable ? "translate-x-5" : "translate-x-0.5"}`} />
            </button>
          </div>
          <div>
            <label className="block text-sm font-medium text-slate-700 mb-1">Expires At <span className="text-slate-400 font-normal">(optional)</span></label>
            <input type="datetime-local" value={expiresAt} onChange={(e) => setExpiresAt(e.target.value)}
              className="w-full px-3 py-2 rounded-lg border border-slate-300 text-sm focus:outline-none focus:ring-2 focus:ring-indigo-500" />
          </div>
          <div className="flex gap-3 pt-2">
            <button type="button" onClick={onClose}
              className="flex-1 py-2 rounded-lg border border-slate-300 text-sm font-medium text-slate-700 hover:bg-slate-50">Cancel</button>
            <button type="submit" disabled={loading}
              className="flex-1 py-2 rounded-lg bg-indigo-600 text-white text-sm font-semibold hover:bg-indigo-700 disabled:opacity-50">
              {loading ? "Creating…" : "Create Link"}
            </button>
          </div>
        </form>
      </div>
    </div>
  );
}

export default function LinksPage() {
  const [allLinks, setAllLinks] = useState<PaymentLink[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState("");
  const [tab, setTab] = useState<"active" | "expired">("active");
  const [showCreate, setShowCreate] = useState(false);

  async function load() {
    setLoading(true);
    setError("");
    try {
      const res = await api.list();
      setAllLinks(res.data);
    } catch (err) {
      setError(err instanceof ApiError ? err.message : "Failed to load links.");
    } finally {
      setLoading(false);
    }
  }

  useEffect(() => { load(); }, []);

  const activeLinks = allLinks.filter((l) => l.isActive && !(l.expiresAt && new Date(l.expiresAt) < new Date()));
  const expiredLinks = allLinks.filter((l) => !l.isActive || (l.expiresAt && new Date(l.expiresAt) < new Date()));
  const displayed = tab === "active" ? activeLinks : expiredLinks;

  function handleDeactivated(id: string) {
    setAllLinks((prev) => prev.map((l) => l.id === id ? { ...l, isActive: false } : l));
  }
  function handleDeleted(id: string) {
    setAllLinks((prev) => prev.filter((l) => l.id !== id));
  }

  return (
    <div>
      <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-4 mb-6">
        <div>
          <h1 className="text-xl sm:text-2xl font-bold text-slate-900">Payment Links</h1>
          <p className="text-slate-500 text-sm">{allLinks.length} total links</p>
        </div>
        <button onClick={() => setShowCreate(true)}
          className="flex items-center gap-2 px-4 py-2 rounded-lg bg-indigo-600 text-white text-sm font-semibold hover:bg-indigo-700 w-full sm:w-auto">
          <Plus size={16} /> Create Link
        </button>
      </div>

      <div className="flex gap-1 mb-5 border-b border-slate-200">
        {[
          { key: "active", label: `Active (${activeLinks.length})` },
          { key: "expired", label: `Expired (${expiredLinks.length})` },
        ].map((t) => (
          <button key={t.key} onClick={() => setTab(t.key as "active" | "expired")}
            className={`px-4 py-2 text-sm font-medium border-b-2 -mb-px transition-colors
              ${tab === t.key ? "border-indigo-500 text-indigo-600" : "border-transparent text-slate-500 hover:text-slate-700"}`}>
            {t.label}
          </button>
        ))}
        <button onClick={load} className="ml-auto p-2 text-slate-400 hover:text-slate-600">
          <RefreshCw size={15} />
        </button>
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
      ) : displayed.length === 0 ? (
        <div className="text-center py-20 text-slate-400">
          <Link2 size={48} className="mx-auto mb-3 opacity-40" />
          <p className="font-medium">No {tab} links</p>
          {tab === "active" && <p className="text-sm mt-1">Create your first payment link to start selling.</p>}
        </div>
      ) : (
        <div className="grid grid-cols-1 lg:grid-cols-2 gap-4">
          {displayed.map((l) => (
            <LinkCard key={l.id} link={l} onDeactivate={handleDeactivated} onDelete={handleDeleted} />
          ))}
        </div>
      )}

      {showCreate && (
        <CreateLinkModal
          onClose={() => setShowCreate(false)}
          onCreated={(l) => setAllLinks((prev) => [l, ...prev])}
        />
      )}
    </div>
  );
}
