// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script, console2} from "forge-std/Script.sol";
import {GHOptim} from "../src/GHOptim.sol";

contract CounterScript is Script {
    function setUp() public {}

    function run() public {
        vm.startBroadcast(vm.envUint("GHOA0_PVK"));
        address GHO_MAINNET_ADDRESS = 0x40D16FC0246aD3160Ccc09B8D0D3A2cD28aE6C2f;

        GHOptim G = new GHOptim(GHO_MAINNET_ADDRESS);
        string memory ghotoken = string.concat("GHOtoken: ", '"', vm.toString(GHO_MAINNET_ADDRESS), '"');
        string memory ghoptim = string.concat("GHOptim: ", '"', vm.toString(address(G)), '"');
        string memory log = string.concat("export const contractAddr = {", ghoptim, " , ", ghotoken, "}");
        console2.log(log);
        vm.writeFile("./public/deployments.js", log);
        vm.stopBroadcast();
    }
}
