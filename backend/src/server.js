import { createApp } from './app.js'
import { closePool } from './db.js'

const port = Number(process.env.PORT ?? 3000)

const app = createApp()
const server = app.listen(port, () => {
  console.log(`[api] Beika District Chronicles berjalan di http://localhost:${port}`)
})

// Tutup koneksi dengan rapi saat dihentikan (Ctrl+C / SIGTERM).
for (const signal of ['SIGINT', 'SIGTERM']) {
  process.on(signal, async () => {
    console.log(`\n[api] menerima ${signal}, mematikan server...`)
    server.close(async () => {
      await closePool()
      process.exit(0)
    })
  })
}
