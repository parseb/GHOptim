// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console2} from "forge-std/Test.sol";
import {GHOptim} from "../src/GHOptim.sol";
import {IGhoToken} from "gho-core/src/contracts/gho/interfaces/IGhoToken.sol";
import {IAToken} from 'aave-v3-core/contracts/interfaces/IAToken.sol';

contract GHOinit is Test {
    GHOptim G;
    IGhoToken GHO20;

    address public A0;
    address public A1;
    address public A2;

    address GHO_MAINNET_ADDRESS = 0x40D16FC0246aD3160Ccc09B8D0D3A2cD28aE6C2f;
    bytes32 BUCKET_MANAGER_ROLE = 0xc7f115822aabac0cd6b9d21b08c0c63819451a58157aecad689d1b5674fad408;
    bytes32 FACILITATOR_MANAGER_ROLE = 0x5e20732f79076148980e17b6ce9f22756f85058fe2765420ed48a504bef5a8bc;


    function setUp() public {
        
        //// gives A0 all Roles
        vm.store(GHO_MAINNET_ADDRESS, 0xbb4847e279544d497bb67b07270131df5a6e82353d0530a748ff5812e31e41a5, 0x0000000000000000000000000000000000000000000000000000000000000001);
        vm.store(GHO_MAINNET_ADDRESS, 0x5e20732f79076148980e17b6ce9f22756f85058fe2765420ed48a504bef5a8bc, 0x0000000000000000000000000000000000000000000000000000000000000001);
        vm.store(GHO_MAINNET_ADDRESS, 0x7c353fa2585450782b529838f38e2b464390119169ac919c03d1003aeb4b7710, 0x0000000000000000000000000000000000000000000000000000000000000001);

        G = new GHOptim(GHO_MAINNET_ADDRESS);
        GHO20 = IGhoToken(GHO_MAINNET_ADDRESS);

        A0 = 0xaeBf88463b38b72f893cd83220C483d9321496bE;
        A1 = 0x34F10b00cd1F032106BD7CBdA208934cF70764BC;
        A2 = 0x709ef2CBa57dfB96704aC10FB739c9dFF8B9e5Fe;

        if (block.chainid == 1) {
            vm.prank(A0);
            GHO20.grantRole(BUCKET_MANAGER_ROLE, address(G));
            vm.prank(A0);
            GHO20.grantRole(FACILITATOR_MANAGER_ROLE, address(A0));
        }

    }

    function test_deployed() public {
        assertTrue(address(G).code.length > 1, "No Code");
    }

    function test_getsAssetPrice() public {
        if (block.chainid != getChain("mainnet").chainId) return;
        (address[] memory tokens, uint256[] memory prices ) = G.getAllAssetsPrices();
        assertTrue(tokens.length > 1);
        assertTrue(prices[0] > 2000, "weth is not under 2000 @ 01.24");
        assertTrue(prices.length >1, "should be bigger" );

        //// Adds GHOption as facilitator
        assertTrue(IGhoToken(GHO_MAINNET_ADDRESS).hasRole(bytes32(0),A0 ), "is not GHO admin");
        vm.prank(A0);
        GHO20.addFacilitator(address(G), "GHOptim Options Minter", 100000000000000000000000000 );
        assertTrue(GHO20.getFacilitator(address(G)).bucketCapacity > 0, "no capacity" );
        assertTrue(GHO20.hasRole(BUCKET_MANAGER_ROLE, address(G)), "expected to have manager role");

        assertTrue(IAToken(G.getATokenAddressFor(tokens[0])).UNDERLYING_ASSET_ADDRESS() == tokens[0], "token missmatch" );
    } 

    


    // function test_updateBucketCapacity() external {
    //     fail();
    // }



}
