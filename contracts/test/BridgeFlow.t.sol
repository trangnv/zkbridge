// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console2 as console} from "forge-std/Test.sol";

import {ZKBridgeMasterVault} from "../src/master/ZKBridgeMasterVault.sol";
import {ZKBridgeSatellite, UltraVerifier} from "../src/satellites/ZKBridgeSatellite.sol";
import {mockERC20} from "../src/commons/Tokens/mockERC20.sol";
import {ZKBERC20} from "../src/commons/Tokens/ZKBERC20.sol";

contract BridgeFlow is Test {
  ZKBridgeMasterVault public zkbMasterVault;
  ZKBridgeSatellite public zkSatellite;
  mockERC20 public mockERC20_1;
  ZKBERC20 public zkbERC20_1;
  UltraVerifier public ultraVerifier;
  address public constant USER = address(1);

  function setUp() public {
    ultraVerifier = new UltraVerifier();
    zkbMasterVault = new ZKBridgeMasterVault();
    uint16 zkSatelliteChainId = zkbMasterVault.addSupportedChain("zkSync Testnet");
    zkSatellite = new ZKBridgeSatellite(ultraVerifier, address(this), zkSatelliteChainId);

    mockERC20_1 = new mockERC20("mockERC20", "mERC", 18);
    // Set this up so this contract is the controller
    zkbERC20_1 = new ZKBERC20("zkbmockERC20", "zkbmERC20", 18, address(zkSatellite));

    zkbMasterVault.addSupportedCurrency(address(mockERC20_1));
    zkSatellite.addSupportedCurrency(address(zkbERC20_1));
  }

  function test_AddSupportedChainOnMaster() public {
    uint16 chainId = zkbMasterVault.addSupportedChain("zkSync Testnet");
    string memory chainName = zkbMasterVault.getChainName(chainId);
    assertGt(chainId, 0);
    assertEq(chainName, "zkSync Testnet");
  }

  function test_GetSupportedChainOnMaster() public {
    uint256 sizeBefore = zkbMasterVault.getSupportedChains().length;
    uint16 chainId = zkbMasterVault.addSupportedChain("zkSync Testnet");
    uint256 sizeAfter = zkbMasterVault.getSupportedChains().length;
    assertGt(chainId, 0);
    assertGt(sizeAfter, sizeBefore);
  }

  function test_AddSupportedChainOnSatellite() public {
    // Chains are not allowed to add on Satellites
    vm.expectRevert();
    zkSatellite.addSupportedChain("zkSync Testnet");
  }

  function test_AddSupportedCurrencyOnMaster() public {
    uint16 currencyId = zkbMasterVault.addSupportedCurrency(address(mockERC20_1));
    string memory currencyName = zkbMasterVault.getCurrencyName(currencyId);
    console.logString(currencyName);
    assertEq(currencyName, mockERC20_1.name());
  }

  function test_AddSupportedCurrencyOnSatellite() public {
    uint16 currencyId = zkSatellite.addSupportedCurrency(address(zkbERC20_1));
    string memory currencyName = zkSatellite.getCurrencyName(currencyId);
    console.logString(currencyName);
    assertEq(currencyName, zkbERC20_1.name());
  }

  function test_GetSupportedCurrenciesOnMaster() public {
    zkbMasterVault.addSupportedCurrency(address(mockERC20_1));
    string[] memory supportedCurrencies = zkbMasterVault.getSupportedCurrencies();
    assertGt(supportedCurrencies.length, 0);
  }

  function test_GetSupportedCurrenciesOnSatellite() public {
    zkSatellite.addSupportedCurrency(address(zkbERC20_1));
    string[] memory supportedCurrencies = zkSatellite.getSupportedCurrencies();
    assertGt(supportedCurrencies.length, 0);
  }

  function test_Init() public {
    string[] memory supportedChains = zkbMasterVault.getSupportedChains();
    console.logString("Chains Supported: ");
    console.logUint(supportedChains.length);
    for(uint8 x = 0; x < supportedChains.length; x++) {
      console.logString(supportedChains[x]);
    }
  }

  function test_Increment() public {
//    assertEq(counter.number(), 1);
  }

  function test_Deposit() public {
    uint32 amount = 100;
    mockERC20_1.mint(USER, amount);
    mockERC20_1.approve(address(zkbMasterVault), amount);

    uint16 chainId = zkbMasterVault.addSupportedChain("zkSync Testnet");
    uint16 currencyId = zkbMasterVault.addSupportedCurrency(address(mockERC20_1));

    zkbMasterVault.deposit(amount, currencyId, chainId, USER);
  }

/*  function testFuzz_SetNumber(uint256 x) public {
    counter.setNumber(x);
    assertEq(counter.number(), x);
  }*/
}
