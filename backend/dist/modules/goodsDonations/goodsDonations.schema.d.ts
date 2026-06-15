import { z } from 'zod';
export declare const submitGoodsDonationSchema: z.ZodObject<{
    campaign_id: z.ZodNumber;
    item_name: z.ZodString;
    category: z.ZodString;
    description: z.ZodString;
    photo_url: z.ZodOptional<z.ZodString>;
    quantity: z.ZodNumber;
    unit: z.ZodString;
    pickup_address: z.ZodString;
    pickup_lat: z.ZodOptional<z.ZodNumber>;
    pickup_lng: z.ZodOptional<z.ZodNumber>;
    contact_number: z.ZodString;
}, "strip", z.ZodTypeAny, {
    description: string;
    campaign_id: number;
    category: string;
    quantity: number;
    unit: string;
    item_name: string;
    pickup_address: string;
    contact_number: string;
    photo_url?: string | undefined;
    pickup_lat?: number | undefined;
    pickup_lng?: number | undefined;
}, {
    description: string;
    campaign_id: number;
    category: string;
    quantity: number;
    unit: string;
    item_name: string;
    pickup_address: string;
    contact_number: string;
    photo_url?: string | undefined;
    pickup_lat?: number | undefined;
    pickup_lng?: number | undefined;
}>;
export declare const deliverGoodsDonationSchema: z.ZodObject<{
    proof_photo_url: z.ZodString;
    qty_confirmed: z.ZodNumber;
    volunteer_note: z.ZodOptional<z.ZodString>;
}, "strip", z.ZodTypeAny, {
    proof_photo_url: string;
    qty_confirmed: number;
    volunteer_note?: string | undefined;
}, {
    proof_photo_url: string;
    qty_confirmed: number;
    volunteer_note?: string | undefined;
}>;
export declare const rejectGoodsDonationSchema: z.ZodObject<{
    rejection_reason: z.ZodString;
}, "strip", z.ZodTypeAny, {
    rejection_reason: string;
}, {
    rejection_reason: string;
}>;
export declare const overrideGoodsDonationSchema: z.ZodObject<{
    status: z.ZodEnum<["PENDING", "ASSIGNED", "DELIVERED", "APPROVED", "REJECTED"]>;
    rejection_reason: z.ZodOptional<z.ZodString>;
    note: z.ZodOptional<z.ZodString>;
}, "strip", z.ZodTypeAny, {
    status: "ASSIGNED" | "PENDING" | "REJECTED" | "APPROVED" | "DELIVERED";
    rejection_reason?: string | undefined;
    note?: string | undefined;
}, {
    status: "ASSIGNED" | "PENDING" | "REJECTED" | "APPROVED" | "DELIVERED";
    rejection_reason?: string | undefined;
    note?: string | undefined;
}>;
export declare const donationIdParam: z.ZodObject<{
    id: z.ZodNumber;
}, "strip", z.ZodTypeAny, {
    id: number;
}, {
    id: number;
}>;
export type SubmitGoodsDonationInput = z.infer<typeof submitGoodsDonationSchema>;
export type DeliverGoodsDonationInput = z.infer<typeof deliverGoodsDonationSchema>;
export type RejectGoodsDonationInput = z.infer<typeof rejectGoodsDonationSchema>;
export type OverrideGoodsDonationInput = z.infer<typeof overrideGoodsDonationSchema>;
//# sourceMappingURL=goodsDonations.schema.d.ts.map