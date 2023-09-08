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
  mapping(uint32 => uint256) private redemptionClaimsSlot;

  mapping(address => mapping(uint32 => uint32)) private claimProcesses;
  // Address => claimId => claimProcessId
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

  event ClaimProcessStarted(uint32 indexed claimId, uint32 indexed claimProcessId, uint32 indexed destinationAccount, uint32 indexed initiator);
  event ClaimProcessStatusChanged(uint32 indexed claimId, uint32 claimProcessId, uint8 indexed claimProcessStage, address indexed initiator, address destinationAccount);
  event ClaimProcessCompleted(uint32 indexed claimId, uint32 indexed claimProcessId, uint32 indexed destinationAccount, uint32 indexed initiator);

  // Marks the ZKBVaultManagement as satellite (isMaster = false)
  constructor(UltraVerifier _proofVerifier, address _stateVerifier, uint16 _chainId) ZKBPermissionsController() ZKBVaultManagement(false, _chainId) {
    proofVerifier = _proofVerifier;
    internalChainId = _chainId;
  }

  function setProofVerifier(address _proofVerifier) external onlyLevelAndUpOrOwnerOrController(PermissionLevel.CONTROLLER) {
    // TODO: Anything we should do with the previous one?
    proofVerifier = _proofVerifier;
  }

  function setStateVerifier(address _stateVerifier) external onlyLevelAndUpOrOwnerOrController(PermissionLevel.CONTROLLER) {
    // TODO: Anything we should do with the previous one?
    stateVerifier = _stateVerifier;
  }

  function startClaimProcess(bytes memory _proof, bytes32[] memory _publicInputs) external returns (uint32 claimId_, uint32 claimProcessId_) {
    require(proofVerifier.verify(_proof, _publicInputs), "Invalid proof");

    uint256 slot = uint256(_publicInputs[0]);
    (uint32 amount, uint16 currency, uint16 _chainId, uint32 claimId, address account) = ZKBridgeUtils.getValuesFrom(slot);

    require(internalChainId == _chainId, "This claim is not supposed to be on this chain");
    require(redemptionClaims[claimId] == false, "Claim has already been redeemed");
    require(claimProcesses[account][claimId] == 0, "A claim verification process has already started");

    claimId_ = claimId;
    claimProcessId_ = claimProcessesCounter++;

    // Store the claim process Id related to the claimId
    claimProcesses[account][claimId_] = claimProcessId_;
    // Store claim slot
    redemptionClaimsSlot[claimId_] = slot;

    emit ClaimProcessStarted(claimId_, claimProcessId_, account, msg.sender);

    redemptionClaims[claimId_] = ClaimProcessStages.CLAIM_STARTED;

    emit ClaimProcessStatusChanged(claimId_, claimProcessId_, account, redemptionClaims[claimId_], msg.sender);

    return (claimId_, claimProcessId_);
  }

  function _markClaimProcess(uint32 _claimProcessId, address _destinationAccount, bool _confirmed) public onlyStateVerifier {
    if(_confirmed == true) {
      redemptionClaims[claimId_] = ClaimProcessStages.CLAIM_VERIFIED;
    } else {
      redemptionClaims[claimId_] = ClaimProcessStages.CLAIM_REJECTED;
    }

    emit ClaimProcessStatusChanged(claimId_, claimProcessId_, account, redemptionClaims[claimId_], msg.sender);
  }

  function completeClaimProcess(bytes memory _signature, uint32 _claimId, bytes24 _nonce, uint32 _processClaimId) external {
    require(redemptionClaims[_claimId] == ClaimProcessStages.CLAIM_VERIFIED, "The claim cannot be redeemed yet");
    require(noncesUsed[_nonce] == false, "Nonce has already been consumed, please generate a new signature");

    // this recreates the message that was signed on the client
    bytes32 prefixedHashedMessage = keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", "Verification for redemption: ", _claimId, _nonce));
    (bytes32 _r, bytes32 _s, uint8 _v) = ZKBridgeUtils.splitSignature(_signature);

    address signer = ecrecover(prefixedHashedMessage, _v, _r, _s);
    noncesUsed[_nonce] = true;

    (uint32 amount_, uint16 currency_, uint16 chainId_, uint32 claimId_, address account_, uint32 claimProcessId_, string memory status_) = getMetadataForClaimId(_claimId);

    require(account_ == signer, "The signature must come from the destination address");

    // The process is complete at this point, everything has been validated. Releasing the tokens.
    emit ClaimProcessStatusChanged(claimId_, claimProcessId_, amount_, redemptionClaims[claimId_], msg.sender);

    redemptionClaims[_claimId] = true;
    _mintTokens(account_, currency_, amount_);

    emit ClaimProcessCompleted(claimId_, claimProcessId_, account, msg.sender);
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
