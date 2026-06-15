import { Response, NextFunction } from 'express';
import { AuthRequest } from './auth.js';
/**
 * Role-based authorization middleware factory.
 * Usage: authorize('ADMIN', 'NGO')
 */
export declare function authorize(...allowedRoles: string[]): (req: AuthRequest, res: Response, next: NextFunction) => void;
//# sourceMappingURL=authorize.d.ts.map