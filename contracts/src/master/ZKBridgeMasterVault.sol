pragma solidity ^0.8.9;

// Contains all the to / from claim bit packings
import {ZKBridgeUtils} from "../commons/EVM/ZKBridgeUtils.sol";

import {ZKBVaultManagement} from "../commons/Admin/ZKBVaultManagement.sol";

import {IERC20} from "forge-std/interfaces/IERC20.sol";

import {ReentrancyGuard} from "solmate/utils/ReentrancyGuard.sol";

contract ZKBridgeMasterVault is ZKBVaultManagement, ReentrancyGuard {
  address private owner;

  // Each claim is laid out as follows (see ZKBridgeUtils)
  // [ Amount, Currency, ChainId, ClaimId,  Address]
  // [32 bits,  16 bits, 16 bits, 32 bits, 160 bits]
  mapping(uint256 => uint256) public claims;
  uint private claimId = 1; // Master NFT counter, ID of the "next" NFT to mint

  // Properties / mappings / enums / structs / events
  //
  // TODO:
  //   - Re-entrances?

  event ClaimCreated(address indexed from, uint16 indexed currency, uint16 internalChainId, uint32 indexed finalAmount, uint32 fees);

  // Marks the ZKBVaultManagement as master
  constructor() ZKBVaultManagement(true) {
    owner = msg.sender;
  }

  // Methods
  //
  // TODO:

  function deposit(uint32 _amount, uint16 _currency, uint16 _chainId, address _account) nonReentrant external {
    address tokenAddress = _getCurrencyContractAddress(_currency);

    // Make sure this should happen
    require(_beforeDeposit(_account, _currency, _chainId, _amount) == true, "Deposit cannot happen");

    require(IERC20(tokenAddress).transferFrom(msg.sender, address(this), _amount) == true, "Transfer seems to have failed");

    // Take notes of what happened, take a small amount as a fee, and build the claim
    uint32 finalAmount = _afterDeposit(_account, _currency, _chainId, _amount);

    claims[claimId] = ZKBridgeUtils.getSlotFrom(finalAmount, _currency, _chainId, _claimId, _account);
    claimId++;

    emit ClaimCreated(_account, _currency, _chainId, _amount, finalAmount);
  }

  // TODO:
  // - Public APIs for claiming withdrawals
  // - Public APIs for pulling from the reserves
  // - Public APIs for updating chains and currencies support flags and names
  // - Public APIs for listing supported chains and their related names
  // - Public APIs for listing supported currencies and their related tickers
  // - Public permissioned APIs to set the fees
}