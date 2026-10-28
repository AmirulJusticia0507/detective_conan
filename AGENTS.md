# Aturan Agen — Beika District Chronicles

## Wajib commit + push setiap task

Setelah **setiap** task selesai, agen wajib langsung:

```bash
git status
git diff
git add -A
git commit -m "feat(scope): deskripsi singkat"   # Conventional Commits, bahasa Indonesia
git push
```

Aturan detail:

- Format commit: `feat|fix|docs|refactor|test|chore(scope): pesan`.
- Satu commit untuk satu perubahan logis.
- Jangan commit `.env`, secret, `node_modules/`, atau artefak build.
- Jangan `git push --force` ke `main`/`master` tanpa izin user.
- Jika push gagal (auth / diverged / protected), laporkan error dan langkah
  perbaikannya; perubahan lokal tetap harus ter-commit.

Rincian lengkap ada di `.opencode/agents/auto-commit.md`.

## Konteks proyek

- Frontend: Vue 3 (`<script setup>`), Pinia, Tailwind, Canvas/PixiJS.
- Backend: Node.js + Express, PostgreSQL + PostGIS.
- Teks UI & commit: bahasa Indonesia. Nama variabel/fungsi: Inggris.
