// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.20;

import {
    Position,
    State,
    IGHOptim,
    Illegal,
    BadSigP,
    InsufficientDuration,
    Untaken,
    MinOneDay,
    OnlyTakerOrExpired
} from "../src/interfaces/IGHOptim.sol";
import {AaveV3Ethereum, IAaveOracle} from "aave-address-book/AaveV3Ethereum.sol";

import {GHOinit} from "./GHOptim.t.sol";
import {VerifySignature} from "../src/utils/VerifySignature.sol";
import {AaveV3Ethereum, IAaveOracle} from "aave-address-book/AaveV3Ethereum.sol";


import {console2} from 'forge-std/console2.sol';
import {console} from 'forge-std/console.sol';



contract PositionsTest is GHOinit, VerifySignature {
    //  function setUp() public override {
    //     super.setUp();
    //  }

    function test_newPositionF() public {
        _addFacilitator();
        G.updateBucketCapacity();

        Position memory P;
        P.taker = A1;
        P.amount = 5;
        P.lper = A0;



        vm.expectRevert(Illegal.selector);
        G.takePosition(P);
        P.asset = address(AWETH);

        P.executionPrice = AaveV3Ethereum.ORACLE.getAssetPrice(WETHaddr) * 10 gwei / 1 ether;
        P.wantedPrice = 3400;

        vm.expectRevert(Untaken.selector);
        G.takePosition(P);
        P.state = State.Sell;

        vm.expectRevert(MinOneDay.selector);
        G.takePosition(P);

        P.expriresAt = block.timestamp + 2 days;
        P.durationBalance[0] = 5 days;



        P.durationBalance[0] = 10 days;
        P.lper = A0;
        P.taker = A1;

        P.durationBalance[0] = 864000;
        P.durationBalance[1] = 0;
        P.executionPrice = AaveV3Ethereum.ORACLE.getAssetPrice(WETHaddr) * 10 gwei / 1 ether;
        P.wantedPrice = P.executionPrice + P.executionPrice / 3;

        (uint8 v, bytes32 r, bytes32 s) = vm.sign(uint256(678909876567894393495409), keccak256(abi.encode(P)));
        P.LPsig = abi.encodePacked(v, r, s);


        vm.prank(P.taker);
        vm.expectRevert(BadSigP.selector);
        G.takePosition(P);


        vm.warp(block.timestamp + 1);
        vm.expectRevert();
        vm.prank(P.taker);
        G.takePosition(P);

        Position memory Px = P;
        delete Px.executionPrice;
        delete Px.expriresAt;
        delete Px.LPsig;
        delete Px.taker;
        Px.state = State.Staging;
        Px.durationBalance[1] = 0;
        bytes32 signedHash = getEthSignedMessageHash(keccak256(abi.encode(Px)));

        (v, r, s) = vm.sign(A0pvk, signedHash);
        P.LPsig = abi.encodePacked(r, s, v);

        P.state = State.Sell;
        P.durationBalance[0] = 10 days;
        P.lper = A0;
        P.taker = A1;
        P.durationBalance[1] = 0;
        P.expriresAt = block.timestamp + 4 days;
        P.executionPrice = AaveV3Ethereum.ORACLE.getAssetPrice(WETHaddr) * 10 gwei / 1 ether;


        vm.prank(P.taker);
        G.takePosition(P);

        ////////////////////////////////////////////
    }

    function _createPosition(uint8 buyOrSell, uint256 amount, uint256 wantedPMul, uint256 maxD, bool profitable, bool expired ) public returns (bytes32 ph) {

        
        Position memory P;


        
        P.asset = address(AWETH);
        P.durationBalance[0] = maxD; /// min 1 day
        P.taker = A1;
        P.lper = A0;
        P.amount = 3;

        Position memory P0;
        P0.asset = P.asset;
        P0.lper = P.lper;
        P0.durationBalance  = P.durationBalance;
        P0.amount = P.amount;
        P0.state = State.Staging;
        P.executionPrice = AaveV3Ethereum.ORACLE.getAssetPrice(WETHaddr) * 10 gwei / 1 ether;
        P.wantedPrice = P.executionPrice *2;
        P0.wantedPrice = P.wantedPrice;

        
        
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(A0pvk, getEthSignedMessageHash(keccak256(abi.encode(P0))));
        P.LPsig = abi.encodePacked(r,s,v);


        P.state = buyOrSell % 2 == 0 ? State.Buy : State.Sell;
        P.taker = A1; 

        P.expriresAt = block.timestamp + (maxD / 2);



        vm.prank(A1);
        ph = G.takePosition(P);
        console2.log(vm.toString(ph), P.taker,  "---");


        if (expired) vm.warp(block.timestamp + (maxD * 1 days) + 16);
    }




    function testLiquidatePosition() public {
                _addFacilitator();
        G.updateBucketCapacity();
        //////////////////////////////////////
        bytes32 P1hash = _createPosition(2, 3, 3456, 5 days, false, true);
        Position memory P1 = G.getPosition(P1hash);

        uint256 snap1 = vm.snapshot();


        vm.warp(block.timestamp +1);
        vm.expectRevert(OnlyTakerOrExpired.selector);
        G.liquidatePosition(P1hash);

        vm.expectRevert(OnlyTakerOrExpired.selector);
        vm.prank(A2);
        G.liquidatePosition(P1hash);

        //// price unchanged
        vm.prank(A1);
        G.liquidatePosition(P1hash);

        vm.revertTo(snap1);
        P1hash = _createPosition(3, 3, 230, 5 days, true, false);
        P1 = G.getPosition(P1hash);

        /// 2541 -- sell -- 2440 -- profit
        
        
    }

    



}
