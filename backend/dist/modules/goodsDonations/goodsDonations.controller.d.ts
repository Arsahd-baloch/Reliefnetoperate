import { Response, NextFunction } from 'express';
import { AuthRequest } from '../../middleware/auth.js';
export declare class GoodsDonationsController {
    submit(req: AuthRequest, res: Response, next: NextFunction): Promise<void>;
    getMine(req: AuthRequest, res: Response, next: NextFunction): Promise<void>;
    getById(req: AuthRequest, res: Response, next: NextFunction): Promise<void>;
    getAvailable(_req: AuthRequest, res: Response, next: NextFunction): Promise<void>;
    claim(req: AuthRequest, res: Response, next: NextFunction): Promise<void>;
    markDelivered(req: AuthRequest, res: Response, next: NextFunction): Promise<void>;
    getForReview(_req: AuthRequest, res: Response, next: NextFunction): Promise<void>;
    approve(req: AuthRequest, res: Response, next: NextFunction): Promise<void>;
    reject(req: AuthRequest, res: Response, next: NextFunction): Promise<void>;
    getNgoDonations(req: AuthRequest, res: Response, next: NextFunction): Promise<void>;
    getAll(_req: AuthRequest, res: Response, next: NextFunction): Promise<void>;
    adminOverride(req: AuthRequest, res: Response, next: NextFunction): Promise<void>;
}
export declare const goodsDonationsController: GoodsDonationsController;
//# sourceMappingURL=goodsDonations.controller.d.ts.map