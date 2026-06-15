import { campaignsService } from './campaigns.service.js';
import { createError } from '../../middleware/errorHandler.js';
import { mapCampaign, mapCampaignList } from '../../common/mappers/campaign.mapper.js';
import { executeAdminCommand } from '../../admin/commands/admin.command.router.js';
export class CampaignsController {
    async create(req, res, next) {
        try {
            if (!req.user) {
                res.status(401).json({ error: 'Auth required' });
                return;
            }
            // Get NGO profile if user is NGO
            let ngoId;
            if (req.user.role === 'NGO') {
                const id = await campaignsService.getNgoIdByUserId(req.user.id);
                ngoId = id || undefined;
            }
            const campaign = await campaignsService.create(req.body, req.user.id, ngoId);
            res.status(201).json(mapCampaign(campaign));
        }
        catch (err) {
            next(err);
        }
    }
    async getAll(req, res, next) {
        try {
            const status = req.query.status;
            const campaigns = await campaignsService.getAll(status);
            res.json(mapCampaignList(campaigns));
        }
        catch (err) {
            next(err);
        }
    }
    async getById(req, res, next) {
        try {
            const id = parseInt(req.params.id, 10);
            const campaign = await campaignsService.getById(id);
            res.json(mapCampaign(campaign));
        }
        catch (err) {
            next(err);
        }
    }
    async update(req, res, next) {
        try {
            const id = parseInt(req.params.id, 10);
            const campaign = await campaignsService.update(id, req.body, req.user?.id, req.ip, req.user?.role);
            res.json(mapCampaign(campaign));
        }
        catch (err) {
            next(err);
        }
    }
    async updateStatus(req, res, next) {
        try {
            if (!req.user) {
                res.status(401).json({ error: 'Auth required' });
                return;
            }
            const id = parseInt(req.params.id, 10);
            const { status } = req.body;
            if (!status)
                throw createError('Status is required', 400);
            const campaign = await executeAdminCommand({
                type: 'UPDATE_CAMPAIGN_STATUS',
                actorAdminId: req.user.id,
                targetId: id,
                ipAddress: req.ip,
                metadata: { status }
            });
            res.json(mapCampaign(campaign));
        }
        catch (err) {
            next(err);
        }
    }
}
export const campaignsController = new CampaignsController();
//# sourceMappingURL=campaigns.controller.js.map