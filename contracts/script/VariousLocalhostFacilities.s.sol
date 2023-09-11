// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.20;

import {Script} from "forge-std/Script.sol";

import {ZKBridgeMasterVault} from "../src/master/ZKBridgeMasterVault.sol";
import {ZKBridgeSatellite, UltraVerifier} from "../src/satellites/ZKBridgeSatellite.sol";
import {mockERC20} from "../src/commons/Tokens/mockERC20.sol";
import {ZKBERC20} from "../src/commons/Tokens/ZKBERC20.sol";

contract VariousLocalhostFacilities is Script {
    address payable nick = payable(0x03D0e96BB554fFe4e7d189f554907BA17a8C220b);
    address payable nickMM = payable(0xAE093Ac1B4B83c1b8d8D2A5D3b9436f873959a28);
    address payable runner = payable(0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266);

    // TODO before run: Update address
    mockERC20 existingMockERC20 = mockERC20(0x82e01223d51Eb87e16A03E24687EDF0F294da6f1);
    ZKBERC20 existingZKBERC20 = ZKBERC20(0xCD8a1C3ba11CF5ECfa6267617243239504a98d90);

    function run() public {
        vm.startBroadcast();

//        existingMockERC20.mint(nickMM, 4294967295);
        nickMM.transfer(100 ether);

        vm.stopBroadcast();
    }
}