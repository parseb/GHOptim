// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.20;

import {IGHOptim} from './interfaces/IGHOptim.sol';
import {AaveV3Ethereum} from "aave-address-book/AaveV3Ethereum.sol";
import {IGhoToken} from "gho-core/src/contracts/gho/interfaces/IGhoToken.sol";


/// GHO based 
contract GHOptim is IGHOptim {

    /// if 0x, not executed
    /// if self only once
    /// if different - multi cycled liquidity
    /// ---- parent(hash) -> return currentLastHash[parent]
    mapping(bytes32 => bytes32) currentLastHash;

    IGhoToken public GHO;

    ///////////////////
    //////////////////

    constructor(address denominator) {
        GHO = IGhoToken(denominator);
    }


    ///////////
    /// View

    function getAssetPrice(address asset_) external view returns (uint256) {
        return AaveV3Ethereum.ORACLE.getAssetPrice(asset_);
    }

    /// External
    function getAllowedTokens() public view returns (address[] memory) {
        return AaveV3Ethereum.POOL.getReservesList();
    }

    function getAllAssetPrices() external view returns (uint256[] memory ) {
        address[] memory assets = getAllowedTokens();
        return AaveV3Ethereum.ORACLE.getAssetsPrices(assets);
    }
    
}
