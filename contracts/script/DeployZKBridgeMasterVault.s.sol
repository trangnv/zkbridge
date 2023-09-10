// SPDX-License-Identifier: MIT
pragma solidity >=0.8.20;

import {Script} from "forge-std/Script.sol";

import {ZKBridgeMasterVault} from "../src/master/ZKBridgeMasterVault.sol";
import {ZKBridgeSatellite, UltraVerifier} from "../src/satellites/ZKBridgeSatellite.sol";
import {mockERC20} from "../src/commons/Tokens/mockERC20.sol";
import {ZKBERC20} from "../src/commons/Tokens/ZKBERC20.sol";

contract DeployZKBridgeMasterVault is Script {
  function run() public {
    vm.startBroadcast();

    UltraVerifier ultraVerifier = new UltraVerifier();
    ZKBridgeMasterVault zkbMasterVault = new ZKBridgeMasterVault();
    uint16 zkSatelliteChainId = zkbMasterVault.addSupportedChain("zkSync Testnet");

    mockERC20_1 = new mockERC20("mockERC20", "mERC", 18);

    zkbMasterVault.addSupportedCurrency(address(mockERC20_1));

    vm.stopBroadcast();
  }

  function run_ZKBridgeMasterVaultOnly() external returns (ZKBridgeMasterVault) {
      vm.startBroadcast();

      ZKBridgeMasterVault vault = new ZKBridgeMasterVault();

      vm.stopBroadcast();
      return vault;
  }
}