// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.20;

import './interfaces/IGHOptim.sol';
import './abstract/AaveFx.sol';
import {IAToken} from 'aave-v3-core/contracts/interfaces/IAToken.sol';


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

    //// @notice main entry point for all user centered operations
    /// @param typeOfOperation uint indicative and correlating to Position state
    /// @param P Position details
    /// @param h hash of position
    function executeOperation(uint8 typeOfOperation, Position memory P, bytes32 h ) external {
        
    }

    
    function profit(address Aasset) external {
        if (! (msg.sender == genesis) ) revert Unauthorised();
        IAToken(Aasset).transfer(genesis, IAToken(Aasset).balanceOf(address(this)) - assetTotalLiable[Aasset]);
    } 

}


