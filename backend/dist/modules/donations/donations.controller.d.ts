import { Response, NextFunction } from 'express';
import { AuthRequest } from '../../middleware/auth.js';
export declare class DonationsController {
    create(req: AuthRequest, res: Response, next: NextFunction): Promise<void>;
    createStripeSession(req: AuthRequest, res: Response, next: NextFunction): Promise<void>;
    handleWebhook(req: AuthRequest, res: Response, next: NextFunction): Promise<void>;
    approve(req: AuthRequest, res: Response, next: NextFunction): Promise<void>;
    reject(req: AuthRequest, res: Response, next: NextFunction): Promise<void>;
    getMyDonations(req: AuthRequest, res: Response, next: NextFunction): Promise<void>;
    getByCampaign(req: AuthRequest, res: Response, next: NextFunction): Promise<void>;
    getNgoDonations(req: AuthRequest, res: Response, next: NextFunction): Promise<void>;
}
export declare const donationsController: DonationsController;
//# sourceMappingURL=donations.controller.d.ts.map