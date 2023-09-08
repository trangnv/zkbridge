pragma solidity ^0.8.9;

interface IZKBPermissionsController {
  function can(address actor_, string memory action_, bytes memory role_) external view returns (bool);
  function addPermission(address actor_, string memory action_, string memory role_) external view returns (bool);
  function removePermission(address actor_, string memory action_, string memory role_) external view returns (bool);
}

abstract contract ZKBPermissionsController is IZKBPermissionsController {
  address public owner;
  address public controller;

  enum Permissions {
    NONE,
    READ,
    WRITE,
    RUN
  }

  // Address to role hash to permission set
  mapping (address => mapping (bytes32 => uint8)) permissionMap;

  constructor () {
    owner = msg.sender;
  }

  function canRead(uint8 permissionList) pure internal returns (bool) {
    return (permissionList >> (uint8(Permissions.READ)-1) & 1) == 1;
  }
  function canWrite(uint8 permissionList) internal pure returns (bool) {
    return (permissionList >> (uint8(Permissions.WRITE)-1) & 1) == 1;
  }
  function canRun(uint8 permissionList) internal pure returns (bool) {
    return (permissionList >> (uint8(Permissions.RUN)-1) & 1) == 1;
  }

  function can(address actor_, string memory action_, string memory role) public virtual view returns (bool);
  function addPermission(address actor_, string memory action_, string memory role) public virtual view returns (bool);
  function removePermission(address actor_, string memory action_, string memory role) public virtual view returns (bool);
}