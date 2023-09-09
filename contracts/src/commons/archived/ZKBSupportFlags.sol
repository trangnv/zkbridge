// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.9;

// This would work but does not have any permission handling. It's cleaner code-wise, but much harder blockchain-wise
// It's untested but should be working.

// Not in use at the moment
contract ZKBSupportFlags {
  // currencyId to permission layout, 0 = not supported
  mapping(uint16 => uint8) private supportStorage;

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

  function _supportsAction(uint16 _item, Actions _action) public view returns (bool) {
    uint8 status_ = supportStorage[_item];

    // 0 means not supported
    if (status_ == 0) return false;

    return ((status_ >> uint8(_action)) & 1) == 1;
  }

  function _canChangeFlag(uint16 _currency, Actions _action) public view returns (bool) {
    // Can only change flags if the flag is the change status flag or if the CHANGE_STATUS flag is set to true
    // This effectively prevents any change to flags unless CHANGE_STATUS is set to true, acting as a lock
    return (
      _action == Actions.CHANGE_STATUS ||
      _supportsAction(_currency, Actions.CHANGE_STATUS) == true
    );
  }

  // Action comes from the constants MINT, BURN, CLAIM, REDEEM, TRANSFER, DEPOSIT
  function _setActionSupportStatus(uint16 _item, Actions _action, bool _enabled) internal returns (uint8) {
    require(_canChangeFlag(_item, _action), "Does not support changing flags");

    // Need to unit test that
    if (uint8(_action) > 0 && _enabled == true) {
      supportStorage[_item] |= uint8(1 << uint8(_action));
    } else {
      supportStorage[_item] &= ~uint8(1 << uint8(_action));
    }

    return supportStorage[_item];
  }

  // Action comes from the constants MINT, BURN, CLAIM, REDEEM, TRANSFER, DEPOSIT
  function _setSupportStatus(uint16 _item, uint8 _status) internal returns (uint8) {
    // TODO: Test this
    // We should only be able to update the full flag set if the currency was not previously supporter (0) or
    // if it is (>0) and the action flag CHANGE_STATUS is set to true, this effectively locks full flag statuses overwrite
    require(
      supportStorage[_item] == 0 ||
      (
        supportStorage[_item] > 0 &&
        _supportsAction(_item, Actions.CHANGE_STATUS) == true
      ), "Currency does not support changing all flags at once");

    supportStorage[_item] = _status;

    return supportStorage[_item];
  }
}