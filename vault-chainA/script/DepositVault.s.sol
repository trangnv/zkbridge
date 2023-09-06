// SPDX-License-Identifier: MIT
pragma solidity >=0.8.20;

import {Script} from "forge-std/Script.sol";
import {Vault} from "../src/Vault.sol";
import {IERC20} from "forge-std/interfaces/IERC20.sol";

contract DepositVault is Script {
    address public immutable vault_contract_address = 0xad3a56d718aCbD139f50A38558d0a7C2eFdf4858;
    address public immutable noir_contract_address = 0x0041ff33E47eAE38ab8B9A1C2070E279d5AAf211;
    uint256 amount = 1000 ether;
    uint256 public depositorKey;
    function run() external {
        depositorKey = vm.envUint("PRIVATE_KEY");
        
        vm.startBroadcast(depositorKey);

        IERC20(noir_contract_address).approve(vault_contract_address, amount);
        Vault(vault_contract_address).deposit(amount);

        vm.stopBroadcast();
    }
}