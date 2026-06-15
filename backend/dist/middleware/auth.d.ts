import { Request, Response, NextFunction } from 'express';
export interface AuthUser {
    id: number;
    email: string | null;
    phone: string | null;
    name: string;
    role: string;
    role_id: number;
    status: string;
}
export interface AuthRequest extends Request {
    user?: AuthUser;
}
/**
 * JWT authentication middleware.
 * NEVER trusts client-supplied role — always reads from DB.
 * Sets app.current_user_id for RLS policies after auth.
 */
export declare function authenticate(req: AuthRequest, res: Response, next: NextFunction): Promise<void>;
//# sourceMappingURL=auth.d.ts.map