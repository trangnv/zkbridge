// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.9;

import {ZKBERC20} from "../Tokens/ZKBERC20.sol";

contract ZKBCurrencyAndChainManagement {
  // currencyId to permission layout, 0 = not supported
  mapping(uint16 => uint8) private supportedCurrencies;
  mapping(uint16 => address) private currenciesContract;

  // Layout mapping of the currency support
  enum Actions {
    MINT,
    BURN,
    CLAIM,
    REDEEM,
    TRANSFER,
    DEPOSIT
  }

  function getCurrencyContractAddress(uint16 _currency) public view returns (address) {
    return currenciesContract[_currency];
  }

  function currencySupportsAction(uint16 _currency, Actions _action) public view returns (bool) {
    uint8 status_ = supportedCurrencies[_currency];

    // 0 means not supported
    if (status_ == 0) return false;

    return ((status_ >> uint8(Actions.DEPOSIT)) & 1) == 1;
  }

  // Action comes from the constants MINT, BURN, CLAIM, REDEEM,
  function _setCurrencyStatus(uint16 _currency, Actions _action, bool _enabled) internal returns (uint8) {
    // Need to unit test that
    if (uint8(_action) > 0 && _enabled == true) {
      supportedCurrencies[_currency] |= uint8(1 << uint8(_action));
    } else {
      supportedCurrencies[_currency] &= ~uint8(1 << uint8(_action));
    }

    return supportedCurrencies[_currency];
  }

  function _setCurrencyContractAddress(uint16 _currency, address _contractAddress) internal returns (bool) {
    // TODO: Check what conditions could be that this should not be allowed + proper permissions
    currenciesContract[_currency] = _contractAddress;
    return true;
  }

  function _mintTokens(address _to, uint16 _currency, uint32 _amount) internal {
    ZKBERC20(currenciesContract[_currency]).mint(_to, _amount);
  }
}