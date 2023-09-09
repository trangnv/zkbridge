// SPDX-License-Identifier: MIT

import {Script, console} from "forge-std/Script.sol";
import {Test, console} from "forge-std/Test.sol";
import {ZKBridgeMasterVault} from "../src/master/ZKBridgeMasterVault.sol";
import {DeployZKBridgeMasterVault} from "../script/DeployZKBridgeMasterVault.s.sol";

import {mockERC20} from "../src/commons/Tokens/mockERC20.sol";
import {ERC20} from "solmate/tokens/ERC20.sol";


contract TestZKBridgeMasterVault is Test {
    ZKBridgeMasterVault public vault;
    address public constant USER = address(1);
    ERC20 public erc20;


    function setUp() external {
        vm.startPrank(USER);
        erc20 = new mockERC20("Test", "TST", 18);
        // DeployZKBridgeMasterVault deployer = new DeployZKBridgeMasterVault();
        // vault = deployer.run();
        vault = new ZKBridgeMasterVault();
        vm.stopPrank();
        

    }
    function testAddCurrency() external {
        vm.startPrank(USER);
        vault.addSupportedCurrency(address(erc20));
        vm.stopPrank();
    }
}