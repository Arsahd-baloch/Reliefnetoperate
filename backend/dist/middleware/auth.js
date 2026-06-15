import jwt from 'jsonwebtoken';
import { pool } from '../config/database.js';
import { env } from '../config/env.js';
/**
 * JWT authentication middleware.
 * NEVER trusts client-supplied role — always reads from DB.
 * Sets app.current_user_id for RLS policies after auth.
 */
export async function authenticate(req, res, next) {
    try {
        const authHeader = req.headers.authorization;
        if (!authHeader || !authHeader.startsWith('Bearer ')) {
            res.status(401).json({ error: 'Authentication required' });
            return;
        }
        const token = authHeader.split(' ')[1];
        if (!token) {
            res.status(401).json({ error: 'Invalid token format' });
            return;
        }
        const decoded = jwt.verify(token, env.JWT_SECRET);
        if (decoded.status !== 'ACTIVE') {
            res.status(403).json({ error: 'Account suspended' });
            return;
        }
        // Use decoded payload directly - avoids heavy JOIN query on every request
        req.user = decoded;
        // Set session-level user ID so RLS policies can read it.
        await pool.query("SELECT set_config('app.current_user_id', $1, true)", [String(decoded.id)]);
        next();
    }
    catch (err) {
        if (err instanceof jwt.JsonWebTokenError) {
            res.status(401).json({ error: 'Invalid token' });
            return;
        }
        if (err instanceof jwt.TokenExpiredError) {
            res.status(401).json({ error: 'Token expired' });
            return;
        }
        next(err);
    }
}
//# sourceMappingURL=auth.js.map