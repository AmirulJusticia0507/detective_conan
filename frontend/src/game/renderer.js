/**
 * Renderer peta top-down 2D. Logika murni: tidak menyentuh Pinia.
 * Hanya menggambar apa pun yang ada di state + data dunia.
 */

import { WORLD, ROADS, BUILDINGS, NPCS } from './worldData'

const COLORS = {
  ground: '#1f3d2b',
  road: '#2b3442',
  building: '#334155',
  buildingEdge: '#64748b',
  player: '#facc15',
  playerInk: '#0f172a',
  evidence: '#dc2626',
  evidenceGlow: 'rgba(220, 38, 38, 0.35)',
  npc: '#38bdf8',
  npcNear: '#facc15',
  buildingLabel: 'rgba(226, 232, 240, 0.75)',
}

export function createRenderer(canvas) {
  const ctx = canvas.getContext('2d')
  let dpr = 1

  function resize() {
    const rect = canvas.getBoundingClientRect()
    dpr = window.devicePixelRatio || 1
    canvas.width = Math.max(1, Math.floor(rect.width * dpr))
    canvas.height = Math.max(1, Math.floor(rect.height * dpr))
    ctx.setTransform(dpr, 0, 0, dpr, 0, 0)
  }

  const observer = new ResizeObserver(resize)
  observer.observe(canvas)
  resize()

  function draw(state) {
    // ctx sudah di-scale oleh resize(), jadi hitung luas gambar dalam unit CSS
    // agar fillRect tidak terpotong di layar HiDPI.
    const width = canvas.width / dpr
    const height = canvas.height / dpr
    const {
      camera,
      player,
      facing = 'down',
      collectedEvidenceIds = [],
      evidenceMarkers = [],
      nearbyId = null,
    } = state

    ctx.fillStyle = COLORS.ground
    ctx.fillRect(0, 0, width, height)

    ctx.save()
    ctx.translate(-Math.round(camera.x), -Math.round(camera.y))

    drawRoads(ctx)
    drawBuildings(ctx)
    drawEvidence(ctx, evidenceMarkers, collectedEvidenceIds, state.time ?? 0)
    drawNpcs(ctx, nearbyId)
    drawPlayer(ctx, player, facing)

    ctx.restore()
  }

  function destroy() {
    observer.disconnect()
  }

  return { draw, destroy, resize }
}

function drawRoads(ctx) {
  ctx.fillStyle = COLORS.road
  for (const road of ROADS) {
    ctx.fillRect(road.x, road.y, road.w, road.h)
  }

  // Marka jalan putus-putus pada jalan utama horizontal
  ctx.strokeStyle = 'rgba(250, 204, 21, 0.25)'
  ctx.lineWidth = 3
  ctx.setLineDash([24, 20])
  ctx.beginPath()
  ctx.moveTo(0, 688)
  ctx.lineTo(WORLD.width, 688)
  ctx.stroke()
  ctx.setLineDash([])
}

function drawBuildings(ctx) {
  for (const b of BUILDINGS) {
    ctx.fillStyle = COLORS.building
    ctx.fillRect(b.x, b.y, b.w, b.h)

    ctx.strokeStyle = COLORS.buildingEdge
    ctx.lineWidth = 2
    ctx.strokeRect(b.x + 1, b.y + 1, b.w - 2, b.h - 2)

    // Atap sederhana agar terlihat isometrik ringan
    ctx.fillStyle = 'rgba(15, 23, 42, 0.35)'
    ctx.fillRect(b.x, b.y + b.h, b.w, 14)

    ctx.fillStyle = COLORS.buildingLabel
    ctx.font = 'bold 13px ui-sans-serif, system-ui, sans-serif'
    ctx.textAlign = 'center'
    ctx.fillText(b.name, b.x + b.w / 2, b.y + b.h / 2 + 4)
    ctx.textAlign = 'left'
  }
}

function drawEvidence(ctx, markers, collectedIds, time) {
  const pulse = 0.55 + 0.45 * Math.sin(time / 400)
  for (const marker of markers) {
    if (collectedIds.includes(marker.id)) continue

    ctx.fillStyle = COLORS.evidenceGlow
    ctx.beginPath()
    ctx.arc(marker.x, marker.y, 20 * pulse, 0, Math.PI * 2)
    ctx.fill()

    ctx.fillStyle = COLORS.evidence
    ctx.beginPath()
    ctx.arc(marker.x, marker.y, 8, 0, Math.PI * 2)
    ctx.fill()

    ctx.strokeStyle = '#fecaca'
    ctx.lineWidth = 1.5
    ctx.stroke()

    // Ikon kaca pembesar kecil
    ctx.strokeStyle = '#fecaca'
    ctx.beginPath()
    ctx.arc(marker.x, marker.y, 4, 0, Math.PI * 2)
    ctx.stroke()
  }
}

function drawNpcs(ctx, nearbyId) {
  for (const npc of NPCS) {
    ctx.fillStyle = npc.id === nearbyId ? COLORS.npcNear : COLORS.npc
    ctx.beginPath()
    ctx.arc(npc.x, npc.y, 10, 0, Math.PI * 2)
    ctx.fill()

    ctx.fillStyle = 'rgba(226, 232, 240, 0.9)'
    ctx.font = '11px ui-sans-serif, system-ui, sans-serif'
    ctx.textAlign = 'center'
    ctx.fillText(npc.name, npc.x, npc.y - 18)
    ctx.textAlign = 'left'
  }
}

function drawPlayer(ctx, player, facing) {
  if (!player) return

  // Bayangan
  ctx.fillStyle = 'rgba(0, 0, 0, 0.35)'
  ctx.beginPath()
  ctx.ellipse(player.x, player.y + 10, 11, 5, 0, 0, Math.PI * 2)
  ctx.fill()

  ctx.fillStyle = COLORS.player
  ctx.beginPath()
  ctx.arc(player.x, player.y, 12, 0, Math.PI * 2)
  ctx.fill()

  ctx.fillStyle = COLORS.playerInk
  const eyeOffset = facing === 'left' ? -4 : facing === 'right' ? 4 : 0
  const eyeY = facing === 'up' ? player.y - 6 : player.y - 3

  ctx.beginPath()
  if (facing === 'up') {
    // Punggung kepala: tanpa mata
  } else {
    ctx.arc(player.x + eyeOffset - 3, eyeY, 2, 0, Math.PI * 2)
    ctx.arc(player.x + eyeOffset + 3, eyeY, 2, 0, Math.PI * 2)
  }
  ctx.fill()
}
