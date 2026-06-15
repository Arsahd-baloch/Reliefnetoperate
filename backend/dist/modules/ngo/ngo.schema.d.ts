import { z } from 'zod';
export declare const updateNgoProfileSchema: z.ZodObject<{
    org_name: z.ZodOptional<z.ZodString>;
    description: z.ZodOptional<z.ZodString>;
    bank_name: z.ZodOptional<z.ZodString>;
    account_title: z.ZodOptional<z.ZodString>;
    account_number: z.ZodOptional<z.ZodString>;
}, "strip", z.ZodTypeAny, {
    description?: string | undefined;
    org_name?: string | undefined;
    bank_name?: string | undefined;
    account_title?: string | undefined;
    account_number?: string | undefined;
}, {
    description?: string | undefined;
    org_name?: string | undefined;
    bank_name?: string | undefined;
    account_title?: string | undefined;
    account_number?: string | undefined;
}>;
export type UpdateNgoProfileInput = z.infer<typeof updateNgoProfileSchema>;
//# sourceMappingURL=ngo.schema.d.ts.map