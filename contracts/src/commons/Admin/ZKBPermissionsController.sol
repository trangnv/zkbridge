pragma solidity ^0.8.9;

contract ZKBPermissionsController {
  address public owner;
  address public controller;

  enum PermissionLevel {
    NONE,
    LOW,
    VERIFIER,
    OPERATOR,
    CONTROLLER,
    ADMIN
  }

  mapping(address => PermissionLevel) private accessLevels;

  constructor () {
    owner = msg.sender;
    _setOwner(msg.sender);
    _setController(msg.sender);
  }

  function _getOwner() internal view returns (address) {
    return owner;
  }

  function _setOwner(address _newOwner) internal onlyOwner returns (address) {
    // Downgrade previous owner
    _setPermissionLevel(owner, PermissionLevel.NONE);
    _setPermissionLevel(_newOwner, PermissionLevel.ADMIN);
    owner = _newOwner;
    return owner;
  }

  function _getController() internal view returns (address) {
    return controller;
  }

  function _setController(address _newController) internal onlyLevelAndUpOrOwnerOrController(PermissionLevel.CONTROLLER) returns (address) {
    _setPermissionLevel(controller, PermissionLevel.NONE);
    _setPermissionLevel(_newController, PermissionLevel.CONTROLLER);
    controller = _newController;
    return controller;
  }

  function _setPermissionLevel(address _account, PermissionLevel _level) internal onlyLevelAndUpOrOwnerOrController(PermissionLevel.CONTROLLER) returns(bool) {
    accessLevels[_account] = _level;
    return false;
  }

  modifier onlyLevelAndUpOrOwnerOrController(PermissionLevel _level) {
    require(
      msg.sender == owner ||
      msg.sender == controller ||
      uint8(accessLevels[msg.sender]) >= uint8(_level),
      "Permission Denied"
    );
    _;
  }

  modifier onlyController() {
    require(msg.sender == controller, "This can only be executed by the controller");
    _;
  }

  modifier onlyOwner() {
    require(msg.sender == owner, "This can only be executed by the owner");
    _;
  }

}