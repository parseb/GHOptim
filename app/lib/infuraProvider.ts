import { ethers, InfuraProvider, JsonRpcProvider } from 'ethers';
import { sepolia, mainnet, polygonMumbai, optimism, arbitrum, gnosis, Chain } from '@wagmi/core/chains'

/// @note will default to mainnet tenderly devnet for now

// export function getInfuraProvider(chainID: number): InfuraProvider {
//     const infuraKey = process.env.NEXT_PRIVATE_INFURA;
//     const net = [sepolia, mainnet, polygonMumbai, optimism, arbitrum].filter((n:Chain) => {return n.id == chainID});
//     const url = net[0].rpcUrls.infura.http;
//     const provider = new InfuraProvider(net[0],'GHOption', infuraKey);


//     return provider;
// }


export function getInfuraProvider(chainID: number): JsonRpcProvider {
    const provider = new JsonRpcProvider(process.env.NEXT_PRIVATE_DEVNETMAIN_TENDERLY);

    return provider;
}


// console.log("Fetching hello world contracts");
// const contract = $contracts["HelloWorld"];

// const provider = new ethers.providers.JsonRpcProvider($rpcUrl);
// const factory = new ethers.ContractFactory(contract.abi, contract.evm.bytecode, provider.getSigner);

// console.log("Deploying hello world contracts");
// const helloWorld = await factory.deploy("Hello World");

// console.log("Calling setGreeting function");
// await helloWorld.setGreeting("Hello Sandboxes");

// console.log(await helloWorld.getGreeting());
