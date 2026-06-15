import { Response, NextFunction } from 'express';
import { AuthRequest } from '../../middleware/auth.js';
export declare class NgoController {
    getDashboardStats(req: AuthRequest, res: Response, next: NextFunction): Promise<void>;
    getProfile(req: AuthRequest, res: Response, next: NextFunction): Promise<void>;
    updateProfile(req: AuthRequest, res: Response, next: NextFunction): Promise<void>;
    getCampaigns(req: AuthRequest, res: Response, next: NextFunction): Promise<void>;
    getPublicProfile(req: AuthRequest, res: Response, next: NextFunction): Promise<void>;
}
export declare const ngoController: NgoController;
//# sourceMappingURL=ngo.controller.d.ts.map