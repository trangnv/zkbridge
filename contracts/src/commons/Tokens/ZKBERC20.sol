// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.20;

import {ERC20} from "solmate/tokens/ERC20.sol";

contract ZKBERC20 is ERC20 {
  address private controller;
  address private owner;

  constructor(        
    string memory _name,
    string memory _symbol,
    uint8 _decimals,
    address _controller
    // TODO: Add a multiplier for currencies with large denominators, so we can bypass the uint32 limit
  ) ERC20(_name, _symbol, _decimals) {
    controller = _controller;
    owner = msg.sender;
  }

  function setController(address _controller) external onlyAllowed() {
    controller = _controller;
  }

  function mint(address _to, uint32 _amount) external onlyController() {
    _mint(_to, _amount);
  }

  modifier onlyController() {
    require(msg.sender == controller, "Only the controller is allowed to take such actions");
    _;
  }
  
  modifier onlyAllowed() {
    require(msg.sender == controller || msg.sender == owner, "Only high allowance entities can take such action");
    _;    
  }
}