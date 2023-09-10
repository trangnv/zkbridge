import {ref, computed} from 'vue'
import {defineStore} from 'pinia'

export const useClaimStore = defineStore('claim', () => {
  const claimIds = ref([]);

  const claimAt = computed((id) => claimIds.value.at(id));

  function addClaim(claim) {
    // TODO: add a claim model
    claimIds.value.push(claim);
  }

  return {
    claimAt,
    addClaim,
  }
})
