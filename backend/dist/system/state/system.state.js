/**
 * System State Engine — global behavioral modifier for the entire platform.
 *
 * KNOWN LIMITATION: Task *creation* (POST /tasks) does not route through the
 * admin command layer, so DISASTER_MODE "task creation → priority only" cannot
 * be enforced here. Only task *updates* (UPDATE_TASK) are gated. Add a command-
 * layer hook in tasks.controller if that restriction is needed in a future phase.
 */
/**
 * Policy matrix: which command types are allowed in each system state.
 * 'ALL' = no restriction. A Set = only those types pass.
 *
 * SET_SYSTEM_STATE must appear in every restricted-mode set so admin can
 * always transition out of LOCKDOWN or DISASTER_MODE.
 */
export const STATE_POLICY = {
    NORMAL: 'ALL',
    HIGH_LOAD: 'ALL',
    DISASTER_MODE: new Set([
        'APPROVE_DONATION',
        'REJECT_DONATION',
        'SUSPEND_USER',
        'REACTIVATE_USER',
        'VERIFY_DELIVERY',
        'SET_SYSTEM_STATE',
    ]),
    LOCKDOWN: new Set([
        'SUSPEND_USER',
        'REACTIVATE_USER',
        'SET_SYSTEM_STATE',
    ]),
};
export const BLOCKED_CATEGORIES = {
    NORMAL: [],
    HIGH_LOAD: [],
    DISASTER_MODE: ['withdrawals', 'campaign_status_updates', 'task_updates'],
    LOCKDOWN: ['donations', 'withdrawals', 'campaign_status_updates', 'task_updates', 'delivery_verification'],
};
export const STATE_DESCRIPTIONS = {
    NORMAL: 'All platform operations running normally.',
    HIGH_LOAD: 'Elevated load detected — all operations permitted, extra telemetry active.',
    DISASTER_MODE: 'Disaster active — donations and emergency admin actions only; withdrawals and task mutations blocked.',
    LOCKDOWN: 'Full lockdown — only user suspension/reactivation and state transitions permitted.',
};
//# sourceMappingURL=system.state.js.map