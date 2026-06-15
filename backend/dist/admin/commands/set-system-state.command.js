import { systemStateService } from '../../system/state/system.state.service.js';
export async function handleSetSystemStateCommand(command) {
    return systemStateService.setState(command.metadata.state, command.actorAdminId, command.metadata.reason);
}
//# sourceMappingURL=set-system-state.command.js.map