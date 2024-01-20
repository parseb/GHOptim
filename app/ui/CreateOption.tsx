
import { 
        useWaitForTransaction, 
        useContractWrite
} from 'wagmi'

// import React from 'react';

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
        DropdownItem,
        Datepicker,
        RangeSliderProps
    } from 'flowbite-react';
    import { useContractRead, useBalance } from 'wagmi'
    import { useWalletClient, Address } from 'wagmi'

import {useIsMounted} from 'connectkit'
import { InputCounter } from 'flowbite';
import { ChangeEvent, ChangeEventHandler } from 'react';


export  function CreateOption() {
    const clientResult = useWalletClient();


     function submit(e: React.FormEvent<HTMLFormElement>) { 
        e.preventDefault() 
        const formData = new FormData(e.target as HTMLFormElement) 
    }

    // if     (useIsMounted()) {
    //     const { address, connector, isConnected } = useAccount()

    // }

 function  getBalanceFor(assetAddr: `0x${string}`) {

        return useBalance({
            address: clientResult.data?.account.address,
            token: assetAddr,
          }).data?.formatted
    }
    
    // async function getAllAssetPrices(assetAddr:`0x${string}`) {
    //     const priceData = useContractRead({
    //         abi: GHOptimABI,
    //         address: GHOptimAddress as `0x${string}`,
    //         functionName: 'getPriceOfAaveAsset',
    //         args: [assetAddr] 
            
    //     })

//  function getAll() {
//     // function getAllForUser(address userAddress) external view returns(address[] memory assets, uint256[] memory prices, Position[] memory userPositions) {
        
//     const GHOptimData = useContractRead({
//             abi: GHOptimABI,
//             address: GHOptimAddress as `0x${string}`,
//             functionName: 'getAllForUser',
//             args: [`0xaeBf88463b38b72f893cd83220C483d9321496bE`]
//         })
//         console.log(GHOptimData.data);
//         return GHOptimData.data
//     }

//     const usetContextData = getAll();
let priceVal;
const setPriceVal = (e:any) => {
    priceVal = e.target.value;
    console.log(priceVal); ///
}


    return (
        <div style={{ display: 'flex', justifyContent: 'center', alignItems: 'center' }}>
            <>
                <div className='mb-2 block'>
                    <Label value="Asset" htmlFor='asset-selector' />
                    <Dropdown id="asset-selector" label={"Aave Asset"} >
                        {AaveAssets.map((asset:AaveAsset) => (
                            <DropdownItem value={asset.address} key={asset.address}> 
                                ${asset.name} | ${getBalanceFor(asset.address) || "loading balance"}
                            </DropdownItem>
                        ))}
                    </Dropdown>
                    <Label htmlFor="wanted-price-range" value={`Wanted Price: ${priceVal}`} > </Label>
                    <p>{priceVal} </p>
                    <RangeSlider id="wanted-price-range" min={2464} max={3824} onChange={(e)=> {setPriceVal(e) } } />
                    <Label htmlFor='how-many-days' value="Maximum Total Lock Duration" />
                    <Datepicker />
                    <Button type='submit'>Sign Offer</Button>
                </div>
            </>
        </div>

        

    )
}