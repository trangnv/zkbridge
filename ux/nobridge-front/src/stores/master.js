import {ref, computed} from 'vue'
import {defineStore} from 'pinia'

import {abi as masterABIs} from '~/abis/master.json'
import {abi as ERC20ABI} from '~/abis/erc20.json'
import {abi as ZKBERC20ABI} from '~/abis/zkberc20.json'

import {Contract} from 'ethers'

const isDEV = process.env.NODE_ENV !== "production"
// localhost in dev, ETH sepolia in production (testnet for now)
const chainId = isDEV ? 31337 : 11155111;

const contractAddress = "0x8198f5d8F8CfFE8f9C413d98a0A55aEB8ab9FbB7"

export const useMasterStore = defineStore('master', () => {
  const claims = ref([]);
  // const masterContract = Contract()

  async function getSupportedChains(provider) {
    const masterVaultReadOnlyContract = new Contract(contractAddress, masterABIs, provider);
    const unfilteredAssets = await masterVaultReadOnlyContract.getSupportedChains();
    return Object.values({...unfilteredAssets}).map((asset, index) => {return {index, asset}}).filter((asset) => asset.asset !== "");
  }

  async function getSupportedCurrencies(provider) {
    const masterVaultReadOnlyContract = new Contract(contractAddress, masterABIs, provider);
    const unfilteredAssets = await masterVaultReadOnlyContract.getSupportedCurrencies();

    let currencies, contracts;

    try {
      currencies = {...unfilteredAssets[0]};
      contracts = {...unfilteredAssets[1]};
      return Object.values(currencies).map((asset, index) => {return {index, asset, contractAddress: contracts[index]}}).filter((asset) => asset.asset !== "");
    } catch(error) {
      console.error(error);
    }

    if(currencies) {
      return Object.values(currencies).map((asset, index) => {return {index, asset}}).filter((asset) => asset.asset !== "");;
    }
    return [];
  }

  async function deposit(amount, currencyId, chainId, targetAddress, provider) {
    console.log("Deposit from master store, chainID: ", chainId);
    const masterVaultReadOnlyContract = new Contract(contractAddress, masterABIs, provider);
    // amount, currency, chainId, address
    const claimId = await masterVaultReadOnlyContract.deposit(amount, currencyId, chainId, targetAddress);
    console.log("ClaimId: ", claimId);
    return claimId;
  }

  function getEthersContractForMockERC20(address, providerOrSigner) {
    return new Contract(address, ERC20ABI, providerOrSigner);
  }

  function getMasterVaultContract(providerOrSigner) {
    return new Contract(contractAddress, masterABIs, providerOrSigner);
  }

  return {
    deposit,
    chainId,
    contractAddress,
    masterABIs,
    getSupportedChains,
    getSupportedCurrencies,
    getMasterVaultContract,
    getEthersContractForMockERC20,
  }
})
