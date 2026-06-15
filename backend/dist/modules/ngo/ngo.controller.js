import { ngoService } from './ngo.service.js';
import { mapCampaignList } from '../../common/mappers/campaign.mapper.js';
export class NgoController {
    async getDashboardStats(req, res, next) {
        try {
            if (!req.user)
                return;
            const stats = await ngoService.getDashboardStats(req.user.id);
            res.json({ data: stats });
        }
        catch (err) {
            next(err);
        }
    }
    async getProfile(req, res, next) {
        try {
            if (!req.user)
                return;
            const profile = await ngoService.getProfile(req.user.id);
            res.json({ data: profile });
        }
        catch (err) {
            next(err);
        }
    }
    async updateProfile(req, res, next) {
        try {
            if (!req.user)
                return;
            const profile = await ngoService.updateProfile(req.user.id, req.body);
            res.json({ data: profile });
        }
        catch (err) {
            next(err);
        }
    }
    async getCampaigns(req, res, next) {
        try {
            if (!req.user)
                return;
            const campaigns = await ngoService.getCampaigns(req.user.id);
            res.json(mapCampaignList(campaigns));
        }
        catch (err) {
            next(err);
        }
    }
    async getPublicProfile(req, res, next) {
        try {
            const id = parseInt(req.params.id, 10);
            const profile = await ngoService.getPublicProfile(id);
            res.json({ data: profile });
        }
        catch (err) {
            next(err);
        }
    }
}
export const ngoController = new NgoController();
//# sourceMappingURL=ngo.controller.js.map