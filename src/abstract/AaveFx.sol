// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.20;

import {AaveV3Ethereum} from "aave-address-book/AaveV3Ethereum.sol";
import {IGhoToken} from "gho-core/src/contracts/gho/interfaces/IGhoToken.sol";


error Unauthorised();

//// @notice AaveFx - accumulates functions related to managing Aave mechanisms
abstract contract AaveFx {

    IGhoToken public GHO;
    address public genesis;

    constructor(address GHOaddress) {
        GHO = IGhoToken(GHOaddress);
        genesis = msg.sender;
    }


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

    function getATokenAddressFor(address assetAddress) public view returns (address aToken) {
        (aToken,,) = AaveV3Ethereum.AAVE_PROTOCOL_DATA_PROVIDER.getReserveTokensAddresses(assetAddress);
    }




}
