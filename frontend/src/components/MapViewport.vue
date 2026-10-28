<script setup>
import { onMounted, onBeforeUnmount, ref, watch } from 'vue'
import { usePlayerStore } from '@/stores/playerStore'
import { useMapStore } from '@/stores/mapStore'
import { useEpisodeStore } from '@/stores/episodeStore'
import { createRenderer } from '@/game/renderer'
import { createLoop, readMovement, PLAYER_SPEED } from '@/game/loop'
import { NPCS, EVIDENCE_MARKERS, findNearby, isBlocked } from '@/game/worldData'
import { worldToLatLng } from '@/utils/geo'
import DialogueBox from './DialogueBox.vue'
import InventoryPanel from './InventoryPanel.vue'
import EvidenceBoard from './EvidenceBoard.vue'
import HudBar from './HudBar.vue'
import InteractionPrompt from './InteractionPrompt.vue'

const canvasRef = ref(null)
const wrapperRef = ref(null)
const player = usePlayerStore()
const map = useMapStore()
const episode = useEpisodeStore()

const showInventory = ref(false)
const showBoard = ref(false)
const showError = ref(false)
const nearby = ref(null)
const busy = ref(false)

let renderer = null
let loop = null

function update(dt, pressed) {
  const { dx, dy, facing } = readMovement(pressed, PLAYER_SPEED, dt)
  if (dx === 0 && dy === 0) return

  player.setFacing(facing)

  // Sumbu X dan Y diuji terpisah agar pemain bisa "menyusur" dinding.
  const nextX = clamp(player.position.x + dx, 0, map.worldWidth)
  if (!isBlocked(nextX, player.position.y)) player.setPosition(nextX, player.position.y)

  const nextY = clamp(player.position.y + dy, 0, map.worldHeight)
  if (!isBlocked(player.position.x, nextY)) player.setPosition(player.position.x, nextY)
}

function refreshNearby() {
  const npc = findNearby(player.position.x, player.position.y, NPCS)
  if (npc) {
    nearby.value = { type: 'npc', data: npc }
    return
  }
  const uncollected = EVIDENCE_MARKERS.filter(
    (m) => !player.collectedEvidenceIds.includes(m.id),
  )
  const marker = findNearby(player.position.x, player.position.y, uncollected)
  nearby.value = marker ? { type: 'evidence', data: marker } : null
}

function render(time) {
  const rect = wrapperRef.value?.getBoundingClientRect()
  if (!rect) return
  map.centerCameraOn(player.position, { width: rect.width, height: rect.height })
  renderer?.draw({
    camera: map.camera,
    worldWidth: map.worldWidth,
    worldHeight: map.worldHeight,
    player: player.position,
    facing: player.facing,
    collectedEvidenceIds: player.collectedEvidenceIds,
    nearbyId: nearby.value?.type === 'npc' ? nearby.value.data.id : null,
    time,
  })
}

async function interact() {
  if (busy.value || showInventory.value || showBoard.value) return

  // Jika dialog terbuka, E melanjutkan dialog.
  if (episode.activeDialogue) return

  const target = nearby.value
  if (!target) return

  if (target.type === 'npc') {
    episode.openDialogue(target.data.dialogue)
    return
  }

  busy.value = true
  try {
    const coords = worldToLatLng(player.position, map.worldWidth, map.worldHeight)
    await player.syncPositionOnServer(coords.lat, coords.lng)
    const result = await episode.collect(target.data.id)
    if (result) {
      const item = episode.evidence.find((e) => e.id === target.data.id)
      player.inventory = result.inventory
      player.deductionPoints = result.deduction_points
      episode.openDialogue([`Conan: (Ketemu! ${item?.name ?? 'Sebuah bukti'})`])
    }
  } finally {
    busy.value = false
    refreshNearby()
  }
}

function clamp(value, min, max) {
  return Math.min(Math.max(value, min), max)
}

watch(
  () => player.error,
  (message) => {
    showError.value = Boolean(message)
  },
)

watch(
  () => episode.activeDialogue,
  (dialog) => {
    if (dialog) player.setFacing('down')
  },
)

onMounted(() => {
  renderer = createRenderer(canvasRef.value)
  loop = createLoop({
    onUpdate: (dt, pressed, time) => {
      update(dt, pressed)
      refreshNearby()
      render(time)
    },
    onAction: () => {
      if (episode.activeDialogue) {
        // DialogBox menangani klik/E-nya sendiri; arahkan ke tombol lanjut.
        const btn = document.querySelector('[data-dialogue-next]')
        btn?.click()
        return
      }
      interact()
    },
  })
  loop.start()
  render(performance.now())
  player.load()
})

onBeforeUnmount(() => {
  loop?.stop()
  renderer?.destroy()
})
</script>

<template>
  <div ref="wrapperRef" class="relative h-full w-full overflow-hidden bg-beika-ink">
    <canvas ref="canvasRef" class="absolute inset-0 block h-full w-full" />

    <div class="pointer-events-none absolute inset-0 flex flex-col">
      <HudBar class="pointer-events-auto" @open-inventory="showInventory = true" @open-board="showBoard = true" />

      <div class="mt-auto">
        <p v-if="player.isLoading" class="px-4 pb-1 text-xs text-slate-400">Memuat data pemain…</p>
        <p v-if="busy" class="px-4 pb-1 text-xs text-beika-gold">Memeriksa bukti…</p>

        <DialogueBox v-if="episode.activeDialogue" @close="episode.closeDialogue()" />

        <InteractionPrompt
          v-else-if="nearby"
          :type="nearby.type"
          :label="nearby.type === 'npc' ? nearby.data.name : 'Periksa bukti'"
          @activate="interact"
        />

        <div v-else-if="showError && player.error" class="pointer-events-auto px-4 pb-4">
          <div class="mx-auto flex max-w-3xl items-start gap-3 rounded-xl border-2 border-beika-red bg-beika-fog/95 p-4">
            <p class="flex-1 text-sm text-slate-100">{{ player.error }}</p>
            <button class="text-xs text-slate-400 hover:text-slate-100" type="button" @click="showError = false">
              Tutup
            </button>
          </div>
        </div>
      </div>
    </div>

    <InventoryPanel v-if="showInventory" @close="showInventory = false" />
    <EvidenceBoard v-if="showBoard" @close="showBoard = false" />
  </div>
</template>
