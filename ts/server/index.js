// import {} from "bun";
import "./../utils/storageProofPreprocessing.ts"
import {stringify} from "@iarna/toml";
import fs from "fs";
import {preprocessing} from "../utils/storageProofPreprocessing.js";
import {dirname, resolve, join} from "path";
import {fileURLToPath} from "url";
import {writeToToml} from "../utils/helper.js";
import {ethers} from "ethers";
import {Network, Alchemy} from "alchemy-sdk";

// type Serial = {
//     proof: number[];
//     key: number[];
//     value: number[];
//     storage: number[];
// };

function serialise(value = "", pad = false) {
    let x = value.replace("0x", "");
    if (pad) {
        x = x.padStart(64, "0");
    }
    return Array.from(Buffer.from(x, "hex"));
}

// Setup: npm install alchemy-sdk
// Github: https://github.com/alchemyplatform/alchemy-sdk-js
export async function preprocessing(
    contract_address = "0xdeadbeef",
    storage_slot, // string[]
    block = "latest"
) {
    const settings = {
        apiKey: process.env.ALCHEMY_API_KEY,
        network: Network.ETH_SEPOLIA,
    };
    const alchemy = new Alchemy(settings);

    const res = await alchemy.core.send("eth_getProof", [
        contract_address,
        storage_slot,
        block,
    ]);

    const MAX_TRIE_NODE_LENGTH = 532;
    const {storageProof, storageHash} = res;
    const theProof = storageProof[0];

    let proofPath = "";
    for (let i = 0; i < theProof.proof.length; i++) {
        let layer = theProof.proof[i];
        layer = layer.replace("0x", "").padEnd(MAX_TRIE_NODE_LENGTH * 2, "0");
        proofPath = proofPath + layer;
    }

    // encode this into bytes which can be interpreted by the prover
    // The rlp encoded proof path is right padded at each node with 0s and then concatenated
    const key = serialise(theProof.key);
    const value = serialise(theProof.value, true);
    const proof = serialise(proofPath);
    const storage = serialise(storageHash);

    // Serialized proof data
    return {
        proof,
        key,
        storage,
        value,
    };
}

// type Serial = {
//     pub_key: number[];
//     signature: number[];
//     hashed_message: number[];
//     proof: number[];
//     key: number[];
//     storage: number[];
//     value: number[];
// };

// All Number arrays
// TODO: Add JSDoc types
const dataTemplate = {
    pub_key: [],
    signature: [],
    hashed_message: [],
    proof: [],
    key: [],
    storage: [],
    value: [],
}

function numberToHex(num) {
    let hexVal = num.toString(16);
    return '0x' + (hexVal.length % 2 === 0 ? hexVal : "0" + hexVal);
}

async function storeProofToml(content, filePath) {
    const tomlString = stringify(content);
    await Bun.write(filePath, tomlString);
}

export async function generateNargoProofFile(publicKey, signature, contractAddress, claimId) {
    // const pubKey = Array.from(
    //     ethers.utils.arrayify(user.publicKey).slice(1).values()
    // );


    // sign the message
    let signatureArray = Array.from(
        ethers.utils
            .arrayify(signature)
            .slice(0, 64)
            .values()
    );

    // TODO: This feels like it needs to be improved
    let messageToHash = "\x19Ethereum Signed Message:\n17this is a message";
    let hashedMessage = ethers.utils.hashMessage(messageToHash);
    let hashed_message = Array.from(
        ethers.utils.arrayify(hashedMessage).values()
    );

    const storage_slot = getStorageSlot(numberToHex(claimId), "0xe");

    const storage_proof = await preprocessing(
        contractAddress,
        [storage_slot],
        "latest"
    );

    let data = {
        pub_key: publicKey,
        signature: signatureArray,
        hashed_message: hashed_message,
        proof: storage_proof.proof,
        key: storage_proof.key,
        storage: storage_proof.storage,
        value: storage_proof.value,
    };

    // the nargoPath will be the path from the cwd context of one folder up, so different than the import.meta.dir
    const nargoPath = `../circuits/Prover-${claimId}.toml`
    let path = join(import.meta.dir, '../', nargoPath);

    // Write File
    await storeProofToml(data, path);

    return nargoPath;
}

export function getStorageSlot(
    index = "0x1",
    slot = "0xe" // slot 14
) {
    const paddedIndex = ethers.utils.hexZeroPad(index, 32);
    const paddedSlot = ethers.utils.hexZeroPad(slot, 32);
    const concatenated = ethers.utils.concat([paddedIndex, paddedSlot]);
    return ethers.utils.keccak256(concatenated);
}

async function runNargoProof(proverFilePath) {
    const proc = Bun.spawn(["nargo", "-p", proverFilePath], {
        cwd: ".."
    });
    return await new Response(proc.stdout).text();
}

const server = Bun.serve({
    port: 3000,
    async fetch(request) {
        const body = await request.json();

        const {publicKey, signature, contractAddress, claimId} = body;

        const nargoProofPath = await generateNargoProofFile(publicKey, signature, contractAddress, claimId);

        const nargoProof = await runNargoProof(nargoProofPath);

        console.log("Proof: ", nargoProofPath, nargoProof)

        return new Response(nargoProof);
    },
    error(error) {
        return new Response(`There was an error: ${error}`)
    }
});

console.log(`Listening on localhost: ${server.port}`);