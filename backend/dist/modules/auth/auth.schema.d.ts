import { z } from 'zod';
export declare const registerSchema: z.ZodEffects<z.ZodObject<{
    email: z.ZodOptional<z.ZodString>;
    phone: z.ZodOptional<z.ZodString>;
    password: z.ZodString;
    name: z.ZodString;
    role: z.ZodEnum<["DONOR", "BENEFICIARY", "VOLUNTEER", "NGO", "COORDINATOR"]>;
    cnic: z.ZodOptional<z.ZodString>;
    locale: z.ZodDefault<z.ZodString>;
}, "strip", z.ZodTypeAny, {
    password: string;
    name: string;
    role: "NGO" | "DONOR" | "BENEFICIARY" | "VOLUNTEER" | "COORDINATOR";
    locale: string;
    email?: string | undefined;
    phone?: string | undefined;
    cnic?: string | undefined;
}, {
    password: string;
    name: string;
    role: "NGO" | "DONOR" | "BENEFICIARY" | "VOLUNTEER" | "COORDINATOR";
    email?: string | undefined;
    phone?: string | undefined;
    cnic?: string | undefined;
    locale?: string | undefined;
}>, {
    password: string;
    name: string;
    role: "NGO" | "DONOR" | "BENEFICIARY" | "VOLUNTEER" | "COORDINATOR";
    locale: string;
    email?: string | undefined;
    phone?: string | undefined;
    cnic?: string | undefined;
}, {
    password: string;
    name: string;
    role: "NGO" | "DONOR" | "BENEFICIARY" | "VOLUNTEER" | "COORDINATOR";
    email?: string | undefined;
    phone?: string | undefined;
    cnic?: string | undefined;
    locale?: string | undefined;
}>;
export declare const loginSchema: z.ZodEffects<z.ZodObject<{
    email: z.ZodOptional<z.ZodString>;
    phone: z.ZodOptional<z.ZodString>;
    password: z.ZodString;
}, "strip", z.ZodTypeAny, {
    password: string;
    email?: string | undefined;
    phone?: string | undefined;
}, {
    password: string;
    email?: string | undefined;
    phone?: string | undefined;
}>, {
    password: string;
    email?: string | undefined;
    phone?: string | undefined;
}, {
    password: string;
    email?: string | undefined;
    phone?: string | undefined;
}>;
export type RegisterInput = z.infer<typeof registerSchema>;
export type LoginInput = z.infer<typeof loginSchema>;
//# sourceMappingURL=auth.schema.d.ts.map