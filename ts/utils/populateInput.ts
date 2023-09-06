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

const PRIVATE_KEY: string = process.env.PRIVATE_KEY!;

export async function generate() {
  const user = new ethers.Wallet(PRIVATE_KEY);
  console.log("user address: ", user.address);

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
  console.log("hashedMessage: ", hashedMessage);

  const storage_proof = await preprocessing(
    "0xad3a56d718aCbD139f50A38558d0a7C2eFdf4858",
    ["0x3a74720913a16d4e630a557ac2caac6e9d752b9b1bce3f5eed475aa86f7df199"],
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
  let path = resolve(dir + "/Prover.toml");
  writeToToml(data, path);
}
export async function getStorageSlot() {
  // const address =
  //   "0x77fCF983241ceb7e8c928102f6fe63A1de834c5D".toLocaleLowerCase();
  // const slot = "0x0";
  // const paddedAddress = ethers.utils.hexZeroPad(address, 32);
  // const paddedSlot = ethers.utils.hexZeroPad(slot, 32);
  // const concatenated = ethers.utils.concat([paddedAddress, paddedSlot]);
  // const hash = ethers.utils.keccak256(concatenated);
  // console.log("storage slot:", hash);

  const _v =
    "0x3a74720913a16d4e630a557ac2caac6e9d752b9b1bce3f5eed475aa86f7df199";
  const v = ethers.utils.hexZeroPad(_v, 32);
  const _hash = ethers.utils.keccak256(v);
  console.log("hash:", _hash);

  // const result = await provider.getStorageAt(
  //   "0xC216FdC8fb87A151d69313e18a80a58bebBA7267",
  //   hash
  // );
  // console.log("result ethers:", parseInt(result, 16));
}

getStorageSlot();
// generate();
