import CircuitBreaker from 'opossum';
/**
 * Creates a circuit breaker for a given function.
 * @param action The function to wrap.
 * @param options Overrides for default options.
 * @returns A CircuitBreaker instance.
 */
export declare function createBreaker<T extends (...args: any[]) => any>(action: T, options?: CircuitBreaker.Options): CircuitBreaker;
/**
 * Example usage for future integrations (Stripe, Cloudinary):
 *
 * const stripeBreaker = createBreaker(stripe.confirmPayment);
 * stripeBreaker.fallback(() => ({ status: 'PENDING_RETRY', message: 'Service temporarily unavailable' }));
 */
//# sourceMappingURL=circuitBreaker.d.ts.map