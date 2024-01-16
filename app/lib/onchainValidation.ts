import { getInfuraProvider } from './infuraProvider';


export async function validateOffer(offer: IOffer, chainID: number) {
    const provider = await getInfuraProvider(chainID);

    //// validate if offer actual or new valid
}