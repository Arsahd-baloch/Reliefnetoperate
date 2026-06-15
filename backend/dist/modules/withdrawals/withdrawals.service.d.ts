import { CreateWithdrawalInput } from './withdrawals.schema.js';
export declare class WithdrawalsService {
    createWithdrawal(input: CreateWithdrawalInput, ngoUserId: number): Promise<any>;
    approveWithdrawal(withdrawalId: number, adminId: number, ip?: string): Promise<any>;
    rejectWithdrawal(withdrawalId: number, adminId: number, ip?: string): Promise<any>;
    getWithdrawalsByNgo(ngoUserId: number): Promise<any[]>;
}
export declare const withdrawalsService: WithdrawalsService;
//# sourceMappingURL=withdrawals.service.d.ts.map