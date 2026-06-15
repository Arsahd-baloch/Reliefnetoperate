import { pool } from '../../config/database.js';
import { BLOCKED_CATEGORIES, STATE_DESCRIPTIONS, STATE_POLICY } from './system.state.js';
import { systemStateStore } from './system.state.store.js';
class SystemStateService {
    getCurrentState() {
        return systemStateStore.getState();
    }
    isAllowed(commandType) {
        const policy = STATE_POLICY[this.getCurrentState()];
        if (policy === 'ALL')
            return true;
        return policy.has(commandType);
    }
    getBlockedCategories() {
        return BLOCKED_CATEGORIES[this.getCurrentState()];
    }
    getAllowedActions() {
        const policy = STATE_POLICY[this.getCurrentState()];
        if (policy === 'ALL')
            return 'ALL';
        return Array.from(policy);
    }
    async setState(newState, actorAdminId, reason) {
        const previous = this.getCurrentState();
        // DB-first: throws if write fails — memory stays in previous state
        await systemStateStore.setState(newState, actorAdminId, reason);
        // DB + memory both updated — write audit best-effort
        await this.writeTransitionAudit(previous, newState, actorAdminId, reason);
        return { previous_state: previous, current_state: newState };
    }
    async writeTransitionAudit(previousState, newState, actorAdminId, reason) {
        try {
            await pool.query(`INSERT INTO audit_logs (admin_id, action_type, target_entity, target_id, metadata)
         VALUES ($1, 'SET_SYSTEM_STATE', 'system', 0, $2)`, [
                actorAdminId,
                JSON.stringify({
                    previous_state: previousState,
                    new_state: newState,
                    description: STATE_DESCRIPTIONS[newState],
                    reason: reason ?? null,
                    timestamp: new Date().toISOString(),
                }),
            ]);
        }
        catch {
            // best-effort
        }
    }
}
export const systemStateService = new SystemStateService();
//# sourceMappingURL=system.state.service.js.map