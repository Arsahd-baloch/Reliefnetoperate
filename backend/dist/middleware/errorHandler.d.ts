import { Request, Response, NextFunction } from 'express';
export interface AppError extends Error {
    statusCode?: number;
    status?: number;
    isOperational?: boolean;
    code?: string;
    constraint?: string;
}
/**
 * Global error handler. Sanitizes errors in production.
 */
export declare function errorHandler(err: AppError, req: Request, res: Response, _next: NextFunction): void;
/**
 * Create an operational error with a status code.
 */
export declare function createError(message: string, statusCode: number): AppError;
//# sourceMappingURL=errorHandler.d.ts.map