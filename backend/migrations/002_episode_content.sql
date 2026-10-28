-- Beika District Chronicles — Phase 3: konten episode 1126–1150
-- Jalankan setelah 001_init.sql:
--   psql "$DATABASE_URL" -f migrations/002_episode_content.sql
--
-- Konvensi ID (lihat skill episode-quest-generator):
--   evidence & quest: <episode_id><3 digit urut>, mis. 1127001
--   deduction node: sama dengan evidence id yang menjadi kesimpulan
--
-- CATATAN KANON: sinopsis arc di bawah mengikuti kerangka README.v2.md
-- (Kogoro Framed, Kaitou Kid Crown Magic, Cafe Poirot). Detail bukti dan
-- dialog bersifat inventif untuk kebutuhan gameplay.

BEGIN;

-- ======================================================================
-- Episode 1126 — Kogoro Framed Arc (kanon sudah ada di 001_init.sql)
-- ======================================================================
-- Deduction tree diperbaiki: edge harus dari bukti yang lebih awal.
UPDATE episodes
   SET deduction_tree = '{
         "nodes": [
           {"id": 1126001, "label": "Sidik jari di gelas bukan milik Kogoro", "evidence": [1126001]},
           {"id": 1126002, "label": "Pelaku memakai jas serupa Kogoro", "evidence": [1126002]},
           {"id": 1126003, "label": "Waktu kejadian membuktikan alibi Kogoro", "evidence": [1126003]}
         ],
         "edges": [
           {"from": 1126001, "to": 1126002, "requires": [1126001, 1126002]},
           {"from": 1126002, "to": 1126003, "requires": [1126001, 1126002, 1126003]}
         ]
       }'::jsonb
 WHERE id = 1126;

-- ======================================================================
-- Episode 1127 — Phantom Thief Kid: Crown Magic Heist (CANON)
-- ======================================================================
INSERT INTO episodes (id, title, type, description, unlocked_by_default, deduction_tree)
VALUES (
    1127,
    'Phantom Thief Kid: Crown Magic Heist',
    'CANON',
    'Kaitou Kid mengumumkan akan mencuri Mahkota Beika saat pertunjukan sulap di museum. Conan harus membaca triknya sebelum mahkota lenyap.',
    false,
    '{
       "nodes": [
         {"id": 1127001, "label": "Kartu tantangan ditinggalkan sebelum acara", "evidence": [1127001]},
         {"id": 1127002, "label": "Gesper vitrin sudah dilemahkan", "evidence": [1127002]},
         {"id": 1127003, "label": "Cermin panggung menutupi jalur kabur", "evidence": [1127003]}
       ],
       "edges": [
         {"from": 1127001, "to": 1127002, "requires": [1127001, 1127002]},
         {"from": 1127002, "to": 1127003, "requires": [1127001, 1127002, 1127003]}
       ]
     }'::jsonb
)
ON CONFLICT (id) DO NOTHING;

INSERT INTO evidence (id, episode_id, name, description, icon, map_coordinate, is_key_evidence)
VALUES
    (1127001, 1127, 'Kartu Tantangan Kaitou Kid',
     'Kartu bertuliskan "Mahkota akan hilang di bawah lampu panggung". Diletakkan di loket museum.',
     'ticket',
     ST_SetSRID(ST_MakePoint(139.6488, 35.6746), 4326), true),
    (1127002, 1127, 'Gesper Vitrin Longgar',
     'Sekrup gesper mahkota sengaja dikendurkan. Bukan pembobolan paksa.',
     'wrench',
     ST_SetSRID(ST_MakePoint(139.6481, 35.6741), 4326), false),
    (1127003, 1127, 'Serpihan Cermin Panggung',
     'Pecahan cermin di balik panggung, cukup besar untuk memantulkan siluet.',
     'sparkles',
     ST_SetSRID(ST_MakePoint(139.6475, 35.6752), 4326), false)
ON CONFLICT (id) DO NOTHING;

INSERT INTO quests (id, episode_id, title, objective, required_evidence_ids, target_npc)
VALUES
    (1127001, 1127, 'Baca Trik Kaitou Kid',
     'Periksa loket museum, vitrin mahkota, lalu balik panggung untuk membaca triknya.',
     ARRAY[1127001, 1127002, 1127003], 'kaito-kid')
ON CONFLICT (id) DO NOTHING;

-- ======================================================================
-- Episode 1128 — Cafe Poirot: Secret Investigation with Amuro & Sera
-- ======================================================================
INSERT INTO episodes (id, title, type, description, unlocked_by_default, deduction_tree)
VALUES (
    1128,
    'Cafe Poirot: Secret Investigation',
    'CANON',
    'Seorang tamu Poirot menghilang setelah meninggalkan tas. Amuro dan Sera menyelidiki diam-diam sebelum polisi dilibatkan.',
    false,
    '{
       "nodes": [
         {"id": 1128001, "label": "Struk menunjukkan tamu terakhir duduk 40 menit", "evidence": [1128001]},
         {"id": 1128002, "label": "Tas berisi peta Distrik Beika bertanda", "evidence": [1128002]},
         {"id": 1128003, "label": "Resi kamar hotel terdekat terungkap", "evidence": [1128003]}
       ],
       "edges": [
         {"from": 1128001, "to": 1128002, "requires": [1128001, 1128002]},
         {"from": 1128002, "to": 1128003, "requires": [1128001, 1128002, 1128003]}
       ]
     }'::jsonb
)
ON CONFLICT (id) DO NOTHING;

INSERT INTO evidence (id, episode_id, name, description, icon, map_coordinate, is_key_evidence)
VALUES
    (1128001, 1128, 'Struk Meja Pojok',
     'Struk pesanan atas nama "Y. A.". Waktu cetak menunjukkan tamu duduk lama tanpa memesan ulang.',
     'receipt',
     ST_SetSRID(ST_MakePoint(139.6512, 35.6768), 4326), true),
    (1128002, 1128, 'Peta Bertanda di Tas',
     'Peta Distrik Beika dengan tiga titik diwarnai merah.',
     'map',
     ST_SetSRID(ST_MakePoint(139.6516, 35.6773), 4326), false),
    (1128003, 1128, 'Resi Hotel Beika Inn',
     'Resi kamar 502 terbungkus rapi di dalam tas. Tamu disebut belum check-out.',
     'bed',
     ST_SetSRID(ST_MakePoint(139.6502, 35.6776), 4326), false)
ON CONFLICT (id) DO NOTHING;

INSERT INTO quests (id, episode_id, title, objective, required_evidence_ids, target_npc)
VALUES
    (1128001, 1128, 'Lacak Tamu Poirot',
     'Bicaralah dengan Amuro, periksa meja pojok, lalu buka tas yang ditinggal.',
     ARRAY[1128001, 1128002, 1128003], 'amuro-tooru')
ON CONFLICT (id) DO NOTHING;

-- ======================================================================
-- Episode 1129 — Filler: Hilangnya Bento Ran (FILLER)
-- ======================================================================
INSERT INTO episodes (id, title, type, description, unlocked_by_default, deduction_tree)
VALUES (
    1129,
    'Hilangnya Bento Ran',
    'FILLER',
    'Bento buatan Ran hilang dari meja kelas. Kasus kecil di Sekolah Teitan yang ternyata punya pelaku tak terduga.',
    false,
    '{
       "nodes": [
         {"id": 1129001, "label": "Remah nasi mengarah ke koridor", "evidence": [1129001]},
         {"id": 1129002, "label": "Jejak kaki kecil di lantai", "evidence": [1129002]},
         {"id": 1129003, "label": "Kucing liar bersarang di gudang", "evidence": [1129003]}
       ],
       "edges": [
         {"from": 1129001, "to": 1129002, "requires": [1129001, 1129002]},
         {"from": 1129002, "to": 1129003, "requires": [1129001, 1129002, 1129003]}
       ]
     }'::jsonb
)
ON CONFLICT (id) DO NOTHING;

INSERT INTO evidence (id, episode_id, name, description, icon, map_coordinate, is_key_evidence)
VALUES
    (1129001, 1129, 'Remah Nasi di Koridor',
     'Jejak remah membentuk garis menuju gudang sekolah.',
     'utensils',
     ST_SetSRID(ST_MakePoint(139.6524, 35.6748), 4326), true),
    (1129002, 1129, 'Jejak Kaki Kecil',
     'Jejak bercak di lantai gudang, ukurannya jauh lebih kecil dari kaki siswa.',
     'paw-print',
     ST_SetSRID(ST_MakePoint(139.6528, 35.6744), 4326), false),
    (1129003, 1129, 'Kantong Bento Kosong',
     'Kantong bento Ran ditemukan di tumpukan kardus, bersih tanpa sisa.',
     'package',
     ST_SetSRID(ST_MakePoint(139.6531, 35.6742), 4326), false)
ON CONFLICT (id) DO NOTHING;

INSERT INTO quests (id, episode_id, title, objective, required_evidence_ids, target_npc)
VALUES
    (1129001, 1129, 'Cari Bento yang Hilang',
     'Ikuti jejak remah dari koridor hingga gudang sekolah.',
     ARRAY[1129001, 1129002, 1129003], 'sera-masumi')
ON CONFLICT (id) DO NOTHING;

COMMIT;
