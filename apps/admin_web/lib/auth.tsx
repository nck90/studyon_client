"use client";
import { createContext, useContext, useState, useCallback } from "react";
import {
  login as apiLogin,
  signup as apiSignup,
  logout as apiLogout,
  clearTokens,
} from "./api";

interface User {
  id: string;
  role: string;
  name: string;
  email: string;
}

interface AuthContextType {
  user: User | null;
  isLoading: boolean;
  login: (email: string, password: string) => Promise<void>;
  signup: (name: string, email: string, password: string) => Promise<void>;
  logout: () => Promise<void>;
}

const AuthContext = createContext<AuthContextType>({
  user: null,
  isLoading: true,
  login: async () => {},
  signup: async () => {},
  logout: async () => {},
});

export function AuthProvider({ children }: { children: React.ReactNode }) {
  const [user, setUser] = useState<User | null>(() => {
    if (typeof window === "undefined") return null;
    try {
      const stored = localStorage.getItem("user");
      const token = localStorage.getItem("accessToken");
      return stored && token ? (JSON.parse(stored) as User) : null;
    } catch {
      clearTokens();
      return null;
    }
  });
  const [isLoading] = useState(false);

  const login = useCallback(async (email: string, password: string) => {
    const result = await apiLogin(email, password);
    setUser(result.user);
  }, []);

  const signup = useCallback(
    async (name: string, email: string, password: string) => {
      const result = await apiSignup(name, email, password);
      setUser(result.user);
    },
    [],
  );

  const logout = useCallback(async () => {
    await apiLogout();
    setUser(null);
  }, []);

  return (
    <AuthContext.Provider value={{ user, isLoading, login, signup, logout }}>
      {children}
    </AuthContext.Provider>
  );
}

export function useAuth() {
  return useContext(AuthContext);
}
