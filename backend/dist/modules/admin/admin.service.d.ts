export interface PaginationOptions {
    page?: number;
    limit?: number;
    sortField?: string;
    sortOrder?: 'ASC' | 'DESC';
}
export interface AuditLogFilters {
    admin_id?: number;
    action_type?: string;
    target_entity?: string;
    target_id?: number;
    from_date?: string;
    to_date?: string;
    metadata_filter?: Record<string, string>;
}
export declare class AdminService {
    private applyPagination;
    getMapData(): Promise<{
        tasks: any[];
        volunteers: any[];
    }>;
    getDonationStats(): Promise<any>;
    getWithdrawalStats(): Promise<any>;
    getCampaignStats(): Promise<any>;
    getUserStats(): Promise<any>;
    getAllDonations(status?: string, options?: PaginationOptions): Promise<{
        items: any[];
        total: number;
    }>;
    getAllWithdrawals(status?: string, options?: PaginationOptions): Promise<{
        items: any[];
        total: number;
    }>;
    getAllCampaigns(options?: PaginationOptions): Promise<{
        items: any[];
        total: number;
    }>;
    getAllUsers(options?: PaginationOptions): Promise<{
        items: any[];
        total: number;
    }>;
    getAuditLogs(options?: PaginationOptions, filters?: AuditLogFilters): Promise<{
        items: any[];
        total: number;
    }>;
    getNgoDetail(id: number): Promise<{
        ngo: any;
        stats: any;
        recent_campaigns: any[];
    }>;
    getDonationTrace(id: number): Promise<{
        donation: any;
        ledger_entries: any[];
        audit_logs: any[];
    }>;
    getPendingNgos(): Promise<any[]>;
    verifyNgo(id: number, adminId: number, ip: string): Promise<any>;
    rejectNgo(id: number, adminId: number, reason: string, ip: string): Promise<any>;
    flagDonation(id: number, adminId: number, reason: string, ip: string): Promise<any>;
    flagWithdrawal(id: number, adminId: number, reason: string, ip: string): Promise<any>;
    getLedger(): Promise<{
        donations: any[];
        withdrawals: any[];
        campaigns: any[];
    }>;
}
export declare const adminService: AdminService;
//# sourceMappingURL=admin.service.d.ts.map