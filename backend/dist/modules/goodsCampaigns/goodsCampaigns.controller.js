import { goodsCampaignsService } from './goodsCampaigns.service.js';
export class GoodsCampaignsController {
    async getActive(_req, res, next) {
        try {
            const campaigns = await goodsCampaignsService.getActive();
            res.json({ data: campaigns });
        }
        catch (err) {
            next(err);
        }
    }
    async getById(req, res, next) {
        try {
            const id = parseInt(req.params.id, 10);
            const campaign = await goodsCampaignsService.getById(id);
            res.json(campaign);
        }
        catch (err) {
            next(err);
        }
    }
    async getMine(req, res, next) {
        try {
            if (!req.user) {
                res.status(401).json({ error: 'Auth required' });
                return;
            }
            const campaigns = await goodsCampaignsService.getMine(req.user.id);
            res.json({ data: campaigns });
        }
        catch (err) {
            next(err);
        }
    }
    async create(req, res, next) {
        try {
            if (!req.user) {
                res.status(401).json({ error: 'Auth required' });
                return;
            }
            const campaign = await goodsCampaignsService.create(req.body, req.user.id);
            res.status(201).json(campaign);
        }
        catch (err) {
            next(err);
        }
    }
    async update(req, res, next) {
        try {
            if (!req.user) {
                res.status(401).json({ error: 'Auth required' });
                return;
            }
            const id = parseInt(req.params.id, 10);
            const campaign = await goodsCampaignsService.update(id, req.body, req.user.id);
            res.json(campaign);
        }
        catch (err) {
            next(err);
        }
    }
    async delete(req, res, next) {
        try {
            if (!req.user) {
                res.status(401).json({ error: 'Auth required' });
                return;
            }
            const id = parseInt(req.params.id, 10);
            await goodsCampaignsService.delete(id, req.user.id);
            res.status(204).send();
        }
        catch (err) {
            next(err);
        }
    }
}
export const goodsCampaignsController = new GoodsCampaignsController();
//# sourceMappingURL=goodsCampaigns.controller.js.map