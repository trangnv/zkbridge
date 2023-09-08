// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.9;

import {ZKBERC20} from "../Tokens/ZKBERC20.sol";

// TODO: Extract all management into a class since it's shared by both currenty and chain in the same way
contract ZKBVaultManagement {
  // Currencies
  mapping(uint16 => uint8) public supportedCurrencies;
  mapping(uint16 => address) public currenciesContract;
  uint16 private currencyCounter = 0;

  // Chains
  mapping(uint16 => uint8) public supportedChains;
  mapping(uint16 => bytes32) public supportedChainsNames;
  uint16 private chainCounter = 0;

  // currencyId => balance
  mapping(uint16 => uint256) public currencyBalances;
  // mapping per chainId => currencyId => balance
  mapping(uint16 => mapping(uint16 => uint256)) public chainCurrencyBalances;
  // currencyId => reserves balance
  mapping(uint16 => uint256) public currencyReserves;

  // Fees in bips (100 = 0.01%)
  uint16 public feesInBips = 100;

  bool private isMaster = false;

  uint16 chaindId;

  constructor(bool _isMaster, uint16 _chaindId) {
    isMaster = _isMaster;
    chaindId = _chaindId;
  }

  // Layout mapping of the currency support
  enum Actions {
    MINT,
    BURN,
    CLAIM,
    REDEEM,
    TRANSFER,
    DEPOSIT,
    CHANGE_STATUS
  }

  function _getCurrencyContractAddress(uint16 _currency) internal view returns (address) {
    return currenciesContract[_currency];
  }

  function _getCurrencyTicker(uint16 _currency) internal view returns (string memory) {
    return ZKBERC20(_getCurrencyContractAddress(_currency)).name();
  }

  function _getChainName(uint16 _chain) internal view returns (bytes32) {
    return supportedChainsNames[_chain];
  }

  function _currencySupportsAction(uint16 _currency, Actions _action) internal view returns (bool) {
    uint8 status_ = supportedCurrencies[_currency];

    // 0 means not supported
    if (status_ == 0) return false;

    return ((status_ >> uint8(_action)) & 1) == 1;
  }

  function _chainSupportsAction(uint16 _chain, Actions _action) internal view returns (bool) {
    uint8 status_ = supportedChains[_chain];

    // 0 means not supported
    if (status_ == 0) return false;

    return ((status_ >> uint8(_action)) & 1) == 1;
  }

  function _canChangeCurrencyFlag(uint16 _currency, Actions _action) internal view returns (bool) {
    // Can only change flags if the flag is the change status flag or if the CHANGE_STATUS flag is set to true
    // This effectively prevents any change to flags unless CHANGE_STATUS is set to true, acting as a lock
    return (
      _action == Actions.CHANGE_STATUS ||
      _currencySupportsAction(_currency, Actions.CHANGE_STATUS) == true
    );
  }

  function _canChangeChainFlag(uint16 _chain, Actions _action) internal view returns (bool) {
    // Can only change flags if the flag is the change status flag or if the CHANGE_STATUS flag is set to true
    // This effectively prevents any change to flags unless CHANGE_STATUS is set to true, acting as a lock
    return (
      _action == Actions.CHANGE_STATUS ||
      _chainSupportsAction(_chain, Actions.CHANGE_STATUS) == true
    );
  }

  function _addNewSupportedCurrency(uint8 _status, address _contractAddress) internal returns (uint16 currencyId_) {
    currencyId_ = currencyCounter++;
    require(supportedCurrencies[currencyId_] == 0, "This currency has already been set");
    _setCurrencySupportStatus(currencyId_, _status);
    _setCurrencyContractAddress(currencyId_, _contractAddress);
  }

  function _addNewSupportedChain(bytes32 _name, uint8 _status) internal returns (uint16 chainId_) {
    require(isMaster == true, "Can only add chains to the MasterVault");

    chainId_ = chainCounter++; // collect chain counter then immediately increment it

    require(supportedChains[chainId_] == 0, "This chain has already been set");

    _setChainSupportStatus(chainId_, _status);
    supportedChainsNames[chainId_] = _name;
  }

  function _setFees(uint16 _feesInBips) internal {
    feesInBips = _feesInBips;
  }

  // This sets the bits for just 1 Action
  function _setCurrencyActionSupportStatus(uint16 _currency, Actions _action, bool _enabled) internal returns (uint8) {
    require(_canChangeCurrencyFlag(_currency, _action), "Currency does not support changing flags");

    // Need to unit test that
    if (uint8(_action) > 0 && _enabled == true) {
      supportedCurrencies[_currency] |= uint8(1 << uint8(_action));
    } else {
      supportedCurrencies[_currency] &= ~uint8(1 << uint8(_action));
    }

    return supportedCurrencies[_currency];
  }

  // This sets the bits for just 1 Action
  function _setChainActionSupportStatus(uint16 _chain, Actions _action, bool _enabled) internal returns (uint8) {
    require(_canChangeChainFlag(_chain, _action), "Chain does not support changing flags");

    // Need to unit test that
    if (uint8(_action) > 0 && _enabled == true) {
      supportedChains[_chain] |= uint8(1 << uint8(_action));
    } else {
      supportedChains[_chain] &= ~uint8(1 << uint8(_action));
    }

    return supportedChains[_chain];
  }

  // This sets the whole Action status value at once (all the bits)
  function _setCurrencySupportStatus(uint16 _currency, uint8 _status) internal returns (uint8) {
    // TODO: Test this
    // We should only be able to update the full flag set if the currency was not previously supporter (0) or
    // if it is (>0) and the action flag CHANGE_STATUS is set to true, this effectively locks full flag statuses overwrite
    require(
      supportedCurrencies[_currency] == 0 ||
      (
        supportedCurrencies[_currency] > 0 &&
        _currencySupportsAction(_currency, Actions.CHANGE_STATUS) == true
      ), "Currency does not support changing all flags at once");

    supportedCurrencies[_currency] = _status;

    return supportedCurrencies[_currency];
  }

  // This sets the whole Action status value at once (all the bits)
  function _setChainSupportStatus(uint16 _chain, uint8 _status) internal returns (uint8) {
    // TODO: Test this
    // We should only be able to update the full flag set if the currency was not previously supporter (0) or
    // if it is (>0) and the action flag CHANGE_STATUS is set to true, this effectively locks full flag statuses overwrite
    require(
      supportedChains[_chain] == 0 ||
      (
        supportedChains[_chain] > 0 &&
        _currencySupportsAction(_chain, Actions.CHANGE_STATUS) == true
      ), "Chain does not support changing all flags at once");

    supportedChains[_chain] = _status;

    return supportedChains[_chain];
  }

  function _setCurrencyContractAddress(uint16 _currency, address _contractAddress) internal returns (bool) {
    // TODO: Check what conditions could be that this should not be allowed + proper permissions
    currenciesContract[_currency] = _contractAddress;

    if(isMaster == false) {
      // Set the controller on that target contract for satellites
      ZKBERC20(_contractAddress).setController(address(this));
    }

    return true;
  }

  // This is to be used on the satellite chain
  function _mintTokens(address _to, uint16 _currency, uint32 _amount) internal {
    require(isMaster == false, "Tokens can only be minted on the satellite contracts");
    ZKBERC20(currenciesContract[_currency]).mint(_to, _amount);
  }

  function _beforeDeposit(address _depositor, uint16 _currency, uint16 _chainId, uint32 _amount) internal returns (bool) {
    require(isMaster == true, "Funds can only be deposited on the master contract");
    require(supportedChains[_chainId] > 0, "This chain is not supported");
    require(_currencySupportsAction(_currency, Actions.DEPOSIT), "This currency does not support deposit at the moment");
    return true;
  }

  function _afterDeposit(address _depositor, uint16 _currency, uint16 _chainId, uint32 _amount) internal returns (uint32 _finalAmount) {
    uint16 _remainder = uint16((_amount * uint32(feesInBips)) % 10000);
    uint32 _reservesAmount = ((_amount * uint32(feesInBips)) - ((_amount * uint32(feesInBips)) % 10000)) / 10000;
    // Round up
    _reservesAmount += _remainder;

    _finalAmount = _amount - _reservesAmount;

    currencyBalances[_currency] += _amount;
    currencyReserves[_currency] += _reservesAmount;

    return _finalAmount;
  }
}