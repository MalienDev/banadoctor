import { NextResponse } from 'next/server';
import { cookies } from 'next/headers';
import axios from 'axios';

const API_URL = process.env.NEXT_PUBLIC_API_URL || 'http://localhost:8000';

export async function GET() {
  try {
    const token = cookies().get('token')?.value;
    
    if (!token) {
      return NextResponse.json(
        { error: 'Not authenticated' },
        { status: 401 }
      );
    }

    const response = await axios.get(`${API_URL}/api/auth/me/`, {
      headers: {
        'Authorization': `Token ${token}`
      }
    });

    const user = response.data;

    return NextResponse.json({
      user: {
        id: user.id,
        email: user.email,
        firstName: user.first_name,
        lastName: user.last_name,
        role: user.role,
      },
    });
  } catch (error: any) {
    console.error('Auth check error:', error.response?.data || error.message);
    return NextResponse.json(
      { error: 'Authentication check failed' },
      { status: error.response?.status || 500 }
    );
  }
}
