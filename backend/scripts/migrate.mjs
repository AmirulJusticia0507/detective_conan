import 'dotenv/config'
import { readFile } from 'node:fs/promises'
import pg from 'pg'

if (!process.env.DATABASE_URL) throw new Error('DATABASE_URL belum diisi.')

const client = new pg.Client({ connectionString: process.env.DATABASE_URL })
const migrations = ['migrations/001_init.sql', 'migrations/002_episode_content.sql']

try {
  await client.connect()
  for (const file of migrations) {
    await client.query(await readFile(file, 'utf8'))
    console.log(`[migrate] selesai: ${file}`)
  }
} finally {
  await client.end()
}
