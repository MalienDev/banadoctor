'use client';

import { createContext, useContext, useState, ReactNode, useCallback, useEffect } from 'react';
import { useRouter, usePathname } from 'next/navigation';
import api from '@/lib/api';
import { jwtDecode } from 'jwt-decode';

type User = {
  id: number;
  email: string;
  first_name: string;
  last_name: string;
  user_type: 'patient' | 'doctor' | 'admin';
  is_staff: boolean;
  is_active: boolean;
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
    const accessToken = localStorage.getItem('accessToken');
    if (accessToken) {
      try {
        const decodedToken: { exp: number } = jwtDecode(accessToken);
        if (decodedToken.exp * 1000 < Date.now()) {
          throw new Error('Token expired');
        }
        api.defaults.headers.common['Authorization'] = `Bearer ${accessToken}`;
        const { data: userData } = await api.get<User>('/api/v1/auth/profile/');
        setUser(userData);
      } catch (error) {
        console.error('Failed to load user:', error);
        setUser(null);
        localStorage.removeItem('accessToken');
        localStorage.removeItem('refreshToken');
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
    const isPublic = publicPaths.includes(pathname);

    if (isAuthenticated && isPublic) {
      router.push('/dashboard');
    } else if (!isAuthenticated && !isPublic) {
      router.push('/login');
    }
  }, [user, loading, pathname, router, publicPaths]);

  interface RefreshResponse {
    access: string;
  }

  interface LoginResponse {
    access: string;
    refresh: string;
    user: User;
  }

  const login = useCallback(async (email: string, password: string) => {
    try {
      setLoading(true);
      const { data } = await api.post<LoginResponse>('/api/v1/auth/login/', { email, password });
      
      // Store tokens
      localStorage.setItem('accessToken', data.access);
      localStorage.setItem('refreshToken', data.refresh);
      
      // Set auth header
      api.defaults.headers.common['Authorization'] = `Bearer ${data.access}`;
      
      // Update user state
      setUser(data.user);
      
      return data.user;
    } catch (error) {
      console.error('Login failed:', error);
      
      // Clear any partial state on failure
      localStorage.removeItem('accessToken');
      localStorage.removeItem('refreshToken');
      setUser(null);
      
      throw error;
    } finally {
      setLoading(false);
    }
  }, []);

  const register = useCallback(async (userData: Omit<User, 'id' | 'is_staff' | 'is_active' | 'date_joined' | 'last_login'> & { password: string, password2: string }) => {
    try {
      setLoading(true);
      const { data } = await api.post<LoginResponse>('/api/v1/auth/register/', {
        ...userData,
        password2: userData.password2,
        user_type: userData.user_type ? userData.user_type : 'patient'
      });
      
      // Store tokens
      localStorage.setItem('accessToken', data.access);
      localStorage.setItem('refreshToken', data.refresh);
      
      // Set auth header
      api.defaults.headers.common['Authorization'] = `Bearer ${data.access}`;
      
      // Update user state
      setUser(data.user);
      
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
  }, []);

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
            const { data } = await api.post('/api/v1/auth/token/refresh/', { refresh: refreshToken });
            localStorage.setItem('accessToken', data.access);
            api.defaults.headers.common['Authorization'] = `Bearer ${data.access}`;
            originalRequest.headers.Authorization = `Bearer ${data.access}`;
            return api(originalRequest);
          } catch (refreshError) {
            console.error('Token refresh failed:', refreshError);
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
