import { Response, NextFunction } from 'express';
import { AuthRequest } from '../../middleware/auth.js';
export declare class InKindController {
    createDonation(req: AuthRequest, res: Response, next: NextFunction): Promise<void>;
    getBoard(_req: AuthRequest, res: Response, next: NextFunction): Promise<void>;
    getMyDonations(req: AuthRequest, res: Response, next: NextFunction): Promise<void>;
    getDonationById(req: AuthRequest, res: Response, next: NextFunction): Promise<void>;
    createRequest(req: AuthRequest, res: Response, next: NextFunction): Promise<void>;
    getRequests(req: AuthRequest, res: Response, next: NextFunction): Promise<void>;
    acceptRequest(req: AuthRequest, res: Response, next: NextFunction): Promise<void>;
    rejectRequest(req: AuthRequest, res: Response, next: NextFunction): Promise<void>;
    getMyRequests(req: AuthRequest, res: Response, next: NextFunction): Promise<void>;
    completeDonation(req: AuthRequest, res: Response, next: NextFunction): Promise<void>;
    getAdminRecords(_req: AuthRequest, res: Response, next: NextFunction): Promise<void>;
}
export declare const inKindController: InKindController;
//# sourceMappingURL=inkind.controller.d.ts.map