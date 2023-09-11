<template>
  <form class="relative">
    <div
        class="overflow-hidden rounded-lg border border-gray-300 shadow-sm focus-within:border-indigo-500 focus-within:ring-1 focus-within:ring-indigo-500">
      <label for="title" class="sr-only">Title</label>
      <input type="text" name="address" id="address"
             v-model="address"
             class="block w-full border-0 pt-2.5 text-lg font-medium placeholder:text-gray-400 focus:ring-0"
             placeholder="Destination Address (0x...)"/>
      <label for="description" class="sr-only">Enter the address you want to receive the funds on, on the chain you have
        selected.</label>
      <input type="number" @focusout="checkIfValueIsAboveTheMax" name="description" id="description" max="4294967295"
             class="font-light text-3xl block w-full resize-none border-0 py-0 text-slate-900 placeholder:text-gray-400 focus:ring-0 sm:leading-6"
             placeholder="Amount"
             v-model="amount"
      />

      <!-- Spacer element to match the height of the toolbar -->
      <div aria-hidden="true">
        <div class="py-2">
          <div class="h-9"/>
        </div>
        <div class="h-px"/>
        <div class="py-2">
          <div class="py-px">
            <div class="h-9"/>
          </div>
        </div>
      </div>
    </div>

    <div class="absolute inset-x-px bottom-0 z-10">
      <div class="flex flex-nowrap justify-end space-x-2 px-2 py-2 sm:px-3">
        <span class="p-1.5">Currency:</span>
        <Listbox as="div" v-model="currencySelected" class="flex-shrink-0">
          <ListboxLabel class="sr-only">Currency</ListboxLabel>
          <div class="relative">
            <ListboxButton
                class="relative inline-flex items-center whitespace-nowrap rounded-full bg-gray-50 px-2 py-2 text-sm font-medium text-gray-500 hover:bg-gray-100 sm:px-3">
              <UserCircleIcon v-if="!currencySelected.currencyId" class="h-5 w-5 flex-shrink-0 text-gray-300 sm:-ml-1"
                              aria-hidden="true"/>
              <img v-else :src="currencySelected.avatar" alt="" class="h-5 w-5 flex-shrink-0 rounded-full"/>

              <span :class="[!currencySelected.currencyId ? '' : 'text-gray-900', 'hidden truncate sm:ml-2 sm:block']">{{
                  !currencySelected.currencyId ? 'Loading currencies...' : currencySelected.name
                }}</span>
            </ListboxButton>

            <transition leave-active-class="transition ease-in duration-100" leave-from-class="opacity-100"
                        leave-to-class="opacity-0">
              <ListboxOptions
                  class="absolute right-0 z-10 mt-1 max-h-56 w-52 overflow-auto rounded-lg bg-white py-3 text-base shadow ring-1 ring-black ring-opacity-5 focus:outline-none sm:text-sm">
                <ListboxOption as="template" v-for="currency in currencyList" :key="currency.currencyId" :value="currency"
                               v-slot="{ active }">
                  <li :class="[active ? 'bg-gray-100' : 'bg-white', 'relative cursor-default select-none px-3 py-2']">
                    <div class="flex items-center">
                      <img v-if="currency.avatar" :src="currency.avatar" alt=""
                           class="h-5 w-5 flex-shrink-0 rounded-full"/>
                      <UserCircleIcon v-else class="h-5 w-5 flex-shrink-0 text-gray-400" aria-hidden="true"/>
                      <span class="ml-3 block truncate font-medium">{{ currency.name }}</span>
                    </div>
                  </li>
                </ListboxOption>
              </ListboxOptions>
            </transition>
          </div>
        </Listbox>

        <span class="p-1.5">Chain:</span>
        <Listbox as="div" v-model="chainSelected" class="flex-shrink-0">
          <ListboxLabel class="sr-only">Add a label</ListboxLabel>
          <div class="relative">
            <ListboxButton
                class="relative inline-flex items-center whitespace-nowrap rounded-full bg-gray-50 px-2 py-2 text-sm font-medium text-gray-500 hover:bg-gray-100 sm:px-3">
              <UserCircleIcon v-if="!chainSelected.chainId" class="h-5 w-5 flex-shrink-0 text-gray-300 sm:-ml-1"
                              aria-hidden="true"/>
              <img v-else :src="chainSelected.avatar" alt="" class="h-5 w-5 flex-shrink-0 rounded-full"/>

              <span :class="[!chainSelected.chainId ? '' : 'text-gray-900', 'hidden truncate sm:ml-2 sm:block']">{{
                  !chainSelected.chainId ? 'Loading chains...' : chainSelected.name
                }}</span>
            </ListboxButton>

            <transition leave-active-class="transition ease-in duration-100" leave-from-class="opacity-100"
                        leave-to-class="opacity-0">
              <ListboxOptions
                  class="absolute right-0 z-10 mt-1 max-h-56 w-52 overflow-auto rounded-lg bg-white py-3 text-base shadow ring-1 ring-black ring-opacity-5 focus:outline-none sm:text-sm">
                <ListboxOption as="template" v-for="chain in chainList" :key="chain.chainId" :value="chain"
                               v-slot="{ active }">
                  <li :class="[active ? 'bg-gray-100' : 'bg-white', 'relative cursor-default select-none px-3 py-2']">
                    <div class="flex items-center">
                      <img v-if="chain.avatar" :src="chain.avatar" alt="" class="h-5 w-5 flex-shrink-0 rounded-full"/>
                      <TagIcon v-else class="h-5 w-5 flex-shrink-0 text-gray-400" aria-hidden="true"/>
                      <span class="ml-3 block truncate font-medium">{{ chain.name }}</span>
                    </div>
                  </li>
                </ListboxOption>
              </ListboxOptions>
            </transition>
          </div>
        </Listbox>
      </div>
      <div class="flex items-center justify-between space-x-3 border-t border-gray-200 px-2 py-2 sm:px-3">
        <div class="flex">
          <!--                    <button type="button" class="group -my-2 -ml-2 inline-flex items-center rounded-full px-3 py-2 text-left text-gray-400">-->
          <!--                      <PaperClipIcon class="-ml-1 mr-2 h-5 w-5 group-hover:text-gray-500" aria-hidden="true" />-->
          <!--                      <span class="text-sm italic text-gray-500 group-hover:text-gray-600">Attach a file</span>-->
          <!--                    </button>-->
        </div>
        <div class="flex-shrink-0">
          <button @click.prevent="startMasterActionChain"
                  class="inline-flex items-center rounded-md bg-indigo-600 px-3 py-2 text-sm font-semibold text-white shadow-sm hover:bg-indigo-500 focus-visible:outline focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-indigo-600">
            {{ getButtonMessage() }}
          </button>
<!--          <button @click.prevent="startSatelliteActionChain"-->
<!--                  class="inline-flex items-center rounded-md bg-indigo-600 px-3 py-2 text-sm font-semibold text-white shadow-sm hover:bg-indigo-500 focus-visible:outline focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-indigo-600">-->
<!--            Redeem Claim-->
<!--          </button>-->
        </div>
      </div>
    </div>
  </form>
</template>

<script setup>
import {ref, watch} from 'vue'

import {Listbox, ListboxButton, ListboxLabel, ListboxOption, ListboxOptions} from '@headlessui/vue'
import {TagIcon, UserCircleIcon} from '@heroicons/vue/20/solid'

import USDTLogo from '~/svg/icon/usdt.svg'
import RIPPLELogo from '~/svg/icon/xrp.svg'
import AVAXLogo from '~/svg/icon/avax.svg'
import ONELogo from '~/svg/icon/one.svg'

import {ethers} from "ethers";
import {useOnboard} from "@web3-onboard/vue";
import {useMasterStore} from "../stores/master";
import {useSatelliteStore} from "../stores/satellite";

const masterStore = useMasterStore();
const satelliteStore = useSatelliteStore();

const {wallets, connectWallet, disconnectConnectedWallet, connectedWallet, getChain, setChain} = useOnboard()

const emits = defineEmits(["on-create"]);

const currencies = [
  { name: 'Unassigned', currencyId: 0, avatar: undefined },
]

const chains = [
  { name: 'Unassigned', chainId: 0, avatar: undefined },
]

const currencyLogos = [USDTLogo, RIPPLELogo];
const chainsLogos = [AVAXLogo, ONELogo];

const currencySelected = ref(currencies[0])
const chainSelected = ref(chains[0])
const currencyList = ref(currencies)
const chainList = ref(chains)

const amount = ref(undefined)
const address = ref(undefined)
const currentChainId = ref(-1);
const currentProvider = ref({});
const currentEthersProvider = ref({});

const state = ref({
  connected: false,
  supportedAssetsLoaded: false,
  claimCreated: false,
  claimConfirmed: false,
  redeemStarted: false,
  redeemVerified: false,
  redeemConfirmed: false,
})

function getButtonMessage() {
  if(!state.value.connected) return 'Connect';
  if(!state.value.claimCreated) return 'Create Claim';
  if(!state.value.claimConfirmed) return 'waiting for claim confirmation...';
  if(!state.value.redeemStarted) return 'Redeem on target chain';
  if(!state.value.redeemVerified) return 'waiting for 2FV verification...';
  if(!state.value.redeemConfirmed) return 'Finalize redemption';
  return 'Done! Create new claim (restart)';
}

function checkIfValueIsAboveTheMax() {
  console.log("Amount: ", amount.value);
  if (amount.value > Math.pow(2, 32) - 1) amount.value = Math.pow(2, 32) - 1
}

async function ensureChain(requiredChain) {
  let currentChain = Number(wallets.value[0].chains[0].id);

  console.log("CurrentChain: ", currentChain);

  if (currentChain !== requiredChain) {
    console.log("Wrong chain, switching");
    await setChain({
      label: wallets.value[0].label,
      chainId: requiredChain,
    });

    currentChain = Number(wallets.value[0].chains[0].id);
    console.log("CurrentChain is now: ", currentChain);
  }

  if (currentChain !== requiredChain) {
    console.error("We are not on the right chain, please retry to create a claim, exiting the process for now");
    return false;
  }

  return true;
}

async function refreshSupportedAssets() {
  const chainSwitched = await ensureChain(masterStore.chainId);
  if(!chainSwitched) return;

  const _currentProvider = wallets.value[0].provider;
  const _currentEthersProvider = new ethers.BrowserProvider(_currentProvider, 'any')
  const supportedChains = await masterStore.getSupportedChains(_currentEthersProvider);
  const supportedCurrencies = await masterStore.getSupportedCurrencies(_currentEthersProvider);

  const shuffleSort = () => Math.random() - 0.5
  currencyList.value = supportedCurrencies.map((currency) => {
    return {
      name: currency.asset,
      currencyId: currency.index,
      avatar: currencyLogos.sort(shuffleSort).at(0)
    }
  })
  currencySelected.value = currencyList.value[0];

  chainList.value = supportedChains.map((chain) => {
    return {
      name: chain.asset,
      chainId: chain.index,
      avatar: chainsLogos.sort(shuffleSort).at(0)
    }
  });
  chainSelected.value = chainList.value[0];

  state.value.supportedAssetsLoaded = true;

  console.log(supportedChains);
  console.log(supportedCurrencies);
}

watch(connectedWallet, async () => {
  const currentChain = wallets.value[0].chains[0];
  currentProvider.value = wallets.value[0].provider;
  currentEthersProvider.value = new ethers.BrowserProvider(currentProvider.value, 'any')
  currentChainId.value = Number(currentChain.id);
  state.value.connected = true;

  if(!state.value.supportedAssetsLoaded) {
    await refreshSupportedAssets();
  }

  console.log("WalletView watch connectedWallet", wallets.value);
  console.log("CurrentChain is now: ", currentChainId.value);
  console.log("currentProvider is now: ", currentProvider.value);
  console.log("currentEthersProvider is now: ", currentEthersProvider.value);
})

async function startMasterActionChain() {
  if(!state.value.connected) {
    if (wallets.value.length === 0) {
      await connectWallet();
    }
    if (wallets.value.length !== 0) {
      state.value.connected = true;
    }
    return;
  }

  if(!state.value.claimCreated) {
    console.log("Creating claim");

    const chainSwitched = await ensureChain(masterStore.chainId);
    if(!chainSwitched) return;
    console.log("✅ Master Chain ok");

    state.value.claimCreated = true;
    return;
  }

  if(!state.value.claimConfirmed) {
    console.log("Waiting for confirmation");
    state.value.claimConfirmed = true;
    return;
  }

  if(!state.value.redeemStarted) {
    console.log("redemption starting");
    const chainSwitched = await ensureChain(satelliteStore.chainId);
    if(!chainSwitched) return;
    console.log("✅ Satellite Chain ok");
    state.value.redeemStarted = true;
    return;
  }

  if(!state.value.redeemVerified) {
    console.log("waiting for redemption verification");
    state.value.redeemVerified = true;
    return;
  }

  if(!state.value.redeemConfirmed) {
    console.log("confirming redemption");
    state.value.redeemConfirmed = true;
    return;
  }

  console.log('Starting from the beginning (but connected is done already)');
  state.value = {
    connected: true,
    supportedAssetsLoaded: false,
    claimCreated: false,
    claimConfirmed: false,
    redeemStarted: false,
    redeemVerified: false,
    redeemConfirmed: false,
  }
}


</script>