import { Response, NextFunction } from 'express';
import { AuthRequest } from '../../middleware/auth.js';
export declare class UsersController {
    suspend(req: AuthRequest, res: Response, next: NextFunction): Promise<void>;
    reactivate(req: AuthRequest, res: Response, next: NextFunction): Promise<void>;
}
export declare const usersController: UsersController;
//# sourceMappingURL=users.controller.d.ts.map