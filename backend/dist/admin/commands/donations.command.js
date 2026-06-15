import { donationsService } from '../../modules/donations/donations.service.js';
export async function handleDonationCommand(command) {
    if (command.type === 'APPROVE_DONATION') {
        return donationsService.approveDonation(command.targetId, command.actorAdminId, command.ipAddress, command.role);
    }
    return donationsService.rejectDonation(command.targetId, command.actorAdminId, command.ipAddress, command.role);
}
//# sourceMappingURL=donations.command.js.map