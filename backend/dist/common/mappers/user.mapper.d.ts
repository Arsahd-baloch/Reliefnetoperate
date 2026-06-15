/**
 * User Mapper
 * Standardizes user responses for all frontends.
 */
interface UserRow {
    id: string | number;
    name?: string | null;
    email?: string | null;
    phone?: string | null;
    role?: string | null;
    status?: string | null;
    cnic?: string | null;
    locale?: string | null;
    created_at?: string | Date | null;
}
export declare const mapUser: (raw: UserRow) => {
    id: number;
    name: string;
    email: string | null;
    phone: string | null;
    role: string | null;
    status: string;
    cnic: string | null;
    locale: string;
    created_at: string | null;
};
export declare const mapUserList: (rawList: UserRow[]) => {
    data: {
        id: number;
        name: string;
        email: string | null;
        phone: string | null;
        role: string | null;
        status: string;
        cnic: string | null;
        locale: string;
        created_at: string | null;
    }[];
    meta: {
        total: number;
    };
};
export {};
//# sourceMappingURL=user.mapper.d.ts.map