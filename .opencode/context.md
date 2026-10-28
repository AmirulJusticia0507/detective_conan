# Konteks Proyek — sel untuk agen

Status: **Phase 1 selesai (kode), Phase 2 sedang dikerjakan.**
Belum pernah dijalankan `npm install` / `npm run build`.

## Struktur

```text
frontend/                 Vue 3 + Vite + Tailwind + Pinia
  src/
    api/client.js         wrapper fetch ke backend (PLAYER_ID sementara = 1)
    components/           MapViewport, HudBar, DialogueBox, InteractionPrompt,
                          InventoryPanel, EvidenceBoard
    game/worldData.js     dunia statis: WORLD, ROADS, BUILDINGS, NPCS, EVIDENCE_MARKERS
    game/renderer.js      render canvas murni (tanpa Pinia)
    game/loop.js          rAF + input keyboard + tombol aksi (E/Enter/Space)
    stores/               playerStore, mapStore, episodeStore
    utils/geo.js          konversi piksel dunia <-> lat/lng Beika
backend/                  Express + pg
  migrations/001_init.sql skema PostGIS + seed episode 1126
  src/routes/             players, episodes, map, deductions
  src/services/           playerService, evidenceService, episodeService
  src/utils/validate.js   validasi input & HttpError
```

## Alur interaksi

1. Pemain bergerak dengan WASD/panah; collision memblokir bangunan
   (`isBlocked`), dicek per sumbu.
2. Dekat marker bukti/NPC → `InteractionPrompt` muncul, tekan `E`.
3. Bukti: konversi posisi → lat/lng → `PATCH /players/:id/position` →
   `POST /players/:id/evidence/:eid/collect`. Server memvalidasi
   `ST_DWithin` radius 120 m dan menolak jika terlalu jauh.
4. NPC: membuka `DialogueBox` berurutan.
5. Evidence Board: pilih 2 bukti → POST `/deductions` → server memeriksa
   edge di `episodes.deduction_tree`.

## Konvensi teknis

- Koordinat: klien kirim `{ lat, lng }`; SQL `ST_MakePoint(lng, lat)`.
- Proximity selalu `ST_DWithin(...::geography, ...::geography, radius)` +
  GIST index; jangan `ST_Distance(...) < x` di `WHERE`.
- `ROUND(...::numeric)` dari pg mengembalikan **string** → selalu `Number()`.
- Semua query berparameter. Error memakai `HttpError` (pesan aman ke klien).
- State game di Pinia; renderer hanya menerima data.

## Yang belum ada

- Autentikasi (sementara `PLAYER_ID = 1`; tabel `players` perlu seed user).
- Asset gambar/tileset — renderer memakai bentuk primitif.
- Test otomatis, Socket.IO, audio.
- `frontend/src/components/_scratch.vue` — sisa file, aman dihapus.
