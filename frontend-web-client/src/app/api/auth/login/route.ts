import { NextResponse } from 'next/server';
import axios from 'axios'; 

const API_URL = process.env.NEXT_PUBLIC_API_URL || 'http://localhost:8000';

export async function POST(request: Request) {
  try {
    const { email, password } = await request.json();
    
    const response = await axios.post(`${API_URL}/api/auth/login/`, {
      email,
      password,
    });

    const { token, user } = response.data;

    return NextResponse.json({
      token,
      user: {
        id: user.id,
        email: user.email,
        firstName: user.first_name,
        lastName: user.last_name,
        role: user.role,
      },
    });
  } catch (error: any) {
    console.error('Login error:', error.response?.data || error.message);
    return NextResponse.json(
      { error: 'Invalid credentials' },
      { status: error.response?.status || 500 }
    );
  }
}
