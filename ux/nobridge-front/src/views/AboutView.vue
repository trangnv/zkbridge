<template>
  <div class="bg-white">
    <div class="mx-auto max-w-7xl">
      <div class="mx-auto max-w-4xl divide-y divide-gray-900/10">
        <h2 class="text-2xl font-bold leading-10 tracking-tight text-gray-900">How does it work?</h2>
        <dl class="mt-2 space-y-6 divide-y divide-gray-900/10">
          <Disclosure>
            <dt>
              <DisclosureButton class="flex w-full items-start justify-between text-left text-gray-900">
                <span class="text-base font-semibold leading-7">How does it work?</span>
                <span class="ml-6 flex h-7 items-center">
                <PlusSmallIcon v-if="!open" class="h-6 w-6" aria-hidden="true" />
                <MinusSmallIcon v-else class="h-6 w-6" aria-hidden="true" />
              </span>
              </DisclosureButton>
            </dt>
            <DisclosurePanel as="dd" class="mt-2 pr-12">
              <ol class="list-decimal list-inside">
                <li>Enter the address you want to send to on the desired chain</li>
                <li>Enter the amount and the currency</li>
                <li>Click "Create Claim" to trigger the process</li>
                <li>Validate the approval and sign the deposit (of the amount and currency you have selected)</li>
                <li>Once the transfer has completed, you will see a button "Claim", click it, this will trigger the Claim process on the target chain</li>
                <li>A ZK proof of the deposit on the source chain (the master chain) will be generated and sent to the verifier on the destination chain</li>
                <li>If the proof is valid, it will confirm it, and request a decentralized validation</li>
                <li>Once the validation has happened, the claim ticket on the destination chain will be marked as ready to finalize</li>
                <li>At which point, you will be able to click the final button "Finalize Claim Request", sign the request and proceed, and the funds will be added to your address on the destination chain</li>
              </ol>
            </DisclosurePanel>
          </Disclosure>
          <Disclosure>
            <dt>
              <DisclosureButton class="flex w-full items-start justify-between text-left text-gray-900">
                <span class="text-base font-semibold leading-7">Is it the same money than on ETH chain?</span>
                <span class="ml-6 flex h-7 items-center">
                <PlusSmallIcon v-if="!open" class="h-6 w-6" aria-hidden="true" />
                <MinusSmallIcon v-else class="h-6 w-6" aria-hidden="true" />
              </span>
              </DisclosureButton>
            </dt>
            <DisclosurePanel as="dd" class="mt-2 pr-12">
              Yes and no. It is backed 1:1 by the reserves on Ethereum mainnet, and therefore holds the same value. But
              technically speaking, it is a different token. <br/>
              <span class="bg-amber-200">
                Important note: As a caveat, the places you use need to support that currency.
              </span>
            </DisclosurePanel>
          </Disclosure>
        </dl>
      </div>
    </div>
  </div>
</template>

<script setup>
import { Disclosure, DisclosureButton, DisclosurePanel } from '@headlessui/vue'
import { MinusSmallIcon, PlusSmallIcon } from '@heroicons/vue/24/outline'



</script>