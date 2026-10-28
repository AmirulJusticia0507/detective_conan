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
  migrations/002_episode_content.sql episode 1127–1150 (18 chapter, kanon)
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

Konten mengikuti **kanon anime** 1126–1150 (lihat `docs/episodes-1126-1150.md`).
Episode dua bagian digabung; kolom `episodes.source_episodes` menyimpan nomor
aslinya.

| ID | Judul | Asal episode | Bukti |
| --- | --- | --- | --- |
| 1126 | The Detective Who Lost His Mind | 1126 | 1126001–1126003 |
| 1127 | The Interrogation Room 2 | 1127 | 1127001–1127003 |
| 1128 | Conan and Megure's Two Hostages | 1128–1129 | 1128001–1128003 |
| 1130 | The Suspected Infidelity of the Triple Collab | 1130–1131 | 1130001–1130003 |
| 1132 | Mitsuhiko Tsuburaya's Detective Notes 3 | 1132 | 1132001–1132003 |
| 1133 | Best Husband | 1133 | 1133001–1133003 |
| 1134 | Misfortune of the Positive Man | 1134 | 1134001–1134003 |
| 1135 | Momiji Ooka's Sweet Trap | 1135–1136 | 1135001–1135003 |
| 1137 | The Secret of the Popular Restaurant's Changing Flavor | 1137 | 1137001–1137003 |
| 1138 | The Moving Police Box | 1138 | 1138001–1138003 |
| 1139 | The Sister Troubled By Her Naughty Brother | 1139 | 1139001–1139003 |
| 1140 | Girls Day Mystery 3 | 1140 | 1140001–1140003 |
| 1141 | The Mouri Family House Sits | 1141 | 1141001–1141003 |
| 1142 | The Rampo Mansion Murder Case | 1142–1143 | 1142001–1142003 |
| 1144 | The Hotel Serial Bombing Case | 1144–1145 | 1144001–1144003 |
| 1146 | The Whistling Bookstore 4 | 1146 | 1146001–1146003 |
| 1147 | Stakeout 4 | 1147 | 1147001–1147003 |
| 1148 | The Detective Boys and the Two Leaders | 1148–1149 | 1148001–1148003 |
| 1150 | Kaitou Kid and the Crown Trick | 1150–1151 | 1150001–1150003 |

Judul & sinopsis = kanon. Lokasi Distrik Beika, detail bukti, dan dialog
adalah **inventif untuk gameplay** — jangan diklaim sebagai kanon. Episode 1146
belum punya ringkasan resmi di wiki, jadi chapter-nya memakai kerangka sendiri.

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
