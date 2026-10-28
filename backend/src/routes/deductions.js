import { Router } from 'express'
import { submitDeductionService } from '../services/episodeService.js'
import { parsePositiveInt } from '../utils/validate.js'

const router = Router()

// POST /api/deductions  { playerId, episodeId, fromEvidenceId, toEvidenceId }
router.post('/', async (req, res, next) => {
  try {
    const { playerId, episodeId, fromEvidenceId, toEvidenceId } = req.body ?? {}
    const result = await submitDeductionService(
      parsePositiveInt(playerId, 'playerId'),
      parsePositiveInt(episodeId, 'episodeId'),
      parsePositiveInt(fromEvidenceId, 'fromEvidenceId'),
      parsePositiveInt(toEvidenceId, 'toEvidenceId'),
    )
    res.json(result)
  } catch (err) {
    next(err)
  }
})

export default router
