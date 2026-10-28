# 🕵️‍♂️ Beika District Chronicles

Game web **open-world 2D top-down/isometrik** bertema *Detective Conan*, terinspirasi episode 1126–1150. Pemain menjelajahi Distrik Beika, mengumpulkan bukti, berbicara dengan karakter, dan menyelesaikan misteri per episode.

## Fitur

- Menjelajahi lokasi seperti Kantor Detektif Mouri, Cafe Poirot, Tropical Land, dan lokasi heist Kaitou Kid.
- Mengumpulkan petunjuk dan menghubungkannya di evidence board untuk membuat deduksi.
- Progres cerita berbasis episode, termasuk arc Kogoro Framed, Kaitou Kid, dan Cafe Poirot.
- Menggunakan gadget Conan, seperti jam bius, dasi pengubah suara, sepatu super-strength, dan skateboard turbo.

## Rencana Teknologi

| Bagian | Teknologi |
| --- | --- |
| Frontend | Vue 3, Composition API, `<script setup>`, Pinia |
| Antarmuka | Tailwind CSS, Lucide Icons, HTML5 Canvas atau PixiJS |
| Backend | Node.js dan Express.js |
| Database | PostgreSQL dengan PostGIS |
| Realtime | Socket.IO (opsional, untuk NPC realtime atau co-op) |

## Menjalankan Proyek

Struktur `frontend` dan `backend` masih merupakan bagian dari roadmap. Setelah keduanya dibuat, jalankan:

```bash
# Terminal 1
cd backend
npm install
npm run dev

# Terminal 2
cd frontend
npm install
npm run dev
```

## Desain Sistem

```text
[ Browser / Vue 3 Client ]
├── Components: MapViewport, EvidenceBoard, DialogueBox, Inventory
├── Stores: playerStore, mapStore, episodeStore
└── Render engine: Canvas / PixiJS + Tailwind overlay
                │ REST API / WebSocket (JSON)
                ▼
[ Express.js Backend ]
├── Controllers: Player, Deduction, Map
├── Services: Quest Logic, Spatial Movement
└── Middleware: Authentication, Episode Validation
                │
                ▼
[ PostgreSQL + PostGIS ]
├── Tables: players, episodes, evidence, quests
└── Spatial queries: proximity NPC dan bukti dengan `ST_DWithin`
```

Game state dikelola di sisi klien dengan Vue/Pinia, sedangkan server memvalidasi aksi pemain dan menangani data persisten serta query spasial.

## Skema Database Awal

```sql
CREATE EXTENSION IF NOT EXISTS postgis;

CREATE TABLE players (
    id SERIAL PRIMARY KEY,
    username VARCHAR(50) UNIQUE NOT NULL,
    current_episode INT DEFAULT 1126,
    stamina INT DEFAULT 100,
    deduction_points INT DEFAULT 0,
    inventory JSONB DEFAULT '[]'::jsonb,
    location GEOMETRY(Point, 4326),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE episodes (
    id INT PRIMARY KEY,
    title VARCHAR(150) NOT NULL,
    type VARCHAR(20) CHECK (type IN ('CANON', 'FILLER')),
    description TEXT,
    unlocked_by_default BOOLEAN DEFAULT false
);

CREATE TABLE evidence (
    id SERIAL PRIMARY KEY,
    episode_id INT REFERENCES episodes(id),
    name VARCHAR(100) NOT NULL,
    description TEXT,
    icon VARCHAR(50),
    map_coordinate GEOMETRY(Point, 4326),
    is_key_evidence BOOLEAN DEFAULT false
);

CREATE TABLE quests (
    id SERIAL PRIMARY KEY,
    episode_id INT REFERENCES episodes(id),
    title VARCHAR(100),
    objective TEXT,
    required_evidence_ids INT[],
    target_npc VARCHAR(50)
);
```

## Roadmap

- [ ] **Foundation:** buat struktur monorepo, inisialisasi PostGIS, Vue + Tailwind + Pinia, dan Express dengan koneksi PostgreSQL.
- [ ] **Mekanik inti:** peta 2D, interaksi NPC dan dialog, inventaris, serta evidence board.
- [ ] **Konten episode:** arc Kogoro Framed, Kaitou Kid, Cafe Poirot, dan mini-quest episode filler.
- [ ] **Polish:** UI bertema anime, efek suara, optimasi indeks PostGIS, dan sinkronisasi state.

## Konvensi Konten

- `episodes` menyimpan metadata dan status unlock episode.
- `evidence` menyimpan petunjuk beserta koordinat lokasinya.
- `quests` menghubungkan tujuan dengan episode, bukti yang diperlukan, dan NPC target.
