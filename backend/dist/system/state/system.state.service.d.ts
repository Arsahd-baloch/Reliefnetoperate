import { AdminCommandType, SystemState } from './system.state.js';
declare class SystemStateService {
    getCurrentState(): SystemState;
    isAllowed(commandType: AdminCommandType): boolean;
    getBlockedCategories(): string[];
    getAllowedActions(): 'ALL' | AdminCommandType[];
    setState(newState: SystemState, actorAdminId: number, reason?: string): Promise<{
        previous_state: SystemState;
        current_state: SystemState;
    }>;
    private writeTransitionAudit;
}
export declare const systemStateService: SystemStateService;
export {};
//# sourceMappingURL=system.state.service.d.ts.map