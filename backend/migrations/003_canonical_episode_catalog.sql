-- Katalog kanon anime 1126–1150. Quest, bukti, dan lokasi game tetap
-- interpretasi gameplay; kolom episodes di bawah menyimpan premis anime.

INSERT INTO episodes (id, title, type, description, unlocked_by_default)
VALUES
  (1126, 'The Detective Who Lost His Mind', 'FILLER', 'Kogoro menyelidiki dugaan perselingkuhan ketua perusahaan dan seorang joki idola; sebuah jeritan saat ia mengantar klien pulang mengubah penyelidikan menjadi kasus kriminal.', true),
  (1127, 'The Interrogation Room 2', 'FILLER', 'Pengakuan tersangka pembunuhan di ruang interogasi justru membuat Megure ragu. Conan dan Kogoro menelusuri orang-orang yang terkait dengannya untuk menemukan dalang sebenarnya.', false),
  (1128, 'Conan and Megure\'s Two Hostages (Part 1)', 'FILLER', 'Conan menemukan pesan minta tolong dalam kapsul mainan dan menukar tempat dengan seorang anak yang diculik. Ia lalu mengetahui para penculik juga sedang diperas.', false),
  (1129, 'Conan and Megure\'s Two Hostages (Part 2)', 'FILLER', 'Conan bekerja dari dalam persembunyian penculik untuk membebaskan kedua sandera dan menjebak pelaku yang memaksa keluarga lain melakukan penculikan.', false),
  (1130, 'The Suspected Infidelity of the Triple Collab (Part 1)', 'CANON', 'Tiga pasangan yang saling curiga berkumpul di restoran yang sama. Saat seorang tamu tewas, dugaan perselingkuhan bercampur dengan pembunuhan.', false),
  (1131, 'The Suspected Infidelity of the Triple Collab (Part 2)', 'CANON', 'Yumi dan Naeko memecahkan pembunuhan di restoran sekaligus mengungkap bahwa kegiatan mencurigakan para pasangan adalah persiapan hadiah kejutan.', false),
  (1132, 'Mitsuhiko Tsuburaya\'s Detective Notes 3', 'FILLER', 'Mitsuhiko melihat tanda bahwa seorang pria yang diduga terkait komplotan perampok sebenarnya sedang berada dalam bahaya.', false),
  (1133, 'Best Husband', 'FILLER', 'Keluarga Mouri melindungi seorang wanita dari ancaman misterius. Kematian di gudang bawah tanah yang tampak sebagai bela diri menyimpan kejanggalan.', false),
  (1134, 'Misfortune of the Positive Man', 'FILLER', 'Seorang pria optimistis menyerahkan sidik jarinya untuk membersihkan namanya dari perampokan, tetapi bukti itu malah menautkannya pada kasus pembunuhan lama.', false),
  (1135, 'Momiji Ooka\'s Sweet Trap (Part 1)', 'CANON', 'Rencana Momiji menyatakan perasaan kepada Heiji berlangsung bersamaan dengan kematian di rumah penulis naskah TV yang menyerupai bunuh diri lama.', false),
  (1136, 'Momiji Ooka\'s Sweet Trap (Part 2)', 'CANON', 'Conan dan Heiji membongkar trik pembunuhan melalui petunjuk lollipop, sementara identitas masa lalu Iori mulai terkuak.', false),
  (1137, 'The Secret of the Popular Restaurant\'s Changing Flavor', 'FILLER', 'Conan menyelidiki perubahan rasa kedai ramen populer dan hilangnya sang pemilik.', false),
  (1138, 'The Moving Police Box', 'FILLER', 'Saat menghadiri peresmian koban bergerak, Detektif Cilik terseret pembajakan mobil. Sinyal badge mereka menjadi kunci ketika para pembajak ditemukan tewas.', false),
  (1139, 'The Sister Troubled By Her Naughty Brother', 'FILLER', 'Pembunuhan di apartemen memaksa Conan menilai dua kesaksian saudara yang saling bertentangan dan memiliki hubungan buruk.', false),
  (1140, 'Girls Day Mystery 3', 'FILLER', 'Event ninja membawa Ran, Sonoko, Detektif Cilik, dan Sato ke pencurian mahkota di toko perhiasan.', false),
  (1141, 'The Mouri Family House Sits', 'FILLER', 'Saat menjaga rumah seorang kritikus sastra, keluarga Mouri menemukan jasad tersembunyi dan harus menentukan siapa yang diuntungkan oleh kematian korban.', false),
  (1142, 'The Rampo Mansion Murder Case (Part 1)', 'FILLER', 'Kunjungan Detektif Cilik ke gudang terkait Edogawa Ranpo berubah menjadi penyelidikan pembunuhan dengan rekaman CCTV yang menyesatkan.', false),
  (1143, 'The Rampo Mansion Murder Case (Part 2)', 'FILLER', 'Masa lalu anggota asosiasi Ranpo dan kematian lama menjadi kunci motif pembunuhan berantai di gudang.', false),
  (1144, 'The Hotel Serial Bombing Case (Part 1)', 'CANON', 'Kode ancaman bom membawa Conan dan Masumi ke hotel yang ternyata bukan target pertama pelaku.', false),
  (1145, 'The Hotel Serial Bombing Case (Part 2)', 'CANON', 'Eri memimpin evakuasi hotel sementara Conan menelusuri perubahan posisi pelapor untuk menemukan lokasi pengebom.', false),
  (1146, 'The Whistling Bookstore 4', 'FILLER', 'Detektif Cilik kembali ke toko buku bekas yang selalu diiringi suara peluit kereta untuk menangani misteri baru.', false),
  (1147, 'Stakeout 4', 'FILLER', 'Hari di taman hiburan berubah menjadi operasi pengintaian bersama Takagi dan Chiba terhadap pelaku perampokan lama.', false),
  (1148, 'The Detective Boys and the Two Leaders (Part 1)', 'CANON', 'Rumi membawa Detektif Cilik ke acara pantai; pembunuhan di lokasi membuat Conan meminta Subaru ikut mengawasi situasi.', false),
  (1149, 'The Detective Boys and the Two Leaders (Part 2)', 'CANON', 'Petunjuk kecil pada pakaian Genta menggugurkan kesimpulan awal polisi dan mempertemukan Subaru dengan Rumi.', false),
  (1150, 'Kaitou Kid and the Crown Trick (Part 1)', 'CANON', 'Conan menjaga mahkota Siren\'s Splash di gedung Suzuki saat Kaitou Kid menguji sistem keamanan khusus dan membuat mahkota tampak lenyap.', false)
ON CONFLICT (id) DO UPDATE
SET title = EXCLUDED.title,
    type = EXCLUDED.type,
    description = EXCLUDED.description;
