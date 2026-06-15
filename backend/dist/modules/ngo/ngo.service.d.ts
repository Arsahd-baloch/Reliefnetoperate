export declare class NgoService {
    /**
     * Get NGO profile ID for a user.
     */
    getNgoIdByUserId(userId: number): Promise<number | null>;
    /**
     * Get NGO dashboard statistics.
     */
    getDashboardStats(userId: number): Promise<{
        campaigns: {
            total: number;
            active: number;
            total_raised: number;
            total_goal: number;
        };
        donations: {
            count: number;
            total_amount: number;
        };
    }>;
    /**
     * Get full NGO profile.
     */
    getProfile(userId: number): Promise<any>;
    /**
     * Update NGO profile.
     */
    updateProfile(userId: number, input: any): Promise<any>;
    /**
     * Get NGO campaigns (paginated).
     */
    getCampaigns(userId: number): Promise<any[]>;
    /**
     * Public profile data.
     */
    getPublicProfile(ngoId: number): Promise<{
        profile: any;
        campaigns: any[];
    }>;
}
export declare const ngoService: NgoService;
//# sourceMappingURL=ngo.service.d.ts.map