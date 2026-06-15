import { CreateDonationInput } from './donations.schema.js';
export declare class DonationsService {
    createStripeSession(input: CreateDonationInput, donorId: number): Promise<{
        sessionId: string;
        url: string | null;
    }>;
    handleStripeWebhook(signature: string, rawBody: Buffer): Promise<{
        received: boolean;
    }>;
    createDonation(input: CreateDonationInput, donorId: number): Promise<any>;
    approveDonation(donationId: number, adminId: number, ip?: string, role?: string): Promise<any>;
    rejectDonation(donationId: number, adminId: number, ip?: string, role?: string): Promise<any>;
    getDonationsByDonor(donorId: number): Promise<any[]>;
    getDonationsByCampaign(campaignId: number): Promise<any[]>;
    getDonationsByNgo(ngoUserId: number, status?: string): Promise<any[]>;
}
export declare const donationsService: DonationsService;
//# sourceMappingURL=donations.service.d.ts.map