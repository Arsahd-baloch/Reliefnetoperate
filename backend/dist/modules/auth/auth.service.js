import bcrypt from 'bcrypt';
import jwt from 'jsonwebtoken';
import { pool } from '../../config/database.js';
import { env } from '../../config/env.js';
import { createError } from '../../middleware/errorHandler.js';
export class AuthService {
    static rolesCache = {};
    async getRoleId(roleName) {
        if (AuthService.rolesCache[roleName]) {
            return AuthService.rolesCache[roleName];
        }
        const roleResult = await pool.query('SELECT id FROM roles WHERE name = $1', [roleName]);
        if (roleResult.rows.length === 0) {
            throw createError('Invalid role', 400);
        }
        const roleId = roleResult.rows[0].id;
        AuthService.rolesCache[roleName] = roleId;
        return roleId;
    }
    /**
     * Register a new user. ADMIN role is explicitly forbidden.
     */
    async register(input) {
        // SECURITY: No admin signup — ever
        if (input.role === 'ADMIN') {
            throw createError('Admin registration is not allowed', 403);
        }
        // Check for existing user
        if (input.email) {
            const existing = await pool.query('SELECT id FROM users WHERE email = $1', [input.email]);
            if (existing.rows.length > 0) {
                throw createError('Email already registered', 409);
            }
        }
        if (input.phone) {
            const existing = await pool.query('SELECT id FROM users WHERE phone = $1', [input.phone]);
            if (existing.rows.length > 0) {
                throw createError('Phone already registered', 409);
            }
        }
        // Get role ID from cache or DB
        const roleId = await this.getRoleId(input.role);
        // Hash password with bcrypt 12 rounds (async)
        const passwordHash = await bcrypt.hash(input.password, env.BCRYPT_ROUNDS);
        // Insert user
        const result = await pool.query(`INSERT INTO users (email, phone, password_hash, role_id, name, cnic, locale)
       VALUES ($1, $2, $3, $4, $5, $6, $7)
       RETURNING id, email, phone, name, created_at`, [
            input.email || null,
            input.phone || null,
            passwordHash,
            roleId,
            input.name,
            input.cnic || null,
            input.locale,
        ]);
        const user = result.rows[0];
        // Create profile if volunteer or NGO
        if (input.role === 'VOLUNTEER') {
            await pool.query(`INSERT INTO volunteer_profiles (user_id, volunteer_type) VALUES ($1, 'INDEPENDENT')`, [user.id]);
        }
        else if (input.role === 'NGO') {
            await pool.query('INSERT INTO ngo_profiles (user_id, org_name) VALUES ($1, $2)', [user.id, input.name]);
        }
        const token = this.generateToken(user.id, input.role, roleId, user.name, 'ACTIVE');
        return {
            user: { ...user, role: input.role },
            token,
        };
    }
    /**
     * Login with email/phone + password.
     */
    async login(input) {
        const identifier = input.email || input.phone;
        const field = input.email ? 'email' : 'phone';
        const result = await pool.query(`SELECT u.id, u.email, u.phone, u.name, u.password_hash, u.role_id, u.status, r.name AS role
       FROM users u
       JOIN roles r ON r.id = u.role_id
       WHERE u.${field} = $1 AND u.deleted_at IS NULL`, [identifier]);
        if (result.rows.length === 0) {
            throw createError('Invalid credentials', 401);
        }
        const user = result.rows[0];
        if (user.status === 'SUSPENDED') {
            throw createError('Your account has been suspended. Please contact support.', 403);
        }
        const isValidPassword = await bcrypt.compare(input.password, user.password_hash);
        if (!isValidPassword) {
            throw createError('Invalid credentials', 401);
        }
        const token = this.generateToken(user.id, user.role, user.role_id, user.name, user.status);
        return {
            user: {
                id: user.id,
                email: user.email,
                phone: user.phone,
                name: user.name,
                role: user.role,
            },
            token,
        };
    }
    /**
     * Get user profile by ID.
     */
    async getProfile(userId) {
        const result = await pool.query(`SELECT u.id, u.email, u.phone, u.name, u.cnic, u.locale, u.created_at,
              r.name AS role
       FROM users u
       JOIN roles r ON r.id = u.role_id
       WHERE u.id = $1 AND u.deleted_at IS NULL`, [userId]);
        if (result.rows.length === 0) {
            throw createError('User not found', 404);
        }
        return result.rows[0];
    }
    /**
     * Generate JWT token.
     */
    generateToken(id, role, role_id, name, status) {
        return jwt.sign({ id, role, role_id, name, status }, env.JWT_SECRET, {
            expiresIn: env.JWT_EXPIRES_IN,
        });
    }
}
export const authService = new AuthService();
//# sourceMappingURL=auth.service.js.map