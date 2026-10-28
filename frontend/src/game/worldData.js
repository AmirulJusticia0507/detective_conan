/**
 * Data dunia statis: bangunan, jalan, NPC, dan marker bukti.
 * Koordinat dalam piksel dunia. Renderer, collision, dan interaksi membaca
 * dari sini supaya bentuk visual dan logika selalu sinkron.
 */

export const WORLD = {
  width: 2048,
  height: 1536,
}

export const ROADS = [
  // { x, y, w, h } persegi panjang jalan
  { x: 0, y: 640, w: 2048, h: 96 }, // jalan utama horizontal
  { x: 900, y: 0, w: 96, h: 1536 }, // jalan utama vertikal
  { x: 0, y: 1100, w: 2048, h: 72 }, // jalan sekunder
]

export const BUILDINGS = [
  { id: 'kantor-mouri', name: 'Kantor Detektif Mouri', x: 180, y: 180, w: 320, h: 220, area: 'Kantor Detektif Mouri' },
  { id: 'cafe-poirot', name: 'Cafe Poirot', x: 1120, y: 180, w: 280, h: 200, area: 'Cafe Poirot' },
  { id: 'tropical-land', name: 'Tropical Land', x: 1600, y: 820, w: 300, h: 180, area: 'Tropical Land' },
  { id: 'museum', name: 'Museum Beika', x: 150, y: 860, w: 320, h: 200, area: 'Museum Beika' },
  { id: 'sekolah', name: 'Sekolah Teitan', x: 1120, y: 1220, w: 360, h: 200, area: 'Sekolah Teitan' },
]

export const NPCS = [
  {
    id: 'kogoro-mouri',
    name: 'Kogoro Mouri',
    x: 340,
    y: 470,
    dialogue: [
      'Kogoro: Aku dijebak! Aku tak pernah menyentuh gelas itu!',
      'Conan: (Ada sesuatu yang aneh dengan jas di rekaman CCTV...)',
    ],
    questHint: 'Periksa gelas dan rekaman di sekitar kantor.',
  },
  {
    id: 'amuro-tooru',
    name: 'Amuro Tooru',
    x: 1250,
    y: 440,
    dialogue: [
      'Amuro: Selamat pagi. Kafe sedang sibuk, tapi aku punya waktu sebentar.',
      'Amuro: Ada tamu yang meninggalkan tiket... kamu mungkin perlu memeriksanya.',
    ],
    questHint: 'Cari tiket di sekitar Cafe Poirot.',
  },
  {
    id: 'sera-masumi',
    name: 'Sera Masumi',
    x: 1180,
    y: 520,
    dialogue: [
      'Sera: Kamu juga menyelidiki kasus ini? Bagus, aku tidak keberatan bekerja sama.',
    ],
    questHint: 'Bicaralah dengan Amuro untuk informasi lebih lanjut.',
  },
]

/**
 * Marker bukti di peta. `id` harus sama dengan evidence.id di database.
 */
export const EVIDENCE_MARKERS = [
  { id: 1126001, x: 1024, y: 768 },
  { id: 1126002, x: 1087, y: 846 },
  { id: 1126003, x: 952, y: 679 },
]

export const INTERACT_RADIUS = 60 // piksel

export function findNearby(targetX, targetY, list, radius = INTERACT_RADIUS) {
  let closest = null
  let closestDist = Infinity
  for (const item of list) {
    const dist = Math.hypot(item.x - targetX, item.y - targetY)
    if (dist <= radius && dist < closestDist) {
      closest = item
      closestDist = dist
    }
  }
  return closest
}

/**
 * Blokir pergerakan pemain ke dalam bangunan.
 */
export function isBlocked(x, y, radius = 12) {
  for (const b of BUILDINGS) {
    if (
      x + radius > b.x &&
      x - radius < b.x + b.w &&
      y + radius > b.y &&
      y - radius < b.y + b.h
    ) {
      return true
    }
  }
  return false
}
