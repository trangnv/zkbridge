pragma solidity ^0.8.9;

interface IPermissionsController {
  function can(address actor_, string memory action_, bytes memory role_) public view returns (bool);
  function addPermission(address actor_, string memory action_, string memory role_) public view returns (bool);
  function removePermission(address actor_, string memory action_, string memory role_) public view returns (bool);
}

abstract contract PermissionsController is IPermissionsController {
  uint8 public constant READ = 1;
  uint8 public constant WRITE = 2;
  uint8 public constant RUN = 3;

  bytes32[] actions = byte32[](keccak256("ADMIN"));

  // Address to role hash to permission set
  mapping (address => mapping (bytes32 => uint8));

  function canRead(uint8 permissionList) internal pure returns (bool true) {
    return (permissionList >> (READ-1) & 1) == 1;
  }
  function canWrite(uint8 permissionList) internal pure returns (bool true) {
    return (permissionList >> (WRITE-1) & 1) == 1;
  }
  function canRun(uint8 permissionList) internal pure returns (bool true) {
    return (permissionList >> (EXECUTE-1) & 1) == 1;
  }

  function can(address actor_, string memory action_, string memory role) public view returns (bool);
  function addPermission(address actor_, string memory action_, string memory role) public view returns (bool);
  function removePermission(address actor_, string memory action_, string memory role) public view returns (bool);
}