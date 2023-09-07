// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.9;

library ZKBridgeUtils {
  // The slot is 256 bits
  //
  // Slot Layout:
  // Amount: 32 bits
  // Currency: 16 bits
  // ChainId: 16 bits
  // ClaimId: 32 bits
  // Address: 160 bits
  function getSlotFrom(uint32 amount, uint16 currency, uint16 chainId, uint32 claimId, address account) pure public returns (uint256 slot) {
    slot = uint256(amount) << 224 | uint256(currency) << 208 | uint256(chainId) << 192 | uint256(claimId) << 160 | uint256(uint160(account));
  }

  function getValuesFrom(uint256 slot) public pure returns (uint32 amount, uint16 currency, uint16 chainId, uint32 claimId, address account) {
    return (
      getAmount(slot),
      getCurrency(slot),
      getChainId(slot),
      getClaimId(slot),
      getAddress(slot)
    );
  }

  function getAmount(uint256 slot) pure internal returns (uint32 amount) {
    amount = uint32(slot >> 256 - 32);
  }

  function getCurrency(uint256 slot) pure internal returns (uint16 currency) {
    currency = uint16((slot << 32) >> 256 - 16);
  }

  function getChainId(uint256 slot) pure internal returns (uint16 chainId) {
    chainId = uint16((slot << 32 + 16) >> 256 - 16);
  }

  function getClaimId(uint256 slot) pure internal returns (uint32 claimId) {
    claimId = uint32((slot << (32 + 16 + 16)) >> (256 - 32));
  }

  function getAddress(uint256 slot) pure internal returns (address address_) {
    address_ = address(uint160((slot << (32 + 16 + 16 + 32)) >> (256 - 160)));
  }
}