<script setup>
import { onMounted, onBeforeUnmount, ref, computed } from 'vue'
import { X } from 'lucide-vue-next'
import { useEpisodeStore } from '@/stores/episodeStore'

const emit = defineEmits(['close'])
const episode = useEpisodeStore()

const index = ref(0)

const nodes = computed(() => {
  const source = episode.activeDialogue ?? []
  return Array.isArray(source) ? source : [source]
})
const current = computed(() => nodes.value[index.value] ?? '')
const isLast = computed(() => index.value >= nodes.value.length - 1)

function splitLine(line) {
  // Format "Speaker: teks" atau teks bebas
  const match = /^([^:]{1,24}):\s*(.+)$/s.exec(line ?? '')
  return match ? { speaker: match[1], text: match[2] } : { speaker: '', text: line ?? '' }
}

function next() {
  if (isLast.value) {
    emit('close')
    return
  }
  index.value += 1
}

function skip() {
  emit('close')
}
</script>

<template>
  <div class="pointer-events-auto px-4 pb-4">
    <div class="mx-auto max-w-3xl rounded-xl border-2 border-beika-gold bg-beika-fog/95 p-4 shadow-panel backdrop-blur">
      <div class="flex items-start gap-3">
        <div class="grid h-12 w-12 shrink-0 place-items-center rounded-lg bg-beika-navy text-lg font-bold text-beika-gold">
          {{ splitLine(current).speaker.slice(0, 1) || '❓' }}
        </div>

        <div class="min-w-0 flex-1">
          <p v-if="splitLine(current).speaker" class="mb-1 font-detective text-sm font-bold uppercase tracking-wide text-beika-gold">
            {{ splitLine(current).speaker }}
          </p>
          <p class="text-base leading-relaxed text-slate-100">{{ splitLine(current).text }}</p>

          <div class="mt-3 flex items-center gap-2 text-xs text-slate-400">
            <button
              data-dialogue-next
              class="rounded bg-beika-gold px-3 py-1 text-xs font-semibold text-beika-ink hover:opacity-90"
              type="button"
              @click="next"
            >
              {{ isLast ? 'Selesai (E)' : 'Lanjut (E)' }}
            </button>
            <button class="rounded px-2 py-1 hover:bg-slate-700 hover:text-slate-100" type="button" @click="skip">
              Lewati
            </button>
            <span class="ml-auto">{{ index + 1 }} / {{ nodes.length }}</span>
          </div>
        </div>

        <button class="rounded p-1 hover:bg-slate-700" type="button" aria-label="Tutup dialog" @click="emit('close')">
          <X class="h-4 w-4" />
        </button>
      </div>
    </div>
  </div>
</template>
