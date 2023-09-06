// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script, console2} from "forge-std/Script.sol";
import {IERC20} from "forge-std/interfaces/IERC20.sol";
import {UltraVerifier} from "../src/plonk_vk.sol";
import {Claim} from "../src/Claim.sol";

contract ClaimScript is Script {
    address public immutable claim_contract_address  = 0xDfA320DF0933daA9dB4941e30856E233b818DB59;
    // address public immutable noir_contract_address = 0xFEa16a8Cf9b655d6497769f601E5b2c3C3c7E962;
    
    bytes public proofBytes;
    bytes32[] publicInputs = new bytes32[](1);


    function setUp() public {
        string memory proof = vm.readLine("./data/p.proof");
        proofBytes = vm.parseBytes(proof);

        string memory json = vm.readFile("./data/public_inputs.json");
        bytes memory  publicValue = vm.parseJson(json, ".return");
        publicInputs[0] = bytes32(publicValue);
    }

    function run() public {
        vm.startBroadcast();

        Claim claim = Claim(claim_contract_address);
        // uint256 amount = uint256(publicInputs[0]);
        // IERC20(noir_contract_address).approve(claim_contract_address, amount);

        claim.claim(proofBytes, publicInputs);

        vm.stopBroadcast();
    }
}