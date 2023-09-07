pragma solidity ^0.8.9;

// Contains all the to / from claim bit packings
import {ZKBridgeUtils} from "../commons/EVM/ZKBridgeUtils.sol";

import {ZKBCurrenAndChainManagement} from "../commons/Admin/ZKBCurrencyAndChainManagement.sol";

contract ZKBridgeMasterVault is ZKBCurrenAndChainManagement {
  address private owner;

  mapping(uint256 => uint256) public claims;
  uint private claimId = 0; // Master NFT counter

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
  // - Handle deposits


}