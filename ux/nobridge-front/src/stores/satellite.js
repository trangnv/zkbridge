import {ref, computed} from 'vue'
import {defineStore} from 'pinia'
import {abi as satellite} from '~/abis/satellite.json'

const isDEV = process.env.NODE_ENV !== "production"
// const chainId = isDEV ? 31337 : 421614; // localhost in dev, arbitrum sepolia in production (testnet for now) 42161 is Arbitrum One Mainnet
const chainId = 1; // localhost in dev, arbitrum sepolia in production (testnet for now) 42161 is Arbitrum One Mainnet
const contractAddress = "0x959922bE3CAee4b8Cd9a407cc3ac1C251C2007B1"

export const useSatelliteStore = defineStore('satellite', () => {
  const redemptionClaims = ref([]);

  function claim() {
    console.log("Claims from satellite store, chainID: ", chainId);
  }

  return {
    claim,
    chainId,
    satelliteABIs: satellite,
  }
})
