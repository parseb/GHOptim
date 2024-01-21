// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.20;

import "./abstract/AaveFx.sol";
import "./interfaces/IGHOptim.sol";

/// @title GHOptim: An efficient, GHO denominating, Aave dependent Options Protocol
/// @author parseb | Bogdan A
contract GHOptim is AaveFx {
    constructor(address denominator) AaveFx(denominator) {}

    /// @notice First point of contact of a Position. Can be executed only by the position taker that pays for it.
    /// @notice Transfers the collateral from the LP. In case of Sell orders, mints GHO as a substitute for selling.
    /// @param P Complete position containing execution data ase well as Permit signature
    function takePosition(Position memory P) external returns (bytes32) {
        if (!isAllowedAToken[P.asset]) revert Illegal();
        if (uint8(P.state) <= 1) revert Untaken();
        if (P.executionPrice * P.wantedPrice * P.amount == 0) revert AZero();
        if (P.executionPrice >= P.wantedPrice) revert NotADex();

        (uint256 cost, uint256 executionPrice) = calculateTakePrice(P);
        if ((P.executionPrice) != (executionPrice / 1 ether)) revert InvalidExecutionPrice();

        uint256 duration = P.expriresAt >= (block.timestamp + 1 days) ? P.expriresAt - block.timestamp : 0;
        if (duration == 0) revert MinOneDay();

        if (P.durationBalance[0] < duration) revert InsufficientDuration();
        if (P.taker != _msgSender()) revert NotTaker();

        P.taker = _msgSender();
        uint256 amount = P.amount * 1 ether;

        if (cost / P.amount > executionPrice) revert ValueSensitivity();
        if (
            !(
                GHO.transferFrom(_msgSender(), address(this), cost)
                    && IAToken(P.asset).transferFrom(P.lper, address(this), amount)
            )
        ) {
            revert TransferFaileure();
        }

        assetTotalLiable[P.asset] += amount;

        if (P.state == State.Sell) {
            uint256 b = GHO.balanceOf(address(this));
            GHO.mint(address(this), executionPrice * P.amount);
            if (b >= GHO.balanceOf(address(this))) revert AaveRug();
        }

        P.durationBalance[1] =
            P.durationBalance[1] == 0 ? P.durationBalance[0] - duration : P.durationBalance[1] - duration;

        bytes32 h = keccak256(abi.encode(P));
        if (hashPosition[h].executionPrice >= 1) revert AlreadyTaken();

        hashPosition[h] = P;

        if (!verifyLPsig(P)) revert BadSigP();

        emit NewPosition(h);
        return h;
    }

    /// @notice closes a position provided it is expired or called by its owner
    /// @notice depending on the outcome, the LP is recapitalized or the underlying is re-auctioned
    /// @param positionHash hash of position to be fetched from storage
    function liquidatePosition(bytes32 positionHash) public {
        Position memory P = hashPosition[positionHash];

        if (P.executionPrice == 1 && _msgSender() == P.lper) {
            delete hashPosition[positionHash];
            if (!IAToken(P.asset).transfer(_msgSender(), P.amount * 1 ether)) revert TransferFaileure();
            if (IAToken(P.asset).allowance(_msgSender(), address(this)) > 1) revert ResidualPermit();
            return;
        }

        if (P.expriresAt > block.timestamp || _msgSender() != P.taker) revert OnlyTakerOrExpired();

        uint256 currentPrice = getPriceOfAsset(IAToken(P.asset).UNDERLYING_ASSET_ADDRESS()) / 0.1 gwei;
        uint256 profit;
        if (P.state == State.Sell) {
            if (currentPrice < P.executionPrice) {
                uint256 payout = (P.executionPrice - currentPrice) * P.amount * 1 ether;
                GHO.transfer(P.taker, payout);
                GHO.transfer(P.lper, P.wantedPrice * 1 ether);
                IAToken(P.asset).transfer(IAToken(P.asset).RESERVE_TREASURY_ADDRESS(), P.amount * 1 ether);
                assetTotalLiable[P.asset] -= P.amount * 1 ether;
                P.executionPrice = 1;
            } else {
                profit = (P.wantedPrice - P.executionPrice) * 1 ether;
                GHO.transfer(P.lper, profit / 2);
                GHO.transfer(_msgSender(), profit / 20);

                delete P.executionPrice;
            }
        }
        if (P.state == State.Buy) {
            if (currentPrice > P.wantedPrice) {
                uint256 payout = (currentPrice - P.wantedPrice) * P.amount * 1 ether;
                GHO.mint(P.taker, payout);
                GHO.mint(P.lper, P.wantedPrice * P.amount * 1 ether);
                IAToken(P.asset).transfer(IAToken(P.asset).RESERVE_TREASURY_ADDRESS(), P.amount * 1 ether);
                assetTotalLiable[P.asset] -= P.amount * 1 ether;
                P.executionPrice = 1;
            } else {
                profit = (P.wantedPrice - P.executionPrice);
                GHO.transfer(P.lper, profit / 2);
                GHO.transfer(_msgSender(), profit / 20);

                delete P.executionPrice;
            }
        }

        delete P.taker;
        delete P.expriresAt;
        hashPosition[positionHash] = P;

        emit PositionLiquid(positionHash);
    }

    /// @notice Sweeps Atoken surplus and redistributes it to Aave threasury and genesis
    /// @notice open execution, rewards 1% to executor
    /// @param Aasset_ wanted aToken address
    function profitTake(address Aasset_) external {
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

    /// @notice calculates the cost (price) payed by the option taker
    /// @notice the cost delta, price wanted by the liquidity provider and current value of tradeable assets
    /// @param P is the targeted position
    function calculateTakePrice(Position memory P) public view returns (uint256 cost, uint256 executionPrice) {
        executionPrice = getPriceOfAsset(IAToken(P.asset).UNDERLYING_ASSET_ADDRESS()) * 10 gwei;

        cost = ((P.wantedPrice * 1 ether) - executionPrice) * P.amount;
    }
}
