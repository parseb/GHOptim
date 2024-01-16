// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console2} from "forge-std/Test.sol";
import {GHOptim} from "../src/GHOptim.sol";

contract CounterTest is Test {
    GHOptim G;

    address public A0;
    address public A1;
    address public A2;

    address GHO_MAINNET_ADDRESS = 0x40D16FC0246aD3160Ccc09B8D0D3A2cD28aE6C2f;

    function setUp() public {

        G = new GHOptim(GHO_MAINNET_ADDRESS);

        A0 = 0xaeBf88463b38b72f893cd83220C483d9321496bE;
        A1 = 0x34F10b00cd1F032106BD7CBdA208934cF70764BC;
        A2 = 0x709ef2CBa57dfB96704aC10FB739c9dFF8B9e5Fe;

    }

    function test_deployed() public {
        assertTrue(address(G).code.length > 1, "No Code");
    }

    function test_getsAssetPrice() public {
        if (block.chainid != getChain("mainnet").chainId) return;
        address[] memory tokens = G.getAllowedTokens();
        assertTrue(tokens.length > 1);
        assertTrue(G.getAssetPrice(tokens[0]) > 2000, "weth is not under 2000 @ 01.24");
        assertTrue(G.getAllAssetPrices().length >1, "should be bigger" );

        //// DEV env fork setup
        assertTrue(G.GHO().hasRole(bytes32(0),msg.sender), "is not GHO admin");


    } 


}
