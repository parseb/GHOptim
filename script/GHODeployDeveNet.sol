// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script, console2} from "forge-std/Script.sol";
import {GHOptim} from "../src/GHOptim.sol";
import {IGhoToken} from "gho-core/src/contracts/gho/interfaces/IGhoToken.sol";

import {GHOinit, IAToken} from "../test/GHOptim.t.sol";
import {GHOinitCOPY} from "./EnvSetupCP.sol";

contract CounterScript is Script {
    bytes32 BUCKET_MANAGER_ROLE = 0xc7f115822aabac0cd6b9d21b08c0c63819451a58157aecad689d1b5674fad408;
    bytes32 FACILITATOR_MANAGER_ROLE = 0x5e20732f79076148980e17b6ce9f22756f85058fe2765420ed48a504bef5a8bc;
    GHOinitCOPY GIC;

    function setUp() public {
        GIC = new GHOinitCOPY();
        GIC.setUp();
    }

    function run() public {
        vm.startBroadcast(vm.envUint("GHOA0_PVK"));
        // address GHO_MAINNET_ADDRESS = 0x40D16FC0246aD3160Ccc09B8D0D3A2cD28aE6C2f;

        // GHOptim G = new GHOptim(GHO_MAINNET_ADDRESS);

        string memory ghotoken = string.concat("GHOtoken: ", '"', vm.toString(address(GIC.GHO_MAINNET_ADDRESS())), '"');
        string memory ghoptim = string.concat("GHOptim: ", '"', vm.toString(address(GIC.G())), '"');
        string memory log = string.concat("export const contractAddr = {", ghoptim, " , ", ghotoken, "}");
        console2.log(log);
        vm.writeFile("./public/deployments.js", log);

        /////// DEVnet
        // GHO20.addFacilitator(address(G), "GHOptim Options Minter", 100000000000000000000000000000000);
        vm.stopBroadcast();

        // G.updateBucketCapacity();
    }
}
