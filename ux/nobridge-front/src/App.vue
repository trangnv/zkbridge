<!--<template>-->
<!--  <header>-->
<!--    <img alt="Vue logo" class="logo" src="@/assets/logo.svg" width="125" height="125" />-->

<!--    <div class="wrapper">-->
<!--      <nav>-->
<!--        <RouterLink to="/">Home</RouterLink>-->
<!--        <RouterLink to="/about">About</RouterLink>-->
<!--        <RouterLink to="/deposit">Deposit</RouterLink>-->
<!--      </nav>-->
<!--    </div>-->
<!--  </header>-->

<!--  <RouterView />-->
<!--</template>-->
<template>
  <div class="min-h-full z-10">
    <Popover as="header" class="bg-indigo-600 pb-24" v-slot="{ open }">
      <div class="mx-auto max-w-3xl px-4 sm:px-6 lg:max-w-7xl lg:px-8">
        <div class="relative flex items-center justify-center py-5 lg:justify-between">
          <!-- Logo -->
          <div class="absolute left-0 flex-shrink-0 lg:static">
            <a href="#">
              <span class="sr-only">NoAB</span>
              <span class="text-6xl">🌁</span>
            </a>
          </div>

          <!-- Right section on desktop -->
          <div class="hidden lg:ml-4 lg:flex lg:items-center lg:pr-0.5">
            <button type="button" class="relative flex-shrink-0 rounded-full p-1 text-indigo-200 hover:bg-white hover:bg-opacity-10 hover:text-white focus:outline-none focus:ring-2 focus:ring-white">
              <span class="absolute -inset-1.5" />
              <span class="sr-only">View notifications</span>
              <BellIcon class="h-6 w-6" aria-hidden="true" />
            </button>
          </div>

          <!-- Search -->
          <div class="min-w-0 flex-1 px-12 lg:hidden">
<!--            <div class="mx-auto w-full max-w-xs">-->
<!--              <label for="desktop-search" class="sr-only">Search</label>-->
<!--              <div class="relative text-white focus-within:text-gray-600">-->
<!--                <div class="pointer-events-none absolute inset-y-0 left-0 flex items-center pl-3">-->
<!--                  <MagnifyingGlassIcon class="h-5 w-5" aria-hidden="true" />-->
<!--                </div>-->
<!--                <input id="desktop-search" class="block w-full rounded-md border-0 bg-white/20 py-1.5 pl-10 pr-3 text-white placeholder:text-white focus:bg-white focus:text-gray-900 focus:ring-0 focus:placeholder:text-gray-500 sm:text-sm sm:leading-6" placeholder="Search" type="search" name="search" />-->
<!--              </div>-->
<!--            </div>-->
            <!-- Right Sidebar Header -->
          </div>
        </div>
        <div class="hidden border-t border-white border-opacity-20 py-5 lg:block">
          <div class="grid grid-cols-3 items-center gap-8">
            <div class="col-span-2">
              <nav class="flex space-x-4">
                <RouterLink v-for="item in navigation" :key="item.name" :to="item.href" :class="[item.current ? 'text-white' : 'text-indigo-100', 'rounded-md bg-white bg-opacity-0 px-3 py-2 text-sm font-medium hover:bg-opacity-10']" :aria-current="item.current ? 'page' : undefined">{{ item.name }}</RouterLink>
              </nav>
            </div>
            <div>
              <div class="mx-auto w-full max-w-md text-indigo-100">
                <!-- Right Sidebar Header -->
                <RouterView class="view wallet overflow-visible" name="Wallet"></RouterView>
              </div>
<!--              <div class="mx-auto w-full max-w-md">-->
<!--                <label for="mobile-search" class="sr-only">Search</label>-->
<!--                <div class="relative text-white focus-within:text-gray-600">-->
<!--                  <div class="pointer-events-none absolute inset-y-0 left-0 flex items-center pl-3">-->
<!--                    <MagnifyingGlassIcon class="h-5 w-5" aria-hidden="true" />-->
<!--                  </div>-->
<!--                  <input id="mobile-search" class="block w-full rounded-md border-0 bg-white/20 py-1.5 pl-10 pr-3 text-white placeholder:text-white focus:bg-white focus:text-gray-900 focus:ring-0 focus:placeholder:text-gray-500 sm:text-sm sm:leading-6" placeholder="Search" type="search" name="search" />-->
<!--                </div>-->
<!--              </div>-->
            </div>
          </div>
        </div>
      </div>

      <TransitionRoot as="template" :show="open">
        <div class="lg:hidden">
          <TransitionChild as="template" enter="duration-150 ease-out" enter-from="opacity-0" enter-to="opacity-100" leave="duration-150 ease-in" leave-from="opacity-100" leave-to="opacity-0">
            <PopoverOverlay class="fixed inset-0 z-20 bg-black bg-opacity-25" />
          </TransitionChild>

          <TransitionChild as="template" enter="duration-150 ease-out" enter-from="opacity-0 scale-95" enter-to="opacity-100 scale-100" leave="duration-150 ease-in" leave-from="opacity-100 scale-100" leave-to="opacity-0 scale-95">
            <PopoverPanel focus class="absolute inset-x-0 top-0 z-30 mx-auto w-full max-w-3xl origin-top transform p-2 transition">
              <div class="divide-y divide-gray-200 rounded-lg bg-white shadow-lg ring-1 ring-black ring-opacity-5">
                <div class="pb-2 pt-3">
                  <div class="flex items-center justify-between px-4">
                    <div>
                      <span class="sr-only">NoAB</span>
                      <span class="text-6xl">🌁</span>
                    </div>
                    <div class="-mr-2">
                      <PopoverButton class="relative inline-flex items-center justify-center rounded-md bg-white p-2 text-gray-400 hover:bg-gray-100 hover:text-gray-500 focus:outline-none focus:ring-2 focus:ring-inset focus:ring-indigo-500">
                        <span class="absolute -inset-0.5" />
                        <span class="sr-only">Close menu</span>
                        <XMarkIcon class="h-6 w-6" aria-hidden="true" />
                      </PopoverButton>
                    </div>
                  </div>
                  <div class="mt-3 space-y-1 px-2">
                    <RouterLink v-for="item in navigation" :key="item.name" :to="item.href" :class="[item.current ? 'text-white' : 'text-indigo-100', 'rounded-md bg-white bg-opacity-0 px-3 py-2 text-sm font-medium hover:bg-opacity-10']" :aria-current="item.current ? 'page' : undefined">{{ item.name }}</RouterLink>
                  </div>
                </div>
<!--                <div class="pb-2 pt-4">-->
<!--                  <div class="flex items-center px-5">-->
<!--                    <div class="flex-shrink-0">-->
<!--                      <img class="h-10 w-10 rounded-full" :src="user.imageUrl" alt="" />-->
<!--                    </div>-->
<!--                    <div class="ml-3 min-w-0 flex-1">-->
<!--                      <div class="truncate text-base font-medium text-gray-800">{{ user.name }}</div>-->
<!--                      <div class="truncate text-sm font-medium text-gray-500">{{ user.email }}</div>-->
<!--                    </div>-->
<!--                    <button type="button" class="relative ml-auto flex-shrink-0 rounded-full bg-white p-1 text-gray-400 hover:text-gray-500 focus:outline-none focus:ring-2 focus:ring-indigo-500 focus:ring-offset-2">-->
<!--                      <span class="absolute -inset-1.5" />-->
<!--                      <span class="sr-only">View notifications</span>-->
<!--                      <BellIcon class="h-6 w-6" aria-hidden="true" />-->
<!--                    </button>-->
<!--                  </div>-->
<!--                </div>-->
              </div>
            </PopoverPanel>
          </TransitionChild>
        </div>
      </TransitionRoot>
    </Popover>
    <main class="-mt-24 pb-8">
      <div class="mx-auto max-w-3xl px-4 sm:px-6 lg:max-w-7xl lg:px-8">
        <h1 class="sr-only">Transactions</h1>
        <!-- Main 3 column grid -->
        <div class="grid grid-cols-1 items-start gap-4 lg:grid-cols-3 lg:gap-8">
          <!-- Left column -->
          <div class="grid grid-cols-1 gap-4 lg:col-span-2">
            <section aria-labelledby="section-1-title">
              <h2 class="sr-only" id="section-1-title">Claim</h2>
              <div class="overflow-hidden rounded-lg bg-white shadow">
                <div class="p-6">
                  <!-- actual router -->
                  <RouterView class="view left-sidebar overflow-visible" name="LeftSidebar"></RouterView>
                </div>
              </div>
            </section>
          </div>

          <!-- Right column -->
          <div class="grid grid-cols-1 gap-4">
            <section aria-labelledby="section-2-title">
              <h2 class="sr-only" id="section-2-title">
                <!-- Right Sidebar Header -->
              </h2>
              <div class="overflow-hidden rounded-lg bg-white shadow">
                <div class="p-6">
                  <!-- default router -->
                  <RouterView class="view right-sidebar overflow-visible" name="RightSidebar"></RouterView>
                </div>
              </div>
            </section>
          </div>
        </div>
      </div>
    </main>
    <footer>
      <div class="mx-auto max-w-3xl px-4 sm:px-6 lg:max-w-7xl lg:px-8">
        <div class="border-t border-gray-200 py-8 text-center text-sm text-gray-500 sm:text-left"><span class="block sm:inline">&copy; 2023 Trang Nguyen Vu & Nicolas Embleton</span> <span class="block sm:inline">All rights reserved.</span></div>
      </div>
    </footer>
  </div>
</template>

<script setup>
import {
  Popover,
  PopoverButton,
  PopoverOverlay,
  PopoverPanel,
  TransitionChild,
  TransitionRoot,
} from '@headlessui/vue'
import { Bars3Icon, BellIcon, XMarkIcon } from '@heroicons/vue/24/outline'
import { RouterLink, RouterView } from 'vue-router'

function reactToOnCreate(event) {
  console.log("Payload received", event);
}

const navigation = [
  { name: 'Home', href: '/', current: true },
  // { name: 'About', href: '/about', current: false },
  // { name: 'Deposit', href: '/deposit', current: false },
  // { name: 'Claim', href: '/claim', current: false },
  // { name: 'Team', href: '/team', current: false },
]

</script>