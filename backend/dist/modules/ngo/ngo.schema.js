import { z } from 'zod';
export const updateNgoProfileSchema = z.object({
    org_name: z.string().min(1).max(255).optional(),
    description: z.string().optional(),
    bank_name: z.string().max(100).optional(),
    account_title: z.string().max(100).optional(),
    account_number: z.string().max(100).optional(),
});
//# sourceMappingURL=ngo.schema.js.map