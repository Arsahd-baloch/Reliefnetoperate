/**
 * System State Engine — global behavioral modifier for the entire platform.
 *
 * KNOWN LIMITATION: Task *creation* (POST /tasks) does not route through the
 * admin command layer, so DISASTER_MODE "task creation → priority only" cannot
 * be enforced here. Only task *updates* (UPDATE_TASK) are gated. Add a command-
 * layer hook in tasks.controller if that restriction is needed in a future phase.
 */
export type SystemState = 'NORMAL' | 'HIGH_LOAD' | 'DISASTER_MODE' | 'LOCKDOWN';
export type AdminCommandType = 'APPROVE_DONATION' | 'REJECT_DONATION' | 'APPROVE_WITHDRAWAL' | 'REJECT_WITHDRAWAL' | 'SUSPEND_USER' | 'REACTIVATE_USER' | 'UPDATE_CAMPAIGN_STATUS' | 'UPDATE_TASK' | 'VERIFY_DELIVERY' | 'SET_SYSTEM_STATE';
/**
 * Policy matrix: which command types are allowed in each system state.
 * 'ALL' = no restriction. A Set = only those types pass.
 *
 * SET_SYSTEM_STATE must appear in every restricted-mode set so admin can
 * always transition out of LOCKDOWN or DISASTER_MODE.
 */
export declare const STATE_POLICY: Record<SystemState, 'ALL' | Set<AdminCommandType>>;
export declare const BLOCKED_CATEGORIES: Record<SystemState, string[]>;
export declare const STATE_DESCRIPTIONS: Record<SystemState, string>;
//# sourceMappingURL=system.state.d.ts.map