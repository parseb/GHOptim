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
            AT.transfer(AT.RESERVE_TREASURY_ADDRESS(), amount);
        }

        P.durationBalance[1] =
            P.durationBalance[1] == 0 ? P.durationBalance[0] - duration : P.durationBalance[1] - duration;

        bytes32 h = keccak256(abi.encode(P));

        userHashes[P.lper].push(h);
        userHashes[P.taker].push(h);
        hashPosition[h] = P;

        hashPosition[h] = P;

        emit NewPosition(h);
    }

    // _manageExistingPosition();

    function liquidatePosition(bytes32 positionHash) public {
        Position memory P = hashPosition[positionHash];
        if (P.expriresAt > block.timestamp || _msgSender() != P.taker) revert OnlyTakerOrExpired();

        ///// if position type

        //// flashloan? ...always pay in gho?

        /// if successful sell - liquidate || reliquify
    }

    /// @notice Sweeps Atoken surplus
    /// @param Aasset_ atoken address
    function profit(address Aasset_) external {
        // if (!(msg.sender == genesis)) revert Unauthorised();

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
