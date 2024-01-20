'use client'
import {CreateOption} from "../ui/CreateOption"
import { useAccount } from "wagmi";
export default function Page() {
    const { address, connector, isConnected } = useAccount()


    return (
        <div className='container' style={{ height: '100vh' }}>
            <CreateOption />
       
            {address}
        </div>
    );
}
