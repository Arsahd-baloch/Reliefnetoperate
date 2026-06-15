import { Response, NextFunction } from 'express';
import { AuthRequest } from '../../middleware/auth.js';
export declare class AdminController {
    private getPaginationOptions;
    getDonationStats(_req: AuthRequest, res: Response, next: NextFunction): Promise<void>;
    getWithdrawalStats(_req: AuthRequest, res: Response, next: NextFunction): Promise<void>;
    getCampaignStats(_req: AuthRequest, res: Response, next: NextFunction): Promise<void>;
    getUserStats(_req: AuthRequest, res: Response, next: NextFunction): Promise<void>;
    listDonations(req: AuthRequest, res: Response, next: NextFunction): Promise<void>;
    listWithdrawals(req: AuthRequest, res: Response, next: NextFunction): Promise<void>;
    listCampaigns(req: AuthRequest, res: Response, next: NextFunction): Promise<void>;
    listUsers(req: AuthRequest, res: Response, next: NextFunction): Promise<void>;
    getAuditLogs(req: AuthRequest, res: Response, next: NextFunction): Promise<void>;
    getNgoDetail(req: AuthRequest, res: Response, next: NextFunction): Promise<void>;
    getDonationTrace(req: AuthRequest, res: Response, next: NextFunction): Promise<void>;
    private processBulkAction;
    bulkVerifyNgo(req: AuthRequest, res: Response, next: NextFunction): Promise<void>;
    bulkDonationAction(req: AuthRequest, res: Response, next: NextFunction): Promise<void>;
    bulkUserStatus(req: AuthRequest, res: Response, next: NextFunction): Promise<void>;
    bulkCampaignStatus(req: AuthRequest, res: Response, next: NextFunction): Promise<void>;
    listPendingNgos(_req: AuthRequest, res: Response, next: NextFunction): Promise<void>;
    verifyNgo(req: AuthRequest, res: Response, next: NextFunction): Promise<void>;
    rejectNgo(req: AuthRequest, res: Response, next: NextFunction): Promise<void>;
    flagDonation(req: AuthRequest, res: Response, next: NextFunction): Promise<void>;
    flagWithdrawal(req: AuthRequest, res: Response, next: NextFunction): Promise<void>;
    getLedger(_req: AuthRequest, res: Response, next: NextFunction): Promise<void>;
    getMapData(_req: AuthRequest, res: Response, next: NextFunction): Promise<void>;
}
export declare const adminController: AdminController;
//# sourceMappingURL=admin.controller.d.ts.map