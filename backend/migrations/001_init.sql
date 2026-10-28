-- Beika District Chronicles — Skema awal (Phase 1)
-- Jalankan: psql "$DATABASE_URL" -f migrations/001_init.sql

CREATE EXTENSION IF NOT EXISTS postgis;

-- 1. Players -------------------------------------------------------------
CREATE TABLE IF NOT EXISTS players (
    id SERIAL PRIMARY KEY,
    username VARCHAR(50) UNIQUE NOT NULL,
    current_episode INT DEFAULT 1126,
    stamina INT DEFAULT 100,
    deduction_points INT DEFAULT 0,
    inventory JSONB DEFAULT '[]'::jsonb,
    location GEOMETRY(Point, 4326),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 2. Episodes (Ep 1126 - 1150) ------------------------------------------
-- `id` = nomor episode anime pertama pada chapter tersebut. Episode dua
-- bagian digabung dan nomor bagian keduanya disimpan di `source_episodes`.
CREATE TABLE IF NOT EXISTS episodes (
    id INT PRIMARY KEY,
    title VARCHAR(150) NOT NULL,
    type VARCHAR(20) CHECK (type IN ('CANON', 'FILLER')),
    description TEXT,
    unlocked_by_default BOOLEAN DEFAULT false,
    source_episodes INT[],
    deduction_tree JSONB DEFAULT '{"nodes": [], "edges": []}'::jsonb
);

-- Migrasi untuk database yang dibuat sebelum kolom `source_episodes` ada.
ALTER TABLE episodes ADD COLUMN IF NOT EXISTS source_episodes INT[];

-- 3. Evidence / Clues ---------------------------------------------------
CREATE TABLE IF NOT EXISTS evidence (
    id SERIAL PRIMARY KEY,
    episode_id INT REFERENCES episodes(id) ON DELETE CASCADE,
    name VARCHAR(100) NOT NULL,
    description TEXT,
    icon VARCHAR(50),
    map_coordinate GEOMETRY(Point, 4326),
    is_key_evidence BOOLEAN DEFAULT false
);

-- 4. Quests & Deductions ------------------------------------------------
CREATE TABLE IF NOT EXISTS quests (
    id SERIAL PRIMARY KEY,
    episode_id INT REFERENCES episodes(id) ON DELETE CASCADE,
    title VARCHAR(100),
    objective TEXT,
    required_evidence_ids INT[],
    target_npc VARCHAR(50)
);

-- Status quest per pemain -------------------------------------------------
CREATE TABLE IF NOT EXISTS player_progress (
    player_id INT REFERENCES players(id) ON DELETE CASCADE,
    quest_id INT REFERENCES quests(id) ON DELETE CASCADE,
    completed_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (player_id, quest_id)
);

-- Index spasial (wajib untuk ST_DWithin yang cepat) ----------------------
CREATE INDEX IF NOT EXISTS idx_evidence_geog ON evidence USING GIST ((map_coordinate::geography));
CREATE INDEX IF NOT EXISTS idx_players_geog ON players USING GIST ((location::geography));
CREATE INDEX IF NOT EXISTS idx_evidence_episode ON evidence (episode_id);
CREATE INDEX IF NOT EXISTS idx_quests_episode ON quests (episode_id);

-- Episode 1126 — "The Detective Who Lost His Mind" (TV original, 8 Jun 2024) --
-- Kanoko Kon meminta Kogoro menyelidiki dugaan perselingkuhan suaminya,
-- Heiwa Kon (ketua Kon Corporation), dengan joki idola Sakurada Sakura.
-- Kogoro menguntit selama seminggu tanpa hasil; malam itu, saat mengantar
-- Kanoko pulang, terdengar jeritan.
INSERT INTO episodes (id, title, type, description, unlocked_by_default, source_episodes)
VALUES (
    1126,
    'The Detective Who Lost His Mind',
    'CANON',
    'Kanoko Kon meminta Kogoro menyelidiki dugaan perselingkuhan suaminya, Heiwa Kon, ketua Kon Corporation, dengan joki idola Sakurada Sakura. Seminggu menguntit tanpa hasil, sampai malam saat Kogoro mengantar Kanoko pulang terdengar sebuah jeritan.',
    true,
    ARRAY[1126]
)
ON CONFLICT (id) DO NOTHING;

-- Pemain demo agar frontend dapat dipakai langsung setelah migrasi.
INSERT INTO players (id, username, current_episode, location)
VALUES (
    1,
    'Conan',
    1126,
    ST_SetSRID(ST_MakePoint(139.6503, 35.6762), 4326)
)
ON CONFLICT (id) DO NOTHING;

SELECT setval('players_id_seq', (SELECT MAX(id) FROM players));

-- Bukti episode 1126 (lokasi & detail inventif untuk gameplay).
INSERT INTO evidence (id, episode_id, name, description, icon, map_coordinate, is_key_evidence)
VALUES
    (1126001, 1126, 'Catatan Penguntitan Seminggu',
     'Buku catatan Kogoro: tujuh hari mengikuti Heiwa Kon ke kantor, paddock, dan rumah makan. Nihil kejanggalan.',
     'notebook-pen',
     ST_SetSRID(ST_MakePoint(139.6503, 35.6762), 4326), true),
    (1126002, 1126, 'Struk Makan Malam Kanoko',
     'Struk restoran malam itu. Waktu cetak membuktikan jam Kogoro dan Kanoko masih di meja saat keributan terjadi.',
     'receipt',
     ST_SetSRID(ST_MakePoint(139.6511, 35.6757), 4326), false),
    (1126003, 1126, 'Jeritan di Depan Kediaman Kon',
     'Terdengar tepat saat Kanoko turun dari mobil. Arah suaranya bukan dari rumah, melainkan dari sisi carport.',
     'audio-waveform',
     ST_SetSRID(ST_MakePoint(139.6494, 35.6771), 4326), false)
ON CONFLICT (id) DO NOTHING;

INSERT INTO quests (id, episode_id, title, objective, required_evidence_ids, target_npc)
VALUES
    (1126001, 1126, 'Laporan Perselingkuhan yang Sunyi',
     'Buka catatan penguntitan Kogoro, periksa struk makan malam, lalu telusuri sumber jeritan di kediaman Kon.',
     ARRAY[1126001, 1126002, 1126003], 'kogoro-mouri')
ON CONFLICT (id) DO NOTHING;

UPDATE episodes
   SET deduction_tree = '{
         "nodes": [
           {"id": 1126001, "label": "Seminggu menguntit: Heiwa tidak berselingkuh", "evidence": [1126001]},
           {"id": 1126002, "label": "Alibi jam: Kogoro dan Kanoko masih di meja makan", "evidence": [1126001, 1126002]},
           {"id": 1126003, "label": "Jeritan datang dari carport, bukan dari dalam rumah", "evidence": [1126001, 1126002, 1126003]}
         ],
         "edges": [
           {"from": 1126001, "to": 1126002, "requires": [1126001, 1126002]},
           {"from": 1126002, "to": 1126003, "requires": [1126001, 1126002, 1126003]}
         ]
       }'::jsonb
 WHERE id = 1126;
