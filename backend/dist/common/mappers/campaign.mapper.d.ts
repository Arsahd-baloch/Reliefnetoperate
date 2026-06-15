/**
 * Campaign Mapper
 * Standardizes campaign responses for all frontends.
 */
interface CampaignRow {
    id: string | number;
    ngo_id?: string | number | null;
    created_by?: string | number | null;
    title?: string | null;
    description?: string | null;
    goal_pkr?: string | number | null;
    raised_pkr?: string | number | null;
    spent_pkr?: string | number | null;
    status?: string | null;
    latitude?: string | number | null;
    longitude?: string | number | null;
    ngo_name?: string | null;
    created_by_name?: string | null;
    created_at?: string | Date | null;
    updated_at?: string | Date | null;
}
export declare const mapCampaign: (raw: CampaignRow) => {
    id: number;
    ngo_id: number | null;
    created_by: number | null;
    title: string;
    description: string;
    goal_pkr: number;
    raised_pkr: number;
    spent_pkr: number;
    status: string;
    latitude: number | null;
    longitude: number | null;
    ngo_name: string | null;
    created_by_name: string | null;
    created_at: string | null;
    updated_at: string | null;
};
export declare const mapCampaignList: (rawList: CampaignRow[]) => {
    data: {
        id: number;
        ngo_id: number | null;
        created_by: number | null;
        title: string;
        description: string;
        goal_pkr: number;
        raised_pkr: number;
        spent_pkr: number;
        status: string;
        latitude: number | null;
        longitude: number | null;
        ngo_name: string | null;
        created_by_name: string | null;
        created_at: string | null;
        updated_at: string | null;
    }[];
    meta: {
        total: number;
    };
};
export {};
//# sourceMappingURL=campaign.mapper.d.ts.map