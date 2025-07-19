import { drizzle } from 'drizzle-orm/node-postgres';
import { Pool } from 'pg';
import * as schema from './schema';

declare global {
  // eslint-disable-next-line no-var
  var __pool: Pool | undefined;
}

if (!global.__pool) {
  global.__pool = new Pool({
    connectionString: process.env.DATABASE_URL!,
    max: 20,
    idleTimeoutMillis: 30000,
    connectionTimeoutMillis: 2000,
    maxUses: 7500,
  });

  const cleanup = () => {
    if (global.__pool) {
      global.__pool.end();
      global.__pool = undefined;
    }
  };
  process.on('SIGINT', cleanup);
  process.on('SIGTERM', cleanup);
}

const pool = global.__pool!;
// Create the drizzle database instance with schema
export const db = drizzle(pool, { schema });

// Export the pool for raw queries if needed
export { pool };
