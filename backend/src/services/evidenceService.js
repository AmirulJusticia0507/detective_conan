import { query } from '../db.js'
import { HttpError, validateRadius } from '../utils/validate.js'

/**
 * Kumpulkan bukti. Server memvalidasi jarak — klien tidak boleh menentukan
 * apakah interaksi sah.
 */
export async function collectEvidenceService(playerId, evidenceId, radiusInput) {
  const radius = validateRadius(radiusInput)

  const { rows } = await query(
    `SELECT e.id, e.name, e.description, e.episode_id, e.is_key_evidence,
            p.location IS NULL AS player_has_no_location,
            CASE WHEN p.location IS NULL THEN NULL
                 ELSE ROUND(ST_Distance(e.map_coordinate::geography, p.location::geography)::numeric, 1)
            END AS distance_m
       FROM evidence e
       JOIN players p ON p.id = $1
      WHERE e.id = $2
        AND e.episode_id = p.current_episode`,
    [playerId, evidenceId],
  )

  if (rows.length === 0) throw new HttpError(404, 'Bukti tidak ditemukan pada episode aktif')

  const item = rows[0]
  if (item.player_has_no_location) {
    throw new HttpError(409, 'Posisi pemain belum tersimpan. Kirim posisi terlebih dahulu.')
  }
  if (item.distance_m === null || buildNumber(item.distance_m) > radius) {
    throw new HttpError(403, 'Terlalu jauh dari bukti untuk memeriksanya')
  }

  const points = item.is_key_evidence ? 20 : 5
  const { rows: updated } = await query(
    `UPDATE players p
        SET inventory = CASE
              WHEN p.inventory @> jsonb_build_array(jsonb_build_object('id', $2::int)) THEN p.inventory
              ELSE p.inventory || jsonb_build_array(jsonb_build_object(
                     'id', $2::int,
                     'name', $3::text,
                     'description', $4::text
                   ))
            END,
            deduction_points = p.deduction_points + CASE
              WHEN p.inventory @> jsonb_build_array(jsonb_build_object('id', $2::int)) THEN 0
              ELSE $5::int
            END
      WHERE p.id = $1
      RETURNING p.inventory, p.deduction_points`,
    [playerId, item.id, item.name, item.description ?? '', points],
  )

  return {
    evidence: {
      id: item.id,
      name: item.name,
      description: item.description,
      is_key_evidence: item.is_key_evidence,
      distance_m: item.distance_m,
    },
    inventory: updated[0].inventory,
    deduction_points: updated[0].deduction_points,
  }
}

// `ROUND(...::numeric, 1)` mengembalikan string dari pg; samakan ke angka.
function buildNumber(value) {
  const num = Number(value)
  return Number.isFinite(num) ? num : Infinity
}
