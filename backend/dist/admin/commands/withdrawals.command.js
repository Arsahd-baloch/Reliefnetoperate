import { withdrawalsService } from '../../modules/withdrawals/withdrawals.service.js';
export async function handleWithdrawalCommand(command) {
    if (command.type === 'APPROVE_WITHDRAWAL') {
        return withdrawalsService.approveWithdrawal(command.targetId, command.actorAdminId, command.ipAddress);
    }
    return withdrawalsService.rejectWithdrawal(command.targetId, command.actorAdminId, command.ipAddress);
}
//# sourceMappingURL=withdrawals.command.js.map