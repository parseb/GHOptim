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


    // function executeOperation()



    function updateBucketCapacity() public {
        (address[] memory assets, uint256[] memory prices) = getAllAssetsPrices();
        uint256 totalValue;

        for (uint256 i = 0; i < assets.length; i++) {
            (
                uint256 currentATokenBalance,
                ,
                ,
                ,
                ,
                ,
                ,
                ,
                bool usageAsCollateralEnabled
            ) = AaveV3Ethereum.AAVE_PROTOCOL_DATA_PROVIDER.getUserReserveData(assets[i], address(this));
            
            if (! usageAsCollateralEnabled ||  (currentATokenBalance < 1 ether )) continue;
            
            uint256 assetValue = ((prices[i] / 0.1 gwei) * currentATokenBalance);
            totalValue += uint128(assetValue);
        }

        GHO.setFacilitatorBucketCapacity(address(this), uint128(totalValue));

    }



    ///////////
    /// View

        



    /// External


    function getAllAssetsPrices() public view returns (address[] memory assets, uint256[] memory prices) {
        assets = AaveV3Ethereum.POOL.getReservesList();
        prices = AaveV3Ethereum.ORACLE.getAssetsPrices(assets);
    }

// function getUserReserveData(
//     address asset,
//     address user
//   )
//     external
//     view
//     override
//     returns (
//       uint256 currentATokenBalance,
//       uint256 currentStableDebt,
//       uint256 currentVariableDebt,
//       uint256 principalStableDebt,
//       uint256 scaledVariableDebt,
//       uint256 stableBorrowRate,
//       uint256 liquidityRate,
//       uint40 stableRateLastUpdated,
//       bool usageAsCollateralEnabled
//     )

}


