import { Router } from 'express'
import { nearbyService } from '../services/playerService.js'
import { parsePositiveInt } from '../utils/validate.js'

const router = Router()

// GET /api/map/players/:playerId/nearby?radius=120
router.get('/players/:playerId/nearby', async (req, res, next) => {
  try {
    const playerId = parsePositiveInt(req.params.playerId, 'playerId')
    res.json(await nearbyService(playerId, req.query.radius))
  } catch (err) {
    next(err)
  }
})

export default router
