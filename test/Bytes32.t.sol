// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../src/Bytes32.sol";

import "openzeppelin-contracts/contracts/utils/cryptography/SignatureChecker.sol";

contract ContractTest is Test {
    Bytes32 private b32;
    address alice;
    uint256 nonce;
    bytes32 head;
    bytes signature;

    function setUp() public {
        b32 = new Bytes32();
        alice = vm.addr(1);
        nonce = b32.nonces(alice);
        head = keccak256("test publish");
        bytes32 hash = keccak256(abi.encodePacked(head, nonce));
        bytes32 message = ECDSA.toEthSignedMessageHash(hash);
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(1, message);
        signature = abi.encodePacked(r, s, v);

        vm.recordLogs();
    }

    function testSanity() public {
        assertEq(nonce, 0);
        assertEq(b32.heads(address(this)), 0);
        assertEq(b32.heads(alice), 0);
    }

    function testSelfPublish() public {
        b32.publish(head);
        bytes32 newHead = b32.heads(address(this));
        assertEq(newHead, head);
        
        Vm.Log[] memory entries = vm.getRecordedLogs();
        assertEq(entries.length, 1);
        assertEq(entries[0].topics[0], keccak256("Publication(address,bytes32)"));
        assertEq(entries[0].topics[1], bytes32(abi.encode(address(this))));
        assertEq(abi.decode(entries[0].data, (bytes32)), head);
    }

    function testPublishFor() public {

        b32.publishFor(alice, head, signature);
        
        assertEq(b32.nonces(alice), 1);
        assertEq(b32.heads(alice), head);

        Vm.Log[] memory entries = vm.getRecordedLogs();
        assertEq(entries.length, 1);
        assertEq(entries[0].topics[0], keccak256("Publication(address,bytes32)"));
        assertEq(entries[0].topics[1], bytes32(abi.encode(alice)));
        assertEq(abi.decode(entries[0].data, (bytes32)), head);

        // new publish
        vm.recordLogs();
        head = keccak256("test publish 2");
        nonce = b32.nonces(alice);
        bytes32 hash = keccak256(abi.encodePacked(head, nonce));
        bytes32 message = ECDSA.toEthSignedMessageHash(hash);
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(1, message);
        signature = abi.encodePacked(r, s, v);
        b32.publishFor(alice, head, signature);
        
        assertEq(b32.nonces(alice), 2);
        assertEq(b32.heads(alice), head);

        entries = vm.getRecordedLogs();
        assertEq(entries.length, 1);
        assertEq(entries.length, 1);
        assertEq(entries[0].topics[0], keccak256("Publication(address,bytes32)"));
        assertEq(entries[0].topics[1], bytes32(abi.encode(alice)));
        assertEq(abi.decode(entries[0].data, (bytes32)), head);

        // replay should fail:
        vm.expectRevert(WrongSignature.selector);
        b32.publishFor(alice, head, signature);

    }
}
