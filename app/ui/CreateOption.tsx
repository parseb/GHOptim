
import { 
        useWaitForTransaction, 
        useContractWrite
} from 'wagmi'

import React from 'react';

import {GHOptimABI,AaveAssets, GHOtoken, GHOptimAddress, GHOptimContract, AAveOracle, AAvePool,GHOtokenABI , provider, AaveAsset} from "../lib/contracts";
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
    import { useContractRead, useBalance } from 'wagmi'
    import { useWalletClient, Address } from 'wagmi'

import {useIsMounted} from 'connectkit'


export function CreateOption() {
    const clientResult = useWalletClient();


     function submit(e: React.FormEvent<HTMLFormElement>) { 
        e.preventDefault() 
        const formData = new FormData(e.target as HTMLFormElement) 
    }

    // if     (useIsMounted()) {
    //     const { address, connector, isConnected } = useAccount()

    // }

    async function  getBalanceFor(assetAddr: `0x${string}`) {

        return useBalance({
            address: clientResult.data?.account.address,
            token: assetAddr,
          }).data?.formatted
    }
    
    async function getAllAssetPrices(assetAddr:`0x${string}`) {
        const priceData = useContractRead({
            abi: GHOptimABI,
            address: GHOptimAddress as `0x${string}`,
            functionName: 'getPriceOfAaveAsset',
            args: [assetAddr] 
            
        })

    }

    return (
        <form onSubmit={submit} style={{ margin: '0 auto', width: '50vw' }}>
            <div className='mb-2 block'>
                <Label value="Asset" htmlFor='asset-selector' />
            </div>
            <Dropdown id="asset-selector" label={"Aave Asset"} >
                {AaveAssets.map((asset:AaveAsset) => (
                    <DropdownItem value={asset.address}> 
                        ${asset.name} | ${getBalanceFor(asset.address) || "loading balance"}
                    </DropdownItem>
                ))}
            </Dropdown>
            <Label htmlFor="wanted-price-range" value="Wanted Price" />
            <RangeSlider id="wanted-price-range" min={}/>

            <Button type='submit'>Sign Offer</Button>
        </form>
    )
}