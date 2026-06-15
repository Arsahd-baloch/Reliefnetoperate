/**
 * Role-based authorization middleware factory.
 * Usage: authorize('ADMIN', 'NGO')
 */
export function authorize(...allowedRoles) {
    return (req, res, next) => {
        if (!req.user) {
            res.status(401).json({ error: 'Authentication required' });
            return;
        }
        if (!allowedRoles.includes(req.user.role)) {
            res.status(403).json({
                error: 'Insufficient permissions',
                required: allowedRoles,
                current: req.user.role,
            });
            return;
        }
        next();
    };
}
//# sourceMappingURL=authorize.js.map