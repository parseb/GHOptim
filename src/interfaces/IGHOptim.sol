// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.3;

struct Position {
    address asset;
    uint8 state;
    uint256 expriresAt;
    uint256 amount;
    /// full units
    uint256 wantedPrice;
    /// 1 eth
    uint256 durationBalance;
    /// % 1 day == 0
    address taker;
    address lper;
    uint256 executionPrice;
    bytes LPsig;
}

error Illegal();

interface IGHOptim {
    // Interface functions go here

    function executeOperation(Position memory P) external;
}
