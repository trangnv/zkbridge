// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.20;

import {Script} from "forge-std/Script.sol";

import {ZKBridgeMasterVault} from "../src/master/ZKBridgeMasterVault.sol";
import {ZKBridgeSatellite, UltraVerifier} from "../src/satellites/ZKBridgeSatellite.sol";
import {mockERC20} from "../src/commons/Tokens/mockERC20.sol";
import {ZKBERC20} from "../src/commons/Tokens/ZKBERC20.sol";

contract DeployZKBridgeMasterVault is Script {
  function run() public {
    vm.startBroadcast();

    ZKBridgeMasterVault zkbMasterVault = new ZKBridgeMasterVault();
    zkbMasterVault.addSupportedChain("zkSync Testnet");

    mockERC20 mockERC20_1 = new mockERC20("mockERC20", "mERC", 18);

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