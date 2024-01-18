// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {
    Position,
    State,
    IGHOptim,
    Illegal,
    BadSigP,
    InsufficientDuration,
    Untaken,
    MinOneDay
} from "../src/interfaces/IGHOptim.sol";
import {AaveV3Ethereum, IAaveOracle} from "aave-address-book/AaveV3Ethereum.sol";

import {GHOinit} from "./GHOptim.t.sol";
import {VerifySignature} from "../src/utils/VerifySignature.sol";

contract PositionsTest is GHOinit, VerifySignature {
    //  function setUp() public override {
    //     super.setUp();
    //  }

    function test_newPositionF() public {
        Position memory P;
        P.taker = A1;
        P.amount = 2;

        vm.expectRevert(Illegal.selector);
        G.takePosition(P);
        P.asset = address(AWETH);

        P.executionPrice = AaveV3Ethereum.ORACLE.getAssetPrice(WETHaddr) * 10 gwei / 1 ether;
        P.wantedPrice = 6231;

        vm.expectRevert(Untaken.selector);
        G.takePosition(P);
        P.state = State.Sell;

        vm.expectRevert(MinOneDay.selector);
        G.takePosition(P);

        P.expriresAt = block.timestamp + 1 days;
        P.durationBalance[0] = 0.1 days;

        vm.prank(P.taker);
        vm.expectRevert(InsufficientDuration.selector);
        G.takePosition(P);

        P.durationBalance[0] = 10 days;
        P.lper = A0;
        P.taker = A1;

        P.durationBalance[0] = 864000;
        P.durationBalance[1] = 0;
        P.executionPrice = AaveV3Ethereum.ORACLE.getAssetPrice(WETHaddr) * 10 gwei / 1 ether;
        P.wantedPrice = P.executionPrice * 2;

        (uint8 v, bytes32 r, bytes32 s) = vm.sign(uint256(678909876567894393495409), keccak256(abi.encode(P)));
        P.LPsig = abi.encodePacked(v, r, s);

        vm.expectRevert(BadSigP.selector);
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
        P.wantedPrice = P.executionPrice * 2;
        P = P;

        vm.prank(P.taker);
        G.takePosition(P);

        ////////////////////////////////////////////
    }
}
