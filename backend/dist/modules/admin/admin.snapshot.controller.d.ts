import { Response, NextFunction } from 'express';
import { AuthRequest } from '../../middleware/auth.js';
export declare class AdminSnapshotController {
    getSystemSnapshot(_req: AuthRequest, res: Response, next: NextFunction): Promise<void>;
    getOperationalOverview(_req: AuthRequest, res: Response, next: NextFunction): Promise<void>;
}
export declare const adminSnapshotController: AdminSnapshotController;
//# sourceMappingURL=admin.snapshot.controller.d.ts.map