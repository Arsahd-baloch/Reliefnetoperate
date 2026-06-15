import { goodsDonationsService } from './goodsDonations.service.js';
export class GoodsDonationsController {
    // ── Donor ──────────────────────────────────────────────────────────────────
    async submit(req, res, next) {
        try {
            if (!req.user) {
                res.status(401).json({ error: 'Auth required' });
                return;
            }
            const donation = await goodsDonationsService.submit(req.body, req.user.id);
            res.status(201).json(donation);
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
            const donations = await goodsDonationsService.getMyDonations(req.user.id);
            res.json({ data: donations });
        }
        catch (err) {
            next(err);
        }
    }
    // ── Shared ─────────────────────────────────────────────────────────────────
    async getById(req, res, next) {
        try {
            const id = parseInt(req.params.id, 10);
            const donation = await goodsDonationsService.getById(id);
            res.json(donation);
        }
        catch (err) {
            next(err);
        }
    }
    // ── Volunteer ──────────────────────────────────────────────────────────────
    async getAvailable(_req, res, next) {
        try {
            const donations = await goodsDonationsService.getAvailable();
            res.json({ data: donations });
        }
        catch (err) {
            next(err);
        }
    }
    async claim(req, res, next) {
        try {
            if (!req.user) {
                res.status(401).json({ error: 'Auth required' });
                return;
            }
            const id = parseInt(req.params.id, 10);
            const donation = await goodsDonationsService.claim(id, req.user.id);
            res.json(donation);
        }
        catch (err) {
            next(err);
        }
    }
    async markDelivered(req, res, next) {
        try {
            if (!req.user) {
                res.status(401).json({ error: 'Auth required' });
                return;
            }
            const id = parseInt(req.params.id, 10);
            const donation = await goodsDonationsService.markDelivered(id, req.user.id, req.body);
            res.json(donation);
        }
        catch (err) {
            next(err);
        }
    }
    // ── Coordinator ────────────────────────────────────────────────────────────
    async getForReview(_req, res, next) {
        try {
            const donations = await goodsDonationsService.getForReview();
            res.json({ data: donations });
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
            const donation = await goodsDonationsService.approve(id, req.user.id);
            res.json(donation);
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
            const donation = await goodsDonationsService.reject(id, req.user.id, req.body);
            res.json(donation);
        }
        catch (err) {
            next(err);
        }
    }
    // ── NGO ────────────────────────────────────────────────────────────────────
    async getNgoDonations(req, res, next) {
        try {
            if (!req.user) {
                res.status(401).json({ error: 'Auth required' });
                return;
            }
            const donations = await goodsDonationsService.getNgoDonations(req.user.id);
            res.json({ data: donations });
        }
        catch (err) {
            next(err);
        }
    }
    // ── Admin ──────────────────────────────────────────────────────────────────
    async getAll(_req, res, next) {
        try {
            const donations = await goodsDonationsService.getAll();
            res.json({ data: donations });
        }
        catch (err) {
            next(err);
        }
    }
    async adminOverride(req, res, next) {
        try {
            if (!req.user) {
                res.status(401).json({ error: 'Auth required' });
                return;
            }
            const id = parseInt(req.params.id, 10);
            const donation = await goodsDonationsService.adminOverride(id, req.user.id, req.body);
            res.json(donation);
        }
        catch (err) {
            next(err);
        }
    }
}
export const goodsDonationsController = new GoodsDonationsController();
//# sourceMappingURL=goodsDonations.controller.js.map