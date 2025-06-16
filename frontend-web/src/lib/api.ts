import axios, { AxiosInstance, AxiosRequestConfig, AxiosResponse, AxiosError } from 'axios';

const BASE_URL = process.env.NEXT_PUBLIC_API_URL || 'http://localhost:8000';
const API_URL = `${BASE_URL}/api/v1`;

// Create a custom axios instance
const api: AxiosInstance = axios.create({
  baseURL: API_URL,
  headers: {
    'Content-Type': 'application/json',
  },
  withCredentials: true,
});

// Add a request interceptor to include the auth token
api.interceptors.request.use(
  (config) => {
    if (typeof window !== 'undefined') {
      const token = localStorage.getItem('accessToken');
      if (token) {
        config.headers.Authorization = `Bearer ${token}`;
      }
    }
    return config;
  },
  (error) => {
    return Promise.reject(error);
  }
);

// Add a response interceptor to handle token refresh and common errors
api.interceptors.response.use(
  (response) => response,
  async (error) => {
    const originalRequest = error.config;
    
    // If the error status is 401 and we haven't tried to refresh the token yet
    if (error.response?.status === 401 && !originalRequest._retry) {
      originalRequest._retry = true;
      
      try {
        // Try to refresh the token
        const response = await axios.post(`${API_URL}/users/token/refresh/`, {
          refresh: localStorage.getItem('refreshToken')
        });
        
        const { access } = response.data;
        localStorage.setItem('accessToken', access);
        
        // Update the authorization header
        originalRequest.headers.Authorization = `Bearer ${access}`;
        
        // Retry the original request
        return api(originalRequest);
      } catch (error) {
        // If refresh token is invalid, redirect to login
        if (typeof window !== 'undefined') {
          localStorage.removeItem('accessToken');
          localStorage.removeItem('refreshToken');
          window.location.href = '/login';
        }
        return Promise.reject(error);
      }
    }
    
    return Promise.reject(error);
  }
);

// Helper functions to make authenticated requests
export const get = async <T>(url: string, config?: AxiosRequestConfig): Promise<T> => {
  const response = await api.get<T>(url, config);
  return response.data;
};

export const post = async <T>(url: string, data?: any, config?: AxiosRequestConfig): Promise<T> => {
  const response = await api.post<T>(url, data, config);
  return response.data;
};

export const put = async <T>(url: string, data?: any, config?: AxiosRequestConfig): Promise<T> => {
  const response = await api.put<T>(url, data, config);
  return response.data;
};

export const patch = async <T>(url: string, data?: any, config?: AxiosRequestConfig): Promise<T> => {
  const response = await api.patch<T>(url, data, config);
  return response.data;
};

export const del = async <T>(url: string, config?: AxiosRequestConfig): Promise<T> => {
  const response = await api.delete<T>(url, config);
  return response.data;
};

// Interfaces
export interface User {
  id: number;
  email: string;
  first_name: string;
  last_name: string;
  phone_number?: string;
  user_type: 'patient' | 'doctor' | 'admin';
  date_of_birth?: string;
  gender?: string;
  is_active: boolean;
  is_staff: boolean;
  created_at: string;
  updated_at: string;
  doctor_profile?: DoctorProfile;
}

export interface DoctorProfile {
  specialization: string;
  license_number: string;
  years_of_experience?: number;
  bio?: string;
  consultation_fee?: number;
  address?: string;
  city?: string;
  country?: string;
  educations?: Education[];
}

export interface Education {
  id: number;
  degree: string;
  institution: string;
  year_completed: number;
}

export interface Availability {
  id: number;
  day_of_week: number;
  start_time: string;
  end_time: string;
  is_available: boolean;
}

export interface Appointment {
  id: number;
  doctor: number;
  patient: number;
  scheduled_date: string;
  start_time: string;
  end_time: string;
  status: 'pending' | 'confirmed' | 'cancelled' | 'completed';
  status_display: string;
  appointment_type: 'in_person' | 'phone' | 'teleconsultation';
  type_display: string;
  notes?: string;
  is_paid: boolean;
  amount: number;
  created_at: string;
  updated_at: string;
  patient_name: string;
  doctor_name: string;
}

export interface DashboardStats {
  stats: {
    appointments_today: number;
    pending_appointments: number;
    total_patients: number;
    unread_messages: number;
    total_revenue: number;
  };
  upcoming_appointments: Appointment[];
  recent_activity: Appointment[];
}

// Auth API
export const login = (email: string, password: string) => {
  return post<{ access: string; refresh: string }>('/users/login/', { email, password });
};

export const register = (data: {
  email: string;
  password: string;
  password2: string;
  first_name: string;
  last_name: string;
  user_type: 'patient' | 'doctor';
  phone_number?: string;
  date_of_birth?: string;
  gender?: string;
}) => {
  return post<User>('/users/register/', data);
};

export const getCurrentUser = (): Promise<User> => {
  return get<User>('/users/me/');
};

// User Profile API
export const updateProfile = (data: Partial<User>): Promise<User> => {
  return put<User>('/users/profile/', data);
};

export const updateDoctorProfile = (data: Partial<DoctorProfile>): Promise<DoctorProfile> => {
  return patch<DoctorProfile>('/users/profile/doctor/', data);
};

export const changePassword = (oldPassword: string, newPassword: string) => {
  return post('/users/change-password/', {
    old_password: oldPassword,
    new_password: newPassword
  });
};

// Availability API
export const getDoctorAvailability = (): Promise<Availability[]> => {
  return get<Availability[]>('/users/availability/');
};

export const addDoctorAvailability = (data: Omit<Availability, 'id'>): Promise<Availability> => {
  return post<Availability>('/users/availability/', data);
};

export const updateDoctorAvailability = (id: number, data: Partial<Availability>): Promise<Availability> => {
  return patch<Availability>(`/users/availability/${id}/`, data);
};

export const deleteDoctorAvailability = (id: number): Promise<void> => {
  return del(`/users/availability/${id}/`);
};

// Appointments API
export const getAppointments = (params?: {
  status?: string;
  start_date?: string;
  end_date?: string;
  doctor_id?: number;
  patient_id?: number;
}): Promise<Appointment[]> => {
  return get<Appointment[]>('/appointments/', { params });
};

export const getAppointment = (id: number): Promise<Appointment> => {
  return get<Appointment>(`/appointments/${id}/`);
};

export const createAppointment = (data: {
  doctor: number;
  patient: number;
  scheduled_date: string;
  start_time: string;
  end_time: string;
  appointment_type: 'in_person' | 'video' | 'phone';
  notes?: string;
}): Promise<Appointment> => {
  return post<Appointment>('/appointments/', data);
};

export const updateAppointment = (id: number, data: Partial<Appointment>): Promise<Appointment> => {
  return patch<Appointment>(`/appointments/${id}/`, data);
};

export const cancelAppointment = (id: number, reason?: string): Promise<Appointment> => {
  return post<Appointment>(`/appointments/${id}/cancel/`, { reason });
};

// Dashboard API
export const getDashboardStats = (): Promise<DashboardStats> => {
  return get<DashboardStats>('/users/dashboard-stats/');
};

// Search API
export const searchDoctors = (params: {
  query?: string;
  specialization?: string;
  city?: string;
  min_fee?: number;
  max_fee?: number;
  available_on?: string; // YYYY-MM-DD
}): Promise<User[]> => {
  return get<User[]>('/search/doctors/', { params });
};

export default api;
