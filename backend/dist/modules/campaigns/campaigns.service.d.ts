import { CreateCampaignInput, UpdateCampaignInput } from './campaigns.schema.js';
export declare class CampaignsService {
    /**
     * Helper to get NGO profile ID for a user.
     */
    getNgoIdByUserId(userId: number): Promise<number | null>;
    create(input: CreateCampaignInput, createdBy: number, ngoId?: number): Promise<any>;
    getAll(status?: string): Promise<any[]>;
    getById(id: number): Promise<any>;
    update(id: number, input: UpdateCampaignInput, requesterId?: number, ip?: string, role?: string): Promise<any>;
}
export declare const campaignsService: CampaignsService;
//# sourceMappingURL=campaigns.service.d.ts.map