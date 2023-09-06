// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import "./plonk_vk.sol";
import {IERC20} from "forge-std/interfaces/IERC20.sol";

contract Claim {
    UltraVerifier public verifier;
    IERC20 public immutable token;
    mapping(bytes => bool) public storageHashes;
    mapping(uint => bool) private claimed;
    uint chainID = 1000; // Arbitrum

    constructor(UltraVerifier _verifier, address _token) {
        verifier = _verifier;
        token = IERC20(_token);
    }
    function claim(bytes memory _proof, bytes32[] memory _publicInputs) public {
        require(verifier.verify(_proof, _publicInputs), "Invalid proof");
        require(storageHashes[_publicInputs[1]]);
        token.transfer(msg.sender, uint256(_publicInputs[0]));
    }
}
