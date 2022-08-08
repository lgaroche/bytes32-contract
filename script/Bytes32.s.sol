// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Script.sol";
import "openzeppelin-contracts/contracts/utils/cryptography/SignatureChecker.sol";

contract ContractScript is Script {
    function setUp() public {}

    function run() public {

        uint256 nonce = 5;
        bytes32 head = keccak256("test");
        bytes32 hash = keccak256(abi.encodePacked(head, nonce));
        bytes32 message = ECDSA.toEthSignedMessageHash(hash);
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80, message);
        console2.logAddress(vm.addr(0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80));
        bytes memory signature = abi.encodePacked(r, s, v);
        console2.logBytes(signature);

        vm.broadcast();
    }
}
