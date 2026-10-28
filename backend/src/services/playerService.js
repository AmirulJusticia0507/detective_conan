import { query } from '../db.js'
import { HttpError, validateLatLng, validateRadius } from '../utils/validate.js'

/**
 * Ambil profil pemain beserta posisinya dalam format lat/lng untuk klien.
 */
export async function getPlayerService(playerId) {
  const { rows } = await query(
    `SELECT id, username, current_episode, stamina, deduction_points, inventory,
            ST_Y(location::geometry) AS lat, ST_X(location::geometry) AS lng
       FROM players
      WHERE id = $1`,
    [playerId],
  )
  if (rows.length === 0) throw new HttpError(404, 'Pemain tidak ditemukan')

  const row = rows[0]
  return {
    id: row.id,
    username: row.username,
    current_episode: row.current_episode,
    stamina: row.stamina,
    deduction_points: row.deduction_points,
    inventory: row.inventory,
    lat: row.lat,
    lng: row.lng,
  }
}

/**
 * Simpan posisi pemain. ST_MakePoint menerima (lng, lat).
 */
export async function updatePositionService(playerId, latInput, lngInput) {
  const { lat, lng } = validateLatLng(latInput, lngInput)

  const { rows } = await query(
    `UPDATE players
        SET location = ST_SetSRID(ST_MakePoint($2, $1), 4326)
      WHERE id = $3
      RETURNING id, ST_Y(location::geometry) AS lat, ST_X(location::geometry) AS lng`,
    [lat, lng, playerId],
  )
  if (rows.length === 0) throw new HttpError(404, 'Pemain tidak ditemukan')
  return rows[0]
}

/**
 * Bukti di sekitar pemain (radius meter) memakai ST_DWithin agar index GIST
 * terpakai. Pemain harus punya lokasi dulu.
 */
export async function nearbyService(playerId, radiusInput) {
  const radius = validateRadius(radiusInput)

  const { rows: players } = await query(
    'SELECT id, location IS NOT NULL AS has_location FROM players WHERE id = $1',
    [playerId],
  )
  if (players.length === 0) throw new HttpError(404, 'Pemain tidak ditemukan')
  if (!players[0].has_location) {
    return { radius, items: [], reason: 'Lokasi pemain belum tersimpan di server.' }
  }

  const { rows } = await query(
    `SELECT e.id,
            e.name,
            e.icon,
            e.is_key_evidence,
            ROUND(ST_Distance(e.map_coordinate::geography, p.location::geography)::numeric, 1) AS distance_m,
            ST_Y(e.map_coordinate::geometry) AS lat,
            ST_X(e.map_coordinate::geometry) AS lng,
            p.inventory @> jsonb_build_array(jsonb_build_object('id', e.id)) AS collected
       FROM evidence e
       JOIN players p ON p.id = $1
      WHERE e.episode_id = p.current_episode
        AND e.map_coordinate IS NOT NULL
        AND ST_DWithin(e.map_coordinate::geography, p.location::geography, $2)
      ORDER BY distance_m ASC
      LIMIT 20`,
    [playerId, radius],
  )

  return { radius, items: rows }
}
