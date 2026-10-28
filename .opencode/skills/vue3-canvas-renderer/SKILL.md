---
name: vue3-canvas-renderer
description: >-
  Menghasilkan komponen Vue 3 (Composition API, script setup) dengan HTML5
  Canvas atau PixiJS untuk peta top-down Distrik Beika, movement pemain, dialog
  box, inventory, dan evidence board, dibungkus overlay Tailwind. Gunakan saat
  membangun UI game atau render map.
---

# Vue3 Canvas Renderer

## Struktur file

```text
frontend/
├── src/
│   ├── components/
│   │   ├── MapViewport.vue
│   │   ├── DialogueBox.vue
│   │   ├── InventoryPanel.vue
│   │   └── EvidenceBoard.vue
│   ├── stores/
│   │   ├── playerStore.js
│   │   ├── mapStore.js
│   │   └── episodeStore.js
│   └── game/
│       ├── renderer.js
│       └── loop.js
```

## Aturan komponen

1. Selalu `<script setup>` + Composition API. Tanpa Options API.
2. State game tinggal di Pinia, **bukan** di komponen. Komponen hanya membaca dan
   mengirim aksi.
3. Canvas render loop:
   - Gunakan `requestAnimationFrame` dengan delta time, bukan `setInterval`.
   - Bersihkan listener dan `cancelAnimationFrame` di `onBeforeUnmount`.
   - Tangani `devicePixelRatio` dan resize (`ResizeObserver`).
4. Input keyboard jangan menangkap key saat fokus berada di `<input>`/dialog.
5. UI overlay (dialog, inventory, HUD) memakai Tailwind di atas canvas dengan
   `pointer-events-none` pada wrapper dan `pointer-events-auto` pada kontrol.
6. Pisahkan logika render murni (`game/renderer.js`) dari komponen agar bisa
   dites tanpa DOM.

## Contoh pola MapViewport

```vue
<script setup>
import { onMounted, onBeforeUnmount, ref } from 'vue'
import { usePlayerStore } from '@/stores/playerStore'
import { createRenderer } from '@/game/renderer'

const canvasRef = ref(null)
const player = usePlayerStore()
let renderer = null
let rafId = 0
let last = 0

function frame(now) {
  const dt = Math.min((now - last) / 1000, 0.1)
  last = now
  renderer.update(dt, player.position)
  renderer.draw()
  rafId = requestAnimationFrame(frame)
}

onMounted(() => {
  renderer = createRenderer(canvasRef.value)
  last = performance.now()
  rafId = requestAnimationFrame(frame)
})

onBeforeUnmount(() => {
  cancelAnimationFrame(rafId)
  renderer?.destroy()
})
</script>

<template>
  <div class="relative w-full h-full overflow-hidden bg-slate-900">
    <canvas ref="canvasRef" class="absolute inset-0 h-full w-full" />
    <div class="pointer-events-none absolute inset-0">
      <!-- HUD / DialogueBox / Inventory -->
    </div>
  </div>
</template>
```

## Tema visual

- Palet Detective Conan: biru tua (`#1e3a8a`), merah (`#dc2626`), kuning aksen
  (`#facc15`), dasar gelap netral.
- Font judul bernuansa detektif/retro; body tetap sans-serif yang mudah dibaca.
- Dialog box: panel semi-transparan, sudut membulat, nama speaker berwarna
  aksen.

## Checklist sebelum selesai

- [ ] Tidak ada memory leak (listener/RAF dibersihkan).
- [ ] Canvas responsif dan tajam di layar HiDPI.
- [ ] State tetap di Pinia; komponen stateless semaksimal mungkin.
- [ ] `npm run build` atau `npm run lint` lolos bila tersedia.
