'use client';

import { createContext, useContext, useState, ReactNode, useCallback, useEffect } from 'react';
import { useRouter, usePathname } from 'next/navigation';
import api from '@/lib/api';
import { jwtDecode } from 'jwt-decode';
import type { AxiosError } from 'axios';

type User = {
  id: number;
  email: string;
  first_name: string;
  last_name: string;
  user_type: 'patient' | 'doctor' | 'admin';
  is_staff: boolean;
  is_active: boolean;
  is_verified: boolean;
  date_joined: string;
  last_login: string | null;
};

type AuthContextType = {
  user: User | null;
  loading: boolean;
  login: (email: string, password: string) => Promise<User>;
  register: (userData: Omit<User, 'id' | 'is_staff' | 'is_active' | 'date_joined' | 'last_login'> & { 
    password: string;
    password2: string;
  }) => Promise<User>;
  logout: () => void;
  isAuthenticated: boolean;
};

const AuthContext = createContext<AuthContextType | undefined>(undefined);

export const AuthProvider = ({ children }: { children: ReactNode }) => {
  const [user, setUser] = useState<User | null>(null);
  const [loading, setLoading] = useState(true);
  const router = useRouter();
  const pathname = usePathname();
  const publicPaths = ['/login', '/register'];

  const loadUser = useCallback(async () => {
    // Only run on client-side
    if (typeof window === 'undefined') {
      setLoading(false);
      return;
    }

    const accessToken = localStorage.getItem('accessToken');
    if (accessToken) {
      try {
        const decodedToken: { exp: number } = jwtDecode(accessToken);
        if (decodedToken.exp * 1000 < Date.now()) {
          throw new Error('Token expired');
        }
        api.defaults.headers.common['Authorization'] = `Bearer ${accessToken}`;
        const { data: userData } = await api.get<User>('/users/profile/');
        setUser(userData);
      } catch (error) {
        console.error('Failed to load user:', error);
        setUser(null);
        if (typeof window !== 'undefined') {
          localStorage.removeItem('accessToken');
          localStorage.removeItem('refreshToken');
        }
        delete api.defaults.headers.common['Authorization'];
      }
    }
    setLoading(false);
  }, []);

  useEffect(() => {
    loadUser();
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, []);

  useEffect(() => {
    if (loading) return; // Wait until loading is finished

    const isAuthenticated = !!user;
    const proPaths = ['/pro/login', '/pro/register'];
    const allPublicPaths = [...publicPaths, ...proPaths];
    const isPublic = allPublicPaths.some(p => pathname.startsWith(p));

    if (isAuthenticated && isPublic) {
      if (user.user_type === 'doctor') {
        router.push('/pro/dashboard');
      } else {
        router.push('/dashboard');
      }
    } else if (!isAuthenticated && !isPublic) {
      if (pathname.startsWith('/pro/')) {
        router.push('/pro/login');
      } else if (pathname.startsWith('/admin/')) {
        router.push('/admin/login');
      } else {
        router.push('/login');
      }
    }
  }, [user, loading, pathname, router, publicPaths]);

  interface RefreshResponse {
    access: string;
  }

  interface LoginResponse {
    access: string;
    refresh: string;
    user: User & {
      is_verified: boolean;
    };
  }

  const login = useCallback(async (email: string, password: string): Promise<User> => {
    try {
      setLoading(true);
      const { data } = await api.post<LoginResponse>('/auth/login/', { email, password });
      
      // Check if email is verified
      if (!data.user.is_verified) {
        // Redirect to activation page with email as query param
        router.push(`/activate-account?email=${encodeURIComponent(email)}`);
        return data.user;
      }

      // If email is verified, proceed with normal login
      localStorage.setItem('accessToken', data.access);
      localStorage.setItem('refreshToken', data.refresh);
      api.defaults.headers.common['Authorization'] = `Bearer ${data.access}`;
      
      // Update user state
      setUser(data.user);
      
      // Redirect based on user type
      if (data.user.user_type === 'doctor') {
        router.push('/pro/dashboard');
      } else if (data.user.user_type === 'admin') {
        router.push('/admin/dashboard');
      } else {
        router.push('/dashboard');
      }
      
      return data.user;
    } catch (err) {
      console.error('Login failed:', err);

      // Handle 403 (forbidden) which our backend sends when the account is not yet verified
      const axiosResp = (err as AxiosError<{ redirect_to?: string; error?: string }>).response;
      if (axiosResp && axiosResp.status === 403) {
        // Prefer URL provided by backend but fall back to the built-in activation page
        const redirectUrl = axiosResp.data?.redirect_to ?? `/activate-account?email=${encodeURIComponent(email)}`;
        router.push(redirectUrl);
        // propagate a readable error to calling form handlers
        throw new Error(axiosResp.data?.error || 'Votre compte n\'est pas encore activé.');
      }
      
      // Clear any partial state on failure
      localStorage.removeItem('accessToken');
      localStorage.removeItem('refreshToken');
      setUser(null);
      
      throw err;
    } finally {
      setLoading(false);
    }
  }, [router]);

  const register = useCallback(async (userData: Omit<User, 'id' | 'is_staff' | 'is_active' | 'date_joined' | 'last_login'> & { password: string, password2: string }) => {
    try {
      setLoading(true);
      const payload = {
        email: userData.email,
        first_name: userData.first_name,
        last_name: userData.last_name,
        password: userData.password,
        password2: userData.password2,
        user_type: userData.user_type || 'patient',
      };
      const { data } = await api.post<LoginResponse>('/auth/register/', payload);
      
      // Store tokens
      localStorage.setItem('accessToken', data.access);
      localStorage.setItem('refreshToken', data.refresh);
      
      // Set auth header
      api.defaults.headers.common['Authorization'] = `Bearer ${data.access}`;
      
      // Update user state
      setUser(data.user);
      
      // Redirect based on user type
      if (data.user.user_type === 'doctor') {
        router.push('/pro/dashboard');
      } else if (data.user.user_type === 'admin') {
        router.push('/admin/dashboard');
      } else {
        router.push('/dashboard');
      }
      
      return data.user;
    } catch (error) {
      console.error('Registration failed:', error);
      
      // Clear any partial state on failure
      localStorage.removeItem('accessToken');
      localStorage.removeItem('refreshToken');
      setUser(null);
      
      throw error;
    } finally {
      setLoading(false);
    }
  }, [router]);

  const logout = useCallback(() => {
    // Clear tokens from storage
    localStorage.removeItem('accessToken');
    localStorage.removeItem('refreshToken');
    
    // Reset user state
    setUser(null);
    
    // Clear auth header
    delete api.defaults.headers.common['Authorization'];
    
    // Redirect to login page
    router.push('/login');
  }, [router]);

  useEffect(() => {
    const responseInterceptor = api.interceptors.response.use(
      (response) => response,
      async (error) => {
        const originalRequest = error.config;
        if (error.response?.status === 401 && !originalRequest._retry) {
          originalRequest._retry = true;
          const refreshToken = localStorage.getItem('refreshToken');
          if (!refreshToken) {
            logout();
            return Promise.reject(error);
          }
          try {
            const { data: refreshData } = await api.post<RefreshResponse>('/auth/token/refresh/', { refresh: refreshToken });
            const newAccessToken = refreshData.access;

            localStorage.setItem('accessToken', newAccessToken);
            api.defaults.headers.common['Authorization'] = `Bearer ${newAccessToken}`;
            originalRequest.headers.Authorization = `Bearer ${newAccessToken}`;

            const { data: userData } = await api.get<User>('/users/profile/');
            setUser(userData);

            return api(originalRequest);
          } catch (refreshError) {
            console.error('Token refresh or profile fetch failed:', refreshError);
            logout();
            return Promise.reject(refreshError);
          }
        }
        return Promise.reject(error);
      }
    );

    return () => {
      api.interceptors.response.eject(responseInterceptor);
    };
  }, [logout]);

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
