pragma solidity ^0.8.9;

import {IERC20} from "forge-std/interfaces/IERC20.sol";
import {ZKBridgeUtils} from "../commons/EVM/ZKBridgeUtils.sol";

import {ReentrancyGuard} from "solmate/utils/ReentrancyGuard.sol";
import {ZKBPermissionsController} from "../commons/Admin/ZKBPermissionsController.sol";
import {ZKBVaultManagement} from "../commons/Admin/ZKBVaultManagement.sol";

contract ZKBridgeMasterVault is ReentrancyGuard, ZKBPermissionsController, ZKBVaultManagement {
  // Each claim is laid out as follows (see ZKBridgeUtils)
  // [ Amount, Currency, ChainId, ClaimId,  Address]
  // [32 bits,  16 bits, 16 bits, 32 bits, 160 bits]
  mapping(uint32 => uint256) public claims;
  uint32 private claimId = 0; // Master NFT counter, ID of the "next" NFT to mint

  event ClaimReady(address indexed from, uint16 indexed currency, uint16 internalChainId, uint32 indexed finalAmount, uint32 fees);

  // Marks the ZKBVaultManagement as master, chainId 1
  constructor()  ZKBPermissionsController() ZKBVaultManagement(true, 1) {
  }

  function deposit(uint32 _amount, uint16 _currency, uint16 _chainId, address _account) nonReentrant external {
    address tokenAddress = _getCurrencyContractAddress(_currency);

    // Make sure this should happen
    require(_beforeDeposit(_account, _currency, _chainId, _amount) == true, "Deposit cannot happen");

    require(IERC20(tokenAddress).transferFrom(msg.sender, address(this), _amount) == true, "Transfer seems to have failed");

    // Take notes of what happened, take a small amount as a fee, and build the claim
    uint32 finalAmount = _afterDeposit(_account, _currency, _chainId, _amount);

    claimId++;
    claims[claimId] = ZKBridgeUtils.getSlotFrom(finalAmount, _currency, _chainId, claimId, _account);

    emit ClaimReady(_account, _currency, _chainId, _amount, finalAmount);
  }

  // TODO:
  // - Public APIs for claiming withdrawals from satellites to master
  // - Public permissioned APIs to set the fees

//  function startRedeemClaim() external returns (bool) {
//    // TODO
//    return false;
//  }

  function withdrawCurrencyReserve(uint16 _currency, address _account) onlyLevelAndUpOrOwnerOrController(PermissionLevel.CONTROLLER) external {
    require(isMaster == true, "Only available on MasterVault");

    address tokenAddress = _getCurrencyContractAddress(_currency);
    uint256 balances = currencyReserves[_currency];

    // TODO: Test
    bool outcome = IERC20(tokenAddress).transferFrom(address(this), _account, balances);
    require(outcome == true, "Transfer failed");
    currencyReserves[_currency] = 0;
  }

  function getSupportedCurrencies() external view returns (string[] memory) {
    return _getAllSupportedCurrencies();
  }

  function getSupportedChains() external view returns (string[] memory) {
    return _getAllSupportedChains();
  }

  function getChainName(uint16 _chainId) external view returns (string memory) {
    return _getChainName(_chainId);
  }

  function getCurrencyName(uint16 _currencyId) external view returns (string memory) {
    return _getCurrencyTicker(_currencyId);
  }

  function addSupportedCurrency(address _contractAddress) external onlyLevelAndUpOrOwnerOrController(PermissionLevel.OPERATOR) returns (uint16 currencyId_) {
    uint8 currencyStatus = _getFlagValue(Actions.REDEEM) &
      _getFlagValue(Actions.DEPOSIT);
    currencyId_ = _addNewSupportedCurrency(currencyStatus, _contractAddress);
  }

  function updateSupportedCurrencyContract(uint16 _currency, address _contractAddress) external onlyLevelAndUpOrOwnerOrController(PermissionLevel.CONTROLLER) returns (address) {
    return _setCurrencyContractAddress(_currency, _contractAddress);
  }

  function setSupportedCurrencyFlag(uint16 _currency, Actions _action, bool _enabled) external onlyLevelAndUpOrOwnerOrController(PermissionLevel.OPERATOR) returns (uint8) {
    require(_action != Actions.CHANGE_STATUS || (_action == Actions.CHANGE_STATUS && (msg.sender == owner || msg.sender == controller)), "Changing the CHANGE_STATUS flag requires elevated permissions");
    return _setCurrencyActionSupportStatus(_currency, _action, _enabled);
  }

  function addSupportedChain(string calldata _name) external onlyLevelAndUpOrOwnerOrController(PermissionLevel.OPERATOR) returns (uint16 chainId_) {
    uint8 chainStatus = _getFlagValue(Actions.CLAIM) &
      _getFlagValue(Actions.REDEEM) &
      _getFlagValue(Actions.TRANSFER);
    chainId_ = _addNewSupportedChain(_name, chainStatus);
  }

  function setSupportedChainFlag(uint16 _currency, Actions _action, bool _enabled) external onlyLevelAndUpOrOwnerOrController(PermissionLevel.OPERATOR) returns (uint8) {
    require(_action != Actions.CHANGE_STATUS || (_action == Actions.CHANGE_STATUS && (msg.sender == owner || msg.sender == controller)), "Changing the CHANGE_STATUS flag requires elevated permissions");
    return _setCurrencyActionSupportStatus(_currency, _action, _enabled);
  }
}