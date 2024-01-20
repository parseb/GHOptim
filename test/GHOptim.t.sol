// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {AaveV3Ethereum, IAaveOracle} from "aave-address-book/AaveV3Ethereum.sol";
import {Test, console2} from "forge-std/Test.sol";
import {GHOptim} from "../src/GHOptim.sol";
import {IGhoToken} from "gho-core/src/contracts/gho/interfaces/IGhoToken.sol";
import {IAToken} from "aave-v3-core/contracts/interfaces/IAToken.sol";

contract GHOinit is Test {
    GHOptim G;
    IGhoToken GHO20;
    IAToken AWETH;

    address public A0;
    address public A1;
    address public A2;
    address public WETHaddr;
    address public aWETHaddr;

    address public GHO_MAINNET_ADDRESS = 0x40D16FC0246aD3160Ccc09B8D0D3A2cD28aE6C2f;
    bytes32 BUCKET_MANAGER_ROLE = 0xc7f115822aabac0cd6b9d21b08c0c63819451a58157aecad689d1b5674fad408;
    bytes32 FACILITATOR_MANAGER_ROLE = 0x5e20732f79076148980e17b6ce9f22756f85058fe2765420ed48a504bef5a8bc;

    uint256 public A1pvk;
    uint256 public A0pvk;

    function setUp() public virtual {
        aWETHaddr = 0x4d5F47FA6A74757f35C14fD3a6Ef8E3C9BC514E8;
        AWETH = IAToken(aWETHaddr);
        WETHaddr = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;
        //// gives A0 all Roles

        A1pvk = vm.envUint("GHO2CREATE_PVK");
        A0pvk = vm.envUint("GHOA0_PVK");

        /// @dev create an environment variable with your mainnet fork RPC
        vm.createSelectFork(vm.envString("RPCmainDevTenderly"));

        // vm.createSelectFork('http://127.0.0.1:8545');

        vm.store(
            GHO_MAINNET_ADDRESS,
            0xbb4847e279544d497bb67b07270131df5a6e82353d0530a748ff5812e31e41a5,
            0x0000000000000000000000000000000000000000000000000000000000000001
        );
        vm.store(
            GHO_MAINNET_ADDRESS,
            0x5e20732f79076148980e17b6ce9f22756f85058fe2765420ed48a504bef5a8bc,
            0x0000000000000000000000000000000000000000000000000000000000000001
        );
        vm.store(
            GHO_MAINNET_ADDRESS,
            0x7c353fa2585450782b529838f38e2b464390119169ac919c03d1003aeb4b7710,
            0x0000000000000000000000000000000000000000000000000000000000000001
        );

        //// A0 GHO balance
        vm.store(
            GHO_MAINNET_ADDRESS,
            0x321ffdbea809790d5b1d4e691113a486fce50db524ed7ba04c606c424bd206b8,
            0x00000000000000000000000000000000000000000052b7d2dcc80cd2e4000000
        );

        //// A0 AWETH balance - 103386199279792118522912610
        vm.store(
            aWETHaddr,
            0x70ff7bd8c4af219479cae4e866a315fe462159a39268bf31c5be5da9c7c11dd1,
            0x00000000000000000000000000000000000000000052b7d2dcc80cd2e4000000
        );

        A0 = 0xaeBf88463b38b72f893cd83220C483d9321496bE;

        assertTrue(IAToken(aWETHaddr).balanceOf(A0) > 10_000_000 ether, "bad A0 balance");

        vm.label(A0, "A0");
        A1 = 0x92492b2C2df5967893ae903864EB9B669217c2da;
        /// GHO2
        vm.label(A1, "A1");
        A2 = 0x709ef2CBa57dfB96704aC10FB739c9dFF8B9e5Fe;
        vm.label(A2, "A2");

        GHO20 = IGhoToken(GHO_MAINNET_ADDRESS);
        vm.label(address(GHO20), "GHO20");

        address Gaddr = vm.computeCreateAddress(A0, vm.getNonce(A0));

        vm.prank(A0);
        GHO20.grantRole(BUCKET_MANAGER_ROLE, address(Gaddr));
        vm.prank(A0);
        GHO20.grantRole(FACILITATOR_MANAGER_ROLE, address(A0));

        vm.prank(A0);
        G = new GHOptim(GHO_MAINNET_ADDRESS);

        vm.prank(A0);
        IAToken(aWETHaddr).transfer(address(G), 9 * 1_000_000 * 1 ether);

        vm.prank(A0);
        IAToken(aWETHaddr).transfer(address(A1), 100_000 * 1 ether);

        vm.prank(A0);
        IAToken(aWETHaddr).transfer(address(A2), 100_000 * 1 ether);

        vm.prank(A0);
        GHO20.transfer(A1, 100_000 ether);

        vm.prank(A1);
        GHO20.approve(address(G), type(uint256).max / 2);
        /// overflow on absent approval

        vm.prank(A2);
        GHO20.approve(address(G), type(uint256).max / 2);

        vm.prank(A0);
        GHO20.transfer(A2, 100_000 ether);

        vm.prank(A0);
        AWETH.approve(address(G), type(uint256).max / 21781);
    }

    function _addAllowed() public {}

    function test_deployed() public {
        assertTrue(address(G).code.length > 1, "No Code");
    }

    function _addFacilitator() public {
        vm.prank(A0);
        GHO20.addFacilitator(address(G), "GHOptim Options Minter", 100000000000000000000000000000000);
    }

    function test_getsAssetPrice() public {
        if (block.chainid != getChain("mainnet").chainId) return;
        (address[] memory tokens, uint256[] memory prices) = G.getAllAssetsPrices();
        assertTrue(tokens.length > 1);
        assertTrue(prices[0] > 2000, "weth is not under 2000 @ 01.24");
        assertTrue(prices.length > 1, "should be bigger");

        //// Adds GHOption as facilitator
        assertTrue(IGhoToken(GHO_MAINNET_ADDRESS).hasRole(bytes32(0), A0), "is not GHO admin");

        _addFacilitator();

        assertTrue(GHO20.getFacilitator(address(G)).bucketCapacity > 0, "no capacity");
        assertTrue(GHO20.hasRole(BUCKET_MANAGER_ROLE, address(G)), "expected to have manager role");

        assertTrue(IAToken(G.getATokenAddressFor(tokens[0])).UNDERLYING_ASSET_ADDRESS() == tokens[0], "token missmatch");
    }

    function test_updateBucketCapacity() external {
        _addFacilitator();
        vm.prank(address(345676543567865467543));
        G.updateBucketCapacity();
        vm.warp(block.timestamp + 1234256);
        G.updateBucketCapacity();

        vm.startPrank(address(G));
        GHO20.mint(A1, 1000 ether);
        vm.stopPrank();

        vm.expectRevert();
        GHO20.mint(A2, 100_000 ether);
    }
}
