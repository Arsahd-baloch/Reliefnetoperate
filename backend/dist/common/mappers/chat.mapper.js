/**
 * Chat Mapper
 */
export const mapChatRoom = (raw) => {
    return {
        id: Number(raw.id),
        task_id: raw.task_id != null ? Number(raw.task_id) : null,
        inkind_request_id: raw.inkind_request_id != null ? Number(raw.inkind_request_id) : null,
        task_title: raw.task_title || null,
        task_status: raw.task_status || null,
        creator_name: raw.creator_name || null,
        claimer_name: raw.claimer_name || null,
        coordinator_name: raw.coordinator_name || null,
        message_count: Number(raw.message_count || 0),
        created_at: raw.created_at ? new Date(raw.created_at).toISOString() : null,
        last_message: raw.last_message ?? null,
        last_message_at: raw.last_message_at ? new Date(raw.last_message_at).toISOString() : null,
    };
};
export const mapChatMessage = (raw) => {
    return {
        id: Number(raw.id),
        room_id: Number(raw.room_id),
        sender_id: Number(raw.sender_id),
        sender_name: raw.sender_name || '',
        text: raw.text || '',
        created_at: raw.created_at ? new Date(raw.created_at).toISOString() : null,
    };
};
export const mapChatRoomList = (rawList) => {
    return {
        data: rawList.map(mapChatRoom),
        meta: { total: rawList.length }
    };
};
export const mapChatMessageList = (rawList) => {
    return {
        data: rawList.map(mapChatMessage),
        meta: { total: rawList.length }
    };
};
//# sourceMappingURL=chat.mapper.js.map