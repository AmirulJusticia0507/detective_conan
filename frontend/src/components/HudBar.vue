<script setup>
import { usePlayerStore } from '@/stores/playerStore'
import { useEpisodeStore } from '@/stores/episodeStore'

const player = usePlayerStore()
const episode = useEpisodeStore()
const emit = defineEmits(['open-inventory', 'open-board'])
</script>

<template>
  <header class="flex flex-wrap items-center gap-x-4 gap-y-2 bg-beika-navy/90 px-4 py-2 text-sm shadow-panel">
    <span class="font-detective text-base font-bold text-beika-gold">Beika District</span>

    <span v-if="episode.currentEpisode" class="text-xs text-slate-300">
      Ep {{ episode.currentEpisode.id }} · {{ episode.currentEpisode.title }}
    </span>

    <div class="flex items-center gap-2">
      <span class="text-slate-300">Stamina</span>
      <div class="h-2 w-24 overflow-hidden rounded-full bg-slate-700">
        <div class="h-full bg-beika-gold transition-all" :style="{ width: `${player.staminaPercent}%` }" />
      </div>
    </div>

    <span class="text-slate-300">
      Poin deduksi: <b class="text-beika-gold">{{ player.deductionPoints }}</b>
    </span>

    <div class="ml-auto flex gap-2">
      <button
        class="rounded-md bg-slate-700 px-3 py-1 transition hover:bg-slate-600"
        type="button"
        @click="emit('open-inventory')"
      >
        Inventaris ({{ player.inventory.length }})
      </button>
      <button
        class="rounded-md bg-beika-red px-3 py-1 font-semibold transition hover:opacity-90"
        type="button"
        @click="emit('open-board')"
      >
        Evidence Board
      </button>
    </div>
  </header>
</template>
