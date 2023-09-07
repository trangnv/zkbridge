// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import "./plonk_vk.sol";

import {ZKBridgeUtils} from "../commons/EVM/ZKBridgeUtils.sol";

import {ZKBCurrenAndChainManagement} from "../commons/Admin/ZKBCurrencyAndChainManagement.sol";

contract ZKBridgeSatellite is ZKBCurrenAndChainManagement {
  UltraVerifier public verifier;

  mapping(uint32 => bool) private claimHasBeenClaimed;

  uint16 chainId;

  constructor(UltraVerifier _verifier, uint16 _chainId) {
    verifier = _verifier;
    chainId = _chainId;
  }

  function claim(bytes memory _proof, uint256[] memory _publicInputs) public {
    require(verifier.verify(_proof, _publicInputs), "Invalid proof");

    (uint32 amount, uint16 currency, uint16 _chainId, uint32 claimId, address account) = ZKBridgeUtils.getValuesFrom(_publicInputs[0]);

    require(chainId == _chainId, "This claim is not supposed to be claimed on this chain");
    require(claimHasBeenClaimed[claimId] == false, "Claim has already been claimed");

    _mintTokens(account, currency, amount);
  }
}
