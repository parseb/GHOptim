// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.20;

import './interfaces/IGHOptim.sol';
import './abstract/AaveFx.sol';

/// GHO based 
contract GHOptim is IGHOptim, AaveFx {

    /// if 0x, not executed
    /// if self only once
    /// if different - multi cycled liquidity
    /// ---- parent(hash) -> return currentLastHash[parent]
    mapping(bytes32 => bytes32) currentLastHash;

    mapping(address => uint256) assetTotalLiable;



    
    ///////////////////
    //////////////////

    constructor(address denominator) AaveFx(denominator) {}


    function executeOperation(uint8 typeOfOperation, Position memory P, bytes32 hash ) external {

    }





}


