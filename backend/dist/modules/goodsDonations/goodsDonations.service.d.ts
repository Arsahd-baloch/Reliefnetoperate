import { SubmitGoodsDonationInput, DeliverGoodsDonationInput, RejectGoodsDonationInput, OverrideGoodsDonationInput } from './goodsDonations.schema.js';
export declare class GoodsDonationsService {
    submit(input: SubmitGoodsDonationInput, donorId: number): Promise<any>;
    getMyDonations(donorId: number): Promise<any[]>;
    getById(id: number): Promise<any>;
    getAvailable(): Promise<any[]>;
    claim(id: number, volunteerId: number): Promise<any>;
    markDelivered(id: number, volunteerId: number, input: DeliverGoodsDonationInput): Promise<any>;
    getForReview(): Promise<any[]>;
    approve(id: number, coordinatorId: number): Promise<any>;
    reject(id: number, coordinatorId: number, input: RejectGoodsDonationInput): Promise<any>;
    getNgoDonations(ngoId: number): Promise<any[]>;
    getAll(): Promise<any[]>;
    adminOverride(id: number, adminId: number, input: OverrideGoodsDonationInput): Promise<any>;
}
export declare const goodsDonationsService: GoodsDonationsService;
//# sourceMappingURL=goodsDonations.service.d.ts.map