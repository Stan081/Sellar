"use client";

import { createContext, useContext, useState } from "react";
import { auth, Vendor } from "./api";

interface AuthState {
  vendor: Vendor | null;
  token: string | null;
  loading: boolean;
}

interface AuthContextValue extends AuthState {
  login: (identifier: string, password: string) => Promise<void>;
  register: (body: Parameters<typeof auth.register>[0]) => Promise<void>;
  logout: () => void;
  refreshProfile: () => Promise<void>;
}

function readStorage(): AuthState {
  if (typeof window === "undefined") {
    return { vendor: null, token: null, loading: true };
  }
  const token = localStorage.getItem("sellar_token");
  const raw = localStorage.getItem("sellar_vendor");
  if (token && raw) {
    try {
      return { vendor: JSON.parse(raw) as Vendor, token, loading: false };
    } catch {
      // fall through
    }
  }
  return { vendor: null, token: null, loading: false };
}

const AuthContext = createContext<AuthContextValue | null>(null);

export function AuthProvider({ children }: { children: React.ReactNode }) {
  const [state, setState] = useState<AuthState>(readStorage);

  function persist(token: string, vendor: Vendor) {
    localStorage.setItem("sellar_token", token);
    localStorage.setItem("sellar_vendor", JSON.stringify(vendor));
    setState({ vendor, token, loading: false });
  }

  async function login(identifier: string, password: string) {
    const res = await auth.login({ identifier, password });
    persist(res.data.token, res.data.vendor);
  }

  async function register(body: Parameters<typeof auth.register>[0]) {
    const res = await auth.register(body);
    persist(res.data.token, res.data.vendor);
  }

  function logout() {
    localStorage.removeItem("sellar_token");
    localStorage.removeItem("sellar_vendor");
    setState({ vendor: null, token: null, loading: false });
    window.location.href = "/login";
  }

  async function refreshProfile() {
    const res = await auth.getProfile();
    const vendor = res.data;
    localStorage.setItem("sellar_vendor", JSON.stringify(vendor));
    setState((s) => ({ ...s, vendor }));
  }

  return (
    <AuthContext.Provider
      value={{ ...state, login, register, logout, refreshProfile }}
    >
      {children}
    </AuthContext.Provider>
  );
}

export function useAuth() {
  const ctx = useContext(AuthContext);
  if (!ctx) throw new Error("useAuth must be used inside AuthProvider");
  return ctx;
}
