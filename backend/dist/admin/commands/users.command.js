import { pool } from '../../config/database.js';
import { usersService } from '../../modules/users/users.service.js';
async function writeAuditLog(adminId, actionType, targetId, metadata, ipAddress) {
    try {
        await pool.query(`INSERT INTO audit_logs (admin_id, action_type, target_entity, target_id, metadata, ip_address)
       VALUES ($1, $2, 'users', $3, $4, $5)`, [adminId, actionType, targetId, JSON.stringify(metadata), ipAddress || null]);
    }
    catch {
        // best-effort: audit failure does not roll back the committed action
    }
}
export async function handleUserCommand(command) {
    if (command.type === 'SUSPEND_USER') {
        const result = await usersService.suspendUser(command.targetId, command.actorAdminId);
        await writeAuditLog(command.actorAdminId, 'SUSPEND_USER', command.targetId, command.metadata ?? {}, command.ipAddress);
        return result;
    }
    const result = await usersService.reactivateUser(command.targetId);
    await writeAuditLog(command.actorAdminId, 'REACTIVATE_USER', command.targetId, {}, command.ipAddress);
    return result;
}
//# sourceMappingURL=users.command.js.map