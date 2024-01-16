// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.3;

    struct Position {
        address asset;
        uint256 amount;
        uint256 wantedPrice;
        uint256 duration;
        address taker;
        address lper;
        uint256 executionPrice;
    }
interface IGHOptim {
    // Interface functions go here
}
