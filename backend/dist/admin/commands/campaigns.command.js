import { campaignsService } from '../../modules/campaigns/campaigns.service.js';
export async function handleCampaignCommand(command) {
    return campaignsService.update(command.targetId, { status: command.metadata.status }, command.actorAdminId, command.ipAddress, 'ADMIN');
}
//# sourceMappingURL=campaigns.command.js.map