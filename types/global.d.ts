import { formatEther } from "viem"

export {}

declare global {




  interface IOffer {
    asset: string, 
    amount: number, 
    wantedPrice: number,
    duration: number,
    lper: string,
    taker: string,
    executionPrice: number,
  }

  interface IAllowance {
    allowSignature: string,
    standingBalance: (balance: BigInt) =>  {formatEther(balance) },
  }

  type Offer = {
    data: IOffer,
    allowance: IAllowance
  }




}