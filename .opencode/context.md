# Konteks Proyek — sel untuk agen

Status: **Phase 1–3 selesai di level kode.** Belum pernah `npm install` /
build. Belum ada repo git.

## Struktur

```text
frontend/                 Vue 3 + Vite + Tailwind + Pinia
  src/
    api/client.js         wrapper fetch (PLAYER_ID sementara = 1)
    components/           MapViewport, HudBar, DialogueBox, InteractionPrompt,
                          InventoryPanel, EvidenceBoard
    game/worldData.js     WORLD, ROADS, BUILDINGS, NPCS, EVIDENCE_MARKERS (fallback)
    game/renderer.js      render canvas murni, marker dari state
    game/loop.js          rAF + input (WASD/panah, E/Enter/Space)
    stores/               playerStore, mapStore, episodeStore
    utils/geo.js          piksel dunia <-> lat/lng Beika (1px = 1m)
backend/
  migrations/001_init.sql          skema + PostGIS + seed episode 1126 + player 1
  migrations/002_episode_content.sql episode 1127, 1128, 1129
  scripts/validate-content.mjs     validator konten (npm run validate:content)
  src/routes/                      players, episodes, map, deductions
  src/services/                    playerService, evidenceService, episodeService
  src/utils/validate.js            HttpError + validasi input
```

## Alur interaksi

1. WASD/panah; collision `isBlocked` dicek per sumbu.
2. Dekat marker/NPC → `InteractionPrompt`, tekan `E`.
3. Bukti: posisi → lat/lng → `PATCH /players/:id/position` →
   `POST /players/:id/evidence/:eid/collect` (server `ST_DWithin` 120 m).
4. NPC: `DialogueBox` berurutan.
5. Evidence Board: pilih 2 bukti → `POST /deductions` → server cek edge di
   `episodes.deduction_tree`.

## Konten episode

| ID | Judul | Tipe | Bukti |
| --- | --- | --- | --- |
| 1126 | Kogoro Framed | CANON | 1126001–1126003 |
| 1127 | Phantom Thief Kid: Crown Magic Heist | CANON | 1127001–1127003 |
| 1128 | Cafe Poirot: Secret Investigation | CANON | 1128001–1128003 |
| 1129 | Hilangnya Bento Ran | FILLER | 1129001–1129003 |

Aturan konten: lihat skill `episode-quest-generator`. Jalankan
`npm run validate:content` di `backend/` setelah mengubah seed.

## Konvensi teknis

- Klien kirim `{ lat, lng }`; SQL `ST_MakePoint(lng, lat)`.
- Proximity `ST_DWithin(...::geography, ...::geography, radius)` + GIST index.
- `ROUND(...::numeric)` dari pg = **string** → selalu `Number()`.
- `ctx` canvas sudah di-scale dpr; hitung luas gambar dari
  `canvas.width / dpr`, bukan `getBoundingClientRect()`.
- Query berparameter; error lewat `HttpError`.

## Yang belum ada

- Autentikasi (`PLAYER_ID = 1`).
- Asset gambar/tileset; renderer pakai bentuk primitif.
- Perpindahan pemain ke episode lain (`current_episode` belum bisa diubah).
- Test otomatis, Socket.IO, audio.
- `frontend/src/components/_scratch.vue` — sisa file, aman dihapus.
