import Stripe from 'stripe';
import { env } from './env.js';

export const stripe = new Stripe(env.STRIPE_SECRET_KEY, {
  apiVersion: '2024-10-28.acacia' as any, // Use latest or pinning to a specific one
  typescript: true,
});
