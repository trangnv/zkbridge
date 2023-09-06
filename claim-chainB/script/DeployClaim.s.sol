// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script, console2} from "forge-std/Script.sol";
import {IERC20} from "forge-std/interfaces/IERC20.sol";
import {UltraVerifier} from "../src/plonk_vk.sol";
import {Claim} from "../src/Claim.sol";

contract DeployClaim is Script {
    address public immutable noir_contract_address  = 0xFEa16a8Cf9b655d6497769f601E5b2c3C3c7E962;
    function setUp() public {}

    function run() public returns (Claim){
        vm.startBroadcast();
        
        UltraVerifier verifier = new UltraVerifier();
        Claim claim = new Claim(verifier, noir_contract_address);

        vm.stopBroadcast();

        return claim;
    }
}
