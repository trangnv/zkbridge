pragma solidity ^0.8.9;

// Contains all the to / from claim bit packings
import {ZKBridgeUtils} from "../commons/EVM/ZKBridgeUtils.sol";

import {ZKBCurrencyAndChainManagement} from "../commons/Admin/ZKBCurrencyAndChainManagement.sol";

import {IERC20} from "forge-std/interfaces/IERC20.sol";

contract ZKBridgeMasterVault is ZKBCurrencyAndChainManagement {
  address private owner;

  // Each claim is laid out as follows (see ZKBridgeUtils)
  // [ Amount, Currency, ChainId, ClaimId,  Address]
  // [32 bits,  16 bits, 16 bits, 32 bits, 160 bits]
  mapping(uint256 => uint256) public claims;
  uint private claimId = 1; // Master NFT counter, ID of the "next" NFT to mint

  // Properties / mappings / enums / structs / events
  //
  // TODO:
  //   - NFT counters
  //   - NFT Mappings
  //   - Re-entrances?

  constructor() {
    owner = msg.sender;
  }

  // Methods
  //
  // TODO:

  function deposit(uint32 _amount, uint16 _currency, uint16 _chainId, uint32 _claimId, address _account) external {
    address tokenToDeposit = getCurrencyContractAddress(_currency);
    require(currencySupportsAction(_currency, Actions.DEPOSIT), "This currency does not support deposit at the moment");

    require(IERC20(tokenToDeposit).transferFrom(msg.sender, address(this), _amount) == true, "Transfer seems to have failed");

    claims[claimId] = ZKBridgeUtils.getSlotFrom(_amount, _currency, _chainId, _claimId, _account);
    claimId++;
  }

}