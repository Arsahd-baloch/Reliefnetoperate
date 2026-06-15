import { Request, Response, NextFunction } from 'express';
import { ZodSchema } from 'zod';
/**
 * Zod-based request validation middleware factory.
 * Validates body, query, and/or params.
 */
export declare function validate(schema: {
    body?: ZodSchema;
    query?: ZodSchema;
    params?: ZodSchema;
}): (req: Request, res: Response, next: NextFunction) => void;
//# sourceMappingURL=validate.d.ts.map