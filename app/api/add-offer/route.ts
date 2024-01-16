import { sql } from '@vercel/postgres';
import { NextResponse } from 'next/server';
import { createOffer } from '@/app/lib/createOffer'

export async function GET(request: Request) {
  const { searchParams } = new URL(request.url);
 
 
  const asset = searchParams.get('asset');
  const amount = searchParams.get('amount');
  const wantedPrice = searchParams.get('wantedPrice');
  const duration = searchParams.get('duration');
  const lper = searchParams.get('lper');

 
  try {
    if (!asset || !wantedPrice || !lper ) throw new Error('Required Field Missing');
    const result = await createOffer(asset,amount,wantedPrice,duration,lper);
    // const offers = await sql`SELECT * FROM Offer;`;
    return NextResponse.json({ result }, { status: 200 });
} catch (error) {
    return NextResponse.json({ error }, { status: 500 });
  }
 

}