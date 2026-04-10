"use client";

import { useEffect, useState } from "react";
import { products as api, Product, ApiError } from "@/lib/api";
import { Package, Plus, Search, X, RefreshCw } from "lucide-react";
import Image from "next/image";

const CATEGORIES = [
  "Electronics", "Clothing", "Food", "Books", "Beauty", "Home", "Sports", "Art", "Other",
];
const CURRENCIES = ["USD", "EUR", "GBP", "NGN", "GHS", "KES", "ZAR"];

function formatPrice(amount: number, currency: string) {
  return new Intl.NumberFormat("en-US", { style: "currency", currency }).format(amount);
}

function ProductCard({ product, onDelete }: { product: Product; onDelete: (id: string) => void }) {
  const [deleting, setDeleting] = useState(false);

  async function handleDelete() {
    if (!confirm(`Delete "${product.name}"?`)) return;
    setDeleting(true);
    try {
      await api.remove(product.id);
      onDelete(product.id);
    } catch {
      alert("Failed to delete product.");
    } finally {
      setDeleting(false);
    }
  }

  const img = product.images?.[0];

  return (
    <div className="bg-white rounded-xl border border-slate-200 overflow-hidden flex flex-col">
      <div className="relative h-40 bg-slate-100">
        {img ? (
          <Image src={img} alt={product.name} fill className="object-cover" />
        ) : (
          <div className="absolute inset-0 flex items-center justify-center text-slate-300">
            <Package size={40} />
          </div>
        )}
        <span className={`absolute top-2 right-2 text-xs font-semibold px-2 py-0.5 rounded-full
          ${product.isActive ? "bg-emerald-100 text-emerald-700" : "bg-slate-100 text-slate-500"}`}>
          {product.isActive ? "Active" : "Inactive"}
        </span>
      </div>
      <div className="p-4 flex-1 flex flex-col gap-1">
        <p className="font-semibold text-slate-900 text-sm truncate">{product.name}</p>
        <p className="text-xs text-slate-500 truncate">{product.category}</p>
        <p className="text-indigo-600 font-bold text-sm mt-auto">
          {formatPrice(product.price, product.currency)}
        </p>
        {product.quantity != null && (
          <p className={`text-xs ${product.quantity <= 3 ? "text-amber-600 font-semibold" : "text-slate-400"}`}>
            Stock: {product.quantity}
          </p>
        )}
      </div>
      <div className="px-4 pb-4">
        <button
          onClick={handleDelete}
          disabled={deleting}
          className="w-full text-xs text-red-500 hover:text-red-700 border border-red-200 hover:bg-red-50 rounded-lg py-1.5 transition-colors disabled:opacity-50"
        >
          {deleting ? "Deleting…" : "Delete"}
        </button>
      </div>
    </div>
  );
}

function AddProductModal({ onClose, onAdded }: { onClose: () => void; onAdded: (p: Product) => void }) {
  const [name, setName] = useState("");
  const [description, setDescription] = useState("");
  const [price, setPrice] = useState("");
  const [currency, setCurrency] = useState("USD");
  const [category, setCategory] = useState("Other");
  const [quantity, setQuantity] = useState("1");
  const [tags, setTags] = useState("");
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState("");

  async function handleSubmit(e: React.FormEvent) {
    e.preventDefault();
    setError("");
    if (!name.trim() || !price) { setError("Name and price are required."); return; }
    const priceNum = parseFloat(price);
    if (isNaN(priceNum) || priceNum <= 0) { setError("Enter a valid price."); return; }
    setLoading(true);
    try {
      const res = await api.create({
        name: name.trim(),
        description: description.trim(),
        price: priceNum,
        currency,
        category,
        quantity: parseInt(quantity) || 1,
        tags: tags.split(",").map((t) => t.trim()).filter(Boolean),
        images: [],
      });
      onAdded(res.data);
      onClose();
    } catch (err) {
      setError(err instanceof ApiError ? err.message : "Failed to create product.");
    } finally {
      setLoading(false);
    }
  }

  return (
    <div className="fixed inset-0 z-50 flex items-center justify-center bg-black/40 px-4 py-4">
      <div className="bg-white rounded-2xl shadow-xl w-full max-w-md max-h-[90vh] overflow-y-auto">
        <div className="flex items-center justify-between px-6 py-4 border-b border-slate-100">
          <h2 className="font-bold text-slate-900">Add Product</h2>
          <button onClick={onClose} className="text-slate-400 hover:text-slate-600"><X size={20} /></button>
        </div>
        <form onSubmit={handleSubmit} className="p-6 space-y-4">
          {error && <p className="text-sm text-red-600 bg-red-50 border border-red-200 rounded-lg px-3 py-2">{error}</p>}
          <div>
            <label className="block text-sm font-medium text-slate-700 mb-1">Name *</label>
            <input value={name} onChange={(e) => setName(e.target.value)} placeholder="Product name"
              className="w-full px-3 py-2 rounded-lg border border-slate-300 text-sm focus:outline-none focus:ring-2 focus:ring-indigo-500" />
          </div>
          <div>
            <label className="block text-sm font-medium text-slate-700 mb-1">Description</label>
            <textarea value={description} onChange={(e) => setDescription(e.target.value)} rows={2}
              placeholder="Short description"
              className="w-full px-3 py-2 rounded-lg border border-slate-300 text-sm focus:outline-none focus:ring-2 focus:ring-indigo-500 resize-none" />
          </div>
          <div className="grid grid-cols-2 gap-3">
            <div>
              <label className="block text-sm font-medium text-slate-700 mb-1">Price *</label>
              <input type="number" min="0" step="0.01" value={price} onChange={(e) => setPrice(e.target.value)}
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
          <div className="grid grid-cols-2 gap-3">
            <div>
              <label className="block text-sm font-medium text-slate-700 mb-1">Category</label>
              <select value={category} onChange={(e) => setCategory(e.target.value)}
                className="w-full px-3 py-2 rounded-lg border border-slate-300 text-sm focus:outline-none focus:ring-2 focus:ring-indigo-500 bg-white">
                {CATEGORIES.map((c) => <option key={c}>{c}</option>)}
              </select>
            </div>
            <div>
              <label className="block text-sm font-medium text-slate-700 mb-1">Quantity</label>
              <input type="number" min="0" value={quantity} onChange={(e) => setQuantity(e.target.value)}
                className="w-full px-3 py-2 rounded-lg border border-slate-300 text-sm focus:outline-none focus:ring-2 focus:ring-indigo-500" />
            </div>
          </div>
          <div>
            <label className="block text-sm font-medium text-slate-700 mb-1">Tags <span className="text-slate-400 font-normal">(comma-separated)</span></label>
            <input value={tags} onChange={(e) => setTags(e.target.value)} placeholder="tag1, tag2"
              className="w-full px-3 py-2 rounded-lg border border-slate-300 text-sm focus:outline-none focus:ring-2 focus:ring-indigo-500" />
          </div>
          <div className="flex gap-3 pt-2">
            <button type="button" onClick={onClose}
              className="flex-1 py-2 rounded-lg border border-slate-300 text-sm font-medium text-slate-700 hover:bg-slate-50">
              Cancel
            </button>
            <button type="submit" disabled={loading}
              className="flex-1 py-2 rounded-lg bg-indigo-600 text-white text-sm font-semibold hover:bg-indigo-700 disabled:opacity-50">
              {loading ? "Adding…" : "Add Product"}
            </button>
          </div>
        </form>
      </div>
    </div>
  );
}

export default function ProductsPage() {
  const [allProducts, setAllProducts] = useState<Product[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState("");
  const [tab, setTab] = useState<"active" | "sold">("active");
  const [search, setSearch] = useState("");
  const [category, setCategory] = useState("");
  const [showAdd, setShowAdd] = useState(false);

  async function load() {
    setLoading(true);
    setError("");
    try {
      const res = await api.list();
      setAllProducts(res.data);
    } catch (err) {
      setError(err instanceof ApiError ? err.message : "Failed to load products.");
    } finally {
      setLoading(false);
    }
  }

  useEffect(() => { load(); }, []);

  const filtered = allProducts
    .filter((p) => (tab === "active" ? p.isActive : !p.isActive))
    .filter((p) => !search || p.name.toLowerCase().includes(search.toLowerCase()) || p.category.toLowerCase().includes(search.toLowerCase()))
    .filter((p) => !category || p.category === category);

  const allCategories = [...new Set(allProducts.map((p) => p.category))].sort();

  const tabs = [
    { key: "active", label: `Active (${allProducts.filter((p) => p.isActive).length})` },
    { key: "sold", label: `Inactive (${allProducts.filter((p) => !p.isActive).length})` },
  ] as const;

  return (
    <div>
      <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-4 mb-6">
        <div>
          <h1 className="text-xl sm:text-2xl font-bold text-slate-900">Products</h1>
          <p className="text-slate-500 text-sm">{allProducts.length} total products</p>
        </div>
        <button
          onClick={() => setShowAdd(true)}
          className="flex items-center gap-2 px-4 py-2 rounded-lg bg-indigo-600 text-white text-sm font-semibold hover:bg-indigo-700 transition-colors w-full sm:w-auto"
        >
          <Plus size={16} /> Add Product
        </button>
      </div>

      <div className="flex gap-1 mb-4 border-b border-slate-200">
        {tabs.map((t) => (
          <button key={t.key} onClick={() => setTab(t.key)}
            className={`px-4 py-2 text-sm font-medium border-b-2 -mb-px transition-colors
              ${tab === t.key ? "border-indigo-500 text-indigo-600" : "border-transparent text-slate-500 hover:text-slate-700"}`}>
            {t.label}
          </button>
        ))}
      </div>

      <div className="flex flex-col sm:flex-row gap-3 mb-5">
        <div className="relative flex-1">
          <Search size={15} className="absolute left-3 top-1/2 -translate-y-1/2 text-slate-400" />
          <input value={search} onChange={(e) => setSearch(e.target.value)} placeholder="Search products…"
            className="w-full pl-9 pr-3 py-2 rounded-lg border border-slate-300 text-sm text-slate-900 placeholder:text-slate-400 focus:outline-none focus:ring-2 focus:ring-indigo-500" />
        </div>
        {allCategories.length > 0 && (
          <select value={category} onChange={(e) => setCategory(e.target.value)}
            className="px-3 py-2 rounded-lg border border-slate-300 text-sm focus:outline-none focus:ring-2 focus:ring-indigo-500 bg-white">
            <option value="">All categories</option>
            {allCategories.map((c) => <option key={c}>{c}</option>)}
          </select>
        )}
        <button onClick={load} className="p-2 rounded-lg border border-slate-300 text-slate-500 hover:text-slate-700 hover:bg-slate-50">
          <RefreshCw size={16} />
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
      ) : filtered.length === 0 ? (
        <div className="text-center py-20 text-slate-400">
          <Package size={48} className="mx-auto mb-3 opacity-40" />
          <p className="font-medium">No products found</p>
          <p className="text-sm mt-1">
            {allProducts.length === 0 ? "Add your first product to get started." : "Try adjusting your search."}
          </p>
        </div>
      ) : (
        <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 xl:grid-cols-4 gap-4">
          {filtered.map((p) => (
            <ProductCard key={p.id} product={p} onDelete={(id) => setAllProducts((prev) => prev.filter((x) => x.id !== id))} />
          ))}
        </div>
      )}

      {showAdd && (
        <AddProductModal
          onClose={() => setShowAdd(false)}
          onAdded={(p) => setAllProducts((prev) => [p, ...prev])}
        />
      )}
    </div>
  );
}
