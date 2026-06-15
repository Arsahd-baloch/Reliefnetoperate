import { z } from 'zod';
export declare const submitDeliverySchema: z.ZodObject<{
    task_id: z.ZodNumber;
    storage_keys: z.ZodArray<z.ZodString, "many">;
    latitude: z.ZodNumber;
    longitude: z.ZodNumber;
    notes: z.ZodOptional<z.ZodString>;
    quantity_delivered: z.ZodNumber;
}, "strip", z.ZodTypeAny, {
    latitude: number;
    longitude: number;
    task_id: number;
    storage_keys: string[];
    quantity_delivered: number;
    notes?: string | undefined;
}, {
    latitude: number;
    longitude: number;
    task_id: number;
    storage_keys: string[];
    quantity_delivered: number;
    notes?: string | undefined;
}>;
export declare const verifyDeliverySchema: z.ZodObject<{
    verified: z.ZodBoolean;
    outcome: z.ZodOptional<z.ZodEnum<["VERIFY", "FLAG", "REJECT"]>>;
    notes: z.ZodOptional<z.ZodString>;
}, "strip", z.ZodTypeAny, {
    verified: boolean;
    notes?: string | undefined;
    outcome?: "VERIFY" | "FLAG" | "REJECT" | undefined;
}, {
    verified: boolean;
    notes?: string | undefined;
    outcome?: "VERIFY" | "FLAG" | "REJECT" | undefined;
}>;
export declare const deliveryIdParam: z.ZodObject<{
    id: z.ZodNumber;
}, "strip", z.ZodTypeAny, {
    id: number;
}, {
    id: number;
}>;
export type SubmitDeliveryInput = z.infer<typeof submitDeliverySchema>;
export type VerifyDeliveryInput = z.infer<typeof verifyDeliverySchema>;
//# sourceMappingURL=deliveries.schema.d.ts.map