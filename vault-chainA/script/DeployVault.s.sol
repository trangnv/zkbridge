// SPDX-License-Identifier: MIT
pragma solidity >=0.8.20;

import {Script} from "forge-std/Script.sol";
import {Vault} from "../src/Vault.sol";

contract DeployVault is Script {
    address public immutable noir_contract_address = 0x0041ff33E47eAE38ab8B9A1C2070E279d5AAf211;
    function run() external returns (Vault) {
        vm.startBroadcast();

        Vault vault = new Vault(noir_contract_address);

        vm.stopBroadcast();
        return vault;
    }
}

