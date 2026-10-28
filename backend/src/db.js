import 'dotenv/config'
import pg from 'pg'

if (!process.env.DATABASE_URL) {
  throw new Error('DATABASE_URL belum diisi. Salin .env.example menjadi .env.')
}

export const pool = new pg.Pool({
  connectionString: process.env.DATABASE_URL,
  max: 10,
  idleTimeoutMillis: 30_000,
})

pool.on('error', (err) => {
  console.error('[db] error tak terduga pada pool:', err.message)
})

/**
 * Query berparameter. Jangan pernah menyusun SQL dengan interpolasi string.
 */
export function query(text, params) {
  return pool.query(text, params)
}

export async function closePool() {
  await pool.end()
}
