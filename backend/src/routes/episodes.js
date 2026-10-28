import { Router } from 'express'
import { getEpisodeService } from '../services/episodeService.js'
import { parsePositiveInt } from '../utils/validate.js'

const router = Router()

// GET /api/episodes/:id
router.get('/:id', async (req, res, next) => {
  try {
    const id = parsePositiveInt(req.params.id, 'id')
    res.json(await getEpisodeService(id))
  } catch (err) {
    next(err)
  }
})

export default router
