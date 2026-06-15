/**
 * Delivery Mapper
 */
export interface DeliveryRow {
    id: string | number;
    task_id: string | number;
    volunteer_id: string | number;
    storage_keys?: string[];
    notes?: string | null;
    verified_by?: string | number | null;
    verified_at?: string | Date | null;
    submitted_at?: string | Date | null;
    latitude?: string | number | null;
    longitude?: string | number | null;
}
export declare const mapDelivery: (raw: DeliveryRow) => {
    id: number;
    task_id: number;
    volunteer_id: number;
    storage_keys: string[];
    notes: string;
    verified_by: number | null;
    verified_at: string | null;
    submitted_at: string | null;
    latitude: number | null;
    longitude: number | null;
};
export declare const mapDeliveryList: (rawList: DeliveryRow[]) => {
    data: {
        id: number;
        task_id: number;
        volunteer_id: number;
        storage_keys: string[];
        notes: string;
        verified_by: number | null;
        verified_at: string | null;
        submitted_at: string | null;
        latitude: number | null;
        longitude: number | null;
    }[];
    meta: {
        total: number;
    };
};
//# sourceMappingURL=delivery.mapper.d.ts.map