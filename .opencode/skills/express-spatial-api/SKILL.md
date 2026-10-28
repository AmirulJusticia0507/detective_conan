---
name: express-spatial-api
description: >-
  Membuat endpoint Express.js + PostgreSQL/PostGIS untuk game Beika District
  Chronicles, termasuk deteksi proximity pemain terhadap NPC dan bukti memakai
  ST_DWithin, validasi bukti, dan indexing spasial. Gunakan saat menulis route,
  controller, service, atau query spasial backend.
---

# Express Spatial API

## Struktur backend

```text
backend/
├── src/
│   ├── app.js
│   ├── db.js
│   ├── routes/
│   ├── controllers/
│   ├── services/
│   └── middleware/
└── migrations/
```

## Akses database

- Satu connection pool, dibaca dari `DATABASE_URL` di `.env`.
- Jangan menyusun SQL dengan interpolasi string. Selalu pakai parameter
  (`$1`, `$2`).
- Koordinat dari klien dikirim sebagai `{ lat, lng }` lalu dikonversi server:

```sql
ST_SetSRID(ST_MakePoint($2, $1), 4326)::geography
```

Urutan argumen `ST_MakePoint(lng, lat)` — jangan tertukar.

## Query proximity

```sql
-- NPC / bukti dalam radius tertentu (meter) dari posisi pemain
SELECT e.id, e.name, e.is_key_evidence,
       ST_Distance(e.map_coordinate::geography, p.location::geography) AS distance_m
FROM evidence e
JOIN players p ON p.id = $1
WHERE e.episode_id = p.current_episode
  AND ST_DWithin(e.map_coordinate::geography, p.location::geography, $2)
ORDER BY distance_m ASC
LIMIT 20;
```

Rule penting:

1. Cast ke `geography` agar jarak dalam meter dan akurat pada lintang nyata.
2. `ST_DWithin` **harus** dipakai di `WHERE`, bukan `ST_Distance(...) < x`,
   supaya index spasial terpakai.
3. Buat index:

```sql
CREATE INDEX idx_evidence_geog ON evidence USING GIST ((map_coordinate::geography));
CREATE INDEX idx_players_geog  ON players  USING GIST ((location::geography));
```

4. Selalu scope query ke `episode_id` agar konten episode lain tidak bocor.

## Pola endpoint

```js
// POST /api/player/:id/interact  { evidenceId }
router.post('/:id/interact', async (req, res, next) => {
  try {
    const { id } = req.params
    const { evidenceId } = req.body
    const result = await collectEvidence({ playerId: id, evidenceId })
    if (!result.inRange) return res.status(403).json({ error: 'Terlalu jauh dari bukti' })
    res.json(result)
  } catch (err) { next(err) }
})
```

## Validasi & keamanan

- Validasi tipe dan rentang input (`lat` -90..90, `lng` -180..180, radius ≤ 500 m).
- Server memvalidasi aksi pemain; **jangan** percaya state dari klien (poin,
  inventory, posisi akhir).
- Error handler terpusat; jangan bocorkan pesan database ke klien.
- Rate limit endpoint interaksi untuk mencegah farming.

## Checklist

- [ ] Semua query berparameter (tanpa string concat).
- [ ] `ST_DWithin` + cast `geography`, didukung GIST index.
- [ ] Endpoint dibatasi oleh episode pemain.
- [ ] Ada test minimal untuk jalur "dalam radius" dan "di luar radius".
