import { SystemState } from './system.state.js';
export type RecoveryStatus = 'ok' | 'fallback' | 'repaired';
export type PersistenceSource = 'database' | 'default';
declare class SystemStateStore {
    private current;
    private lastUpdatedAt;
    private recoveryStatus;
    private persistenceSource;
    /**
     * Called once at server startup. Reads persisted state from DB.
     * Falls back to NORMAL on any error — never throws.
     */
    load(): Promise<void>;
    private ensureTable;
    getState(): SystemState;
    getLastUpdatedAt(): string | null;
    getRecoveryStatus(): RecoveryStatus;
    getPersistenceSource(): PersistenceSource;
    /**
     * DB-first update: writes to DB before touching in-memory state.
     * Throws on DB failure — caller's memory is NOT updated.
     */
    setState(newState: SystemState, updatedBy?: number, reason?: string): Promise<void>;
    private persist;
    private writeRestoreAudit;
}
export declare const systemStateStore: SystemStateStore;
export {};
//# sourceMappingURL=system.state.store.d.ts.map