// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import {UltraVerifier} from "./plonk_vk.sol";

import {ZKBridgeUtils} from "../commons/EVM/ZKBridgeUtils.sol";

import {ZKBVaultManagement} from "../commons/Admin/ZKBVaultManagement.sol";

contract ZKBridgeSatellite is ZKBVaultManagement {
  UltraVerifier public verifier;

  mapping(uint32 => bool) private claimHasBeenClaimed;

  uint16 public internalChainId;
  bytes32 public internalChainName;

  // Marks the ZKBVaultManagement as satellite (isMaster = false)
  constructor(UltraVerifier _verifier, uint16 _chainId) ZKBVaultManagement(false, _chainId) {
    verifier = _verifier;
    internalChainId = _chainId;
  }

  function claim(bytes memory _proof, bytes32[] memory _publicInputs) public {
    require(verifier.verify(_proof, _publicInputs), "Invalid proof");

    (uint32 amount, uint16 currency, uint16 _chainId, uint32 claimId, address account) = ZKBridgeUtils.getValuesFrom(uint256(_publicInputs[0]));

    require(internalChainId == _chainId, "This claim is not supposed to be on this chain");
    require(claimHasBeenClaimed[claimId] == false, "Claim has already been claimed");

    _mintTokens(account, currency, amount);
  }
}
