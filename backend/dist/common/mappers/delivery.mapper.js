/**
 * Delivery Mapper
 */
export const mapDelivery = (raw) => {
    return {
        id: Number(raw.id),
        task_id: Number(raw.task_id),
        volunteer_id: Number(raw.volunteer_id),
        storage_keys: raw.storage_keys || [],
        notes: raw.notes || '',
        verified_by: raw.verified_by ? Number(raw.verified_by) : null,
        verified_at: raw.verified_at ? new Date(raw.verified_at).toISOString() : null,
        submitted_at: raw.submitted_at ? new Date(raw.submitted_at).toISOString() : null,
        latitude: raw.latitude ? parseFloat(raw.latitude.toString()) : null,
        longitude: raw.longitude ? parseFloat(raw.longitude.toString()) : null,
    };
};
export const mapDeliveryList = (rawList) => {
    return {
        data: rawList.map(mapDelivery),
        meta: { total: rawList.length }
    };
};
//# sourceMappingURL=delivery.mapper.js.map