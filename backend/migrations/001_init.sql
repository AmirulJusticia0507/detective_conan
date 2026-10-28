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
CREATE TABLE IF NOT EXISTS episodes (
    id INT PRIMARY KEY,
    title VARCHAR(150) NOT NULL,
    type VARCHAR(20) CHECK (type IN ('CANON', 'FILLER')),
    description TEXT,
    unlocked_by_default BOOLEAN DEFAULT false,
    deduction_tree JSONB DEFAULT '{"nodes": [], "edges": []}'::jsonb
);

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

-- Seed: Episode 1126 (Kogoro Framed Arc) --------------------------------
INSERT INTO episodes (id, title, type, description, unlocked_by_default)
VALUES (
    1126,
    'Kogoro Framed',
    'CANON',
    'Kogoro Mouri dijebak dalam sebuah kasus. Conan harus mengumpulkan bukti untuk membersihkan namanya.',
    true
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

INSERT INTO evidence (id, episode_id, name, description, icon, map_coordinate, is_key_evidence)
VALUES
    (1126001, 1126, 'Sidik Jari di Gelas', 'Sidik jari pada gelas di kantor Mouri tidak cocok dengan Kogoro.', 'fingerprint',
     ST_SetSRID(ST_MakePoint(139.6503, 35.6762), 4326), true),
    (1126002, 1126, 'Rekaman CCTV Lorong', 'Rekaman menunjukkan seseorang memakai jas yang sama dengan Kogoro.', 'video',
     ST_SetSRID(ST_MakePoint(139.6510, 35.6755), 4326), false),
    (1126003, 1126, 'Tiket Kafe Poirot', 'Tiket yang tertinggal mengarah ke waktu kejadian.', 'receipt',
     ST_SetSRID(ST_MakePoint(139.6495, 35.6770), 4326), false)
ON CONFLICT (id) DO NOTHING;

INSERT INTO quests (id, episode_id, title, objective, required_evidence_ids, target_npc)
VALUES
    (1126001, 1126, 'Bersihkan Nama Kogoro', 'Kumpulkan bukti di sekitar kantor Mouri lalu buktikan alibi Kogoro.', ARRAY[1126001, 1126002], 'kogoro-mouri')
ON CONFLICT (id) DO NOTHING;

UPDATE episodes
   SET deduction_tree = '{
         "nodes": [
           {"id": 1126001, "label": "Sidik jari bukan milik Kogoro", "evidence": [1126001]},
           {"id": 1126002, "label": "Pelaku memakai jas serupa", "evidence": [1126002]},
           {"id": 1126003, "label": "Waktu kejadian terkonfirmasi", "evidence": [1126003]}
         ],
         "edges": [
           {"from": 1126001, "to": 1126002, "requires": [1126002]},
           {"from": 1126002, "to": 1126003, "requires": [1126003]}
         ]
       }'::jsonb
 WHERE id = 1126;
