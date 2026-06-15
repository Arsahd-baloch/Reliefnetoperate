#!/usr/bin/env node
/**
 * Migration runner — applies SQL files in backend/migrations/ in order.
 * Safe to re-run: tracks applied files in _migrations table.
 */
import pg from 'pg';
import { readdir, readFile } from 'node:fs/promises';
import path from 'node:path';
import { fileURLToPath } from 'node:url';

const __dirname = path.dirname(fileURLToPath(import.meta.url));
const MIGRATIONS_DIR = path.resolve(__dirname, '../migrations');

const pool = new pg.Pool({
  host: process.env.POSTGRES_HOST || process.env.PGHOST || 'localhost',
  port: Number(process.env.POSTGRES_PORT || process.env.PGPORT || 5432),
  database: process.env.POSTGRES_DB || process.env.PGDATABASE || 'disasteraid',
  user: process.env.POSTGRES_USER || process.env.PGUSER || 'disasteraid_user',
  password: process.env.POSTGRES_PASSWORD || process.env.PGPASSWORD,
  ssl: process.env.NODE_ENV === 'production' ? { rejectUnauthorized: false } : false,
});

async function run() {
  const client = await pool.connect();
  try {
    await client.query(`
      CREATE TABLE IF NOT EXISTS _migrations (
        id        SERIAL PRIMARY KEY,
        filename  TEXT UNIQUE NOT NULL,
        applied_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
      )
    `);

    const files = (await readdir(MIGRATIONS_DIR))
      .filter(f => f.endsWith('.sql'))
      .sort();

    for (const file of files) {
      const { rows } = await client.query(
        'SELECT 1 FROM _migrations WHERE filename = $1',
        [file]
      );
      if (rows.length > 0) {
        console.log(`  skip  ${file}`);
        continue;
      }

      const sql = await readFile(path.join(MIGRATIONS_DIR, file), 'utf8');
      console.log(`  apply ${file}`);
      await client.query('BEGIN');
      try {
        await client.query(sql);
        await client.query('INSERT INTO _migrations (filename) VALUES ($1)', [file]);
        await client.query('COMMIT');
      } catch (err) {
        await client.query('ROLLBACK');
        console.error(`  FAILED ${file}:`, err.message);
        process.exit(1);
      }
    }

    console.log('Migrations complete.');
  } finally {
    client.release();
    await pool.end();
  }
}

run().catch(err => {
  console.error('Migration error:', err);
  process.exit(1);
});
