use dep::ecrecover;
use dep::std;
use dep::proof;
mod utils;

global DEPTH: Field = 2;
global PROOF_LEN: Field = 1064;

fn main(
    // input from message signing
    pub_key: [u8; 64],
    signature: [u8; 64],
    hashed_message: [u8; 32],

    // input from storage proof
    proof: [u8; PROOF_LEN], 
    key: [u8;32], // key to the storage slot
    storage: [u8; 32], 
    value: [u8; 32],  // The value in the storage slot
) -> pub [Field;2] {
    // prove to be owner: get address from signature, calculate storage_slot correspond to that address, 
    let address_key = ecrecover::secp256k1::PubKey::from_unified(pub_key);
    let address = address_key.ecrecover(signature, hashed_message);
    let storage_slot = utils::get_storage_slot(address, 1);
    assert(storage_slot == key);

    // verify storage proof
    let depth = DEPTH;
    let trie_proof = proof::TrieProof {
        key,
        proof,
        depth,
        value
    };
    assert(trie_proof.verify_storage_root(storage));

    let value_field = utils::arr32_to_field(value);
    let storage_field = utils::arr32_to_field(storage);
    let storage_hash = std::hash::pedersen([storage_field])[0];
    [value_field, storage_hash]
}
