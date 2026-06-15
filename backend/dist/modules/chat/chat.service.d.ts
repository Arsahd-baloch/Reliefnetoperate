export declare class ChatService {
    /**
     * Create a chat room for a task.
     */
    createRoom(taskId: number, userId: number): Promise<any>;
    /**
     * Get room info by task ID.
     */
    getRoomByTaskId(taskId: number, userId: number): Promise<any>;
    /**
     * Send a message in a chat room.
     */
    sendMessage(roomId: number, senderId: number, text: string): Promise<any>;
    /**
     * Get messages for a chat room.
     */
    getMessages(roomId: number, userId: number, limit?: number, offset?: number): Promise<any[]>;
    /**
     * Get or create a chat room for an inkind request (donor ↔ beneficiary).
     */
    ensureInKindRoom(requestId: number, userId: number): Promise<any>;
    /**
     * Get rooms for a user (via tasks or inkind requests they're involved in).
     */
    getUserRooms(userId: number): Promise<any[]>;
}
export declare const chatService: ChatService;
//# sourceMappingURL=chat.service.d.ts.map