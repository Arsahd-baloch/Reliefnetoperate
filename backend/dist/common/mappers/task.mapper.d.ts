/**
 * Task Mapper
 */
interface TaskRow {
    id: string | number;
    campaign_id?: string | number | null;
    beneficiary_id?: string | number | null;
    created_by?: string | number | null;
    claimed_by?: string | number | null;
    coordinator_id?: string | number | null;
    source_type?: string | null;
    title?: string | null;
    description?: string | null;
    category?: string | null;
    family_size?: string | number | null;
    items_needed?: unknown;
    latitude?: string | number | null;
    longitude?: string | number | null;
    location_text?: string | null;
    radius_km?: string | number | null;
    budget_pkr?: string | number | null;
    urgency?: string | null;
    status?: string | null;
    upvotes?: string | number | null;
    downvotes?: string | number | null;
    view_count?: string | number | null;
    created_at?: string | Date | null;
    updated_at?: string | Date | null;
    claimed_at?: string | Date | null;
    created_by_name?: string | null;
    claimed_by_name?: string | null;
    coordinator_name?: string | null;
    beneficiary_name?: string | null;
    campaign_title?: string | null;
    ngo_name?: string | null;
}
export declare const mapTask: (raw: TaskRow) => {
    id: number;
    campaign_id: number | null;
    beneficiary_id: number | null;
    created_by: number | null;
    claimed_by: number | null;
    coordinator_id: number | null;
    source_type: string;
    title: string;
    description: string;
    category: string;
    family_size: number;
    items_needed: {};
    latitude: number | null;
    longitude: number | null;
    location_text: string;
    radius_km: number;
    budget_pkr: number;
    urgency: string;
    status: string;
    upvotes: number;
    downvotes: number;
    view_count: number;
    created_at: string | null;
    updated_at: string | null;
    claimed_at: string | null;
    created_by_name: string | null;
    claimed_by_name: string | null;
    coordinator_name: string | null;
    beneficiary_name: string | null;
    campaign_title: string | null;
    ngo_name: string | null;
};
export declare const mapTaskList: (rawList: TaskRow[]) => {
    data: {
        id: number;
        campaign_id: number | null;
        beneficiary_id: number | null;
        created_by: number | null;
        claimed_by: number | null;
        coordinator_id: number | null;
        source_type: string;
        title: string;
        description: string;
        category: string;
        family_size: number;
        items_needed: {};
        latitude: number | null;
        longitude: number | null;
        location_text: string;
        radius_km: number;
        budget_pkr: number;
        urgency: string;
        status: string;
        upvotes: number;
        downvotes: number;
        view_count: number;
        created_at: string | null;
        updated_at: string | null;
        claimed_at: string | null;
        created_by_name: string | null;
        claimed_by_name: string | null;
        coordinator_name: string | null;
        beneficiary_name: string | null;
        campaign_title: string | null;
        ngo_name: string | null;
    }[];
    meta: {
        total: number;
    };
};
export {};
//# sourceMappingURL=task.mapper.d.ts.map