import { Response, NextFunction } from 'express';
import { AuthRequest } from '../../middleware/auth.js';
export declare class MediaController {
    upload(req: AuthRequest, res: Response, next: NextFunction): Promise<void>;
}
export declare const mediaController: MediaController;
//# sourceMappingURL=media.controller.d.ts.map