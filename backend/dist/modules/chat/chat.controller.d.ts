import { Response, NextFunction } from 'express';
import { AuthRequest } from '../../middleware/auth.js';
export declare class ChatController {
    createRoom(req: AuthRequest, res: Response, next: NextFunction): Promise<void>;
    sendMessage(req: AuthRequest, res: Response, next: NextFunction): Promise<void>;
    getMessages(req: AuthRequest, res: Response, next: NextFunction): Promise<void>;
    getMyRooms(req: AuthRequest, res: Response, next: NextFunction): Promise<void>;
    getRoomByTaskId(req: AuthRequest, res: Response, next: NextFunction): Promise<void>;
    getInKindRoom(req: AuthRequest, res: Response, next: NextFunction): Promise<void>;
}
export declare const chatController: ChatController;
//# sourceMappingURL=chat.controller.d.ts.map