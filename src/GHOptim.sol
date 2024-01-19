// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.20;

import "./abstract/AaveFx.sol";
import "./interfaces/IGHOptim.sol";

import "forge-std/console2.sol";

/// GHO based
contract GHOptim is AaveFx {
    ///////////////////
    //////////////////

    /// stack?
    // struct Position {
    //     address asset;
    //     uint8 state;
    //     uint256 expriresAt;
    //     uint256 amount; /// full units
    //     uint256 wantedPrice; /// 1 eth
    //     address taker;
    //     address lper;
    //     uint256 executionPrice;
    //     bytes LPsig;
    // }
    constructor(address denominator) AaveFx(denominator) {}

    //// @notice main entry point for all user centered operations
    /// @param P Position details
    function takePosition(Position memory P) external {
        if (!isAllowedAToken[P.asset]) revert Illegal();
        if (uint8(P.state) <= 1) revert Untaken();
        if (P.executionPrice * P.wantedPrice * P.amount == 0) revert AZero();
        if (P.executionPrice >= P.wantedPrice) revert NotADex();

        (uint256 cost, uint256 executionPrice) = calculateTakePrice(P);
        if ((P.executionPrice) != (executionPrice / 1 ether)) revert InvalidExecutionPrice();

        IAToken AT = IAToken(P.asset);
        uint256 duration = P.expriresAt >= (block.timestamp + 1 days) ? P.expriresAt - block.timestamp : 0;
        if (duration == 0) revert MinOneDay();

        if (P.durationBalance[0] < duration) revert InsufficientDuration();
        if (P.taker != _msgSender()) revert NotTaker();

        if (!verifyLPsig(P)) revert BadSigP(); ///// console2.log(P.taker, _msgSender(), "but why P.taker always 0 sadge");

        uint256 amount = P.amount * 1 ether;

        if (cost / P.amount > executionPrice) revert Bro();
        if (!(GHO.transferFrom(_msgSender(), address(this), cost) && AT.transferFrom(P.lper, address(this), amount))) {
            revert TransferFaileure();
        }

        assetTotalLiable[P.asset] += amount;

        if (P.state == State.Sell) {
            uint256 b = GHO.balanceOf(address(this));
            GHO.mint(address(this), executionPrice * P.amount);
            if (b <= GHO.balanceOf(address(this))) revert AaveRug();
        }

        P.durationBalance[1] =
            P.durationBalance[1] == 0 ? P.durationBalance[0] - duration : P.durationBalance[1] - duration;

        bytes32 h = keccak256(abi.encode(P));
        if (hashPosition[h].executionPrice >= 1) revert AlreadyTaken();
        userHashes[P.lper].push(h);
        userHashes[P.taker].push(h);
        hashPosition[h] = P;

        hashPosition[h] = P;

        emit NewPosition(h);
    }

    function liquidatePosition(bytes32 positionHash) public {
        Position memory P = hashPosition[positionHash];
        if (P.expriresAt > block.timestamp || _msgSender() != P.taker) revert OnlyTakerOrExpired();

        uint256 currentPrice = getPriceOfAsset(IAToken(P.asset).UNDERLYING_ASSET_ADDRESS()) / 0.1 gwei;

        if (P.state == State.Sell) {
            if (currentPrice < P.executionPrice) {
                uint256 payout = (P.executionPrice - currentPrice) * P.amount * 1 ether;
                GHO.mint(P.taker, payout);
                GHO.transfer(P.lper, P.wantedPrice * 1 ether);
                IAToken(P.asset).transfer(IAToken(P.asset).RESERVE_TREASURY_ADDRESS(), P.amount * 1 ether);
                P.executionPrice = 1;
            } else {
                uint256 profit = (P.wantedPrice - P.executionPrice) * 1 ether;
                GHO.transfer(P.lper, profit / 2);
                delete P.executionPrice;
            }
            if (P.state == State.Buy) {
                if (currentPrice > P.wantedPrice) {
                    uint256 payout = (currentPrice - P.wantedPrice) * P.amount * 1 ether;
                    GHO.mint(P.taker, payout);
                    GHO.mint(P.lper, P.wantedPrice * P.amount * 1 ether);
                    P.executionPrice = 1;
                } else {
                    uint256 profit = (P.wantedPrice - P.executionPrice);
                    GHO.transfer(P.lper, profit / 2);
                    delete P.executionPrice;
                }
            }
        }
        delete P.taker;
        delete P.expriresAt;
        hashPosition[positionHash] = P;
    }

    /// @notice Sweeps Atoken surplus
    /// @param Aasset_ atoken address
    function profit(address Aasset_) external {
        uint256 onePercentAlmost = IAToken(Aasset_).balanceOf(address(this)) / 101;
        IAToken(Aasset_).transfer(genesis, (onePercentAlmost * 69) - assetTotalLiable[Aasset_]);
        IAToken(Aasset_).transfer(genesis, (onePercentAlmost) - assetTotalLiable[Aasset_]);
        IAToken(Aasset_).transfer(
            IAToken(Aasset_).RESERVE_TREASURY_ADDRESS(),
            IAToken(Aasset_).balanceOf(address(this)) - assetTotalLiable[Aasset_]
        );
    }

    function _msgSender() private view returns (address) {
        return msg.sender;
    }

    function calculateTakePrice(Position memory P) public view returns (uint256 cost, uint256 executionPrice) {
        executionPrice = getPriceOfAsset(IAToken(P.asset).UNDERLYING_ASSET_ADDRESS()) * 10 gwei;

        cost = ((P.wantedPrice * 1 ether) - executionPrice) * P.amount;
    }
}
