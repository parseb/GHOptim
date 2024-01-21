// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.20;

import {AaveV3Ethereum, IAaveOracle} from "aave-address-book/AaveV3Ethereum.sol";
import {IGhoToken} from "gho-core/src/contracts/gho/interfaces/IGhoToken.sol";
import {IGHOptim, Position, State} from "../interfaces/IGHOptim.sol";
import {IAToken} from "aave-v3-core/contracts/interfaces/IAToken.sol";

import {VerifySignature} from "../utils/VerifySignature.sol";

//// @notice AaveFx - accumulates functions related to managing Aave mechanisms
abstract contract AaveFx is IGHOptim, VerifySignature {
    IGhoToken public GHO;
    IAaveOracle ORACLE = AaveV3Ethereum.ORACLE;
    address public genesis;

    mapping(address => bool) isAllowedAToken;
    mapping(address => uint256) assetTotalLiable;

    // mapping(address => bytes32[]) userHashes;
    mapping(bytes32 => Position) hashPosition;

    constructor(address GHOaddress) {
        GHO = IGhoToken(GHOaddress);
        genesis = msg.sender;
        _setAllowedOnlyOnce();
    }

    event NewPosition(bytes32 positionHash);
    event PositionLiquid(bytes32 positionHash);

    function verifyLPsig(Position memory P) public pure returns (bool s) {
        bytes memory signature = P.LPsig;
        delete P.executionPrice;
        delete P.expriresAt;
        delete P.LPsig;
        delete P.taker;

        P.state = State.Staging;
        P.durationBalance[1] = 0;

        bytes32 h = getEthSignedMessageHash(keccak256(abi.encode(P)));
        address signer = recoverSigner(h, signature);

        return (signer == P.lper);
    }

    function updateBucketCapacity() public {
        (address[] memory assets, uint256[] memory prices) = getAllAssetsPrices();
        uint128 totalValue;

        for (uint256 i = 0; i < assets.length; i++) {
            assets[i] = getATokenAddressFor(assets[i]);
            if (!isAllowedAToken[assets[i]]) continue;
            uint256 currentATokenBalance = IAToken(assets[i]).balanceOf(address(this));

            uint256 assetValue = ((prices[i] / 0.1 gwei) * currentATokenBalance);
            totalValue += uint128(assetValue);
        }

        GHO.setFacilitatorBucketCapacity(address(this), uint128(totalValue));
    }

    function _setAllowedOnlyOnce() private {
        if (isAllowedAToken[address(this)]) revert();

        (address[] memory assets, uint256[] memory prices) = getAllAssetsPrices();

        uint256 i;
        for (; i < prices.length; i++) {
            if (prices[i] > 1_87654321) {
                address aToken = getATokenAddressFor(assets[i]);
                isAllowedAToken[aToken] = true;
            }
        }
        isAllowedAToken[address(this)] = true;
        return;
    }

    ///////////
    /// View

    /// External

    /// @notice gets all the aToken underlying assets and their prices
    function getAllAssetsPrices() public view returns (address[] memory assets, uint256[] memory prices) {
        assets = AaveV3Ethereum.POOL.getReservesList();
        prices = AaveV3Ethereum.ORACLE.getAssetsPrices(assets);
    }

    //// @notice gets aToken address for Aave depositable asset
    /// @param assetAddress underlying ERC20 token address
    function getATokenAddressFor(address assetAddress) public view returns (address aToken) {
        (aToken,,) = AaveV3Ethereum.AAVE_PROTOCOL_DATA_PROVIDER.getReserveTokensAddresses(assetAddress);
    }

    /// @notice gets Aave Oracle price given a base underlying asset address, response uses 8 decimals
    /// @param Asset address of base depositable asset
    function getPriceOfAsset(address Asset) public view returns (uint256) {
        return ORACLE.getAssetPrice(Asset);
    }

    function getPriceOfAaveAsset(address aTokenAddress) public view returns (uint256) {
        return getPriceOfAsset(IAToken(aTokenAddress).UNDERLYING_ASSET_ADDRESS()) / 0.1 gwei;
    }

    function getAllAaveAssetPrices() public view returns (address[] memory assets, uint256[] memory prices) {
        (assets, prices) = getAllAssetsPrices();
        for (uint256 i = 0; i < assets.length; i++) {
            assets[i] = getATokenAddressFor(assets[i]);
        }
    }

    // function getAllForUser(address userAddress)
    //     external
    //     view
    //     returns (address[] memory assets, uint256[] memory prices, Position[] memory userPositions)
    // {
    //     (assets, prices) = getAllAaveAssetPrices();
    //     bytes32[] memory userHS = userHashes[userAddress];

    //     uint256 i;
    //     for (i; i < userHS.length; ++i) {
    //         userPositions[i] = hashPosition[userHS[i]];
    //     }
    // }

    function getPosition(bytes32 hashOf) public view returns (Position memory) {
        return hashPosition[hashOf];
    }
}
