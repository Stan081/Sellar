"use client";

import { useEffect, useState } from "react";
import { orders as api, Order, ApiError } from "@/lib/api";
import { ShoppingBag, RefreshCw, ChevronDown } from "lucide-react";

type OrderStatus = Order["orderStatus"];
type DeliveryStatus = Order["deliveryStatus"];

const ORDER_STATUSES: OrderStatus[] = ["PENDING", "PROCESSING", "SHIPPED", "DELIVERED", "CANCELLED"];
const DELIVERY_STATUSES: DeliveryStatus[] = ["PENDING", "PREPARING", "SHIPPED", "IN_TRANSIT", "DELIVERED"];

function statusColor(s: OrderStatus) {
  return ({
    PENDING: "bg-amber-100 text-amber-700",
    PROCESSING: "bg-blue-100 text-blue-700",
    SHIPPED: "bg-indigo-100 text-indigo-700",
    DELIVERED: "bg-emerald-100 text-emerald-700",
    CANCELLED: "bg-red-100 text-red-600",
  } as Record<string, string>)[s] ?? "bg-slate-100 text-slate-600";
}

function deliveryColor(s: DeliveryStatus) {
  return ({
    PENDING: "bg-slate-100 text-slate-600",
    PREPARING: "bg-amber-100 text-amber-700",
    SHIPPED: "bg-indigo-100 text-indigo-700",
    IN_TRANSIT: "bg-violet-100 text-violet-700",
    DELIVERED: "bg-emerald-100 text-emerald-700",
  } as Record<string, string>)[s] ?? "bg-slate-100 text-slate-600";
}

function labelOf(s: string) {
  return s.replace(/_/g, " ");
}

function OrderRow({ order, onChange }: { order: Order; onChange: (updated: Order) => void }) {
  const [updatingStatus, setUpdatingStatus] = useState(false);
  const [updatingDelivery, setUpdatingDelivery] = useState(false);

  async function changeStatus(status: OrderStatus) {
    setUpdatingStatus(true);
    try {
      const res = await api.updateStatus(order.id, status);
      onChange(res.data);
    } catch {
      alert("Failed to update status.");
    } finally {
      setUpdatingStatus(false);
    }
  }

  async function changeDelivery(status: DeliveryStatus) {
    setUpdatingDelivery(true);
    try {
      const res = await api.updateDelivery(order.id, status);
      onChange(res.data);
    } catch {
      alert("Failed to update delivery.");
    } finally {
      setUpdatingDelivery(false);
    }
  }

  const amount = new Intl.NumberFormat("en-US", { style: "currency", currency: order.currency }).format(order.amount);
  const customer = order.customer?.name ?? order.customer?.email ?? order.customerEmail ?? order.customer?.phone ?? order.customerPhone ?? "Anonymous";
  const productName = order.paymentLink?.product?.name;

  return (
    <div className="bg-white rounded-xl border border-slate-200 p-4">
      <div className="flex items-start justify-between gap-3 mb-3">
        <div>
          <p className="font-semibold text-slate-900 text-sm">{customer}</p>
          {productName && (
            <p className="text-xs text-slate-500 mt-0.5">{productName}</p>
          )}
          <p className="text-xs text-slate-400 mt-0.5">
            {new Date(order.createdAt).toLocaleDateString("en-US", { day: "numeric", month: "short", year: "numeric" })}
          </p>
        </div>
        <p className="font-bold text-indigo-700 shrink-0">{amount}</p>
      </div>

      <div className="flex flex-wrap gap-2">
        <div className="relative">
          <select
            value={order.orderStatus}
            onChange={(e) => changeStatus(e.target.value as OrderStatus)}
            disabled={updatingStatus}
            className={`appearance-none pl-3 pr-7 py-1 rounded-full text-xs font-semibold border-0 cursor-pointer focus:outline-none focus:ring-2 focus:ring-indigo-500 ${statusColor(order.orderStatus)}`}
          >
            {ORDER_STATUSES.map((s) => (
              <option key={s} value={s}>{labelOf(s)}</option>
            ))}
          </select>
          <ChevronDown size={10} className="absolute right-2 top-1/2 -translate-y-1/2 pointer-events-none" />
        </div>

        <div className="relative">
          <select
            value={order.deliveryStatus}
            onChange={(e) => changeDelivery(e.target.value as DeliveryStatus)}
            disabled={updatingDelivery}
            className={`appearance-none pl-3 pr-7 py-1 rounded-full text-xs font-semibold border-0 cursor-pointer focus:outline-none focus:ring-2 focus:ring-indigo-500 ${deliveryColor(order.deliveryStatus)}`}
          >
            {DELIVERY_STATUSES.map((s) => (
              <option key={s} value={s}>{labelOf(s)}</option>
            ))}
          </select>
          <ChevronDown size={10} className="absolute right-2 top-1/2 -translate-y-1/2 pointer-events-none" />
        </div>
      </div>

      {order.notes && (
        <p className="mt-2 text-xs text-slate-500 italic">{order.notes}</p>
      )}
    </div>
  );
}

type Tab = "PENDING" | "PROCESSING" | "SHIPPED" | "DELIVERED";

export default function OrdersPage() {
  const [allOrders, setAllOrders] = useState<Order[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState("");
  const [tab, setTab] = useState<Tab>("PENDING");

  async function load() {
    setLoading(true);
    setError("");
    try {
      const res = await api.list();
      setAllOrders(res.data);
    } catch (err) {
      setError(err instanceof ApiError ? err.message : "Failed to load orders.");
    } finally {
      setLoading(false);
    }
  }

  useEffect(() => { load(); }, []);

  const byStatus = (s: Tab) => allOrders.filter((o) => o.orderStatus === s);

  const tabs: { key: Tab; label: string }[] = [
    { key: "PENDING", label: `Pending (${byStatus("PENDING").length})` },
    { key: "PROCESSING", label: `Processing (${byStatus("PROCESSING").length})` },
    { key: "SHIPPED", label: `Shipped (${byStatus("SHIPPED").length})` },
    { key: "DELIVERED", label: `Delivered (${byStatus("DELIVERED").length})` },
  ];

  const displayed = byStatus(tab);

  function handleChange(updated: Order) {
    setAllOrders((prev) => prev.map((o) => o.id === updated.id ? updated : o));
  }

  return (
    <div>
      <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-4 mb-6">
        <div>
          <h1 className="text-xl sm:text-2xl font-bold text-slate-900">Orders</h1>
          <p className="text-slate-500 text-sm">{allOrders.length} total orders</p>
        </div>
        <button onClick={load} className="p-2 rounded-lg border border-slate-300 text-slate-500 hover:text-slate-700">
          <RefreshCw size={16} />
        </button>
      </div>

      <div className="flex gap-1 mb-5 border-b border-slate-200">
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
      ) : displayed.length === 0 ? (
        <div className="text-center py-20 text-slate-400">
          <ShoppingBag size={48} className="mx-auto mb-3 opacity-40" />
          <p className="font-medium">No {tab.toLowerCase()} orders</p>
          <p className="text-sm mt-1">Orders will appear here when customers make purchases.</p>
        </div>
      ) : (
        <div className="grid grid-cols-1 lg:grid-cols-2 gap-4">
          {displayed.map((o) => (
            <OrderRow key={o.id} order={o} onChange={handleChange} />
          ))}
        </div>
      )}
    </div>
  );
}
