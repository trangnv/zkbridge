// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.20;

import {Script} from "forge-std/Script.sol";

import {ZKBridgeSatellite, UltraVerifier} from "../src/satellites/ZKBridgeSatellite.sol";
import {ZKBERC20} from "../src/commons/Tokens/ZKBERC20.sol";

contract DeployZKBridgeSatellite is Script {
  function run() public {
    vm.startBroadcast();

    UltraVerifier ultraVerifier = new UltraVerifier();
    uint16 zkSatelliteChainId = 2;
    ZKBridgeSatellite zkSatellite = new ZKBridgeSatellite(ultraVerifier, address(this), zkSatelliteChainId);
    ZKBERC20 zkbERC20_1 = new ZKBERC20("zkbmockERC20", "zkbmERC20", 18, address(zkSatellite));
    zkSatellite.addSupportedCurrency(address(zkbERC20_1));

    vm.stopBroadcast();
  }
}