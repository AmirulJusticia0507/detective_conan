import { Router } from 'express'
import { getPlayerService, updatePositionService, nearbyService } from '../services/playerService.js'
import { collectEvidenceService } from '../services/evidenceService.js'
import { parsePositiveInt } from '../utils/validate.js'

const router = Router()

// GET /api/players/nearby?playerId=1&radius=120
router.get('/nearby', async (req, res, next) => {
  try {
    const playerId = parsePositiveInt(req.query.playerId, 'playerId')
    res.json(await nearbyService(playerId, req.query.radius))
  } catch (err) {
    next(err)
  }
})

// GET /api/players/:id
router.get('/:id', async (req, res, next) => {
  try {
    res.json(await getPlayerService(parsePositiveInt(req.params.id, 'id')))
  } catch (err) {
    next(err)
  }
})

// PATCH /api/players/:id/position  { lat, lng }
router.patch('/:id/position', async (req, res, next) => {
  try {
    const id = parsePositiveInt(req.params.id, 'id')
    const { lat, lng } = req.body ?? {}
    res.json(await updatePositionService(id, lat, lng))
  } catch (err) {
    next(err)
  }
})

// POST /api/players/:id/evidence/:evidenceId/collect  { radius? }
router.post('/:id/evidence/:evidenceId/collect', async (req, res, next) => {
  try {
    const playerId = parsePositiveInt(req.params.id, 'id')
    const evidenceId = parsePositiveInt(req.params.evidenceId, 'evidenceId')
    res.json(await collectEvidenceService(playerId, evidenceId, req.body?.radius))
  } catch (err) {
    next(err)
  }
})

export default router
