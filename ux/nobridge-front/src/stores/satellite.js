import {ref, computed} from 'vue'
import {defineStore} from 'pinia'

import {abi as satelliteABIs} from '~/abis/satellite.json'
import {abi as ERC20ABI} from '~/abis/erc20.json'
import {abi as ZKBERC20ABI} from '~/abis/zkberc20.json'

import {Contract} from 'ethers'

const isDEV = process.env.NODE_ENV !== "production"
const chainId = isDEV ? 31337 : 421614; // localhost in dev, arbitrum sepolia in production (testnet for now) 42161 is Arbitrum One Mainnet
// const chainId = 1; // localhost in dev, arbitrum sepolia in production (testnet for now) 42161 is Arbitrum One Mainnet
const contractAddress = "0x202CCe504e04bEd6fC0521238dDf04Bc9E8E15aB"

export const useSatelliteStore = defineStore('satellite', () => {
  const redemptionClaims = ref([]);

  function claim() {
    console.log("Claims from satellite store, chainID: ", chainId);
  }

  async function getSupportedCurrencies(provider) {
    const satelliteReadOnlyContract = new Contract(contractAddress, masterABIs, provider);
    const unfilteredAssets = await satelliteReadOnlyContract.getSupportedCurrencies();

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

  function getEthersContractForZKBERC20(address, providerOrSigner) {
    return new Contract(address, ZKBERC20ABI, providerOrSigner);
  }

  function getSatelliteContract(providerOrSigner) {
    return new Contract(contractAddress, satelliteABIs, providerOrSigner);
  }

  return {
    claim,
    chainId,
    contractAddress,
    getSupportedCurrencies,
    satelliteABIs,
    getSatelliteContract,
    getEthersContractForZKBERC20
  }
})
