import { Response, NextFunction } from 'express';
import { AuthRequest } from '../../middleware/auth.js';
export declare class AdminSystemController {
    getSystemState(_req: AuthRequest, res: Response, next: NextFunction): Promise<void>;
    setSystemState(req: AuthRequest, res: Response, next: NextFunction): Promise<void>;
}
export declare const adminSystemController: AdminSystemController;
//# sourceMappingURL=admin.system.controller.d.ts.map