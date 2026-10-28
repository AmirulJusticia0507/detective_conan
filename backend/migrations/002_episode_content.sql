-- Beika District Chronicles — Phase 3: konten episode 1127–1150
-- Jalankan setelah 001_init.sql:
--   psql "$DATABASE_URL" -f migrations/002_episode_content.sql
--
-- Konvensi ID (lihat skill episode-quest-generator):
--   evidence & quest: <episode_id><3 digit urut>, mis. 1127001
--   deduction node: sama dengan evidence id yang menjadi kesimpulan
--
-- KANON: judul & sinopsis mengikuti anime asli (lihat
-- docs/episodes-1126-1150.md). Episode dua bagian digabung menjadi satu
-- chapter; nomor aslinya disimpan di `episodes.source_episodes`.
-- Lokasi di Distrik Beika, detail bukti, dan dialog bersifat inventif untuk
-- kebutuhan gameplay — bukan klaim kanon.
--
-- ID episode = nomor episode anime PERTAMA pada chapter tersebut:
--   1127 Interrogation Room 2
--   1128 Conan and Megure's Two Hostages (1128–1129)
--   1130 The Suspected Infidelity of the Triple Collab (1130–1131)
--   1132 Mitsuhiko's Detective Notes 3
--   1133 Best Husband
--   1134 Misfortune of the Positive Man
--   1135 Momiji Ooka's Sweet Trap (1135–1136)
--   1137 Popular Restaurant's Changing Flavor
--   1138 The Moving Police Box
--   1139 The Sister Troubled By Her Naughty Brother
--   1140 Girls Day Mystery 3
--   1141 The Mouri Family House Sits
--   1142 The Rampo Mansion Murder Case (1142–1143)
--   1144 The Hotel Serial Bombing Case (1144–1145)
--   1146 The Whistling Bookstore 4
--   1147 Stakeout 4
--   1148 The Detective Boys and the Two Leaders (1148–1149)
--   1150 Kaitou Kid and the Crown Trick (1150–1151)
--
-- Episode 1126 sudah di-seed di 001_init.sql dan tidak disentuh lagi.

BEGIN;

-- ======================================================================
-- 1127 — The Interrogation Room 2 (TV original)
-- ======================================================================
INSERT INTO episodes (id, title, type, description, unlocked_by_default, source_episodes, deduction_tree)
VALUES (
    1127,
    'The Interrogation Room 2',
    'CANON',
    'Kogoro dan Conan menemui Inspektur Megure karena kasus yang mereka bantu mandek. Tersangkanya, Kengo Kitao mantan guru SD, ditangkap delapan hari lalu di area konstruksi dan langsung mengaku membunuh — tapi perilakunya saat diinterogasi membuat Megure ragu menuntutnya.',
    false,
    ARRAY[1127],
    '{
       "nodes": [
         {"id": 1127001, "label": "Catatan interogasi: pengakuan Kitao terlalu cepat", "evidence": [1127001]},
         {"id": 1127002, "label": "Serpihan kabel di lokasi konstruksi", "evidence": [1127001, 1127002]},
         {"id": 1127003, "label": "Ada orang lain yang menghubungi Kitao", "evidence": [1127001, 1127002, 1127003]}
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
    (1127001, 1127, 'Berkas Interogasi Kitao',
     'Transkrip interogasi: pengakuan datang lebih cepat dari pertanyaan, dan jawabannya terlalu hafal urutan kejadian.',
     'file-text',
     ST_SetSRID(ST_MakePoint(139.6522, 35.6756), 4326), true),
    (1127002, 1127, 'Serpihan Kabel di Area Konstruksi',
     'Potongan kabel selubung kuning tertinggal di balik papan bangunan — bukan dari peralatan proyek.',
     'cable',
     ST_SetSRID(ST_MakePoint(139.6531, 35.6749), 4326), false),
    (1127003, 1127, 'Kartu Telepon Bekas',
     'Kartu telepon umum dengan nomor terakhir terhubung ke ponsel Kitao beberapa menit sebelum penangkapan.',
     'phone',
     ST_SetSRID(ST_MakePoint(139.6514, 35.6744), 4326), false)
ON CONFLICT (id) DO NOTHING;

INSERT INTO quests (id, episode_id, title, objective, required_evidence_ids, target_npc)
VALUES
    (1127001, 1127, 'Ruang Interogasi',
     'Pelajari berkas interogasi Megure, periksa area konstruksi, lalu cari siapa yang menelepon Kitao.',
     ARRAY[1127001, 1127002, 1127003], 'megure-jiro')
ON CONFLICT (id) DO NOTHING;

-- ======================================================================
-- 1128 — Conan and Megure's Two Hostages (1128–1129, TV original)
-- ======================================================================
INSERT INTO episodes (id, title, type, description, unlocked_by_default, source_episodes, deduction_tree)
VALUES (
    1128,
    'Conan and Megure''s Two Hostages',
    'CANON',
    'Conan menemukan kapsul mainan berisi kertas "HELP" dari seorang anak di toko buku. Ia bertukar pakaian dengan anak itu demi menyelamatkannya, lalu justru ikut diculik. Saat menyelidiki, Conan menyadari para penculik bukan penjahat sungguhan — anak mereka juga disandera.',
    false,
    ARRAY[1128, 1129],
    '{
       "nodes": [
         {"id": 1128001, "label": "Kertas HELP di dalam kapsul mainan", "evidence": [1128001]},
         {"id": 1128002, "label": "Kotak pos tempat pelaku mengambil instruksi", "evidence": [1128001, 1128002]},
         {"id": 1128003, "label": "Penculik sebenarnya juga menyandera anak mereka", "evidence": [1128001, 1128002, 1128003]}
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
    (1128001, 1128, 'Kapsul Mainan Bertuliskan HELP',
     'Kapsul gashapon murah. Kertas di dalamnya ditulis tangan oleh anak dan dilipat empat kali.',
     'package',
     ST_SetSRID(ST_MakePoint(139.6518, 35.6769), 4326), true),
    (1128002, 1128, 'Kotak Pos di Sudut Gang',
     'Kotak pos merah tua di gang belakang toko buku. Penanda kapur di bawahnya dipakai bergantian.',
     'mailbox',
     ST_SetSRID(ST_MakePoint(139.6524, 35.6763), 4326), false),
    (1128003, 1128, 'Foto Anak yang Disandera',
     'Foto polaroid di dompet penculik: anak kecil diikat di ruang sempit, dengan surat kabar bertanggal kemarin.',
     'image',
     ST_SetSRID(ST_MakePoint(139.6530, 35.6758), 4326), false)
ON CONFLICT (id) DO NOTHING;

INSERT INTO quests (id, episode_id, title, objective, required_evidence_ids, target_npc)
VALUES
    (1128001, 1128, 'Dua Sandera',
     'Buka kapsul yang dijatuhkan anak itu, periksa kotak pos di gang, lalu bawa temuannya ke Megure.',
     ARRAY[1128001, 1128002, 1128003], 'megure-jiro')
ON CONFLICT (id) DO NOTHING;

-- ======================================================================
-- 1130 — The Suspected Infidelity of the Triple Collab (1130–1131, manga)
-- ======================================================================
INSERT INTO episodes (id, title, type, description, unlocked_by_default, source_episodes, deduction_tree)
VALUES (
    1130,
    'The Suspected Infidelity of the Triple Collab',
    'CANON',
    'Di Restoran Danny''s Dining, Detektif Cilik menguntit tiga pasangan yang ternyata bertemu di tempat yang sama: Chiba–Kobayashi, Shukichi–Naeko, dan Shiratori–Yumi. Ketiga pasangan saling curiga selingkuh, lalu seseorang tewas di restoran — dan justru Yumi serta Naeko yang memecahkan kasusnya.',
    false,
    ARRAY[1130, 1131],
    '{
       "nodes": [
         {"id": 1130001, "label": "Tiga pasangan bertemu di restoran yang sama", "evidence": [1130001]},
         {"id": 1130002, "label": "Kalender bertanda tanggal yang sama di ketiga rumah", "evidence": [1130001, 1130002]},
         {"id": 1130003, "label": "Mereka menyiapkan hadiah kejutan, bukan selingkuh", "evidence": [1130001, 1130002, 1130003]}
       ],
       "edges": [
         {"from": 1130001, "to": 1130002, "requires": [1130001, 1130002]},
         {"from": 1130002, "to": 1130003, "requires": [1130001, 1130002, 1130003]}
       ]
     }'::jsonb
)
ON CONFLICT (id) DO NOTHING;

INSERT INTO evidence (id, episode_id, name, description, icon, map_coordinate, is_key_evidence)
VALUES
    (1130001, 1130, 'Struk Reservasi Danny''s Dining',
     'Struk tiga meja berurutan, dipesan atas nama berbeda, tetapi jam kedatangan hampir bersamaan.',
     'receipt',
     ST_SetSRID(ST_MakePoint(139.6499, 35.6766), 4326), true),
    (1130002, 1130, 'Kalender Meja dengan Tanda Lingkar',
     'Kalender di meja resepsionis: tanggal hari ini dilingkari merah, dengan coretan nama toko perhiasan.',
     'calendar',
     ST_SetSRID(ST_MakePoint(139.6506, 35.6771), 4326), false),
    (1130003, 1130, 'Kotak Kado Terbungkus Kabur',
     'Kotak berukuran jam tangan, kertas kado belum dilipat rapi — sisa persiapan hadiah kejutan.',
     'gift',
     ST_SetSRID(ST_MakePoint(139.6493, 35.6760), 4326), false)
ON CONFLICT (id) DO NOTHING;

INSERT INTO quests (id, episode_id, title, objective, required_evidence_ids, target_npc)
VALUES
    (1130001, 1130, 'Tiga Pasangan, Satu Restoran',
     'Cek reservasi tiga meja, temukan kalender bertanda, lalu buktikan dugaan selingkuh itu salah.',
     ARRAY[1130001, 1130002, 1130003], 'yumi-miyamoto')
ON CONFLICT (id) DO NOTHING;

-- ======================================================================
-- 1132 — Mitsuhiko Tsuburaya's Detective Notes 3 (TV original)
-- ======================================================================
INSERT INTO episodes (id, title, type, description, unlocked_by_default, source_episodes, deduction_tree)
VALUES (
    1132,
    'Mitsuhiko Tsuburaya''s Detective Notes 3',
    'CANON',
    'Pertengkaran Makio dan Kozo Yuida soal tawaran menguntungkan dari Mayu Iokida membuat Detektif Cilik mencurigai penipuan, sementara polisi mencurigai Makio sebagai pemimpin komplotan perampok. Saat Kozo menelepon Makio, Mitsuhiko menangkap keanehan yang menandakan Makio dalam bahaya.',
    false,
    ARRAY[1132],
    '{
       "nodes": [
         {"id": 1132001, "label": "Tawaran Iokida terlalu menguntungkan", "evidence": [1132001]},
         {"id": 1132002, "label": "Catatan Mitsuhiko: jeda aneh saat telepon", "evidence": [1132001, 1132002]},
         {"id": 1132003, "label": "Makio dalam bahaya, bukan pelaku", "evidence": [1132001, 1132002, 1132003]}
       ],
       "edges": [
         {"from": 1132001, "to": 1132002, "requires": [1132001, 1132002]},
         {"from": 1132002, "to": 1132003, "requires": [1132001, 1132002, 1132003]}
       ]
     }'::jsonb
)
ON CONFLICT (id) DO NOTHING;

INSERT INTO evidence (id, episode_id, name, description, icon, map_coordinate, is_key_evidence)
VALUES
    (1132001, 1132, 'Surat Tawaran Mayu Iokida',
     'Surat tawaran investasi dengan kop tanpa alamat lengkap. Nomor kontaknya hanya dari ponsel.',
     'mail',
     ST_SetSRID(ST_MakePoint(139.6536, 35.6752), 4326), true),
    (1132002, 1132, 'Catatan Telepon Mitsuhiko',
     'Halaman buku catatan: rekaman jeda tiga detik sebelum Makio menjawab, lalu suara benda jatuh.',
     'notebook',
     ST_SetSRID(ST_MakePoint(139.6529, 35.6758), 4326), false),
    (1132003, 1132, 'Kartu Perpustakaan Bekas',
     'Kartu perpustakaan yang jatuh dari saku Makio, dengan nomor genap bertanda stabilo — bukan catatan perampok.',
     'library',
     ST_SetSRID(ST_MakePoint(139.6521, 35.6746), 4326), false)
ON CONFLICT (id) DO NOTHING;

INSERT INTO quests (id, episode_id, title, objective, required_evidence_ids, target_npc)
VALUES
    (1132001, 1132, 'Catatan Detektif Mitsuhiko',
     'Periksa surat tawaran Iokida, bandingkan dengan catatan telepon Mitsuhiko, lalu cari keberadaan Makio.',
     ARRAY[1132001, 1132002, 1132003], 'mitsuhiko-tsuburaya')
ON CONFLICT (id) DO NOTHING;

-- ======================================================================
-- 1133 — Best Husband (TV original)
-- ======================================================================
INSERT INTO episodes (id, title, type, description, unlocked_by_default, source_episodes, deduction_tree)
VALUES (
    1133,
    'Best Husband',
    'CANON',
    'Keluarga Mouri mendatangi kediaman Reiko Mutsu yang terancam seorang pria misterius. Pria itu kabur ke ruang bawah tanah gudang tempat Taro berada, dan di sana ia tewas — diklaim Taro karena membela diri.',
    false,
    ARRAY[1133],
    '{
       "nodes": [
         {"id": 1133001, "label": "Ancaman datang dari orang yang mengenal rumah", "evidence": [1133001]},
         {"id": 1133002, "label": "Perabot di gudang tergeser sebelum kejadian", "evidence": [1133001, 1133002]},
         {"id": 1133003, "label": "Bukan bela diri: jebakan disiapkan lebih dulu", "evidence": [1133001, 1133002, 1133003]}
       ],
       "edges": [
         {"from": 1133001, "to": 1133002, "requires": [1133001, 1133002]},
         {"from": 1133002, "to": 1133003, "requires": [1133001, 1133002, 1133003]}
       ]
     }'::jsonb
)
ON CONFLICT (id) DO NOTHING;

INSERT INTO evidence (id, episode_id, name, description, icon, map_coordinate, is_key_evidence)
VALUES
    (1133001, 1133, 'Surat Ancaman Tanpa Perangko',
     'Kertas lipat yang diantar langsung ke kotak surat. Gaya lipatannya sama untuk semua surat, menunjukkan pengirim mengenal kebiasaan rumah.',
     'file-warning',
     ST_SetSRID(ST_MakePoint(139.6508, 35.6781), 4326), true),
    (1133002, 1133, 'Goresan di Lantai Gudang',
     'Bekas geseran rak besi mengarah ke pintu, dibuat setelah lantai dibersihkan — artinya rak dipindah malam itu.',
     'footprints',
     ST_SetSRID(ST_MakePoint(139.6515, 35.6786), 4326), false),
    (1133003, 1133, 'Pegangan Pisau yang Bersih',
     'Pisau yang disebut alat bela diri sama sekali tanpa sidik jari — dipegang dengan kain atau sarung tangan.',
     'knife',
     ST_SetSRID(ST_MakePoint(139.6499, 35.6788), 4326), false)
ON CONFLICT (id) DO NOTHING;

INSERT INTO quests (id, episode_id, title, objective, required_evidence_ids, target_npc)
VALUES
    (1133001, 1133, 'Suami Terbaik',
     'Periksa surat ancaman di kediaman Mutsu, cek lantai gudang, lalu telusuri pisau yang diklaim alat bela diri.',
     ARRAY[1133001, 1133002, 1133003], 'kogoro-mouri')
ON CONFLICT (id) DO NOTHING;

-- ======================================================================
-- 1134 — Misfortune of the Positive Man (TV original)
-- ======================================================================
INSERT INTO episodes (id, title, type, description, unlocked_by_default, source_episodes, deduction_tree)
VALUES (
    1134,
    'Misfortune of the Positive Man',
    'CANON',
    'Shokichi Hazama tiba di apartemennya sambil mengobrol dengan Conan dan Detektif Cilik. Ia jadi tersangka perampokan di unit tetangga dan menyerahkan sidik jarinya dengan sukarela — tapi justru membuatnya jadi tersangka pembunuhan seminggu sebelumnya.',
    false,
    ARRAY[1134],
    '{
       "nodes": [
         {"id": 1134001, "label": "Sidik jari Hazama ada di barang TKP", "evidence": [1134001]},
         {"id": 1134002, "label": "Barang itu dipinjam ke tetangga", "evidence": [1134001, 1134002]},
         {"id": 1134003, "label": "Sidik jari dipindahkan, bukan ditinggal di TKP", "evidence": [1134001, 1134002, 1134003]}
       ],
       "edges": [
         {"from": 1134001, "to": 1134002, "requires": [1134001, 1134002]},
         {"from": 1134002, "to": 1134003, "requires": [1134001, 1134002, 1134003]}
       ]
     }'::jsonb
)
ON CONFLICT (id) DO NOTHING;

INSERT INTO evidence (id, episode_id, name, description, icon, map_coordinate, is_key_evidence)
VALUES
    (1134001, 1134, 'Laporan Sidik Jari Hazama',
     'Hasil pencocokan: sidik jari Hazama muncul di gelas lipat yang ditemukan di TKP seminggu lalu.',
     'fingerprint',
     ST_SetSRID(ST_MakePoint(139.6540, 35.6768), 4326), true),
    (1134002, 1134, 'Catatan Pinjam-Barang RT',
     'Gelas lipat itu tercatat dipinjam tetangga sepuluh hari lalu untuk acara RT.',
     'clipboard-list',
     ST_SetSRID(ST_MakePoint(139.6546, 35.6762), 4326), false),
    (1134003, 1134, 'Jejak Lem di Dasar Gelas',
     'Lapisan lem tipis di dasar gelas — sisa penyangga kaca yang dipakai untuk mengambil cetakan sidik jari.',
     'sticky-note',
     ST_SetSRID(ST_MakePoint(139.6551, 35.6756), 4326), false)
ON CONFLICT (id) DO NOTHING;

INSERT INTO quests (id, episode_id, title, objective, required_evidence_ids, target_npc)
VALUES
    (1134001, 1134, 'Kemalangan Pria Optimis',
     'Bandingkan sidik jari dengan catatan pinjam RT, lalu periksa benda pemindah sidik jari.',
     ARRAY[1134001, 1134002, 1134003], 'takagi-wataru')
ON CONFLICT (id) DO NOTHING;

-- ======================================================================
-- 1135 — Momiji Ooka's Sweet Trap (1135–1136, manga)
-- ======================================================================
INSERT INTO episodes (id, title, type, description, unlocked_by_default, source_episodes, deduction_tree)
VALUES (
    1135,
    'Momiji Ooka''s Sweet Trap',
    'CANON',
    'Conan, Heiji, dan Kogoro datang ke rumah Kyousuke Kabumoto untuk membahas naskah acara TV yang memakai Momiji sebagai model tokoh. Sementara itu Iori mengajak Ran dan Kazuha mencicipi kue agar Momiji bisa mengutarakan perasaannya ke Heiji — rencana itu kacau karena Kabumoto tewas dengan pola mirip kasus Ninka Gyoda.',
    false,
    ARRAY[1135, 1136],
    '{
       "nodes": [
         {"id": 1135001, "label": "Lollipop yang jatuh dan bersuara aneh", "evidence": [1135001]},
         {"id": 1135002, "label": "Pil tidur Kabumoto ditambah tanpa sepengetahuannya", "evidence": [1135001, 1135002]},
         {"id": 1135003, "label": "Trik batang lollipop sebagai pengantar obat", "evidence": [1135001, 1135002, 1135003]}
       ],
       "edges": [
         {"from": 1135001, "to": 1135002, "requires": [1135001, 1135002]},
         {"from": 1135002, "to": 1135003, "requires": [1135001, 1135002, 1135003]}
       ]
     }'::jsonb
)
ON CONFLICT (id) DO NOTHING;

INSERT INTO evidence (id, episode_id, name, description, icon, map_coordinate, is_key_evidence)
VALUES
    (1135001, 1135, 'Bungkus Lollipop di Ambang Pintu',
     'Bungkus permen yang dilempar Kogoro saat masuk. Suara gemericiknya berbeda dari permen biasa.',
     'candy',
     ST_SetSRID(ST_MakePoint(139.6484, 35.6774), 4326), true),
    (1135002, 1135, 'Botol Pil Tidur Kabumoto',
     'Pil tidur rutin sesuai resep, tetapi segel dalam botol terlihat sudah pernah dibuka dan direkatkan lagi.',
     'pill',
     ST_SetSRID(ST_MakePoint(139.6479, 35.6779), 4326), false),
    (1135003, 1135, 'Naskah Acara dengan Catatan Kecil',
     'Naskah TV dengan coretan di margin: catatan letak Batang lollipop dan jadwal tidur siang korban.',
     'script',
     ST_SetSRID(ST_MakePoint(139.6490, 35.6768), 4326), false)
ON CONFLICT (id) DO NOTHING;

INSERT INTO quests (id, episode_id, title, objective, required_evidence_ids, target_npc)
VALUES
    (1135001, 1135, 'Perangkap Manis Momiji',
     'Ambil bungkus lollipop di ambang pintu, periksa botol pil tidur, lalu baca coretan di naskah acara.',
     ARRAY[1135001, 1135002, 1135003], 'heiji-hattori')
ON CONFLICT (id) DO NOTHING;

-- ======================================================================
-- 1137 — The Secret of the Popular Restaurant's Changing Flavor (TV original)
-- ======================================================================
INSERT INTO episodes (id, title, type, description, unlocked_by_default, source_episodes, deduction_tree)
VALUES (
    1137,
    'The Secret of the Popular Restaurant''s Changing Flavor',
    'CANON',
    'Beredar desas-desus bahwa rasa ramen "Ogataken" berubah. Conan, Haibara, dan Detektif Cilik datang untuk memastikan, dan mendapati pemiliknya hilang. Pemilik kedai ramen "Ichiban", Eiichi Banba, berperilaku aneh sejak kehilangan itu.',
    false,
    ARRAY[1137],
    '{
       "nodes": [
         {"id": 1137001, "label": "Kaldu Ogataken dibuat dari resep berbeda", "evidence": [1137001]},
         {"id": 1137002, "label": "Pesanan bahan Ogataken dialihkan ke Ichiban", "evidence": [1137001, 1137002]},
         {"id": 1137003, "label": "Banba memakai resep itu untuk menutupi kepergian pemilik", "evidence": [1137001, 1137002, 1137003]}
       ],
       "edges": [
         {"from": 1137001, "to": 1137002, "requires": [1137001, 1137002]},
         {"from": 1137002, "to": 1137003, "requires": [1137001, 1137002, 1137003]}
       ]
     }'::jsonb
)
ON CONFLICT (id) DO NOTHING;

INSERT INTO evidence (id, episode_id, name, description, icon, map_coordinate, is_key_evidence)
VALUES
    (1137001, 1137, 'Catatan Kaldu Ogataken',
     'Buku resep di dapur Ogataken: takaran kombu dan katsuobushi di halaman terakhir sudah berbeda.',
     'notebook',
     ST_SetSRID(ST_MakePoint(139.6560, 35.6740), 4326), true),
    (1137002, 1137, 'Slip Kirim Bahan Ichiban',
     'Slip pengiriman dengan alamat asli Ogataken yang dilipat ulang dan dialamatkan ke Ichiban.',
     'truck',
     ST_SetSRID(ST_MakePoint(139.6567, 35.6735), 4326), false),
    (1137003, 1137, 'Papan Menu Dua Sisi',
     'Papan menu Ichiban dua sisi; satu sisi masih memakai tulisan tangan pemilik Ogataken.',
     'utensils',
     ST_SetSRID(ST_MakePoint(139.6572, 35.6746), 4326), false)
ON CONFLICT (id) DO NOTHING;

INSERT INTO quests (id, episode_id, title, objective, required_evidence_ids, target_npc)
VALUES
    (1137001, 1137, 'Rahasia Rasa yang Berubah',
     'Buka buku resep Ogataken, periksa slip kirim bahan, lalu cocokkan dengan papan menu Ichiban.',
     ARRAY[1137001, 1137002, 1137003], 'haibara-ai')
ON CONFLICT (id) DO NOTHING;

-- ======================================================================
-- 1138 — The Moving Police Box (TV original)
-- ======================================================================
INSERT INTO episodes (id, title, type, description, unlocked_by_default, source_episodes, deduction_tree)
VALUES (
    1138,
    'The Moving Police Box',
    'CANON',
    'Haibara dan Detektif Cilik naik koban berjalan saat peresmiannya, lalu terkena aksi pembajakan mobil dan kehilangan semua alat komunikasi. Sinyal dari badge Detektif Cilik memicu penyelidikan, tetapi para pembajak ditemukan tewas dalam ledakan mobil.',
    false,
    ARRAY[1138],
    '{
       "nodes": [
         {"id": 1138001, "label": "Badge Detektif Cilik masih memancarkan sinyal", "evidence": [1138001]},
         {"id": 1138002, "label": "Jejak cat menuju bengkel lukis", "evidence": [1138001, 1138002]},
         {"id": 1138003, "label": "Ledakan dibuat setelah koban ditinggalkan", "evidence": [1138001, 1138002, 1138003]}
       ],
       "edges": [
         {"from": 1138001, "to": 1138002, "requires": [1138001, 1138002]},
         {"from": 1138002, "to": 1138003, "requires": [1138001, 1138002, 1138003]}
       ]
     }'::jsonb
)
ON CONFLICT (id) DO NOTHING;

INSERT INTO evidence (id, episode_id, name, description, icon, map_coordinate, is_key_evidence)
VALUES
    (1138001, 1138, 'Badge Detektif Cilik yang Tersembunyi',
     'Badge dengan pemancar kecil, disembunyikan di lipatan kursi sebelum pembajakan.',
     'badge',
     ST_SetSRID(ST_MakePoint(139.6582, 35.6758), 4326), true),
    (1138002, 1138, 'Jejak Cat Cat Hijau', 'Percikan cat hijau di sudut koban, cocok dengan warna cat bengkel lukis dekat taman.',
     'paintbrush',
     ST_SetSRID(ST_MakePoint(139.6590, 35.6752), 4326), false),
    (1138003, 1138, 'Jam Bekas yang Dilebur',
     'Jam tangan pencuri yang melebur di lantai koban. Pelakunya sudah keluar saat api menyala.',
     'timer',
     ST_SetSRID(ST_MakePoint(139.6597, 35.6746), 4326), false)
ON CONFLICT (id) DO NOTHING;

INSERT INTO quests (id, episode_id, title, objective, required_evidence_ids, target_npc)
VALUES
    (1138001, 1138, 'Koban yang Bergerak',
     'Temukan badge yang disembunyikan Haibara, ikuti jejak cat hijau, lalu periksa sisa jam yang melebur.',
     ARRAY[1138001, 1138002, 1138003], 'haibara-ai')
ON CONFLICT (id) DO NOTHING;

-- ======================================================================
-- 1139 — The Sister Troubled By Her Naughty Brother (TV original)
-- ======================================================================
INSERT INTO episodes (id, title, type, description, unlocked_by_default, source_episodes, deduction_tree)
VALUES (
    1139,
    'The Sister Troubled By Her Naughty Brother',
    'CANON',
    'Ryoichi Doba tewas di apartemennya. Satsuki Makabe, salah satu yang menyimpan dendam, mengklaim punya alibi — tetapi kesaksian adiknya, Yuto, bertentangan, dan hubungan mereka buruk. Kesaksian siapa yang benar?',
    false,
    ARRAY[1139],
    '{
       "nodes": [
         {"id": 1139001, "label": "Kesaksian Yuto bertentangan dengan Satsuki", "evidence": [1139001]},
         {"id": 1139002, "label": "Yuto memakai jam yang lambat lima menit", "evidence": [1139001, 1139002]},
         {"id": 1139003, "label": "Alibi Satsuki justru terbukti dari kekeliruan Yuto", "evidence": [1139001, 1139002, 1139003]}
       ],
       "edges": [
         {"from": 1139001, "to": 1139002, "requires": [1139001, 1139002]},
         {"from": 1139002, "to": 1139003, "requires": [1139001, 1139002, 1139003]}
       ]
     }'::jsonb
)
ON CONFLICT (id) DO NOTHING;

INSERT INTO evidence (id, episode_id, name, description, icon, map_coordinate, is_key_evidence)
VALUES
    (1139001, 1139, 'Dua Kesaksian yang Bertolak Belakang',
     'Catatan polisi: Satsuki menyebut pukul 19.10, Yuto menyebut pukul 19.05 untuk kejadian yang sama.',
     'file-text',
     ST_SetSRID(ST_MakePoint(139.6530, 35.6772), 4326), true),
    (1139002, 1139, 'Jam Dinding Kamar Yuto',
     'Jam dinding kamar Yuto lambat lima menit, tanpa pernah disetel ulang sejak awal bulan.',
     'clock',
     ST_SetSRID(ST_MakePoint(139.6536, 35.6777), 4326), false),
    (1139003, 1139, 'Struk Toko Kelontong', 'Struk pembelian yang tercetak pukul 19.08 di jalur yang sama dengan yang diambil Satsuki.',
     'receipt',
     ST_SetSRID(ST_MakePoint(139.6542, 35.6782), 4326), false)
ON CONFLICT (id) DO NOTHING;

INSERT INTO quests (id, episode_id, title, objective, required_evidence_ids, target_npc)
VALUES
    (1139001, 1139, 'Kakak yang Terjepit Kesaksian Adik',
     'Baca dua kesaksian, periksa jam dinding Yuto, lalu cocokkan dengan struk toko kelontong.',
     ARRAY[1139001, 1139002, 1139003], 'sato-miwako')
ON CONFLICT (id) DO NOTHING;

-- ======================================================================
-- 1140 — Girls Day Mystery 3 (TV original)
-- ======================================================================
INSERT INTO episodes (id, title, type, description, unlocked_by_default, source_episodes, deduction_tree)
VALUES (
    1140,
    'Girls Day Mystery 3',
    'CANON',
    'Event bertema ninja yang berbau kejahatan menarik perhatian Sonoko, Ran, Ayumi, Haibara, dan Sato. Mereka berdandan sebagai kunoichi lalu menjelajah dengan walkie-talkie, sampai kejanggalan membawa mereka ke Toko Perhiasan Kaneko: mahkota Kingscote dicuri dan Keita Kaneko diikat.',
    false,
    ARRAY[1140],
    '{
       "nodes": [
         {"id": 1140001, "label": "Peta event ninja mengarah ke toko perhiasan", "evidence": [1140001]},
         {"id": 1140002, "label": "Kabel pengikat Kaneko dipotong rapi", "evidence": [1140001, 1140002]},
         {"id": 1140003, "label": "Pencuri memakai rute event sebagai jalur kabur", "evidence": [1140001, 1140002, 1140003]}
       ],
       "edges": [
         {"from": 1140001, "to": 1140002, "requires": [1140001, 1140002]},
         {"from": 1140002, "to": 1140003, "requires": [1140001, 1140002, 1140003]}
       ]
     }'::jsonb
)
ON CONFLICT (id) DO NOTHING;

INSERT INTO evidence (id, episode_id, name, description, icon, map_coordinate, is_key_evidence)
VALUES
    (1140001, 1140, 'Peta Event Kunoichi',
     'Peta rute dengan pos terakhir yang ditambahkan tangan, langsung menunjuk etalase Toko Kaneko.',
     'map',
     ST_SetSRID(ST_MakePoint(139.6470, 35.6750), 4326), true),
    (1140002, 1140, 'Potongan Kabel Pengikat',
     'Sisa kabel nilon di kursi Keita Kaneko, ujungnya dipotong rapi dengan gunting, bukan dirobek.',
     'scissors',
     ST_SetSRID(ST_MakePoint(139.6464, 35.6756), 4326), false),
    (1140003, 1140, 'Walkie-Talkie yang Terbuka',
     'Salah satu walkie-talkie yang dilempar pencuri; kanal frekuensinya disetel ke kanal panitia.',
     'radio',
     ST_SetSRID(ST_MakePoint(139.6458, 35.6762), 4326), false)
ON CONFLICT (id) DO NOTHING;

INSERT INTO quests (id, episode_id, title, objective, required_evidence_ids, target_npc)
VALUES
    (1140001, 1140, 'Kunoichi dan Mahkota Kingscote',
     'Baca peta rute event, periksa kabel pengikat di Toko Kaneko, lalu cek walkie-talkie yang terbuka.',
     ARRAY[1140001, 1140002, 1140003], 'sonoko-suzuki')
ON CONFLICT (id) DO NOTHING;

-- ======================================================================
-- 1141 — The Mouri Family House Sits (TV original)
-- ======================================================================
INSERT INTO episodes (id, title, type, description, unlocked_by_default, source_episodes, deduction_tree)
VALUES (
    1141,
    'The Mouri Family House Sits',
    'CANON',
    'Kritikus sastra Takahiko Kamiyu menitipkan rumah dan kucingnya yang cemas kepada Kogoro. Dua orang datang menyelesaikan urusan di hari pertama; di hari kedua polisi memeriksa laporan anonim bahwa Kamiyu mengubur sesuatu — dan jasad So Fujieda ditemukan.',
    false,
    ARRAY[1141],
    '{
       "nodes": [
         {"id": 1141001, "label": "Kucing gelisah hanya di sekitar satu titik halaman", "evidence": [1141001]},
         {"id": 1141002, "label": "Laporan anonim dikirim orang yang tahu jadwal penanaman", "evidence": [1141001, 1141002]},
         {"id": 1141003, "label": "Orang yang menitipkan rumah bukan pembunuhnya", "evidence": [1141001, 1141002, 1141003]}
       ],
       "edges": [
         {"from": 1141001, "to": 1141002, "requires": [1141001, 1141002]},
         {"from": 1141002, "to": 1141003, "requires": [1141001, 1141002, 1141003]}
       ]
     }'::jsonb
)
ON CONFLICT (id) DO NOTHING;

INSERT INTO evidence (id, episode_id, name, description, icon, map_coordinate, is_key_evidence)
VALUES
    (1141001, 1141, 'Kalung Kucing Kamiyu',
     'Kalung dengan gantungan kecil, lekukannya menghadap satu arah halaman terus-menerus.',
     'cat',
     ST_SetSRID(ST_MakePoint(139.6520, 35.6790), 4326), true),
    (1141002, 1141, 'Surat Laporan Anonim',
     'Ditulis tangan, menyebut tanggal penanaman tepat sehari setelah Kogoro menerima kunci.',
     'mail-warning',
     ST_SetSRID(ST_MakePoint(139.6527, 35.6795), 4326), false),
    (1141003, 1141, 'Catatan Kunjungan Dua Tamu',
     'Catatan Kogoro atas dua tamu hari pertama: salah satunya menyebut sudah lama tidak ke rumah ini.',
     'clipboard-list',
     ST_SetSRID(ST_MakePoint(139.6513, 35.6784), 4326), false)
ON CONFLICT (id) DO NOTHING;

INSERT INTO quests (id, episode_id, title, objective, required_evidence_ids, target_npc)
VALUES
    (1141001, 1141, 'Mouri Menjaga Rumah',
     'Temukan titik yang membuat kucing gelisah, baca surat anonim, lalu cocokkan dengan catatan kunjungan.',
     ARRAY[1141001, 1141002, 1141003], 'kogoro-mouri')
ON CONFLICT (id) DO NOTHING;

-- ======================================================================
-- 1142 — The Rampo Mansion Murder Case (1142–1143, TV original)
-- ======================================================================
INSERT INTO episodes (id, title, type, description, unlocked_by_default, source_episodes, deduction_tree)
VALUES (
    1142,
    'The Rampo Mansion Murder Case',
    'CANON',
    'Miss Kobayashi membawa Detektif Cilik ke gudang bekas kediaman Edogawa Ranpo. Prof. Goto jadi tersangka karena terekam CCTV dekat TKP, lalu asistennya Ryosuke Okumoto tewas dicekik di gudang yang sama. Kematian Katsumine di masa lalu menjadi kunci motifnya.',
    false,
    ARRAY[1142, 1143],
    '{
       "nodes": [
         {"id": 1142001, "label": "CCTV menangkap Goto di minimarket, bukan di TKP", "evidence": [1142001]},
         {"id": 1142002, "label": "Manuskrip Ranpo yang belum terbit sebagai umpan", "evidence": [1142001, 1142002]},
         {"id": 1142003, "label": "Kematian Katsumine bukan tenggelam, melainkan dibunuh", "evidence": [1142001, 1142002, 1142003]}
       ],
       "edges": [
         {"from": 1142001, "to": 1142002, "requires": [1142001, 1142002]},
         {"from": 1142002, "to": 1142003, "requires": [1142001, 1142002, 1142003]}
       ]
     }'::jsonb
)
ON CONFLICT (id) DO NOTHING;

INSERT INTO evidence (id, episode_id, name, description, icon, map_coordinate, is_key_evidence)
VALUES
    (1142001, 1142, 'Rekaman CCTV Minimarket',
     'Goto terlihat di minimarket pukul 21.42. Untuk tiba di gudang pada 21.50 ia harus berlari 8 km.',
     'video',
     ST_SetSRID(ST_MakePoint(139.6560, 35.6780), 4326), true),
    (1142002, 1142, 'Telepon Tawaran Manuskrip',
     'Catatan panggilan di ponsel Goto: tawaran menunjukkan manuskrip Ranpo yang belum terbit, tanpa nama pemanggil.',
     'phone',
     ST_SetSRID(ST_MakePoint(139.6554, 35.6785), 4326), false),
    (1142003, 1142, 'Catatan Asosiasi Ranpo',
     'Lembar agenda asosiasi dengan nama Katsumine dicoret, dan tulisan kecil "diduga tenggelam".',
     'library',
     ST_SetSRID(ST_MakePoint(139.6548, 35.6775), 4326), false)
ON CONFLICT (id) DO NOTHING;

INSERT INTO quests (id, episode_id, title, objective, required_evidence_ids, target_npc)
VALUES
    (1142001, 1142, 'Rumah Edogawa Ranpo',
     'Periksa rekaman CCTV, telusuri telepon tawaran manuskrip, lalu baca catatan asosiasi soal Katsumine.',
     ARRAY[1142001, 1142002, 1142003], 'kobayashi-sumiko')
ON CONFLICT (id) DO NOTHING;

-- ======================================================================
-- 1144 — The Hotel Serial Bombing Case (1144–1145, manga)
-- ======================================================================
INSERT INTO episodes (id, title, type, description, unlocked_by_default, source_episodes, deduction_tree)
VALUES (
    1144,
    'The Hotel Serial Bombing Case',
    'CANON',
    'Rencana Masumi mengambil antidot saat Conan mandi gagal. Ia memberi Conan kode pengeboman hotel pertama, tetapi hotel itu ternyata target ketiga. Eri Kisaki memakai pengaruhnya untuk mendapat kode kedua, lalu menyusun rencana evakuasi — sementara Conan memperkirakan lokasi lapor pengebom yang sebenarnya.',
    false,
    ARRAY[1144, 1145],
    '{
       "nodes": [
         {"id": 1144001, "label": "Kode pertama sudah menunjuk target ketiga", "evidence": [1144001]},
         {"id": 1144002, "label": "Resepsionis menyimpan kode kedua di lemari arsip", "evidence": [1144001, 1144002]},
         {"id": 1144003, "label": "Lapor pengebom dipindah ke hotel cabang, bukan hotel target", "evidence": [1144001, 1144002, 1144003]}
       ],
       "edges": [
         {"from": 1144001, "to": 1144002, "requires": [1144001, 1144002]},
         {"from": 1144002, "to": 1144003, "requires": [1144001, 1144002, 1144003]}
       ]
     }'::jsonb
)
ON CONFLICT (id) DO NOTHING;

INSERT INTO evidence (id, episode_id, name, description, icon, map_coordinate, is_key_evidence)
VALUES
    (1144001, 1144, 'Kode Pengeboman Pertama',
     'Potongan kertas dengan koordinat angka dan urutan bom. Angka keluarnya sudah melewati catatan hotel sebelumnya.',
     'hash',
     ST_SetSRID(ST_MakePoint(139.6478, 35.6792), 4326), true),
    (1144002, 1144, 'Lemari Arsip Resepsionis',
     'Lemari terkunci berisi salinan kode kedua, hanya bisa dibuka dengan izin pengacara hotel.',
     'archive',
     ST_SetSRID(ST_MakePoint(139.6472, 35.6797), 4326), false),
    (1144003, 1144, 'Peta Lobi Hotel Cabang',
     'Peta evakuasi lobi hotel cabang, dengan lantai target ketiga disalin tangan di sudutnya.',
     'map-pinned',
     ST_SetSRID(ST_MakePoint(139.6466, 35.6787), 4326), false)
ON CONFLICT (id) DO NOTHING;

INSERT INTO quests (id, episode_id, title, objective, required_evidence_ids, target_npc)
VALUES
    (1144001, 1144, 'Hotel Beruntun',
     'Baca kode pengeboman pertama, buka lemari arsip resepsionis, lalu cocokkan peta lobi hotel cabang.',
     ARRAY[1144001, 1144002, 1144003], 'eri-kisaki')
ON CONFLICT (id) DO NOTHING;

-- ======================================================================
-- 1146 — The Whistling Bookstore 4 (TV original)
-- ======================================================================
INSERT INTO episodes (id, title, type, description, unlocked_by_default, source_episodes, deduction_tree)
VALUES (
    1146,
    'The Whistling Bookstore 4',
    'CANON',
    'Serial toko buku bekas keempat. Detektif Cilik kembali ke toko buku bekas yang suara peluit keretanya terdengar. Ringkasan resmi belum tersedia, sehingga chapter game memakai kerangka: buku lama yang hilang, penanda harga, dan peluit kereta sebagai petunjuk.',
    false,
    ARRAY[1146],
    '{
       "nodes": [
         {"id": 1146001, "label": "Buku hilang hanya dari rak lama", "evidence": [1146001]},
         {"id": 1146002, "label": "Penanda harga berisi nomor buku katalog", "evidence": [1146001, 1146002]},
         {"id": 1146003, "label": "Jadwal kereta menentukan waktu buku diambil", "evidence": [1146001, 1146002, 1146003]}
       ],
       "edges": [
         {"from": 1146001, "to": 1146002, "requires": [1146001, 1146002]},
         {"from": 1146002, "to": 1146003, "requires": [1146001, 1146002, 1146003]}
       ]
     }'::jsonb
)
ON CONFLICT (id) DO NOTHING;

INSERT INTO evidence (id, episode_id, name, description, icon, map_coordinate, is_key_evidence)
VALUES
    (1146001, 1146, 'Rak Buku yang Kosong',
     'Celah di rak lama hanya menyisakan debu bersih di bekas posisi dua buku.',
     'book-open',
     ST_SetSRID(ST_MakePoint(139.6548, 35.6736), 4326), true),
    (1146002, 1146, 'Penanda Harga Tua',
     'Kartu penanda harga dengan nomor katalog yang lebih tua dari nomor buku di rak.',
     'bookmark',
     ST_SetSRID(ST_MakePoint(139.6553, 35.6730), 4326), false),
    (1146003, 1146, 'Jadwal Kereta di Dinding',
     'Jadwal kereta yang dipaku di dinding toko, dengan salah satu jam dilingkari.',
     'train',
     ST_SetSRID(ST_MakePoint(139.6558, 35.6724), 4326), false)
ON CONFLICT (id) DO NOTHING;

INSERT INTO quests (id, episode_id, title, objective, required_evidence_ids, target_npc)
VALUES
    (1146001, 1146, 'Toko Buku yang Berpeluit',
     'Cek rak buku yang kosong, baca penanda harga tua, lalu cocokkan dengan jadwal kereta di dinding.',
     ARRAY[1146001, 1146002, 1146003], 'genta-kagumasa')
ON CONFLICT (id) DO NOTHING;

-- ======================================================================
-- 1147 — Stakeout 4 (TV original)
-- ======================================================================
INSERT INTO episodes (id, title, type, description, unlocked_by_default, source_episodes, deduction_tree)
VALUES (
    1147,
    'Stakeout 4',
    'CANON',
    'Kunjungan ke taman hiburan Beika di hari terakhirnya berubah menjadi misi pengintaian bersama Takagi dan Chiba untuk mencari pelaku perampokan enam tahun lalu yang belum tertangkap. Muncul ibu yang anaknya hilang, kurir yang paketnya dibatalkan, dan penjaga keamanan yang mencurigakan.',
    false,
    ARRAY[1147],
    '{
       "nodes": [
         {"id": 1147001, "label": "Tiket komidi putar dengan cap lama", "evidence": [1147001]},
         {"id": 1147002, "label": "Paket kurir yang dibatalkan berulang", "evidence": [1147001, 1147002]},
         {"id": 1147003, "label": "Penjaga keamanan menyimpan tiket lama sebagai kenangan", "evidence": [1147001, 1147002, 1147003]}
       ],
       "edges": [
         {"from": 1147001, "to": 1147002, "requires": [1147001, 1147002]},
         {"from": 1147002, "to": 1147003, "requires": [1147001, 1147002, 1147003]}
       ]
     }'::jsonb
)
ON CONFLICT (id) DO NOTHING;

INSERT INTO evidence (id, episode_id, name, description, icon, map_coordinate, is_key_evidence)
VALUES
    (1147001, 1147, 'Tiket Komidi Putar Lama',
     'Tiket keluaran enam tahun lalu, masih tersimpan di dompet penjaga keamanan.',
     'ticket',
     ST_SetSRID(ST_MakePoint(139.6452, 35.6760), 4326), true),
    (1147002, 1147, 'Slip Paket Dibatalkan',
     'Tiga slip pengiriman dengan penerima sama, semuanya dibatalkan tanpa alasan tertulis.',
     'package',
     ST_SetSRID(ST_MakePoint(139.6459, 35.6754), 4326), false),
    (1147003, 1147, 'Buku Catatan Penjaga',
     'Buku jaga taman: satu entri lama berisi nama perampok yang tidak tertangkap.',
     'book-open',
     ST_SetSRID(ST_MakePoint(139.6466, 35.6748), 4326), false)
ON CONFLICT (id) DO NOTHING;

INSERT INTO quests (id, episode_id, title, objective, required_evidence_ids, target_npc)
VALUES
    (1147001, 1147, 'Pengintaian di Taman Hiburan',
     'Periksa tiket komidi putar lama, telusuri slip paket yang dibatalkan, lalu baca buku jaga penjaga.',
     ARRAY[1147001, 1147002, 1147003], 'takagi-wataru')
ON CONFLICT (id) DO NOTHING;

-- ======================================================================
-- 1148 — The Detective Boys and the Two Leaders (1148–1149, manga)
-- ======================================================================
INSERT INTO episodes (id, title, type, description, unlocked_by_default, source_episodes, deduction_tree)
VALUES (
    1148,
    'The Detective Boys and the Two Leaders',
    'CANON',
    'Agasa tak bisa menemani, jadi Rumi mengantar Detektif Cilik ke event pantai bertema Kamen Yaiba. Conan meminta Subaru ikut mengawasi Rumi. Di pantai terjadi pembunuhan; kesimpulan awal polisi menunjuk Takaki sebagai pelaku sampai Conan melihat pakaian renang Genta yang sobek.',
    false,
    ARRAY[1148, 1149],
    '{
       "nodes": [
         {"id": 1148001, "label": "Pakaian renang Genta sobek memotong alibi", "evidence": [1148001]},
         {"id": 1148002, "label": "Handuk dipakai untuk mengeringkan celana pelaku", "evidence": [1148001, 1148002]},
         {"id": 1148003, "label": "Takaki tidak mungkin menjadi pelaku", "evidence": [1148001, 1148002, 1148003]}
       ],
       "edges": [
         {"from": 1148001, "to": 1148002, "requires": [1148001, 1148002]},
         {"from": 1148002, "to": 1148003, "requires": [1148001, 1148002, 1148003]}
       ]
     }'::jsonb
)
ON CONFLICT (id) DO NOTHING;

INSERT INTO evidence (id, episode_id, name, description, icon, map_coordinate, is_key_evidence)
VALUES
    (1148001, 1148, 'Swimsuit Genta yang Sobek',
     'Kain sobek di bagian bahu, cocok dengan kait hiasan topeng Kamen Yaiba di TKP.',
     'shirt',
     ST_SetSRID(ST_MakePoint(139.6606, 35.6728), 4326), true),
    (1148002, 1148, 'Handuk Pantai Basah',
     'Handuk yang digantung di gantungan baju, basah dan berbau garam — bukan bekas mandi.',
     'towel',
     ST_SetSRID(ST_MakePoint(139.6613, 35.6722), 4326), false),
    (1148003, 1148, 'Jadwal Lomba Pantai',
     'Papan jadwal lomba yang menunjukkan Takaki berada di panggung saat kejadian.',
     'clipboard-list',
     ST_SetSRID(ST_MakePoint(139.6620, 35.6716), 4326), false)
ON CONFLICT (id) DO NOTHING;

INSERT INTO quests (id, episode_id, title, objective, required_evidence_ids, target_npc)
VALUES
    (1148001, 1148, 'Dua Pendamping',
     'Periksa pakaian renang Genta yang sobek, cek handuk basah di gantungan, lalu cocokkan jadwal lomba.',
     ARRAY[1148001, 1148002, 1148003], 'amiya-rumi')
ON CONFLICT (id) DO NOTHING;

-- ======================================================================
-- 1150 — Kaitou Kid and the Crown Trick (1150–1151, manga)
-- ======================================================================
INSERT INTO episodes (id, title, type, description, unlocked_by_default, source_episodes, deduction_tree)
VALUES (
    1150,
    'Kaitou Kid and the Crown Trick',
    'CANON',
    'Conan, Ran, dan Sonoko diundang ke lantai 60 gedung Suzuki di Ginza untuk menjaga mahkota Siren Splash, target terbaru Kaitou Kid. Azusa mengantar sandwich, Wakita mencoba menanyai Conan soal Rumi Wakasa, lalu Kid muncul di samping mahkota dan membuatnya lenyap.',
    false,
    ARRAY[1150, 1151],
    '{
       "nodes": [
         {"id": 1150001, "label": "Kecap dari sandwich Azusa sebagai petunjuk trik", "evidence": [1150001]},
         {"id": 1150002, "label": "Vitrin dipasang ulang oleh orang dalam", "evidence": [1150001, 1150002]},
         {"id": 1150003, "label": "Kid menyamar sebagai petugas pengganti lemari", "evidence": [1150001, 1150002, 1150003]}
       ],
       "edges": [
         {"from": 1150001, "to": 1150002, "requires": [1150001, 1150002]},
         {"from": 1150002, "to": 1150003, "requires": [1150001, 1150002, 1150003]}
       ]
     }'::jsonb
)
ON CONFLICT (id) DO NOTHING;

INSERT INTO evidence (id, episode_id, name, description, icon, map_coordinate, is_key_evidence)
VALUES
    (1150001, 1150, 'Bekas Kecap di Tray Sandwich',
     'Tetesan kecap merah di baki Azusa membentuk pola yang sama dengan siluet lantai vitrin.',
     'utensils',
     ST_SetSRID(ST_MakePoint(139.6448, 35.6794), 4326), true),
    (1150002, 1150, 'Sekrup Vitrin yang Dibalik',
     'Sekrup di kaca vitrin Siren Splash diputar ulang dengan arah berlawanan dari pemasangan asli.',
     'wrench',
     ST_SetSRID(ST_MakePoint(139.6441, 35.6799), 4326), false),
    (1150003, 1150, 'Lencana Petugas Pengganti',
     'Lencana petugas pembersih lantai 60 yang baru dipasang hari itu, dengan nama yang tidak ada di daftar.',
     'badge',
     ST_SetSRID(ST_MakePoint(139.6434, 35.6788), 4326), false)
ON CONFLICT (id) DO NOTHING;

INSERT INTO quests (id, episode_id, title, objective, required_evidence_ids, target_npc)
VALUES
    (1150001, 1150, 'Trik Mahkota Siren Splash',
     'Periksa baki sandwich Azusa, cek sekrup vitrin di lantai 60, lalu telusuri lencana petugas pengganti.',
     ARRAY[1150001, 1150002, 1150003], 'kaito-kid')
ON CONFLICT (id) DO NOTHING;

COMMIT;

