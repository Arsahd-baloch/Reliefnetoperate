import { z } from 'zod';
export declare const createCampaignSchema: z.ZodObject<{
    title: z.ZodString;
    description: z.ZodOptional<z.ZodString>;
    goal_pkr: z.ZodNumber;
    latitude: z.ZodOptional<z.ZodNumber>;
    longitude: z.ZodOptional<z.ZodNumber>;
}, "strip", z.ZodTypeAny, {
    title: string;
    goal_pkr: number;
    description?: string | undefined;
    latitude?: number | undefined;
    longitude?: number | undefined;
}, {
    title: string;
    goal_pkr: number;
    description?: string | undefined;
    latitude?: number | undefined;
    longitude?: number | undefined;
}>;
export declare const updateCampaignSchema: z.ZodObject<{
    title: z.ZodOptional<z.ZodString>;
    description: z.ZodOptional<z.ZodString>;
    goal_pkr: z.ZodOptional<z.ZodNumber>;
    status: z.ZodOptional<z.ZodEnum<["DRAFT", "PENDING_APPROVAL", "ACTIVE", "PAUSED", "CLOSED", "REJECTED", "COMPLETED"]>>;
    latitude: z.ZodOptional<z.ZodNumber>;
    longitude: z.ZodOptional<z.ZodNumber>;
}, "strip", z.ZodTypeAny, {
    status?: "ACTIVE" | "REJECTED" | "DRAFT" | "PENDING_APPROVAL" | "PAUSED" | "CLOSED" | "COMPLETED" | undefined;
    description?: string | undefined;
    title?: string | undefined;
    latitude?: number | undefined;
    longitude?: number | undefined;
    goal_pkr?: number | undefined;
}, {
    status?: "ACTIVE" | "REJECTED" | "DRAFT" | "PENDING_APPROVAL" | "PAUSED" | "CLOSED" | "COMPLETED" | undefined;
    description?: string | undefined;
    title?: string | undefined;
    latitude?: number | undefined;
    longitude?: number | undefined;
    goal_pkr?: number | undefined;
}>;
export declare const campaignIdParam: z.ZodObject<{
    id: z.ZodNumber;
}, "strip", z.ZodTypeAny, {
    id: number;
}, {
    id: number;
}>;
export type CreateCampaignInput = z.infer<typeof createCampaignSchema>;
export type UpdateCampaignInput = z.infer<typeof updateCampaignSchema>;
//# sourceMappingURL=campaigns.schema.d.ts.map