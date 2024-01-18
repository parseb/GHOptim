// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.20;

import "./abstract/AaveFx.sol";

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
    function executeOperation(Position memory P) external {
        if (!isAllowedAToken[P.asset]) revert Illegal();
        IAToken AT = IAToken(P.asset);
        uint256 executionPrice = getPriceOfAsset(AT.UNDERLYING_ASSET_ADDRESS());
        bytes32 h = keccak256(abi.encode((P)));

        if (P.expriresAt > block.timestamp) {
            liquidatePosition(hashPosition[h]);

            return;
        }
        /// Untaken

        if (P.state == 1) {
            if (!verifyLPsig(P)) revert BadSigP();

            if (P.executionPrice != executionPrice) revert InvalidExecutionPrice();
            if (P.taker != _msgSender()) revert NotTaker();

            if (P.expriresAt - block.timestamp < 1 days) revert MinOneDay();

            /// new position minting

            uint256 diff = ((P.wantedPrice * 1_00000000) - executionPrice) * 0.1 gwei * P.amount;
            if (
                !(
                    GHO.transferFrom(_msgSender(), address(this), diff)
                        && AT.transferFrom(P.lper, address(this), P.amount * 1 ether)
                )
            ) revert TransferFaileure();

            assetTotalLiable[P.asset] += P.amount * 1 ether;

            P.state = 1;
            P.durationBalance = P.durationBalance - (P.expriresAt - block.timestamp);
        }

        hashPosition[h] = P;
        return;
    }

    // _manageExistingPosition();

    function liquidatePosition(Position memory P) public {
        address taker = hashPosition[keccak256(abi.encode(P))].taker;

        if (msg.sig != IGHOptim(address(this)).executeOperation.selector && _msgSender() != taker) revert OnlyTaker();

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

    function _msgSender() private returns (address) {
        return msg.sender;
    }
}
