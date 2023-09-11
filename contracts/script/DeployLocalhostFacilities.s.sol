// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.20;

import {Script} from "forge-std/Script.sol";

import {ZKBridgeMasterVault} from "../src/master/ZKBridgeMasterVault.sol";
import {ZKBridgeSatellite, UltraVerifier} from "../src/satellites/ZKBridgeSatellite.sol";
import {mockERC20} from "../src/commons/Tokens/mockERC20.sol";
import {ZKBERC20} from "../src/commons/Tokens/ZKBERC20.sol";

contract DeployLocalhostFacilities is Script {
  address payable nick = payable(0x03D0e96BB554fFe4e7d189f554907BA17a8C220b);
  address payable runner = payable(0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266);

  function run() public {
    vm.startBroadcast();

    UltraVerifier ultraVerifier = new UltraVerifier();
    ZKBridgeMasterVault zkbMasterVault = new ZKBridgeMasterVault();
    uint16 zkSatelliteChainId = zkbMasterVault.addSupportedChain("zkSync Testnet");
    ZKBridgeSatellite zkSatellite = new ZKBridgeSatellite(ultraVerifier, address(this), zkSatelliteChainId);
    ZKBERC20 zkbERC20_1 = new ZKBERC20("zkbmockERC20", "zkbmERC20", 8, address(zkSatellite));

    mockERC20 mockERC20_1 = new mockERC20("mockERC20", "mERC", 8);
    mockERC20_1.mint(nick, 4294967295);
    mockERC20_1.approve(nick, 1000e8);

    nick.transfer(100 ether);

    zkbMasterVault.addSupportedCurrency(address(mockERC20_1));
    zkSatellite.addSupportedCurrency(address(zkbERC20_1));

    vm.stopBroadcast();
  }

  function run_ZKBridgeMasterVaultOnly() external returns (ZKBridgeMasterVault) {
    vm.startBroadcast();

    ZKBridgeMasterVault vault = new ZKBridgeMasterVault();

    vm.stopBroadcast();
    return vault;
  }
}