import { z } from 'zod';
export declare const createGoodsCampaignSchema: z.ZodObject<{
    title: z.ZodString;
    item_needed: z.ZodString;
    category: z.ZodString;
    category_other: z.ZodOptional<z.ZodString>;
    target_qty: z.ZodNumber;
    unit: z.ZodString;
    description: z.ZodString;
    location_text: z.ZodString;
    latitude: z.ZodOptional<z.ZodNumber>;
    longitude: z.ZodOptional<z.ZodNumber>;
    deadline: z.ZodString;
    cover_image_url: z.ZodOptional<z.ZodString>;
}, "strip", z.ZodTypeAny, {
    description: string;
    title: string;
    category: string;
    location_text: string;
    item_needed: string;
    target_qty: number;
    unit: string;
    deadline: string;
    latitude?: number | undefined;
    longitude?: number | undefined;
    category_other?: string | undefined;
    cover_image_url?: string | undefined;
}, {
    description: string;
    title: string;
    category: string;
    location_text: string;
    item_needed: string;
    target_qty: number;
    unit: string;
    deadline: string;
    latitude?: number | undefined;
    longitude?: number | undefined;
    category_other?: string | undefined;
    cover_image_url?: string | undefined;
}>;
export declare const updateGoodsCampaignSchema: z.ZodObject<{
    title: z.ZodOptional<z.ZodString>;
    item_needed: z.ZodOptional<z.ZodString>;
    category: z.ZodOptional<z.ZodString>;
    category_other: z.ZodOptional<z.ZodOptional<z.ZodString>>;
    target_qty: z.ZodOptional<z.ZodNumber>;
    unit: z.ZodOptional<z.ZodString>;
    description: z.ZodOptional<z.ZodString>;
    location_text: z.ZodOptional<z.ZodString>;
    latitude: z.ZodOptional<z.ZodOptional<z.ZodNumber>>;
    longitude: z.ZodOptional<z.ZodOptional<z.ZodNumber>>;
    deadline: z.ZodOptional<z.ZodString>;
    cover_image_url: z.ZodOptional<z.ZodOptional<z.ZodString>>;
} & {
    status: z.ZodOptional<z.ZodEnum<["ACTIVE", "PAUSED", "CLOSED", "DRAFT"]>>;
}, "strip", z.ZodTypeAny, {
    status?: "ACTIVE" | "DRAFT" | "PAUSED" | "CLOSED" | undefined;
    description?: string | undefined;
    title?: string | undefined;
    category?: string | undefined;
    latitude?: number | undefined;
    longitude?: number | undefined;
    location_text?: string | undefined;
    item_needed?: string | undefined;
    category_other?: string | undefined;
    target_qty?: number | undefined;
    unit?: string | undefined;
    deadline?: string | undefined;
    cover_image_url?: string | undefined;
}, {
    status?: "ACTIVE" | "DRAFT" | "PAUSED" | "CLOSED" | undefined;
    description?: string | undefined;
    title?: string | undefined;
    category?: string | undefined;
    latitude?: number | undefined;
    longitude?: number | undefined;
    location_text?: string | undefined;
    item_needed?: string | undefined;
    category_other?: string | undefined;
    target_qty?: number | undefined;
    unit?: string | undefined;
    deadline?: string | undefined;
    cover_image_url?: string | undefined;
}>;
export declare const campaignIdParam: z.ZodObject<{
    id: z.ZodNumber;
}, "strip", z.ZodTypeAny, {
    id: number;
}, {
    id: number;
}>;
export type CreateGoodsCampaignInput = z.infer<typeof createGoodsCampaignSchema>;
export type UpdateGoodsCampaignInput = z.infer<typeof updateGoodsCampaignSchema>;
//# sourceMappingURL=goodsCampaigns.schema.d.ts.map