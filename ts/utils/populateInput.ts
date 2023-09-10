import "dotenv/config";
import { convertToHex, writeToToml } from "./helper.js";
import { fileURLToPath } from "url";
import { resolve, dirname } from "path";
import { ethers } from "ethers";
import { preprocessing } from "./storageProofPreprocessing.js";
// @ts-ignore -- no types
// import blake2 from "blake2";

type Serial = {
  pub_key: number[];
  signature: number[];
  hashed_message: number[];
  proof: number[];
  key: number[];
  storage: number[];
  value: number[];
};

const USER_PRIVATE_KEY: string = process.env.USER_PRIVATE_KEY!;

export async function generate() {
  const user = new ethers.Wallet(USER_PRIVATE_KEY);

  const pubKey = Array.from(
    ethers.utils.arrayify(user.publicKey).slice(1).values()
  );

  let message = "this is a message";

  // sign the message
  let signature = Array.from(
    ethers.utils
      .arrayify(await user.signMessage(message))
      .slice(0, 64)
      .values()
  );

  let hashedMessage = ethers.utils.hashMessage(message);
  let hashed_message = Array.from(
    ethers.utils.arrayify(hashedMessage).values()
  );

  const storage_slot = getStorageSlot("0x1", "0xe");

  const storage_proof = await preprocessing(
    "0x85638e79653BEFa817CA4811a1ABD00c918bD1F4",
    [storage_slot],
    "latest"
  );

  let data: Serial = {
    pub_key: pubKey,
    signature: signature,
    hashed_message: hashed_message,
    proof: storage_proof.proof,
    key: storage_proof.key,
    storage: storage_proof.storage,
    value: storage_proof.value,
  };

  const dir = dirname(fileURLToPath(import.meta.url));
  let path = resolve(dir, "../..") + "/circuits/Prover.toml";
  writeToToml(data, path);
}

export function getStorageSlot(
  index: string = "0x1",
  slot: string = "0xe" // slot 14
) {
  const paddedIndex = ethers.utils.hexZeroPad(index, 32);
  const paddedSlot = ethers.utils.hexZeroPad(slot, 32);
  const concatenated = ethers.utils.concat([paddedIndex, paddedSlot]);
  const hash = ethers.utils.keccak256(concatenated);
  return hash;
}

// getStorageSlot();
generate();
