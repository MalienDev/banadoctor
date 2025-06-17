import { NextResponse } from 'next/server';
import axios from 'axios';

const API_URL = process.env.NEXT_PUBLIC_API_URL || 'http://localhost:8000';

interface LoginResponse {
  access: string;
  refresh: string;
  user: {
    id: number;
    email: string;
    first_name: string;
    last_name: string;
    user_type: 'patient' | 'doctor' | 'admin';
    is_verified: boolean;
  };
}

export async function POST(request: Request) {
  try {
    const { email, password } = await request.json();
    
    const response = await axios.post<LoginResponse>(`${API_URL}/api/auth/login/`, {
      email,
      password,
    });

    const { access, refresh, user } = response.data;

    // If we get here, login was successful
    return NextResponse.json({
      access,
      refresh,
      user: {
        id: user.id,
        email: user.email,
        first_name: user.first_name,
        last_name: user.last_name,
        user_type: user.user_type,
        is_verified: user.is_verified,
      },
    });
  } catch (error: any) {
    console.error('Login error:', error.response?.data || error.message);
    
    // Check if this is an email not verified error
    if (error.response?.data?.status === 'email_not_verified') {
      return NextResponse.json(
        { 
          error: error.response.data.error || 'Please verify your email address',
          status: 'email_not_verified',
          email: error.response.data.email || error.config?.data?.email
        },
        { status: 403 }
      );
    }

    return NextResponse.json(
      { 
        error: error.response?.data?.error || 
              error.response?.data?.detail || 
              'Invalid credentials. Please check your email and password and try again.' 
      },
      { status: error.response?.status || 500 }
    );
  }
}
