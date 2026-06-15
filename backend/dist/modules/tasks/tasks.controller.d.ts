import { Response, NextFunction } from 'express';
import { AuthRequest } from '../../middleware/auth.js';
export declare class TasksController {
    create(req: AuthRequest, res: Response, next: NextFunction): Promise<void>;
    getAvailable(req: AuthRequest, res: Response, next: NextFunction): Promise<void>;
    getById(req: AuthRequest, res: Response, next: NextFunction): Promise<void>;
    getMyTasks(req: AuthRequest, res: Response, next: NextFunction): Promise<void>;
    getCoordinatorTasks(req: AuthRequest, res: Response, next: NextFunction): Promise<void>;
    update(req: AuthRequest, res: Response, next: NextFunction): Promise<void>;
    assign(req: AuthRequest, res: Response, next: NextFunction): Promise<void>;
    claim(req: AuthRequest, res: Response, next: NextFunction): Promise<void>;
    start(req: AuthRequest, res: Response, next: NextFunction): Promise<void>;
    unclaim(req: AuthRequest, res: Response, next: NextFunction): Promise<void>;
    getEvents(req: AuthRequest, res: Response, next: NextFunction): Promise<void>;
}
export declare const tasksController: TasksController;
//# sourceMappingURL=tasks.controller.d.ts.map