import { chatService } from './chat.service.js';
import { mapChatRoom, mapChatRoomList, mapChatMessage, mapChatMessageList } from '../../common/mappers/chat.mapper.js';
export class ChatController {
    async createRoom(req, res, next) {
        try {
            if (!req.user) {
                res.status(401).json({ error: 'Auth required' });
                return;
            }
            const taskId = req.body.task_id ?? req.body.taskId;
            if (!taskId || typeof taskId !== 'number') {
                res.status(400).json({ message: 'taskId is required and must be a number' });
                return;
            }
            const room = await chatService.createRoom(taskId, req.user.id);
            res.status(201).json(mapChatRoom(room));
        }
        catch (err) {
            next(err);
        }
    }
    async sendMessage(req, res, next) {
        try {
            if (!req.user) {
                res.status(401).json({ error: 'Auth required' });
                return;
            }
            const roomId = parseInt(req.params.roomId, 10);
            const { text } = req.body;
            const message = await chatService.sendMessage(roomId, req.user.id, text);
            res.status(201).json(mapChatMessage(message));
        }
        catch (err) {
            next(err);
        }
    }
    async getMessages(req, res, next) {
        try {
            if (!req.user) {
                res.status(401).json({ error: 'Auth required' });
                return;
            }
            const roomId = parseInt(req.params.roomId, 10);
            const limit = parseInt(req.query.limit, 10) || 50;
            const offset = parseInt(req.query.offset, 10) || 0;
            const messages = await chatService.getMessages(roomId, req.user.id, limit, offset);
            res.json(mapChatMessageList(messages));
        }
        catch (err) {
            next(err);
        }
    }
    async getMyRooms(req, res, next) {
        try {
            if (!req.user) {
                res.status(401).json({ error: 'Auth required' });
                return;
            }
            const rooms = await chatService.getUserRooms(req.user.id);
            res.json(mapChatRoomList(rooms));
        }
        catch (err) {
            next(err);
        }
    }
    async getRoomByTaskId(req, res, next) {
        try {
            if (!req.user) {
                res.status(401).json({ error: 'Auth required' });
                return;
            }
            const taskId = parseInt(req.params.taskId, 10);
            if (isNaN(taskId)) {
                res.status(400).json({ error: 'Invalid task ID' });
                return;
            }
            const room = await chatService.getRoomByTaskId(taskId, req.user.id);
            res.json(mapChatRoom(room));
        }
        catch (err) {
            next(err);
        }
    }
    async getInKindRoom(req, res, next) {
        try {
            if (!req.user) {
                res.status(401).json({ error: 'Auth required' });
                return;
            }
            const requestId = parseInt(req.params.requestId, 10);
            if (isNaN(requestId)) {
                res.status(400).json({ error: 'Invalid request ID' });
                return;
            }
            const room = await chatService.ensureInKindRoom(requestId, req.user.id);
            res.json(mapChatRoom(room));
        }
        catch (err) {
            next(err);
        }
    }
}
export const chatController = new ChatController();
//# sourceMappingURL=chat.controller.js.map