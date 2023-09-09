<template>
  <form action="#" class="relative">
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
        <Listbox as="div" v-model="currency" class="flex-shrink-0">
          <ListboxLabel class="sr-only">Currency</ListboxLabel>
          <div class="relative">
            <ListboxButton
              class="relative inline-flex items-center whitespace-nowrap rounded-full bg-gray-50 px-2 py-2 text-sm font-medium text-gray-500 hover:bg-gray-100 sm:px-3">
              <UserCircleIcon v-if="currency.value === null" class="h-5 w-5 flex-shrink-0 text-gray-300 sm:-ml-1"
                              aria-hidden="true"/>
              <img v-else :src="currency.avatar" alt="" class="h-5 w-5 flex-shrink-0 rounded-full"/>

              <span :class="[currency.value === null ? '' : 'text-gray-900', 'hidden truncate sm:ml-2 sm:block']">{{
                  currency.value === null ? 'Currency' : currency.name
                }}</span>
            </ListboxButton>

            <transition leave-active-class="transition ease-in duration-100" leave-from-class="opacity-100"
                        leave-to-class="opacity-0">
              <ListboxOptions
                class="absolute right-0 z-10 mt-1 max-h-56 w-52 overflow-auto rounded-lg bg-white py-3 text-base shadow ring-1 ring-black ring-opacity-5 focus:outline-none sm:text-sm">
                <ListboxOption as="template" v-for="currency in currencies" :key="currency.value" :value="currency"
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
        <Listbox as="div" v-model="chain" class="flex-shrink-0">
          <ListboxLabel class="sr-only">Add a label</ListboxLabel>
          <div class="relative">
            <ListboxButton
              class="relative inline-flex items-center whitespace-nowrap rounded-full bg-gray-50 px-2 py-2 text-sm font-medium text-gray-500 hover:bg-gray-100 sm:px-3">
              <UserCircleIcon v-if="chain.value === null" class="h-5 w-5 flex-shrink-0 text-gray-300 sm:-ml-1"
                              aria-hidden="true"/>
              <img v-else :src="chain.avatar" alt="" class="h-5 w-5 flex-shrink-0 rounded-full"/>

              <span :class="[chain.value === null ? '' : 'text-gray-900', 'hidden truncate sm:ml-2 sm:block']">{{
                  chain.value === null ? 'Label' : chain.name
                }}</span>
            </ListboxButton>

            <transition leave-active-class="transition ease-in duration-100" leave-from-class="opacity-100"
                        leave-to-class="opacity-0">
              <ListboxOptions
                class="absolute right-0 z-10 mt-1 max-h-56 w-52 overflow-auto rounded-lg bg-white py-3 text-base shadow ring-1 ring-black ring-opacity-5 focus:outline-none sm:text-sm">
                <ListboxOption as="template" v-for="label in chains" :key="label.value" :value="label"
                               v-slot="{ active }">
                  <li :class="[active ? 'bg-gray-100' : 'bg-white', 'relative cursor-default select-none px-3 py-2']">
                    <div class="flex items-center">
                      <img v-if="label.avatar" :src="label.avatar" alt="" class="h-5 w-5 flex-shrink-0 rounded-full"/>
                      <TagIcon v-else class="h-5 w-5 flex-shrink-0 text-gray-400" aria-hidden="true"/>
                      <span class="ml-3 block truncate font-medium">{{ label.name }}</span>
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
          <button type="submit"
                  class="inline-flex items-center rounded-md bg-indigo-600 px-3 py-2 text-sm font-semibold text-white shadow-sm hover:bg-indigo-500 focus-visible:outline focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-indigo-600">
            Create
          </button>
        </div>
      </div>
    </div>
  </form>
</template>

<script setup>
import {ref} from 'vue'
import {Listbox, ListboxButton, ListboxLabel, ListboxOption, ListboxOptions} from '@headlessui/vue'
import {TagIcon, UserCircleIcon} from '@heroicons/vue/20/solid'
import USDTLogo from '~/svg/icon/usdt.svg'
import RIPPLELogo from '~/svg/icon/xrp.svg'
import AVAXLogo from '~/svg/icon/avax.svg'
import ONELogo from '~/svg/icon/one.svg'

const emits = defineEmits(["on-create"]);

const currencies = [
  // { name: 'Unassigned', value: null },
  {
    name: 'USDT',
    value: 'USDT',
    avatar: USDTLogo,
  },
  {
    name: 'XRP',
    value: 'XRP',
    avatar: RIPPLELogo,
  },
]
const chains = [
  {name: 'Arbitrum One', value: '3', avatar: AVAXLogo,},
  {name: 'Avalanche', value: '4', avatar: ONELogo},
  // More items...
]

const currency = ref(currencies[0])
const chain = ref(chains[0])

const amount = ref(0)
const address = ref("0x1337")

function checkIfValueIsAboveTheMax() {
  console.log("Amount: ", amount.value);
  if (amount.value > Math.pow(2, 32) - 1) amount.value = Math.pow(2, 32) - 1
}

</script>