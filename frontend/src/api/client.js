const BASE_URL = import.meta.env.VITE_API_URL ?? '/api'

// TODO: ganti dengan ID pemain dari sesi login setelah sistem auth dibuat.
const PLAYER_ID = 1

async function request(path, options = {}) {
  const res = await fetch(`${BASE_URL}${path}`, {
    headers: { 'Content-Type': 'application/json', ...(options.headers ?? {}) },
    ...options,
  })
  if (!res.ok) {
    let message = `Request gagal (${res.status})`
    try {
      const body = await res.json()
      if (body?.error) message = body.error
    } catch {
      /* body bukan JSON */
    }
    throw new Error(message)
  }
  if (res.status === 204) return null
  return res.json()
}

export const api = {
  PLAYER_ID,

  getPlayer: (id = PLAYER_ID) => request(`/players/${id}`),
  savePosition: (lat, lng, id = PLAYER_ID) =>
    request(`/players/${id}/position`, {
      method: 'PATCH',
      body: JSON.stringify({ lat, lng }),
    }),

  getEpisode: (episodeId) => request(`/episodes/${episodeId}`),

  nearbyEvidence: (radius = 120, id = PLAYER_ID) =>
    request(`/players/nearby?playerId=${id}&radius=${radius}`),

  collectEvidence: (evidenceId, radius = 120, id = PLAYER_ID) =>
    request(`/players/${id}/evidence/${evidenceId}/collect`, {
      method: 'POST',
      body: JSON.stringify({ radius }),
    }),

  submitDeduction: (episodeId, fromEvidenceId, toEvidenceId, id = PLAYER_ID) =>
    request('/deductions', {
      method: 'POST',
      body: JSON.stringify({ playerId: id, episodeId, fromEvidenceId, toEvidenceId }),
    }),
}
