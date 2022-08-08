// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "openzeppelin-contracts/contracts/utils/cryptography/SignatureChecker.sol";

error WrongSignature();

contract Bytes32 {

    mapping(address => bytes32) public heads;
    mapping(address => uint256) public nonces;

    event Publication(address indexed key, bytes32 head);

    function publish(bytes32 head) public {
        _publish(msg.sender, head);
    }

    function publishFor(address signer, bytes32 head, bytes memory signature) public {
        bytes32 hash = keccak256(abi.encodePacked(head, nonces[signer]++));
        bytes32 message = ECDSA.toEthSignedMessageHash(hash);
        if (!SignatureChecker.isValidSignatureNow(signer, message, signature)) {
            revert WrongSignature();
        }
        _publish(signer, head);
    }


    function _publish(address key, bytes32 head) internal {
        heads[key] = head;
        emit Publication(key, head);
    }
}
