import { Response, NextFunction } from 'express';
import { AuthRequest } from '../../middleware/auth.js';
export declare class CoordinatorIntelligenceController {
    getIntelligence(req: AuthRequest, res: Response, next: NextFunction): Promise<void>;
    getSignals(req: AuthRequest, res: Response, next: NextFunction): Promise<void>;
    flagFraud(req: AuthRequest, res: Response, next: NextFunction): Promise<void>;
    escalate(req: AuthRequest, res: Response, next: NextFunction): Promise<void>;
    emergencyEscalate(req: AuthRequest, res: Response, next: NextFunction): Promise<void>;
    getReports(req: AuthRequest, res: Response, next: NextFunction): Promise<void>;
    getEscalations(req: AuthRequest, res: Response, next: NextFunction): Promise<void>;
    broadcast(req: AuthRequest, res: Response, next: NextFunction): Promise<void>;
}
export declare const coordinatorIntelligenceController: CoordinatorIntelligenceController;
//# sourceMappingURL=coordinator.intelligence.controller.d.ts.map