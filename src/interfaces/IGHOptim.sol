// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.3;

enum State {
    Default,
    Staging,
    Buy,
    Sell,
    Liquidated
}

struct Position {
    address asset;
    State state;
    uint256 expriresAt;
    uint256 amount;
    /// full units
    uint256 wantedPrice;
    /// 1
    uint256[2] durationBalance;
    /// signed,current
    /// % 1 day == 0
    address taker;
    address lper;
    uint256 executionPrice;
    bytes LPsig;
}

error Illegal();
error Unauthorised();
error InvalidExecutionPrice();
error InvalidReference();
error TransferFaileure();
error NotTaker();
error BadSigP();
error OnlyTaker();
error MinOneDay();
error Unavailable();
error OnlyTakerOrExpired();
error Untaken();
error Bro();
error AaveRug();
error InsufficientDuration();
error AZero();
error AlreadyTaken();
error NotADex();

interface IGHOptim {
    // Interface functions go here

    function takePosition(Position memory P) external;

    function liquidatePosition(bytes32 positionHash) external;
}
