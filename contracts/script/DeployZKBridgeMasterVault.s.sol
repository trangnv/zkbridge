// SPDX-License-Identifier: MIT
pragma solidity >=0.8.20;

import {Script} from "forge-std/Script.sol";
import {ZKBridgeMasterVault} from "../src/master/ZKBridgeMasterVault.sol";

contract DeployZKBridgeMasterVault is Script {
    function run() external returns (ZKBridgeMasterVault) {
        vm.startBroadcast();

        ZKBridgeMasterVault vault = new ZKBridgeMasterVault();

        vm.stopBroadcast();
        return vault;
    }
}