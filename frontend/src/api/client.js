const BASE_URL = import.meta.env.VITE_API_URL ?? '/api'

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
  getPlayer: (id) => request(`/players/${id}`),
  savePosition: (id, lat, lng) =>
    request(`/players/${id}/position`, {
      method: 'PATCH',
      body: JSON.stringify({ lat, lng }),
    }),

  getEpisode: (id) => request(`/episodes/${id}`),
  collectEvidence: (episodeId, evidenceId) =>
    request(`/players/me/evidence/${evidenceId}/collect`, {
      method: 'POST',
      body: JSON.stringify({ episodeId }),
    }),
  nearbyEvidence: (playerId, radius = 120) =>
    request(`/map/players/${playerId}/nearby?radius=${radius}`),
  submitDeduction: (episodeId, fromId, toId) =>
    request(`/deductions`, {
      method: 'POST',
      body: JSON.stringify({ episodeId, fromEvidenceId: fromId, toEvidenceId: toId }),
    }),
}
