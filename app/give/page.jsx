'use client'
import {CreateOption} from "../ui/CreateOption"
import { useWalletClient } from "wagmi";

export default function Page() {

    const clientResult = useWalletClient();

    return (
        <div className='container' style={{ height: '100vh' }}>
            <CreateOption />
       
            {clientResult.result}
        </div>
    );
}
