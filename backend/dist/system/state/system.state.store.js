import { pool } from '../../config/database.js';
import { logger } from '../../common/logger.js';
const VALID_STATES = ['NORMAL', 'HIGH_LOAD', 'DISASTER_MODE', 'LOCKDOWN'];
class SystemStateStore {
    current = 'NORMAL';
    lastUpdatedAt = null;
    recoveryStatus = 'ok';
    persistenceSource = 'default';
    /**
     * Called once at server startup. Reads persisted state from DB.
     * Falls back to NORMAL on any error — never throws.
     */
    async load() {
        await this.ensureTable();
        try {
            const result = await pool.query(`SELECT value FROM system_config WHERE key = 'system_state'`);
            if (result.rows.length === 0) {
                await this.persist('NORMAL');
                this.persistenceSource = 'default';
                this.recoveryStatus = 'ok';
                logger.info('[SystemState] No persisted state found — initialized to NORMAL');
                return;
            }
            const record = result.rows[0].value;
            if (!record || !VALID_STATES.includes(record.state)) {
                this.recoveryStatus = 'repaired';
                this.persistenceSource = 'database';
                console.warn('[SystemState] Corrupted persisted state — reset to NORMAL');
                await this.persist('NORMAL');
                return;
            }
            this.current = record.state;
            this.lastUpdatedAt = record.updated_at ?? null;
            this.persistenceSource = 'database';
            this.recoveryStatus = 'ok';
            logger.info(`[SystemState] Hydrated from DB: state=${this.current}` +
                (this.lastUpdatedAt ? ` last_updated=${this.lastUpdatedAt}` : ''));
            if (record.state !== 'NORMAL' && record.updated_by) {
                await this.writeRestoreAudit(record.state, record.updated_by, record.reason);
            }
        }
        catch (err) {
            this.recoveryStatus = 'fallback';
            this.persistenceSource = 'default';
            console.error('[SystemState] DB unavailable during hydration — fallback to NORMAL:', err);
        }
    }
    async ensureTable() {
        try {
            await pool.query(`
        CREATE TABLE IF NOT EXISTS system_config (
          key        VARCHAR(100) PRIMARY KEY,
          value      JSONB NOT NULL,
          updated_at TIMESTAMPTZ DEFAULT NOW()
        )
      `);
        }
        catch (err) {
            console.warn('[SystemState] Could not ensure system_config table:', err);
        }
    }
    getState() {
        return this.current;
    }
    getLastUpdatedAt() {
        return this.lastUpdatedAt;
    }
    getRecoveryStatus() {
        return this.recoveryStatus;
    }
    getPersistenceSource() {
        return this.persistenceSource;
    }
    /**
     * DB-first update: writes to DB before touching in-memory state.
     * Throws on DB failure — caller's memory is NOT updated.
     */
    async setState(newState, updatedBy, reason) {
        await this.persist(newState, updatedBy, reason);
        // app_config table has been removed in migration 003 — no backward-compat sync needed
        this.current = newState;
        this.lastUpdatedAt = new Date().toISOString();
        this.persistenceSource = 'database';
        this.recoveryStatus = 'ok';
    }
    async persist(state, updatedBy, reason) {
        const record = {
            state,
            updated_at: new Date().toISOString(),
            ...(updatedBy !== undefined && { updated_by: updatedBy }),
            ...(reason !== undefined && { reason }),
        };
        await pool.query(`INSERT INTO system_config (key, value, updated_at)
       VALUES ('system_state', $1::jsonb, NOW())
       ON CONFLICT (key) DO UPDATE
         SET value      = EXCLUDED.value,
             updated_at = EXCLUDED.updated_at`, [JSON.stringify(record)]);
    }
    async writeRestoreAudit(restoredState, actorAdminId, reason) {
        try {
            await pool.query(`INSERT INTO audit_logs (admin_id, action_type, target_entity, target_id, metadata)
         VALUES ($1, 'SYSTEM_STATE_RESTORED', 'system', 0, $2)`, [
                actorAdminId,
                JSON.stringify({
                    restored_state: restoredState,
                    source: 'startup_hydration',
                    reason: reason ?? null,
                    timestamp: new Date().toISOString(),
                }),
            ]);
        }
        catch {
            // best-effort — FK may reject if admin was later deleted
        }
    }
}
export const systemStateStore = new SystemStateStore();
//# sourceMappingURL=system.state.store.js.map