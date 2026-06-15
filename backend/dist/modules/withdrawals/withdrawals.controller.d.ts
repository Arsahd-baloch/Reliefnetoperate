import { Response, NextFunction } from 'express';
import { AuthRequest } from '../../middleware/auth.js';
export declare class WithdrawalsController {
    create(req: AuthRequest, res: Response, next: NextFunction): Promise<void>;
    approve(req: AuthRequest, res: Response, next: NextFunction): Promise<void>;
    reject(req: AuthRequest, res: Response, next: NextFunction): Promise<void>;
    getMine(req: AuthRequest, res: Response, next: NextFunction): Promise<void>;
}
export declare const withdrawalsController: WithdrawalsController;
//# sourceMappingURL=withdrawals.controller.d.ts.map