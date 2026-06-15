import { SetSystemStateCommand } from './admin.command.types.js';
export declare function handleSetSystemStateCommand(command: SetSystemStateCommand): Promise<{
    previous_state: import("../../system/state/system.state.js").SystemState;
    current_state: import("../../system/state/system.state.js").SystemState;
}>;
//# sourceMappingURL=set-system-state.command.d.ts.map