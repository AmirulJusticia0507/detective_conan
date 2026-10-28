/**
 * Renderer peta top-down 2D. Logika murni: tidak menyentuh Pinia.
 * Input: canvas, state kamera + pemain. Output: gambar.
 */

const COLORS = {
  grass: '#1f3d2b',
  road: '#2b3442',
  building: '#334155',
  buildingEdge: '#475569',
  player: '#facc15',
  evidence: '#dc2626',
}

const EVIDENCE_MARKERS = [
  { id: 1126001, x: 720, y: 520 },
  { id: 1126002, x: 420, y: 690 },
  { id: 1126003, x: 980, y: 300 },
]

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
    const { width, height } = canvas.getBoundingClientRect()
    const { camera, tileSize = 32, worldWidth, worldHeight } = state

    ctx.fillStyle = COLORS.grass
    ctx.fillRect(0, 0, width, height)

    ctx.save()
    ctx.translate(-camera.x, -camera.y)

    drawGridLines(ctx, worldWidth, worldHeight, tileSize)
    drawRoads(ctx, worldWidth, worldHeight)

    for (const marker of EVIDENCE_MARKERS) {
      if (state.collectedEvidenceIds?.includes(marker.id)) continue
      drawEvidenceMarker(ctx, marker)
    }

    drawPlayer(ctx, state.player, state.facing ?? 'down')

    ctx.restore()
  }

  function destroy() {
    observer.disconnect()
  }

  return { draw, destroy, resize }
}

function drawGridLines(ctx, worldWidth, worldHeight, tileSize) {
  ctx.strokeStyle = 'rgba(255,255,255,0.04)'
  ctx.lineWidth = 1
  ctx.beginPath()
  for (let x = 0; x <= worldWidth; x += tileSize) {
    ctx.moveTo(x + 0.5, 0)
    ctx.lineTo(x + 0.5, worldHeight)
  }
  for (let y = 0; y <= worldHeight; y += tileSize) {
    ctx.moveTo(0, y + 0.5)
    ctx.lineTo(worldWidth, y + 0.5)
  }
  ctx.stroke()
}

function drawRoads(ctx, worldWidth, worldHeight) {
  ctx.fillStyle = COLORS.road
  ctx.fillRect(0, worldHeight * 0.42, worldWidth, 96)
  ctx.fillRect(worldWidth * 0.45, 0, 96, worldHeight)

  ctx.fillStyle = COLORS.building
  ctx.strokeStyle = COLORS.buildingEdge
  const blocks = [
    [80, 80, 320, 200],
    [720, 80, 280, 180],
    [80, 620, 360, 220],
    [700, 660, 300, 170],
  ]
  for (const [x, y, w, h] of blocks) {
    ctx.fillRect(x, y, w, h)
    ctx.strokeRect(x + 0.5, y + 0.5, w, h)
  }
}

function drawEvidenceMarker(ctx, marker) {
  const pulse = 0.6 + 0.4 * Math.sin(performance.now() / 400)
  ctx.globalAlpha = pulse
  ctx.fillStyle = COLORS.evidence
  ctx.beginPath()
  ctx.arc(marker.x, marker.y, 9, 0, Math.PI * 2)
  ctx.fill()
  ctx.globalAlpha = 1
}

function drawPlayer(ctx, player, facing) {
  if (!player) return
  ctx.fillStyle = COLORS.player
  ctx.beginPath()
  ctx.arc(player.x, player.y, 12, 0, Math.PI * 2)
  ctx.fill()

  ctx.fillStyle = '#0f172a'
  const eyeOffset = facing === 'left' ? -4 : facing === 'right' ? 4 : 0
  ctx.beginPath()
  ctx.arc(player.x + eyeOffset - 3, player.y - 3, 2, 0, Math.PI * 2)
  ctx.arc(player.x + eyeOffset + 3, player.y - 3, 2, 0, Math.PI * 2)
  ctx.fill()
}
