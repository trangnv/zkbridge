// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import {UltraVerifier} from "./plonk_vk.sol";
import {ZKBridgeUtils} from "../commons/EVM/ZKBridgeUtils.sol";

import {ZKBPermissionsController} from "../commons/Admin/ZKBPermissionsController.sol";
import {ZKBVaultManagement} from "../commons/Admin/ZKBVaultManagement.sol";

contract ZKBridgeSatellite is ZKBPermissionsController, ZKBVaultManagement {
  UltraVerifier public proofVerifier;
  address public stateVerifier;

  // claimId => reClaimId
  mapping(uint32 => uint8) private redemptionClaims;
  // claimId => slot
  mapping(uint32 => uint256) private redemptionClaimsSlot;
  // address => claimId => claimProcessId
  mapping(address => mapping(uint32 => uint32)) private claimProcesses;
  uint32 private claimProcessesCounter = 0;
  mapping (bytes24 => bool) noncesUsed;

  enum ClaimProcessStages {
    NONE,
    CLAIM_STARTED,
    CLAIM_PENDING,
    CLAIM_REJECTED,
    CLAIM_VERIFIED,
    CLAIM_COMPLETED,
    CLAIM_CANCELLED
  }

  uint16 public internalChainId;
  bytes32 public internalChainName;

  event ClaimProcessStarted(uint32 indexed claimId, uint32 indexed claimProcessId, address indexed destinationAccount, address initiator);
  event ClaimProcessStatusChanged(uint32 indexed claimId, uint32 claimProcessId, uint8 indexed claimProcessStage, address initiator, address destinationAccount);
  event ClaimProcessCompleted(uint32 indexed claimId, uint32 indexed claimProcessId, address indexed destinationAccount, address initiator);

  // Marks the ZKBVaultManagement as satellite (isMaster = false)
  constructor(UltraVerifier _proofVerifier, address _stateVerifier, uint16 _chainId) ZKBPermissionsController() ZKBVaultManagement(false, _chainId) {
    proofVerifier = _proofVerifier;
    stateVerifier = _stateVerifier;
    internalChainId = _chainId;
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
    uint8 currencyStatus = _getFlagValue(Actions.MINT) |
      _getFlagValue(Actions.BURN) |
      _getFlagValue(Actions.CLAIM) |
      _getFlagValue(Actions.REDEEM) |
      _getFlagValue(Actions.TRANSFER) |
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
    uint8 chainStatus = _getFlagValue(Actions.CLAIM) |
            _getFlagValue(Actions.REDEEM) |
            _getFlagValue(Actions.TRANSFER);
    chainId_ = _addNewSupportedChain(_name, chainStatus);
  }

  function setSupportedChainFlag(uint16 _currency, Actions _action, bool _enabled) external onlyLevelAndUpOrOwnerOrController(PermissionLevel.OPERATOR) returns (uint8) {
    require(_action != Actions.CHANGE_STATUS || (_action == Actions.CHANGE_STATUS && (msg.sender == owner || msg.sender == controller)), "Changing the CHANGE_STATUS flag requires elevated permissions");
    return _setCurrencyActionSupportStatus(_currency, _action, _enabled);
  }

  function setProofVerifier(UltraVerifier _proofVerifier) external onlyLevelAndUpOrOwnerOrController(PermissionLevel.CONTROLLER) {
    // TODO: Anything we should do with the previous one?
    proofVerifier = _proofVerifier;
  }

  function setStateVerifier(address _stateVerifier) external onlyLevelAndUpOrOwnerOrController(PermissionLevel.CONTROLLER) {
    // TODO: Anything we should do with the previous one?
    stateVerifier = _stateVerifier;
  }

  function startClaimProcess(bytes memory _proof, bytes32[] memory _publicInputs) external returns (uint32 /* claimId_ */, uint32 /* claimProcessId_ */) {
    require(proofVerifier.verify(_proof, _publicInputs), "Invalid proof");

    (, , uint16 _chainId, uint32 claimId, address account) = ZKBridgeUtils.getValuesFrom(uint256(_publicInputs[0]));

    require(internalChainId == _chainId, "This claim is not supposed to be on this chain");
    require(redemptionClaims[claimId] == uint8(ClaimProcessStages.NONE), "Claim has already been redeemed or redemption has already started");
    require(claimProcesses[account][claimId] == 0, "A claim verification process has already started");

    uint32 claimProcessId_ = claimProcessesCounter++;

    // Store the claim process Id related to the claimId
    claimProcesses[account][claimId] = claimProcessId_;
    // Store claim slot
    redemptionClaimsSlot[claimId] = uint256(_publicInputs[0]);

    emit ClaimProcessStarted(claimId, claimProcessId_, account, msg.sender);

    redemptionClaims[claimId] = uint8(ClaimProcessStages.CLAIM_STARTED);

    emit ClaimProcessStatusChanged(claimId, claimProcessId_, redemptionClaims[claimId], msg.sender, account);

    return (claimId, claimProcessId_);
  }

  function _markClaimProcess(uint32 _claimId, address _destinationAccount, bool _confirmed) public onlyStateVerifier {
    if(_confirmed == true) {
      redemptionClaims[_claimId] = uint8(ClaimProcessStages.CLAIM_VERIFIED);
    } else {
      redemptionClaims[_claimId] = uint8(ClaimProcessStages.CLAIM_REJECTED);
    }
    uint32 claimProcessId_ = claimProcesses[_destinationAccount][_claimId];

    emit ClaimProcessStatusChanged(_claimId, claimProcessId_, redemptionClaims[_claimId], msg.sender, _destinationAccount);
  }

  function completeClaimProcess(bytes memory _signature, uint32 _claimId, bytes24 _nonce, uint32 /* _processClaimId */) external {
    require(redemptionClaims[_claimId] == uint8(ClaimProcessStages.CLAIM_VERIFIED), "The claim cannot be redeemed yet");
    require(noncesUsed[_nonce] == false, "Nonce has already been consumed, please generate a new signature");

    // this recreates the message that was signed on the client
    bytes32 prefixedHashedMessage = keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", "Verification for redemption: ", _claimId, _nonce));
    (bytes32 _r, bytes32 _s, uint8 _v) = ZKBridgeUtils.splitSignature(_signature);

    address signer = ecrecover(prefixedHashedMessage, _v, _r, _s);
    noncesUsed[_nonce] = true;

    (uint32 amount_, uint16 currency_, , uint32 claimId_, address account_, uint32 claimProcessId_, ) = getMetadataForClaimId(_claimId);

    require(account_ == signer, "The signature must come from the destination address");

    // The process is complete at this point, everything has been validated. Releasing the tokens.
    emit ClaimProcessStatusChanged(claimId_, claimProcessId_,  redemptionClaims[claimId_], msg.sender, account_);

    redemptionClaims[_claimId] = uint8(ClaimProcessStages.CLAIM_COMPLETED);
    _mintTokens(account_, currency_, amount_);

    emit ClaimProcessCompleted(claimId_, claimProcessId_, account_, msg.sender);
  }

  function getClaimProcessStagesLabels() public pure returns (string[7] memory cps_) {
    cps_ = [
      "NONE",
      "CLAIM_STARTED",
      "CLAIM_PENDING",
      "CLAIM_REJECTED",
      "CLAIM_VERIFIED",
      "CLAIM_COMPLETED",
      "CLAIM_CANCELLED"
      ];
  }

  function getMetadataForClaimId(uint32 _claimId) public view returns (uint32 amount_, uint16 currency_, uint16 chainId_, uint32 claimId_, address account_, uint32 claimProcessId_, string memory status_) {
    (amount_, currency_, chainId_, claimId_, account_) = ZKBridgeUtils.getValuesFrom(redemptionClaimsSlot[_claimId]);
    claimProcessId_ = claimProcesses[account_][claimId_];
    uint8 status = redemptionClaims[claimId_];
    status_ = getClaimProcessStagesLabels()[status];
  }

  modifier onlyStateVerifier() {
    require(msg.sender == stateVerifier, "Permission denied");
    _;
  }
}
