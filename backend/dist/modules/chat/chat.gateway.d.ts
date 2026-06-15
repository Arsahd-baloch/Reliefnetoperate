import { Server as SocketIOServer } from 'socket.io';
/**
 * Socket.IO gateway for real-time chat messaging and notifications.
 */
export declare function initializeChatGateway(io: SocketIOServer): void;
/**
 * Emit a notification event to a specific user.
 */
export declare function emitToUser(userId: number, event: string, payload: any): void;
//# sourceMappingURL=chat.gateway.d.ts.map