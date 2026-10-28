import express from 'express'
import cors from 'cors'
import playerRoutes from './routes/players.js'
import episodeRoutes from './routes/episodes.js'
import mapRoutes from './routes/map.js'
import deductionRoutes from './routes/deductions.js'

export function createApp() {
  const app = express()

  app.use(cors({ origin: process.env.CLIENT_ORIGIN ?? 'http://localhost:5173' }))
  app.use(express.json({ limit: '128kb' }))

  app.get('/api/health', (_req, res) => res.json({ status: 'ok' }))

  app.use('/api/players', playerRoutes)
  app.use('/api/episodes', episodeRoutes)
  app.use('/api/map', mapRoutes)
  app.use('/api/deductions', deductionRoutes)

  app.use((_req, res) => res.status(404).json({ error: 'Endpoint tidak ditemukan' }))

  // Error handler terpusat: jangan bocorkan detail database ke klien.
  app.use((err, _req, res, _next) => {
    const status = err.status ?? 500
    if (status >= 500) console.error('[api]', err)
    res.status(status).json({ error: err.expose ? err.message : 'Terjadi kesalahan pada server' })
  })

  return app
}
