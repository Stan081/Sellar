const BASE = process.env.NEXT_PUBLIC_API_URL ?? "";

export class ApiError extends Error {
  constructor(
    public status: number,
    message: string,
  ) {
    super(message);
    this.name = "ApiError";
  }
}

function getToken(): string | null {
  if (typeof window === "undefined") return null;
  return localStorage.getItem("sellar_token");
}

interface RequestOptions extends RequestInit {
  requireAuth?: boolean;
}

async function request<T>(
  path: string,
  options: RequestOptions = {},
): Promise<T> {
  const { requireAuth = false, ...fetchOptions } = options;
  const token = getToken();

  if (requireAuth && !token) {
    if (typeof window !== "undefined") {
      localStorage.removeItem("sellar_token");
      localStorage.removeItem("sellar_vendor");
      window.location.href = "/login";
    }
    throw new ApiError(401, "Authentication required. Please log in.");
  }

  const headers: Record<string, string> = {
    "Content-Type": "application/json",
    ...(fetchOptions.headers as Record<string, string>),
  };
  if (token) headers["Authorization"] = `Bearer ${token}`;

  const res = await fetch(`${BASE}${path}`, { ...fetchOptions, headers });

  if (res.status === 401) {
    if (typeof window !== "undefined") {
      localStorage.removeItem("sellar_token");
      localStorage.removeItem("sellar_vendor");
      window.location.href = "/login";
    }
    throw new ApiError(401, "Session expired. Please log in again.");
  }

  const json = await res.json().catch(() => ({}));
  if (!res.ok) {
    throw new ApiError(
      res.status,
      json.error ?? json.message ?? "Something went wrong",
    );
  }
  return json;
}

// ── Auth ──────────────────────────────────────────────────────────────────────

export interface Vendor {
  id: string;
  email: string;
  phone?: string;
  businessName: string;
  firstName: string;
  lastName: string;
  country: string;
  currency?: string;
  createdAt: string;
}

export interface AuthResponse {
  success: boolean;
  data: { token: string; vendor: Vendor };
}

export const auth = {
  register: (body: {
    email: string;
    phone?: string;
    password: string;
    businessName: string;
    firstName: string;
    lastName: string;
    country: string;
    currency?: string;
  }) =>
    request<AuthResponse>("/api/auth/register", {
      method: "POST",
      body: JSON.stringify(body),
    }),

  login: (body: { identifier: string; password: string }) =>
    request<AuthResponse>("/api/auth/login", {
      method: "POST",
      body: JSON.stringify(body),
    }),

  getProfile: () =>
    request<{ success: boolean; data: Vendor }>("/api/auth/profile", {
      requireAuth: true,
    }),

  updateProfile: (body: Partial<Omit<Vendor, "id" | "email" | "createdAt">>) =>
    request<{ success: boolean; data: Vendor }>("/api/auth/profile", {
      method: "PUT",
      body: JSON.stringify(body),
      requireAuth: true,
    }),
};

// ── Products ──────────────────────────────────────────────────────────────────

export interface Product {
  id: string;
  name: string;
  description: string | null;
  price: number;
  currency: string;
  category: string;
  images: string[];
  tags: string[];
  quantity: number | null;
  isActive: boolean;
  createdAt: string;
  updatedAt: string;
}

export const products = {
  list: () =>
    request<{ data: Product[] }>("/api/products", {
      requireAuth: true,
    }),

  get: (id: string) =>
    request<{ data: Product }>(`/api/products/${id}`, {
      requireAuth: true,
    }),

  create: (body: {
    name: string;
    description?: string;
    category: string;
    tags?: string[];
    price: number;
    currency?: string;
    quantity?: number | null;
    images?: string[];
  }) =>
    request<{ data: Product }>("/api/products", {
      method: "POST",
      body: JSON.stringify(body),
      requireAuth: true,
    }),

  update: (id: string, body: Partial<Product>) =>
    request<{ data: Product }>(`/api/products/${id}`, {
      method: "PUT",
      body: JSON.stringify(body),
      requireAuth: true,
    }),

  remove: (id: string) =>
    request<{ message: string }>(`/api/products/${id}`, {
      method: "DELETE",
      requireAuth: true,
    }),
};

// ── Links ─────────────────────────────────────────────────────────────────────

export interface PaymentLink {
  id: string;
  shortCode: string;
  amount: number;
  currency: string;
  linkType: "PUBLIC" | "PRIVATE";
  isActive: boolean;
  isReusable: boolean;
  expiresAt: string | null;
  product: { id: string; name: string } | null;
  _count?: { transactions: number; linkViews: number };
  createdAt: string;
  updatedAt: string;
}

export function linkViewCount(l: PaymentLink): number {
  return l._count?.linkViews ?? 0;
}
export function linkPaymentCount(l: PaymentLink): number {
  return l._count?.transactions ?? 0;
}

export const links = {
  list: () =>
    request<{ data: PaymentLink[] }>("/api/links", {
      requireAuth: true,
    }),

  create: (body: {
    productId?: string;
    amount: number;
    currency: string;
    linkType?: "PUBLIC" | "PRIVATE";
    isReusable?: boolean;
    expiresAt?: string;
  }) =>
    request<{ data: PaymentLink }>("/api/links", {
      method: "POST",
      body: JSON.stringify(body),
      requireAuth: true,
    }),

  deactivate: (id: string) =>
    request<{ data: PaymentLink }>(
      `/api/links/${id}/deactivate`,
      { method: "PATCH", requireAuth: true },
    ),

  remove: (id: string) =>
    request<{ message: string }>(`/api/links/${id}`, {
      method: "DELETE",
      requireAuth: true,
    }),
};

// ── Orders ────────────────────────────────────────────────────────────────────

export interface Order {
  id: string;
  orderStatus: "PENDING" | "PROCESSING" | "SHIPPED" | "DELIVERED" | "CANCELLED";
  deliveryStatus: "PENDING" | "PREPARING" | "SHIPPED" | "IN_TRANSIT" | "DELIVERED";
  status: "PENDING" | "COMPLETED" | "FAILED" | "CANCELLED";
  amount: number;
  currency: string;
  notes?: string;
  customerEmail?: string;
  customerPhone?: string;
  trackingNumber?: string;
  customer?: { id: string; name?: string; email?: string; phone?: string } | null;
  paymentLink?: {
    id: string;
    product?: { id: string; name: string; description?: string; images?: string[] } | null;
  } | null;
  createdAt: string;
  updatedAt: string;
}

export interface OrderStats {
  pending: number;
  processing: number;
  shipped: number;
  delivered: number;
  cancelled: number;
  totalRevenue: number;
}

export const orders = {
  list: () =>
    request<{ success: boolean; data: Order[] }>("/api/orders", {
      requireAuth: true,
    }),

  stats: () =>
    request<{ success: boolean; data: OrderStats }>("/api/orders/stats", {
      requireAuth: true,
    }),

  get: (id: string) =>
    request<{ success: boolean; data: Order }>(`/api/orders/${id}`, {
      requireAuth: true,
    }),

  updateStatus: (id: string, orderStatus: Order["orderStatus"]) =>
    request<{ success: true; data: Order }>(`/api/orders/${id}/status`, {
      method: "PUT",
      body: JSON.stringify({ orderStatus }),
      requireAuth: true,
    }),

  updateDelivery: (id: string, deliveryStatus: Order["deliveryStatus"]) =>
    request<{ success: true; data: Order }>(`/api/orders/${id}/delivery`, {
      method: "PUT",
      body: JSON.stringify({ deliveryStatus }),
      requireAuth: true,
    }),

  updateNotes: (id: string, notes: string) =>
    request<{ success: true; data: Order }>(`/api/orders/${id}/notes`, {
      method: "PUT",
      body: JSON.stringify({ notes }),
      requireAuth: true,
    }),
};

// ── Customers ─────────────────────────────────────────────────────────────────

export interface Customer {
  id: string;
  name?: string;
  email?: string;
  phone?: string;
  totalSpent: number;
  purchaseCount: number;
  lastPurchaseAt?: string;
  createdAt: string;
}

export const customers = {
  list: () =>
    request<{ data: Customer[] }>("/api/customers", {
      requireAuth: true,
    }),

  get: (id: string) =>
    request<{ data: Customer }>(`/api/customers/${id}`, {
      requireAuth: true,
    }),
};
