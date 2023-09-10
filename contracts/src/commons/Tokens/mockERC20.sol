// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.20;

import {ERC20} from "solmate/tokens/ERC20.sol";

contract mockERC20 is ERC20 {
  address private owner;

  constructor(
    string memory _name,
    string memory _symbol,
    uint8 _decimals
  ) ERC20(_name, _symbol, _decimals) {
    owner = msg.sender;
  }

  function mint(address _to, uint32 _amount) external onlyOwner() {
    _mint(_to, _amount);
  }

  modifier onlyOwner() {
    require(msg.sender == owner, "Only high allowance entities can take such action");
    _;
  }
}