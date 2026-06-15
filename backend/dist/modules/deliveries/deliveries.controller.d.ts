import { Response, NextFunction } from 'express';
import { AuthRequest } from '../../middleware/auth.js';
export declare class DeliveriesController {
    submit(req: AuthRequest, res: Response, next: NextFunction): Promise<void>;
    verify(req: AuthRequest, res: Response, next: NextFunction): Promise<void>;
    getByTask(req: AuthRequest, res: Response, next: NextFunction): Promise<void>;
    beneficiaryConfirm(req: AuthRequest, res: Response, next: NextFunction): Promise<void>;
}
export declare const deliveriesController: DeliveriesController;
//# sourceMappingURL=deliveries.controller.d.ts.map