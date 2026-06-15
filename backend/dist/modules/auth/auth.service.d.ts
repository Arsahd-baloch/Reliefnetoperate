import { RegisterInput, LoginInput } from './auth.schema.js';
export declare class AuthService {
    private static rolesCache;
    private getRoleId;
    /**
     * Register a new user. ADMIN role is explicitly forbidden.
     */
    register(input: RegisterInput): Promise<{
        user: any;
        token: string;
    }>;
    /**
     * Login with email/phone + password.
     */
    login(input: LoginInput): Promise<{
        user: {
            id: any;
            email: any;
            phone: any;
            name: any;
            role: any;
        };
        token: string;
    }>;
    /**
     * Get user profile by ID.
     */
    getProfile(userId: number): Promise<any>;
    /**
     * Generate JWT token.
     */
    private generateToken;
}
export declare const authService: AuthService;
//# sourceMappingURL=auth.service.d.ts.map