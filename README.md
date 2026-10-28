
# 🕵️‍♂️ Beika District Chronicles: Detective Conan Episode 1126-1150 Arc

Sebuah game **Open-World 2D Top-Down / Isometric RPG** berbasis Web yang diadaptasi dari serial *Detective Conan (Episode 1126 - 1150)*. Pemain dapat menjelajahi Distrik Beika, memecahkan misteri interaktif, mengumpulkan bukti, dan berinteraksi dengan karakter ikonik seperti Conan, Kogoro Mouri, Amuro Tooru, hingga Kaitou Kid.

## 🛠 Tech Stack

* **Frontend Framework:** Vue 3 (Composition API, Script Setup, Pinia)
* **Styling & UI:** Tailwind CSS, Lucide Icons, HTML5 Canvas / PixiJS (Render Map Open-World)
* **Backend Runtime:** Node.js + Express.js
* **Database & Spatial Engine:** PostgreSQL + PostGIS extension (untuk koordinat tempat & open-world tiles)
* **Realtime / Websocket:** Socket.io (Opsional untuk fitur NPC real-time atau Co-op)

## 🎮 Fitur Utama

1. **Interactive Open World Beika Town:** Jelajahi Kantor Detektif Mouri, Cafe Poirot, Tropical Land, hingga lokasi heist Kaitou Kid.
2. **Deduction Engine & Evidence Board:** Kumpulkan bukti (*clues*) di lokasi kejadian, hubungkan antar bukti, dan buat kesimpulan untuk menyelesaikan episode.
3. **Episode-Based Progression (Ep 1126–1150):**
   * *Ep 1126:* Kogoro Framed Arc (Escape & Prove Innocence)
   * *Phantom Thief Kid Arc:* Crown Magic Heist Event
   * *Poirot Arc:* Secret Investigation with Amuro & Sera
4. **Agility & Gadget System:** Gunakan Gadget Conan (Jam Tangan Bius, Dasi Kupu-Kupu Pengubah Suara, Sepatu Super-Strength, Skate-board Turbo).

## 🚀 Quick Start

```bash
# Backend Setup
cd backend
npm install
npm run dev

# Frontend Setup
cd frontend
npm install
npm run dev

---

# 2. System Design & Database Schema

### Database Schema (PostgreSQL + PostGIS)

```sql
-- Enable PostGIS Extension
CREATE EXTENSION IF NOT EXISTS postgis;

-- 1. Table Users / Players
CREATE TABLE players (
    id SERIAL PRIMARY KEY,
    username VARCHAR(50) UNIQUE NOT NULL,
    current_episode INT DEFAULT 1126,
    stamina INT DEFAULT 100,
    deduction_points INT DEFAULT 0,
    inventory JSONB DEFAULT '[]'::jsonb,
    location GEOMETRY(Point, 4326), -- PostGIS Spatial Coordinate
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 2. Table Episodes (Ep 1126 - 1150)
CREATE TABLE episodes (
    id INT PRIMARY KEY, -- e.g., 1126
    title VARCHAR(150) NOT NULL,
    type VARCHAR(20) CHECK (type IN ('CANON', 'FILLER')),
    description TEXT,
    unlocked_by_default BOOLEAN DEFAULT false
);

-- 3. Table Evidence / Clues per Episode
CREATE TABLE evidence (
    id SERIAL PRIMARY KEY,
    episode_id INT REFERENCES episodes(id),
    name VARCHAR(100) NOT NULL,
    description TEXT,
    icon VARCHAR(50),
    map_coordinate GEOMETRY(Point, 4326),
    is_key_evidence BOOLEAN DEFAULT false
);

-- 4. Table Quests & Deductions
CREATE TABLE quests (
    id SERIAL PRIMARY KEY,
    episode_id INT REFERENCES episodes(id),
    title VARCHAR(100),
    objective TEXT,
    required_evidence_ids INT[],
    target_npc VARCHAR(50)
);
3. System Architecture
Arsitektur dibuat modular dengan pemisahan Game State Client-side (Vue3/Pinia) dan State Validation Server-side (Node/Express/PostgreSQL):

Plaintext


[ Browser / Vue 3 Client ]
    ├── Components (MapViewport, EvidenceBoard, DialogueBox, Inventory)
    ├── Stores (Pinia: playerStore, mapStore, episodeStore)
    └── Render Engine (Canvas / PixiJS + Tailwind Overlay)
           │
           │ REST API / WebSocket (JSON)
           ▼
[ Express.js Backend Server ]
    ├── Controllers (PlayerController, DeductionController, MapController)
    ├── Services (QuestLogic Engine, Spatial Movement Engine)
    └── Middleware (Auth, Episode Validator)
           │
           ▼
[ PostgreSQL Database (PostGIS) ]
    ├── Tables (players, episodes, evidence, quests)
    └── Spatial Queries (ST_DWithin for NPC/Evidence Proximity)
4. Agent & Custom Skills Definition
Agar agen AI (seperti Gemini / Claude) dapat membantu mengembangkan game ini secara mandiri, berikut struktur sistem Agent & Skills:

🤖 Agent Role: conan-game-builder
Purpose: Membantu mendesain logika game, generate quest berdasarkan episode 1126–1150, dan menulis kode Vue 3 / Express.

Capabilities:

Generate episode-specific puzzle logics.

Write Vue 3 Composition API reactive stores & components.

Formulate SQL PostGIS spatial queries for map triggers.

🛠️ Agent Skills Required:
episode-quest-generator: Menerjemahkan sinopsis episode anime Conan menjadi Quest JSON, Evidence Items, dan Deduction Logic Tree.

vue3-canvas-renderer: Menghasilkan komponen Vue 3 dengan HTML5 Canvas / Tailwind UI untuk peta top-down dan dialog box anime.

express-spatial-api: Menyediakan API Express.js untuk deteksi jarak pemain dengan NPC/Bukti menggunakan query PostGIS (ST_DWithin).

5. TODO Checklist & Roadmap
[ ] Phase 1: Foundation & Setup

[ ] Setup Monorepo / Folder Structure (/frontend & /backend).

[ ] Inisialisasi PostgreSQL dengan ekstensi PostGIS.

[ ] Setup Vue 3 + Tailwind CSS + Pinia store.

[ ] Setup Express.js server dengan koneksi pg-promise / Knex.js / Prisma.

[ ] Phase 2: Core Game Mechanics

[ ] Implementasi Peta Open World Distrik Beika (Canvas top-down 2D movement).

[ ] Sistem Interaksi NPC & Dialogue System dengan Tailwind CSS overlay.

[ ] Inventory System & Evidence Board (UI Drag-and-drop bukti untuk analisis).

[ ] Phase 3: Episode Content Development (Ep 1126 - 1150)

[ ] Ep 1126 Arc: Misi pembebasan & pembersihan nama Kogoro Mouri.

[ ] Kaitou Kid Arc: Mini-game pertunjukan sulap & pencurian mahkota di museum.

[ ] Cafe Poirot Arc: Misi penyelidikan rahasia bersama Amuro & Sera.

[ ] Filler Episodes Mini-quests (Investigasi kasus-kasus kecil Beika Town).

[ ] Phase 4: Polish & UI Anime Theme

[ ] Desain UI/UX khas Detective Conan (Skema warna Biru, Merah, Kuning, font retro/detective).

[ ] Sound FX & Audio Triggers (Suara Jam Bius, Penemuan Bukti, BGM Detektif).

[ ] Testing & Optimization (PostGIS Indexing & State Synchronization).
```
