<script setup>
import { ref, computed } from 'vue'
import { X, Link2, CheckCircle2 } from 'lucide-vue-next'
import { useEpisodeStore } from '@/stores/episodeStore'

defineEmits(['close'])
const episode = useEpisodeStore()

const selected = ref([])
const feedback = ref(null)
const solving = ref(false)

const canConnect = computed(() => selected.value.length === 2)

function isCollected(id) {
  return episode.collectedEvidenceIds.includes(id)
}

function toggleSelect(id) {
  feedback.value = null
  if (selected.value.includes(id)) {
    selected.value = selected.value.filter((x) => x !== id)
    return
  }
  // Simpan maksimal 2 pilihan terakhir
  selected.value = [...selected.value, id].slice(-2)
}

async function connect() {
  if (!canConnect.value || solving.value) return
  solving.value = true
  try {
    const [fromId, toId] = selected.value
    const result = await episode.connectEvidence(fromId, toId)
    feedback.value = result.ok
      ? { ok: true, text: 'Deduksi valid! Kesimpulan baru terbuka.' }
      : { ok: false, text: result.reason }
    if (result.ok) selected.value = []
  } finally {
    solving.value = false
  }
}
</script>

<template>
  <div class="pointer-events-auto absolute inset-0 z-20 flex items-center justify-center bg-black/70 p-6">
    <section class="flex max-h-full w-full max-w-3xl flex-col rounded-xl border border-slate-700 bg-beika-fog p-5 shadow-panel">
      <header class="mb-4 flex items-start justify-between">
        <div>
          <h2 class="font-detective text-xl text-beika-gold">Evidence Board</h2>
          <p class="text-xs text-slate-400">
            {{ episode.solvedNodeIds.length }} deduksi terpecahkan dari
            {{ episode.deductionEdges.length }} kemungkinan
          </p>
        </div>
        <button class="rounded p-1 hover:bg-slate-700" type="button" aria-label="Tutup" @click="$emit('close')">
          <X class="h-5 w-5" />
        </button>
      </header>

      <div class="grid grid-cols-2 gap-3 overflow-y-auto md:grid-cols-3">
        <button
          v-for="item in episode.evidence"
          :key="item.id"
          type="button"
          class="rounded-lg border-2 p-3 text-left transition disabled:cursor-not-allowed disabled:opacity-35"
          :class="
            selected.includes(item.id)
              ? 'border-beika-gold bg-slate-700'
              : 'border-slate-700 bg-slate-800/70 hover:border-slate-500'
          "
          :disabled="!isCollected(item.id)"
          @click="toggleSelect(item.id)"
        >
          <div class="flex items-start justify-between gap-2">
            <p class="text-sm font-semibold text-slate-100">{{ item.name }}</p>
            <CheckCircle2 v-if="isCollected(item.id)" class="h-4 w-4 shrink-0 text-emerald-400" />
          </div>
          <p class="mt-1 text-xs text-slate-400">{{ item.description }}</p>
          <span
            v-if="item.is_key_evidence"
            class="mt-2 inline-block rounded bg-beika-red px-2 py-0.5 text-[10px] font-bold uppercase"
          >
            Bukti kunci
          </span>
          <span v-else-if="!isCollected(item.id)" class="mt-2 inline-block text-[10px] uppercase text-slate-500">
            Belum dikumpulkan
          </span>
        </button>
      </div>

      <footer class="mt-5 flex items-center gap-3">
        <button
          type="button"
          class="flex items-center gap-2 rounded-md px-4 py-2 font-semibold transition disabled:opacity-40"
          :class="canConnect ? 'bg-beika-gold text-beika-ink' : 'bg-slate-700 text-slate-400'"
          :disabled="!canConnect || solving"
          @click="connect"
        >
          <Link2 class="h-4 w-4" /> {{ solving ? 'Menguji…' : 'Hubungkan' }}
        </button>
        <p v-if="feedback" class="text-sm" :class="feedback.ok ? 'text-emerald-400' : 'text-beika-red'">
          {{ feedback.text }}
        </p>
        <p v-else class="text-sm text-slate-400">Pilih dua bukti untuk menguji deduksi.</p>
      </footer>
    </section>
  </div>
</template>
