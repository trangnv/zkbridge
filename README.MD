# zkBridge with storage proof

- User deposit ERC20 token on chain A to Vault contract
- User generate proof of deposit (storage proof of Vault contract) and use that proof to claim token on chain B

## Chain A

Sepolia

- ERC20 contract: [0x0041ff33e47eae38ab8b9a1c2070e279d5aaf211](https://sepolia.etherscan.io/address/0x0041ff33e47eae38ab8b9a1c2070e279d5aaf211)

- Vault contract: [0xad3a56d718aCbD139f50A38558d0a7C2eFdf4858](https://sepolia.etherscan.io/address/0xad3a56d718acbd139f50a38558d0a7c2efdf4858)

## Chain B

Goerli

- ERC20 contract: [0xfea16a8cf9b655d6497769f601e5b2c3c3c7e962](https://goerli.etherscan.io/address/0xfea16a8cf9b655d6497769f601e5b2c3c3c7e962)

- Claim contract: [0xdfa320df0933daa9db4941e30856e233b818db59](https://goerli.etherscan.io/address/0xdfa320df0933daa9db4941e30856e233b818db59)

## TODO

- Double spending <br>

  - Using `storageHash` as nullifier now.

- Proof generation

  - Circuits: proof length will vary, need the way to modify the circuit based on it.
  - On browner
  - Any other solution?

- Contract

  - Crosschain contract: Right now contract on chain B has to hold funds to release to claimer, is there other way to do it?
  - Polishing the contracts
  - Is there a way to `burn` balance on chain A Vault contract when user claim on chain B?

- How current bridges work?

- the proof has the chainId
- nft has the balance and claim againt that nft
- Redeem on chain A (when made mistake)
