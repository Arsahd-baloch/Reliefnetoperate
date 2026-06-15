import { Response, NextFunction } from 'express';
import { AuthRequest } from '../../middleware/auth.js';
export declare class AdminReportController {
    private convertToCSV;
    exportDonations(_req: AuthRequest, res: Response, next: NextFunction): Promise<void>;
    exportWithdrawals(_req: AuthRequest, res: Response, next: NextFunction): Promise<void>;
    exportCampaigns(_req: AuthRequest, res: Response, next: NextFunction): Promise<void>;
}
export declare const adminReportController: AdminReportController;
//# sourceMappingURL=admin.report.controller.d.ts.map