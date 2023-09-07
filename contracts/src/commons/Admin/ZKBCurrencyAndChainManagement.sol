// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.9;

import {ZKBERC20} from "../Tokens/ZKBERC20.sol";

abstract contract ZKBCurrenAndChainManagement {
  // currencyId to permission layout, 0 = not supported
  mapping(uint16 => uint8) private supportedCurrencies;
  mapping(uint16 => address) private currenciesContract;

  // Layout mapping of the currency support
  uint8 private constant MINT = 1;
  uint8 private constant BURN = 2;
  uint8 private constant CLAIM = 3;
  uint8 private constant REDEEM = 4;
  uint8 private constant TRANSFER = 5;

  function _setCurrencyStatus(uint16 currency_, uint8 action_, bool enabled) internal returns (uint8) {
    // Need to unit test that
    if(action_ > 0 && enabled == true) {
      supportedCurrencies[currency_] |= uint8(1 << action_);
    } else {
      supportedCurrencies[currency_] &= ~uint8(1 << action_);
    }

    return supportedCurrencies[currency_];
  }

  function _setCurrencyContractAddress(uint16 currency_, address contractAddress_) internal returns (bool) {
    // TODO: Check what conditions could be that this should not be allowed + proper permissions
    currenciesContract[currency_] = contractAddress_;
    return true;
  }

  function _mintTokens(address _to, uint16 _currency, uint32 _amount) internal returns (bool) {
    return ZKBERC20(currenciesContract[_currency]).mint(_to, _amount);
  }
}