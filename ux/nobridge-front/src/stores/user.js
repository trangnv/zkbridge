import {ref, computed} from 'vue'
import {defineStore} from 'pinia'

export const useUserStore = defineStore('user', () => {
  const connectionStateEnum = {
    none: 'none',
    connectionRequested: 'requested',
    started: 'started',
    ready: 'ready',
    connected: 'connected',
    disconnected: 'disconnected',
    disconnectionRequested: 'disconnectionRequested'
  }

  const connectionStatus = ref(connectionStateEnum.none);
  const address = ref("");

  const connectionStates = computed(() => Object.keys[connectionStateEnum]);
  const connectionRequested = computed(() => connectionStatus.value === connectionStateEnum.connectionRequested);
  const disconnectionRequested = computed(() => connectionStatus.value === connectionStateEnum.disconnectionRequested);

  function requestWalletConnection() {
    connectionStatus.value = connectionStateEnum.connectionRequested;
  }

  function requestWalletDisconnection() {
    connectionStatus.value = connectionStateEnum.disconnectionRequested;
  }

  function setCurrentChain(chain) {
    currentChain.value = chain;
  }

  function setConnected(_address) {
    address.value = _address;
    connectionStatus.value = connectionStateEnum.connected;
  }

  function setDisconnected() {
    address.value = undefined;
    connectionStatus.value = connectionStateEnum.none;
  }

  return {
    address,
    connectionStates,
    requestWalletConnection,
    setConnected,
    setCurrentChain,
    setDisconnected,
    requestWalletDisconnection,
    connectionRequested,
    disconnectionRequested
  }
})
