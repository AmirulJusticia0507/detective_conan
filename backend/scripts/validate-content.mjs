#!/usr/bin/env node
/**
 * Validator konten episode (tanpa dependency).
 * Memeriksa aturan dari skill episode-quest-generator terhadap berkas seed SQL:
 *   - ID unik
 *   - tepat 1 is_key_evidence per episode
 *   - setiap quest merujuk evidence episode yang sama
 *   - setiap edge deduction tree merujuk evidence yang ada (DAG menuju node akhir)
 *
 * Pakai: node scripts/validate-content.mjs
 */

import { readFileSync } from 'node:fs'
import { fileURLToPath } from 'node:url'
import { dirname, resolve } from 'node:path'

const here = dirname(fileURLToPath(import.meta.url))
const files = [
  resolve(here, '../migrations/001_init.sql'),
  resolve(here, '../migrations/002_episode_content.sql'),
]

const episodes = new Map() // id -> { evidenceIds:Set, quests:[], tree }
const allEvidenceIds = new Set()
const errors = []

function getEpisode(id) {
  if (!episodes.has(id)) episodes.set(id, { evidenceIds: new Set(), keyCount: 0, quests: [], tree: null })
  return episodes.get(id)
}

function parseEvidence(block) {
  // (id, episodeId, 'name', ..., true|false)
  const re = /\(\s*(\d{7})\s*,\s*(\d{4})\s*,[\s\S]*?,\s*(true|false)\s*\)/g
  let m
  while ((m = re.exec(block))) {
    const [, id, epId, key] = m
    const numericId = Number(id)
    const episodeId = Number(epId)

    if (allEvidenceIds.has(numericId)) errors.push(`ID evidence duplikat: ${id}`)
    allEvidenceIds.add(numericId)
    if (!String(id).startsWith(epId)) {
      errors.push(`Evidence ${id} tidak diawali episode_id ${epId}`)
    }

    const ep = getEpisode(episodeId)
    ep.evidenceIds.add(numericId)
    if (key === 'true') ep.keyCount += 1
  }
}

function parseQuests(block) {
  const re = /\(\s*(\d{7})\s*,\s*(\d{4})\s*,[\s\S]*?ARRAY\[([\d,\s]+)\]/g
  let m
  while ((m = re.exec(block))) {
    const [, , epId, ids] = m
    const required = ids.split(',').map((s) => Number(s.trim()))
    getEpisode(Number(epId)).quests.push({ required })
  }
}

function parseTree(block, episodeId) {
  const edgeRe = /\{"from"\s*:\s*(\d+)\s*,\s*"to"\s*:\s*(\d+)\s*,\s*"requires"\s*:\s*\[([\d,\s]*)\]/g
  const edges = []
  let m
  while ((m = edgeRe.exec(block))) {
    edges.push({ from: Number(m[1]), to: Number(m[2]) })
  }
  // 'requires' tidak divalidasi karena backend sudah mengecek dan seed
  // menyertakan from+to secara eksplisit.
  getEpisode(episodeId).tree = edges
}

for (const file of files) {
  const sql = readFileSync(file, 'utf8')

  for (const match of sql.matchAll(/INSERT INTO evidence[\s\S]*?;\n/g)) {
    parseEvidence(match[0])
  }
  for (const match of sql.matchAll(/INSERT INTO quests[\s\S]*?;\n/g)) {
    parseQuests(match[0])
  }
  // Episode baru yang sekaligus membawa deduction_tree (001 & 002).
  for (const match of sql.matchAll(/INSERT INTO episodes[\s\S]*?ON CONFLICT \(id\) DO NOTHING;/g)) {
    const idMatch = /VALUES\s*\(\s*(\d{4})/.exec(match[0])
    if (!idMatch) continue
    const episodeId = Number(idMatch[1])
    getEpisode(episodeId)
    parseTree(match[0], episodeId)
    // `source_episodes` wajib ada bila disebut: satu chapter = 1–2 episode anime.
    if (match[0].includes('source_episodes')) {
      const src = /ARRAY\[([\d,\s]+)\]/.exec(match[0].slice(match[0].indexOf('source_episodes')))
      if (!src) errors.push(`Episode ${episodeId}: source_episodes tidak terbaca`)
      else if (!src[1].split(',').map((s) => Number(s.trim())).includes(episodeId)) {
        errors.push(`Episode ${episodeId}: source_episodes harus memuat episode itu sendiri`)
      }
    }
  }
  // Update tree untuk episode yang sudah ada (001_init.sql).
  for (const match of sql.matchAll(/UPDATE episodes[\s\S]*?WHERE id = (\d+);/g)) {
    parseTree(match[0], Number(match[1]))
  }
}

// Gabungkan edge dari beberapa sumber per episode (001 UPDATE + 002 INSERT).
for (const [id, ep] of episodes) {
  if (ep.tree === null) errors.push(`Episode ${id}: deduction_tree tidak ditemukan`)
}

for (const [id, ep] of episodes) {
  if (ep.evidenceIds.size < 3) {
    errors.push(`Episode ${id}: hanya ${ep.evidenceIds.size} evidence (minimal 3)`)
  }
  if (ep.keyCount !== 1) {
    errors.push(`Episode ${id}: ${ep.keyCount} bukti kunci (harus tepat 1)`)
  }

  for (const quest of ep.quests) {
    for (const required of quest.required) {
      if (!ep.evidenceIds.has(required)) {
        errors.push(`Episode ${id}: quest meminta evidence ${required} yang tidak ada di episode ini`)
      }
    }
  }

  for (const edge of ep.tree ?? []) {
    if (!ep.evidenceIds.has(edge.from)) {
      errors.push(`Episode ${id}: edge from ${edge.from} bukan evidence episode ini`)
    }
    if (!ep.evidenceIds.has(edge.to)) {
      errors.push(`Episode ${id}: edge to ${edge.to} bukan evidence episode ini`)
    }
  }
}

if (errors.length) {
  console.error(`✖ ${errors.length} masalah konten:`)
  for (const err of errors) console.error(`  - ${err}`)
  process.exit(1)
}

console.log(`✔ Konten valid: ${episodes.size} episode, ${allEvidenceIds.size} evidence.`)
