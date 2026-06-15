export declare class AdminSnapshotService {
    getSystemSnapshot(): Promise<{
        users: {
            total: number;
            by_role: {
                admin: number;
                ngo: number;
                volunteer: number;
                coordinator: number;
                donor: number;
                beneficiary: number;
            };
            suspended: number;
        };
        donations: {
            pending: number;
            confirmed: number;
            rejected: number;
            total_confirmed_pkr: number;
        };
        withdrawals: {
            pending: number;
            approved: number;
            rejected: number;
            total_approved_pkr: number;
        };
        campaigns: {
            total: number;
            active: number;
            total_raised_pkr: number;
            total_goal_pkr: number;
            total_spent_pkr: number;
        };
        generated_at: string;
        system: {
            state: import("../../system/state/system.state.js").SystemState;
            description: string;
            allowed_actions: "ALL" | import("../../system/state/system.state.js").AdminCommandType[];
            blocked_categories: string[];
            state_persistence: {
                source: import("../../system/state/system.state.store.js").PersistenceSource;
                last_updated: string | null;
                recovery_status: import("../../system/state/system.state.store.js").RecoveryStatus;
            };
        };
    }>;
    getOperationalOverview(): Promise<{
        pending: {
            donations: number;
            withdrawals: number;
            deliveries: number;
        };
        oldest_pending_hours: {
            donation: number | null;
            withdrawal: number | null;
            delivery: number | null;
        };
        tasks: {
            open: number;
            claimed: number;
            in_progress: number;
            submitted: number;
            completed: number;
        };
        generated_at: string;
    }>;
}
export declare const adminSnapshotService: AdminSnapshotService;
//# sourceMappingURL=admin.snapshot.service.d.ts.map