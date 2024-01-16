import { useParams } from 'next/navigation'
import { Unit } from 'wagmi'
import {validateOffer} from './onchainValidation'
import { sql } from '@vercel/postgres';

// 
export async function createOffer(
  asset: string, amount: number , wantedPrice: number , duration: number, lper: string
) {

  // const newOffer: IOffer = {asset,amount,wantedPrice,duration,lper}
  
  /// await validateOffer()

  try {
    await sql`INSERT INTO Offer (asset, amount, wantedPrice, duration, lper) VALUES (${asset}, ${amount}, ${wantedPrice}, ${duration}, ${lper});`;
  } catch (err) {
    return err;
  }

  const last = await sql`SELECT * FROM Offer ORDER BY id DESC LIMIT 1;`;
  return last;
  
}