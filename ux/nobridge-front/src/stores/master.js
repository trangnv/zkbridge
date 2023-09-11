import {ref, computed} from 'vue'
import {defineStore} from 'pinia'
import {abi as masterABIs} from '~/abis/master.json'
import {Contract} from 'ethers'

const isDEV = process.env.NODE_ENV !== "production"
// localhost in dev, ETH sepolia in production (testnet for now)
const chainId = isDEV ? 31337 : 11155111;
const contractAddress = "0x9A676e781A523b5d0C0e43731313A708CB607508"

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
    return Object.values({...unfilteredAssets}).map((asset, index) => {return {index, asset}}).filter((asset) => asset.asset !== "");
  }

  function deposit(amount, currency, provider) {
    console.log("Deposit from master store, chainID: ", chainId);
  }

  return {
    deposit,
    chainId,
    masterABIs,
    getSupportedChains,
    getSupportedCurrencies
  }
})
