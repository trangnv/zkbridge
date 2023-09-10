<template>
  <div class="w-full flex justify-items-end">
    <div class="flex-grow">
      <span v-if="connectedWallet">
        Address: {{ connectedWallet.accounts[0].address.slice(0,6) }}...{{ connectedWallet.accounts[0].address.slice(-4) }} <br/>
        Network: {{ connectedWallet.chains[0].namespace }} (ID: {{Number(connectedWallet.chains[0].id)}})
      </span>
    </div>
    <div v-if="!connectedWallet" class="flex">
      <button @click="connect" class="form-input text-indigo-900 rounded h-12 w-36 p-2">Connect Wallet</button>
    </div>
    <div v-else>
      <button @click="disconnect">Disconnect</button>
    </div>
  </div>
</template>
<script setup>
import { init, useOnboard } from '@web3-onboard/vue'
import injectedModule from '@web3-onboard/injected-wallets'
import { ethers } from "ethers"

import {watch} from "vue";

const injected = injectedModule()
const infuraKey = '<INFURA_KEY>'
const rpcUrl = `https://mainnet.infura.io/v3/${infuraKey}`

const LOCALHOST_RPC_URL = 'http://127.0.0.1:8545'

const web3Onboard = init({
  wallets: [injected],
  chains: [
    {
      id: '0x7A69',
      token: 'ETH',
      label: 'Localhost Anvil',
      rpcUrl: LOCALHOST_RPC_URL
    },
    {
      id: '0x1',
      token: 'ETH',
      label: 'Ethereum Mainnet',
      rpcUrl
    },
    {
      id: '0x2105',
      token: 'ETH',
      label: 'Base',
      rpcUrl: 'https://mainnet.base.org'
    }
  ],
  connect: {
    autoConnectLastWallet: true,

  }
})

const { wallets, connectWallet, disconnectConnectedWallet, connectedWallet } = useOnboard()

watch(() => connectedWallet, () => {
  const {accounts, chains} = connectedWallet;
  console.log("WalletView watch connectedWallet", accounts, chains);
})

async function connect() {
  await connectWallet();

  if (connectedWallet.value) {
    // if using ethers v6 this is:
    const ethersProvider = new ethers.BrowserProvider(connectedWallet.provider, 'any')
    // const ethersProvider = new ethers.providers.Web3Provider(connectedWallet.provider, 'any')
    // ..... do stuff with the provider
  }
}

async function disconnect() {
  await disconnectConnectedWallet();
  console.log("Disconnected", ...connectedWallet);
}

</script>
