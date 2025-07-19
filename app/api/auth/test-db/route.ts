import { NextResponse } from 'next/server';
import { pool } from '@/lib/db';

export async function GET() {
  try {
    // Simple test query using the pool directly
    const result = await pool.query('SELECT NOW() as current_time, 1 as test_value');
    
    return NextResponse.json({ 
      success: true, 
      message: 'Database connection successful',
      data: result.rows[0]
    });
  } catch (error) {
    console.error('Database test error:', error);
    
    return NextResponse.json({ 
      success: false, 
      error: error instanceof Error ? error.message : 'Unknown error'
    }, { status: 500 });
  }
}