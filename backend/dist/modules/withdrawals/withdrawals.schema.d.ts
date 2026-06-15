import { z } from 'zod';
export declare const createWithdrawalSchema: z.ZodObject<{
    amount: z.ZodNumber;
    bank_account: z.ZodString;
}, "strip", z.ZodTypeAny, {
    amount: number;
    bank_account: string;
}, {
    amount: number;
    bank_account: string;
}>;
export declare const withdrawalIdParam: z.ZodObject<{
    id: z.ZodNumber;
}, "strip", z.ZodTypeAny, {
    id: number;
}, {
    id: number;
}>;
export type CreateWithdrawalInput = z.infer<typeof createWithdrawalSchema>;
//# sourceMappingURL=withdrawals.schema.d.ts.map