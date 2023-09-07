
pragma solidity ^0.8.9;

library ZKBridgeUtils {
    // The slot is 256 bits
    //
    // Slot Layout:
    // Amount: 32 bits
    // Currency: 16 bits
    // ChainId: 16 bits
    // ClaimId: 32 bits
    // Address: 160 bits
    function getSlotFrom(uint32 amount, uint16 currency, uint16 chainId, uint32 claimId, address account) pure public returns (uint256 slot) {
        slot = uint256(amount) << 224 | uint256(currency) << 208 | uint256(chainId) << 192 | uint256(claimId) << 160 | uint256(uint160(account));
    }

    function getValuesFrom(uint256 slot) public pure returns (uint32 amount, uint16 currency, uint16 chainId, uint32 claimId, address account) {
        return (
            getAmount(slot),
            getCurrency(slot),
            getChainId(slot),
            getClaimId(slot),
            getAddress(slot)
        );
    }
}