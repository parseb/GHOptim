// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.20;

import {GHOinit} from "./GHOptim.t.sol";
import {VerifySignature} from "../src/utils/VerifySignature.sol";

contract HappyPathTest is GHOinit, VerifySignature {
    //// @notice Should walk the path along a minimum complete path of a Position instance
    function test_PreReq() public {
        //// Required state modifications
        //// this adds GHOptim as a facilitator
        _addFacilitator();
        //// this updates the capacity of the facilitator to the total value of aTokens deposited
        G.updateBucketCapacity();

        //// @todo
    }
}
