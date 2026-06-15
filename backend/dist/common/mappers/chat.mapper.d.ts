/**
 * Chat Mapper
 */
interface ChatRoomRow {
    id: string | number;
    task_id?: string | number | null;
    inkind_request_id?: string | number | null;
    task_title?: string | null;
    task_status?: string | null;
    creator_name?: string | null;
    claimer_name?: string | null;
    coordinator_name?: string | null;
    message_count?: string | number | null;
    created_at?: string | Date | null;
    last_message?: string | null;
    last_message_at?: string | Date | null;
}
interface ChatMessageRow {
    id: string | number;
    room_id: string | number;
    sender_id: string | number;
    sender_name?: string | null;
    text?: string | null;
    created_at?: string | Date | null;
}
export declare const mapChatRoom: (raw: ChatRoomRow) => {
    id: number;
    task_id: number | null;
    inkind_request_id: number | null;
    task_title: string | null;
    task_status: string | null;
    creator_name: string | null;
    claimer_name: string | null;
    coordinator_name: string | null;
    message_count: number;
    created_at: string | null;
    last_message: string | null;
    last_message_at: string | null;
};
export declare const mapChatMessage: (raw: ChatMessageRow) => {
    id: number;
    room_id: number;
    sender_id: number;
    sender_name: string;
    text: string;
    created_at: string | null;
};
export declare const mapChatRoomList: (rawList: ChatRoomRow[]) => {
    data: {
        id: number;
        task_id: number | null;
        inkind_request_id: number | null;
        task_title: string | null;
        task_status: string | null;
        creator_name: string | null;
        claimer_name: string | null;
        coordinator_name: string | null;
        message_count: number;
        created_at: string | null;
        last_message: string | null;
        last_message_at: string | null;
    }[];
    meta: {
        total: number;
    };
};
export declare const mapChatMessageList: (rawList: ChatMessageRow[]) => {
    data: {
        id: number;
        room_id: number;
        sender_id: number;
        sender_name: string;
        text: string;
        created_at: string | null;
    }[];
    meta: {
        total: number;
    };
};
export {};
//# sourceMappingURL=chat.mapper.d.ts.map