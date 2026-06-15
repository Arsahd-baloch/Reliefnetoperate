import { z } from 'zod';
export declare const createInKindDonationSchema: z.ZodObject<{
    title: z.ZodString;
    description: z.ZodOptional<z.ZodString>;
    photo_url: z.ZodOptional<z.ZodString>;
    address_text: z.ZodString;
    latitude: z.ZodNumber;
    longitude: z.ZodNumber;
}, "strip", z.ZodTypeAny, {
    title: string;
    latitude: number;
    longitude: number;
    address_text: string;
    description?: string | undefined;
    photo_url?: string | undefined;
}, {
    title: string;
    latitude: number;
    longitude: number;
    address_text: string;
    description?: string | undefined;
    photo_url?: string | undefined;
}>;
export declare const createInKindRequestSchema: z.ZodObject<{
    message: z.ZodOptional<z.ZodString>;
    phone: z.ZodString;
    email: z.ZodOptional<z.ZodString>;
}, "strip", z.ZodTypeAny, {
    phone: string;
    message?: string | undefined;
    email?: string | undefined;
}, {
    phone: string;
    message?: string | undefined;
    email?: string | undefined;
}>;
export declare const acceptRequestSchema: z.ZodObject<{
    donor_shared_phone: z.ZodOptional<z.ZodString>;
}, "strip", z.ZodTypeAny, {
    donor_shared_phone?: string | undefined;
}, {
    donor_shared_phone?: string | undefined;
}>;
export declare const donationIdParam: z.ZodObject<{
    id: z.ZodNumber;
}, "strip", z.ZodTypeAny, {
    id: number;
}, {
    id: number;
}>;
export declare const requestIdParam: z.ZodObject<{
    requestId: z.ZodNumber;
}, "strip", z.ZodTypeAny, {
    requestId: number;
}, {
    requestId: number;
}>;
export type CreateInKindDonationInput = z.infer<typeof createInKindDonationSchema>;
export type CreateInKindRequestInput = z.infer<typeof createInKindRequestSchema>;
export type AcceptRequestInput = z.infer<typeof acceptRequestSchema>;
//# sourceMappingURL=inkind.schema.d.ts.map