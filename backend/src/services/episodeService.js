import { query } from '../db.js'
import { HttpError } from '../utils/validate.js'

function toNumber(value) {
  const num = Number(value)
  return Number.isFinite(num) ? num : null
}

/**
 * Detail episode: metadata, evidence, quest, dan deduction tree.
 */
export async function getEpisodeService(episodeId) {
  const { rows } = await query(
    `SELECT id, title, type, description, unlocked_by_default, deduction_tree
       FROM episodes
      WHERE id = $1`,
    [episodeId],
  )
  if (rows.length === 0) throw new HttpError(404, 'Episode tidak ditemukan')

  const [evidence, quests] = await Promise.all([
    query(
      `SELECT id, name, description, icon, is_key_evidence,
              ST_Y(map_coordinate::geometry) AS lat,
              ST_X(map_coordinate::geometry) AS lng
         FROM evidence
        WHERE episode_id = $1
        ORDER BY id`,
      [episodeId],
    ),
    query(
      `SELECT id, title, objective, required_evidence_ids, target_npc
         FROM quests
        WHERE episode_id = $1
        ORDER BY id`,
      [episodeId],
    ),
  ])

  const episode = rows[0]
  return {
    episode: {
      id: episode.id,
      title: episode.title,
      type: episode.type,
      description: episode.description,
      unlocked_by_default: episode.unlocked_by_default,
    },
    evidence: evidence.rows.map((row) => ({
      ...row,
      lat: toNumber(row.lat),
      lng: toNumber(row.lng),
    })),
    quests: quests.rows.map((row) => ({
      ...row,
      required_evidence_ids: row.required_evidence_ids ?? [],
    })),
    deduction_tree: episode.deduction_tree ?? { nodes: [], edges: [] },
  }
}

/**
 * Validasi satu langkah deduksi (from -> to) terhadap deduction tree episode.
 * Edge valid jika bukti asal, bukti tujuan, dan semua bukti `requires` sudah
 * dikumpulkan pemain.
 */
export async function submitDeductionService(playerId, episodeId, fromId, toId) {
  const { rows } = await query('SELECT deduction_tree FROM episodes WHERE id = $1', [episodeId])
  if (rows.length === 0) throw new HttpError(404, 'Episode tidak ditemukan')

  const tree = rows[0].deduction_tree ?? { nodes: [], edges: [] }
  const edge = (tree.edges ?? []).find(
    (e) => toNumber(e.from) === fromId && toNumber(e.to) === toId,
  )
  if (!edge) {
    return { ok: false, reason: 'Tidak ada hubungan deduksi antara kedua bukti.' }
  }

  const needed = [fromId, toId, ...(edge.requires ?? []).map(toNumber)].filter(
    (id) => id !== null,
  )

  // Satu query: pastikan pemain ada dan hitung berapa bukti yang sudah dimiliki.
  const playerExists = await query('SELECT 1 FROM players WHERE id = $1', [playerId])
  if (playerExists.rowCount === 0) throw new HttpError(404, 'Pemain tidak ditemukan')

  const { rows: owned } = await query(
    `SELECT COUNT(*)::int AS owned_count
       FROM players p,
            unnest($2::int[]) AS wanted(id)
      WHERE p.id = $1
        AND p.inventory @> jsonb_build_array(jsonb_build_object('id', wanted.id))`,
    [playerId, needed],
  )

  const uniqueNeeded = [...new Set(needed)]
  if (owned[0].owned_count < uniqueNeeded.length) {
    return { ok: false, reason: 'Masih ada bukti yang belum dikumpulkan untuk deduksi ini.' }
  }

  await query('UPDATE players SET deduction_points = deduction_points + 10 WHERE id = $1', [
    playerId,
  ])

  return { ok: true, solvedNodeId: toId }
}
