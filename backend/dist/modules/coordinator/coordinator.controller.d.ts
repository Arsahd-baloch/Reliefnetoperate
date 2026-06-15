import { Response, NextFunction } from 'express';
import { AuthRequest } from '../../middleware/auth.js';
export declare class CoordinatorController {
    listVolunteers(req: AuthRequest, res: Response, next: NextFunction): Promise<void>;
}
export declare const coordinatorController: CoordinatorController;
//# sourceMappingURL=coordinator.controller.d.ts.map