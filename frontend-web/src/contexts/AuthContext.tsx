'use client';

import { createContext, useContext, useEffect, useState, ReactNode } from 'react';
import { useRouter } from 'next/navigation';
import api from '@/lib/axios'; // Custom axios configuration with interceptors

interface ApiResponse<T> {
  user: T;
  // Add other fields if your API returns more data
}

type User = {
  id: string;
  email: string;
  firstName: string;
  lastName: string;
  role: 'patient' | 'doctor' | 'admin';
};

type AuthContextType = {
  user: User | null;
  loading: boolean;
  login: (email: string, password: string) => Promise<void>;
  register: (userData: {
    email: string;
    password: string;
    firstName: string;
    lastName: string;
    role: 'patient' | 'doctor';
  }) => Promise<void>;
  logout: () => void;
  isAuthenticated: boolean;
};

const AuthContext = createContext<AuthContextType | undefined>(undefined);

export const AuthProvider = ({ children }: { children: ReactNode }) => {
  const [user, setUser] = useState<User | null>(null);
  const [loading, setLoading] = useState(true);
  const router = useRouter();

  useEffect(() => {
    // Check if user is logged in
    const checkAuth = async () => {
      try {
        const token = typeof window !== 'undefined' ? localStorage.getItem('token') : null;
        if (token) {
          try {
            // Verify token with backend
            const { data } = await api.get<ApiResponse<User>>('/api/auth/me');
            setUser(data.user);
          } catch (error) {
            console.error('API Error:', error);
            // Clear invalid token
            if (typeof window !== 'undefined') {
              localStorage.removeItem('token');
            }
            setUser(null);
          }
        } else {
          // No token, ensure user is set to null
          setUser(null);
        }
      } catch (error) {
        console.error('Auth check failed:', error);
        // Clear invalid token
        if (typeof window !== 'undefined') {
          localStorage.removeItem('token');
        }
        setUser(null);
      } finally {
        // Always set loading to false
        setLoading(false);
      }
    };

    checkAuth();
  }, []);

  interface LoginResponse {
    token: string;
    user: User;
  }

  const login = async (email: string, password: string) => {
    try {
      const { data } = await axios.post<LoginResponse>('/api/auth/login', { email, password });
      localStorage.setItem('token', data.token);
      setUser(data.user);
      router.push('/dashboard');
    } catch (error) {
      console.error('Login failed:', error);
      throw error;
    }
  };

  interface RegisterResponse {
    token: string;
    user: User;
  }

  const register = async (userData: {
    email: string;
    password: string;
    firstName: string;
    lastName: string;
    role: 'patient' | 'doctor';
  }) => {
    try {
      const { data } = await api.post<RegisterResponse>('/auth/register', userData);
      localStorage.setItem('token', data.token);
      setUser(data.user);
      router.push('/dashboard');
    } catch (error) {
      console.error('Registration failed:', error);
      throw error;
    }
  };

  const logout = () => {
    localStorage.removeItem('token');
    setUser(null);
    router.push('/login');
  };

  const value = {
    user,
    loading,
    login,
    register,
    logout,
    isAuthenticated: !!user,
  };

  return <AuthContext.Provider value={value}>{children}</AuthContext.Provider>;
};

export const useAuth = () => {
  const context = useContext(AuthContext);
  if (context === undefined) {
    throw new Error('useAuth must be used within an AuthProvider');
  }
  return context;
};
