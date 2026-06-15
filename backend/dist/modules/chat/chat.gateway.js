import jwt from 'jsonwebtoken';
import { pool } from '../../config/database.js';
import { env } from '../../config/env.js';
import { chatService } from './chat.service.js';
import { logger } from '../../common/logger.js';
let globalIo = null;
/**
 * Socket.IO gateway for real-time chat messaging and notifications.
 */
export function initializeChatGateway(io) {
    globalIo = io;
    // Authentication middleware for Socket.IO
    io.use((socket, next) => {
        const token = socket.handshake.auth.token || socket.handshake.query.token;
        if (!token || typeof token !== 'string') {
            return next(new Error('Authentication required'));
        }
        try {
            const decoded = jwt.verify(token, env.JWT_SECRET);
            socket.userId = decoded.id;
            // Fetch the user's display name once at connection time for typing events.
            pool.query('SELECT name FROM users WHERE id = $1', [decoded.id])
                .then(r => { socket.userName = r.rows[0]?.name ?? 'User'; })
                .catch(() => { socket.userName = 'User'; });
            next();
        }
        catch {
            next(new Error('Invalid token'));
        }
    });
    io.on('connection', (socket) => {
        if (!socket.userId)
            return;
        logger.info(`Socket connected: user ${socket.userId}`);
        // Join user-specific room for private notifications
        socket.join(`user:${socket.userId}`);
        // Join a chat room
        socket.on('join_room', async (roomId) => {
            if (!socket.userId)
                return;
            try {
                // SECURITY: Verify access — task rooms OR inkind donor-beneficiary rooms
                const accessCheck = await pool.query(`SELECT 1 FROM chat_rooms cr
           LEFT JOIN tasks t ON t.id = cr.task_id
           LEFT JOIN inkind_requests ir ON ir.id = cr.inkind_request_id
           LEFT JOIN inkind_donations ikd ON ikd.id = ir.donation_id
           WHERE cr.id = $1 AND (
             t.created_by = $2 OR t.claimed_by = $2 OR t.coordinator_id = $2
             OR cr.created_by = $2
             OR ir.beneficiary_id = $2
             OR ikd.donor_id = $2
           )`, [roomId, socket.userId]);
                if (accessCheck.rows.length === 0) {
                    socket.emit('error', 'Unauthorized room access');
                    return;
                }
                socket.join(`room:${roomId}`);
                logger.info(`User ${socket.userId} joined room ${roomId}`);
            }
            catch {
                socket.emit('error', { message: 'Internal error' });
            }
        });
        // Leave a chat room
        socket.on('leave_room', (roomId) => {
            socket.leave(`room:${roomId}`);
        });
        // Send a message
        socket.on('send_message', async (data) => {
            if (!socket.userId)
                return;
            try {
                const message = await chatService.sendMessage(data.roomId, socket.userId, data.text);
                // Broadcast to all users in the room
                io.to(`room:${data.roomId}`).emit('new_message', message);
            }
            catch {
                socket.emit('error', { message: 'Failed to send message' });
            }
        });
        // Typing indicator
        socket.on('typing', (data) => {
            socket.to(`room:${data.roomId}`).emit('user_typing', {
                userId: socket.userId,
                userName: socket.userName ?? 'User',
                roomId: data.roomId,
                isTyping: data.isTyping,
            });
        });
        socket.on('disconnect', () => {
            logger.info(`Socket disconnected: user ${socket.userId}`);
        });
    });
}
/**
 * Emit a notification event to a specific user.
 */
export function emitToUser(userId, event, payload) {
    if (globalIo) {
        globalIo.to(`user:${userId}`).emit(event, payload);
    }
}
//# sourceMappingURL=chat.gateway.js.map