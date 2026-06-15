/**
 * Donation Mapper
 */
interface DonationRow {
    id: string | number;
    donor_id?: string | number | null;
    campaign_id?: string | number | null;
    amount_pkr?: string | number | null;
    status?: string | null;
    payment_method?: string | null;
    receipt_url?: string | null;
    gateway_ref?: string | null;
    donor_name?: string | null;
    donor_email?: string | null;
    campaign_title?: string | null;
    created_at?: string | Date | null;
    updated_at?: string | Date | null;
}
export declare const mapDonation: (raw: DonationRow) => {
    id: number;
    donor_id: number | null;
    campaign_id: number | null;
    amount_pkr: number;
    status: string;
    payment_method: string;
    receipt_url: string | null;
    gateway_ref: string | null;
    donor_name: string | null;
    donor_email: string | null;
    campaign_title: string | null;
    created_at: string | null;
    updated_at: string | null;
};
export declare const mapDonationList: (rawList: DonationRow[]) => {
    data: {
        id: number;
        donor_id: number | null;
        campaign_id: number | null;
        amount_pkr: number;
        status: string;
        payment_method: string;
        receipt_url: string | null;
        gateway_ref: string | null;
        donor_name: string | null;
        donor_email: string | null;
        campaign_title: string | null;
        created_at: string | null;
        updated_at: string | null;
    }[];
    meta: {
        total: number;
    };
};
export {};
//# sourceMappingURL=donation.mapper.d.ts.map