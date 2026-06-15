import { env } from './src/config/env.js';
console.log('POSTGRES_USER:', env.POSTGRES_USER);
console.log('POSTGRES_DB:', env.POSTGRES_DB);
console.log('POSTGRES_HOST:', env.POSTGRES_HOST);
