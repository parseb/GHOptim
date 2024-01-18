// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.20;

import {AaveV3Ethereum, IAaveOracle} from "aave-address-book/AaveV3Ethereum.sol";
import {IGhoToken} from "gho-core/src/contracts/gho/interfaces/IGhoToken.sol";
import {IGHOptim, Position} from "../interfaces/IGHOptim.sol";
import {IAToken} from "aave-v3-core/contracts/interfaces/IAToken.sol";

import {VerifySignature} from "../utils/VerifySignature.sol";

error Unauthorised();
error InvalidExecutionPrice();
error InvalidReference();
error TransferFaileure();
error NotTaker();
error Illegal();
error BadSigP();
error OnlyTaker();
error MinOneDay();

//// @notice AaveFx - accumulates functions related to managing Aave mechanisms
abstract contract AaveFx is IGHOptim, VerifySignature {
    IGhoToken public GHO;
    IAaveOracle ORACLE = AaveV3Ethereum.ORACLE;
    address public genesis;

    mapping(address => bool) isAllowedAToken;
    mapping(address => uint256) assetTotalLiable;

    mapping(address => bytes32[]) userHashes;
    mapping(bytes32 => Position) hashPosition;

    constructor(address GHOaddress) {
        GHO = IGhoToken(GHOaddress);
        genesis = msg.sender;
        _setAllowedOnlyOnce();
    }

    function verifyLPsig(Position memory P) public pure returns (bool s) {
        bytes memory signature = P.LPsig;
        delete P.executionPrice;
        delete P.expriresAt;
        delete P.LPsig;
        delete P.state;
        delete P.taker;

        bytes32 h = getEthSignedMessageHash(keccak256(abi.encode(P)));
        address signer = recoverSigner(h, signature);
        return (signer == P.lper);
    }

    function updateBucketCapacity() public {
        (address[] memory assets, uint256[] memory prices) = getAllAssetsPrices();
        uint256 totalValue;

        for (uint256 i = 0; i < assets.length; i++) {
            if (!isAllowedAToken[assets[i]]) continue;
            (uint256 currentATokenBalance,,,,,,,, bool usageAsCollateralEnabled) =
                AaveV3Ethereum.AAVE_PROTOCOL_DATA_PROVIDER.getUserReserveData(assets[i], address(this));

            if (!usageAsCollateralEnabled) continue;

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

    function getAllAssetsPrices() public view returns (address[] memory assets, uint256[] memory prices) {
        assets = AaveV3Ethereum.POOL.getReservesList();
        prices = AaveV3Ethereum.ORACLE.getAssetsPrices(assets);
    }

    function getATokenAddressFor(address assetAddress) public view returns (address aToken) {
        (aToken,,) = AaveV3Ethereum.AAVE_PROTOCOL_DATA_PROVIDER.getReserveTokensAddresses(assetAddress);
    }

    function getPriceOfAsset(address Asset) public view returns (uint256) {
        return ORACLE.getAssetPrice(Asset);
    }
}
