---
name: episode-quest-generator
description: >-
  Menerjemahkan sinopsis episode Detective Conan (1126–1150) menjadi data quest,
  evidence item, dialog, dan deduction logic tree dalam JSON yang sesuai skema
  database Beika District Chronicles. Gunakan saat menambah konten episode,
  menulis puzzle, atau membuat file seed data.
---

# Episode Quest Generator

Tujuan: menghasilkan konten episode yang **valid terhadap skema** dan bisa
langsung dipakai sebagai seed atau API payload.

## Skema acuan

Tabel `episodes`, `evidence`, `quests` (lihat `README.v2.md` bagian 2):

- `episodes`: `id`, `title`, `type` (`CANON` | `FILLER`), `description`,
  `unlocked_by_default`
- `evidence`: `id`, `episode_id`, `name`, `description`, `icon`,
  `map_coordinate` (Point 4326), `is_key_evidence`
- `quests`: `id`, `episode_id`, `title`, `objective`, `required_evidence_ids`,
  `target_npc`

## Format output JSON

```json
{
  "episode": {
    "id": 1126,
    "title": "Judul Episode",
    "type": "CANON",
    "description": "Sinopsis 2–3 kalimat.",
    "unlocked_by_default": true
  },
  "evidence": [
    {
      "id": 1126001,
      "episode_id": 1126,
      "name": "Nama bukti",
      "description": "Apa yang terlihat dan mengapa penting.",
      "icon": "lucide-icon-name",
      "map_coordinate": { "lat": 35.6762, "lng": 139.6503 },
      "is_key_evidence": true
    }
  ],
  "quests": [
    {
      "id": 1126001,
      "episode_id": 1126,
      "title": "Judul quest",
      "objective": "Aksi yang harus dilakukan pemain.",
      "required_evidence_ids": [1126001],
      "target_npc": "kogoro-mouri"
    }
  ],
  "deduction_tree": {
    "nodes": [
      { "id": "n1", "label": "Kesimpulan awal", "evidence": [1126001] }
    ],
    "edges": [{ "from": "n1", "to": "n2", "requires": [1126002] }]
  }
}
```

## Aturan

1. **ID unik & deterministik.** Evidence/quest: `<episode_id><seq 3 digit>`,
   mis. `1126001`.
2. **Minimal 3 evidence**, tepat **1 `is_key_evidence: true`** per episode.
3. **Setiap quest harus bisa diselesaikan** hanya dengan evidence yang ada di
   episode yang sama. Tidak ada referensi ke ID yang tidak didefinisikan.
4. **Setiap node deduction tree** merujuk evidence yang ada; graph harus
   asiklik (DAG) dan ujungnya menyimpulkan pelaku/motif.
5. `type` harus konsisten: filler ditandai `FILLER` dan tidak boleh digabung
   dengan arc utama.
6. Nama NPC memakai slug kebab-case yang konsisten.
7. Koordinat dibulatkan 4 desimal, dalam area Distrik Beika fiktif yang
   ditetapkan proyek (jangan berubah antar episode tanpa alasan).

## Validasi sebelum menyerahkan hasil

- JSON valid dan bisa di-parse.
- Semua `episode_id` menyatu ke `episode.id`.
- Semua `required_evidence_ids` ada di daftar evidence.
- Tidak ada ID duplikat di seluruh paket.
- Deskripsi berbahasa Indonesia, nama variabel/kunci berbahasa Inggris.

## Sumber sinopsis

Jika sinopsis episode belum ada, **tanyakan ke user** atau diperoleh lewat
`websearch`; jangan mengarang detail kanon yang bisa salah. Tandai bagian
inventif dengan komentar `// TODO: verifikasi kanon`.
