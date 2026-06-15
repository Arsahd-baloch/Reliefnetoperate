import { z } from 'zod';
export declare const createDonationSchema: z.ZodObject<{
    campaign_id: z.ZodNumber;
    amount_pkr: z.ZodNumber;
    reference_number: z.ZodString;
    receipt_url: z.ZodOptional<z.ZodString>;
}, "strip", z.ZodTypeAny, {
    campaign_id: number;
    amount_pkr: number;
    reference_number: string;
    receipt_url?: string | undefined;
}, {
    campaign_id: number;
    amount_pkr: number;
    reference_number: string;
    receipt_url?: string | undefined;
}>;
export declare const donationIdParam: z.ZodObject<{
    id: z.ZodNumber;
}, "strip", z.ZodTypeAny, {
    id: number;
}, {
    id: number;
}>;
export type CreateDonationInput = z.infer<typeof createDonationSchema>;
//# sourceMappingURL=donations.schema.d.ts.map