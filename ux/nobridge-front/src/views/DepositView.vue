<template>
  <div>
    <h1 class="text-5xl text-center mb-10">
      NotABridge [NoAB] is a new kind of bridge
    </h1>
    <h2 class="text-2xl mt-2">
      Leveraging ZK proofs and cryptography to be verifiably decentralized. <br/>
      It's also the first bridge to not actually be a bridge. More like a teleporting device.
    </h2>
    <div class="my-2">
      <span class="bg-amber-200">
        Important note: only the address market in the form below can claim the request at final stage. Once you have started the process, if the account doesn't belong to you, ask the destination wallet to finalize the claim. The claim ID will be displayed on this page.
      </span>
    </div>
    <Deposit class="mt-6" @on-create="reactToOnCreate"></Deposit>
  </div>
</template>
<script setup>
import Deposit from "@/components/Deposit.vue";

function reactToOnCreate(event) {
  console.log("Payload received", event);
}

</script>
<style>
@media (min-width: 1024px) {
  .about {
    min-height: 100vh;
    display: flex;
    align-items: center;
  }
}
</style>
