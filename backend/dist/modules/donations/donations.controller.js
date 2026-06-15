import { donationsService } from './donations.service.js';
import { mapDonation, mapDonationList } from '../../common/mappers/donation.mapper.js';
import { executeAdminCommand } from '../../admin/commands/admin.command.router.js';
export class DonationsController {
    async create(req, res, next) {
        try {
            if (!req.user) {
                res.status(401).json({ error: 'Auth required' });
                return;
            }
            const donation = await donationsService.createDonation(req.body, req.user.id);
            res.status(201).json(mapDonation(donation));
        }
        catch (err) {
            next(err);
        }
    }
    async createStripeSession(req, res, next) {
        try {
            if (!req.user) {
                res.status(401).json({ error: 'Auth required' });
                return;
            }
            const session = await donationsService.createStripeSession(req.body, req.user.id);
            res.status(201).json(session);
        }
        catch (err) {
            next(err);
        }
    }
    async handleWebhook(req, res, next) {
        try {
            const signature = req.headers['stripe-signature'];
            const result = await donationsService.handleStripeWebhook(signature, req.rawBody);
            res.json(result);
        }
        catch (err) {
            next(err);
        }
    }
    async approve(req, res, next) {
        try {
            if (!req.user) {
                res.status(401).json({ error: 'Auth required' });
                return;
            }
            const id = parseInt(req.params.id, 10);
            const result = await executeAdminCommand({
                type: 'APPROVE_DONATION',
                actorAdminId: req.user.id,
                targetId: id,
                ipAddress: req.ip,
                role: req.user.role
            });
            res.json(mapDonation(result));
        }
        catch (err) {
            next(err);
        }
    }
    async reject(req, res, next) {
        try {
            if (!req.user) {
                res.status(401).json({ error: 'Auth required' });
                return;
            }
            const id = parseInt(req.params.id, 10);
            const result = await executeAdminCommand({
                type: 'REJECT_DONATION',
                actorAdminId: req.user.id,
                targetId: id,
                ipAddress: req.ip,
                role: req.user.role
            });
            res.json(mapDonation(result));
        }
        catch (err) {
            next(err);
        }
    }
    async getMyDonations(req, res, next) {
        try {
            if (!req.user) {
                res.status(401).json({ error: 'Auth required' });
                return;
            }
            const donations = await donationsService.getDonationsByDonor(req.user.id);
            res.json(mapDonationList(donations));
        }
        catch (err) {
            next(err);
        }
    }
    async getByCampaign(req, res, next) {
        try {
            const campaignId = parseInt(req.params.campaignId, 10);
            const donations = await donationsService.getDonationsByCampaign(campaignId);
            res.json(mapDonationList(donations));
        }
        catch (err) {
            next(err);
        }
    }
    async getNgoDonations(req, res, next) {
        try {
            if (!req.user) {
                res.status(401).json({ error: 'Auth required' });
                return;
            }
            const status = req.query.status;
            const donations = await donationsService.getDonationsByNgo(req.user.id, status);
            res.json(mapDonationList(donations));
        }
        catch (err) {
            next(err);
        }
    }
}
export const donationsController = new DonationsController();
//# sourceMappingURL=donations.controller.js.map