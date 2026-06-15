import { CreateInKindDonationInput, CreateInKindRequestInput, AcceptRequestInput } from './inkind.schema.js';
export declare class InKindService {
    createDonation(input: CreateInKindDonationInput, donorId: number): Promise<any>;
    getBoard(): Promise<any[]>;
    getMyDonations(donorId: number): Promise<any[]>;
    getDonationById(donationId: number): Promise<any>;
    createRequest(donationId: number, beneficiaryId: number, input: CreateInKindRequestInput): Promise<any>;
    getRequests(donationId: number, donorId: number): Promise<any[]>;
    acceptRequest(requestId: number, donorId: number, input: AcceptRequestInput): Promise<any>;
    rejectRequest(requestId: number, donorId: number): Promise<any>;
    completeDonation(donationId: number, beneficiaryId: number): Promise<{
        id: number;
        status: string;
    }>;
    getMyRequests(beneficiaryId: number): Promise<any[]>;
    getAdminRecords(): Promise<any[]>;
}
export declare const inKindService: InKindService;
//# sourceMappingURL=inkind.service.d.ts.map