/**
 * Withdrawal Mapper
 */
interface WithdrawalRow {
    id: string | number;
    ngo_user_id?: string | number | null;
    amount?: string | number | null;
    bank_account?: string | null;
    status?: string | null;
    ngo_name?: string | null;
    ngo_email?: string | null;
    approved_by?: string | number | null;
    rejected_by?: string | number | null;
    created_at?: string | Date | null;
    updated_at?: string | Date | null;
}
export declare const mapWithdrawal: (raw: WithdrawalRow) => {
    id: number;
    ngo_user_id: number | null;
    amount: number;
    bank_account: string;
    status: string;
    ngo_name: string | null;
    ngo_email: string | null;
    approved_by: number | null;
    rejected_by: number | null;
    created_at: string | null;
    updated_at: string | null;
};
export declare const mapWithdrawalList: (rawList: WithdrawalRow[]) => {
    data: {
        id: number;
        ngo_user_id: number | null;
        amount: number;
        bank_account: string;
        status: string;
        ngo_name: string | null;
        ngo_email: string | null;
        approved_by: number | null;
        rejected_by: number | null;
        created_at: string | null;
        updated_at: string | null;
    }[];
    meta: {
        total: number;
    };
};
export {};
//# sourceMappingURL=withdrawal.mapper.d.ts.map