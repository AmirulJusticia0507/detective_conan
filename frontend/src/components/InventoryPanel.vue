<script setup>
import { X } from 'lucide-vue-next'
import { usePlayerStore } from '@/stores/playerStore'

defineEmits(['close'])
const player = usePlayerStore()
</script>

<template>
  <div class="pointer-events-auto absolute inset-0 z-20 flex items-center justify-center bg-black/60 p-6">
    <section class="flex max-h-full w-full max-w-lg flex-col rounded-xl border border-slate-700 bg-beika-fog p-5 shadow-panel">
      <header class="mb-4 flex items-center justify-between">
        <div>
          <h2 class="font-detective text-xl text-beika-gold">Inventaris</h2>
          <p class="text-xs text-slate-400">{{ player.inventory.length }} item · {{ player.deductionPoints }} poin deduksi</p>
        </div>
        <button class="rounded p-1 hover:bg-slate-700" type="button" aria-label="Tutup" @click="$emit('close')">
          <X class="h-5 w-5" />
        </button>
      </header>

      <p v-if="player.isLoading" class="text-sm text-slate-400">Memuat inventaris…</p>

      <p v-else-if="!player.inventory.length" class="text-sm text-slate-400">
        Belum ada item. Jelajahi Distrik Beika dan periksa lokasi bertanda merah.
      </p>

      <ul class="grid grid-cols-1 gap-3 overflow-y-auto sm:grid-cols-2">
        <li
          v-for="item in player.inventory"
          :key="item.id"
          class="rounded-lg border border-slate-700 bg-slate-800/70 p-3"
        >
          <p class="text-sm font-semibold text-slate-100">{{ item.name }}</p>
          <p class="mt-1 text-xs text-slate-400">{{ item.description }}</p>
        </li>
      </ul>
    </section>
  </div>
</template>
