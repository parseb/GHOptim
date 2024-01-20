import { 
        useWaitForTransaction, 
        useContractWrite
} from 'wagmi'

import {GHOptimABI,AaveAssets, GHOptimContract, AAveOracle, AAvePool, GHOptimToken,GHOtokenABI , provider, AaveAsset} from "../lib/contracts";
import {contractAddr} from "../../public/deployments"
import {
        Button,
        Label,
        RangeSlider,
        Select,
        Textarea,
        TextInput,
        Dropdown,
        DropdownItem
    } from 'flowbite-react';
    import { useContractRead, useAccount, useBalance } from 'wagmi'

import {useIsMounted} from 'connectkit'
    
export async function CreateOption() {

    async function submit(e: React.FormEvent<HTMLFormElement>) { 
        e.preventDefault() 
        const formData = new FormData(e.target as HTMLFormElement) 
    }

    if     (useIsMounted()) {
        const { address, connector, isConnected } = useAccount()

    }

    async function getBalanceFor(assetAddr: `0x${string}`) {
        return useBalance({
            address: address,
            token: assetAddr,
          }).data?.formatted
    }
    return (
        <form onSubmit={submit}>
                <div className='mb-2 block'>
                <Label value="Asset" />
                </div>
                <Dropdown label={"Aave Asset"} >
                    {AaveAssets.map((asset:AaveAsset) => (
                            

                        <DropdownItem value={asset.address}> 
                        `${asset.name} [balance: ${ getBalanceFor(asset.address)}]`
                        </DropdownItem>
                    ))}
                </Dropdown>

                <Button type='submit'>Sign Offer</Button>
        </form>
    )
}