import { adminService } from './admin.service.js';
import { mapDonationList } from '../../common/mappers/donation.mapper.js';
import { mapWithdrawalList } from '../../common/mappers/withdrawal.mapper.js';
import { mapCampaignList } from '../../common/mappers/campaign.mapper.js';
import { mapUserList } from '../../common/mappers/user.mapper.js';
import { createError } from '../../middleware/errorHandler.js';
import { executeAdminCommand } from '../../admin/commands/admin.command.router.js';
export class AdminController {
    getPaginationOptions(req) {
        return {
            page: req.query.page ? parseInt(req.query.page, 10) : 1,
            limit: req.query.limit ? parseInt(req.query.limit, 10) : 10,
            sortField: req.query.sortField,
            sortOrder: req.query.sortOrder?.toUpperCase() === 'ASC' ? 'ASC' : 'DESC'
        };
    }
    async getDonationStats(_req, res, next) {
        try {
            const stats = await adminService.getDonationStats();
            res.json({
                total_count: Number(stats.total_count),
                total_amount: parseFloat(stats.total_amount || 0),
                pending_count: Number(stats.pending_count),
                confirmed_count: Number(stats.confirmed_count),
                rejected_count: Number(stats.rejected_count),
                disputed_count: Number(stats.disputed_count)
            });
        }
        catch (err) {
            next(err);
        }
    }
    async getWithdrawalStats(_req, res, next) {
        try {
            const stats = await adminService.getWithdrawalStats();
            res.json({
                total_count: Number(stats.total_count),
                total_amount: parseFloat(stats.total_amount || 0),
                pending_count: Number(stats.pending_count),
                approved_count: Number(stats.approved_count),
                rejected_count: Number(stats.rejected_count),
                flagged_count: Number(stats.flagged_count)
            });
        }
        catch (err) {
            next(err);
        }
    }
    async getCampaignStats(_req, res, next) {
        try {
            const stats = await adminService.getCampaignStats();
            res.json({
                total_count: Number(stats.total_count),
                active_count: Number(stats.active_count),
                total_raised: parseFloat(stats.total_raised || 0),
                total_target: parseFloat(stats.total_target || 0)
            });
        }
        catch (err) {
            next(err);
        }
    }
    async getUserStats(_req, res, next) {
        try {
            const stats = await adminService.getUserStats();
            res.json({
                total_count: Number(stats.total_count),
                admin_count: Number(stats.admin_count),
                ngo_count: Number(stats.ngo_count),
                volunteer_count: Number(stats.volunteer_count),
                coordinator_count: Number(stats.coordinator_count),
                donor_count: Number(stats.donor_count),
                beneficiary_count: Number(stats.beneficiary_count),
                pending_ngo_count: Number(stats.pending_ngo_count)
            });
        }
        catch (err) {
            next(err);
        }
    }
    async listDonations(req, res, next) {
        try {
            const status = req.query.status;
            const options = this.getPaginationOptions(req);
            const { items, total } = await adminService.getAllDonations(status, options);
            res.json({
                ...mapDonationList(items),
                meta: { total, ...options }
            });
        }
        catch (err) {
            next(err);
        }
    }
    async listWithdrawals(req, res, next) {
        try {
            const status = req.query.status;
            const options = this.getPaginationOptions(req);
            const { items, total } = await adminService.getAllWithdrawals(status, options);
            res.json({
                ...mapWithdrawalList(items),
                meta: { total, ...options }
            });
        }
        catch (err) {
            next(err);
        }
    }
    async listCampaigns(req, res, next) {
        try {
            const options = this.getPaginationOptions(req);
            const { items, total } = await adminService.getAllCampaigns(options);
            res.json({
                ...mapCampaignList(items),
                meta: { total, ...options }
            });
        }
        catch (err) {
            next(err);
        }
    }
    async listUsers(req, res, next) {
        try {
            const options = this.getPaginationOptions(req);
            const { items, total } = await adminService.getAllUsers(options);
            res.json({
                ...mapUserList(items),
                meta: { total, ...options }
            });
        }
        catch (err) {
            next(err);
        }
    }
    async getAuditLogs(req, res, next) {
        try {
            const options = this.getPaginationOptions(req);
            const filters = {
                admin_id: req.query.admin_id ? parseInt(req.query.admin_id, 10) : undefined,
                action_type: req.query.action_type,
                target_entity: req.query.target_entity,
                target_id: req.query.target_id ? parseInt(req.query.target_id, 10) : undefined,
                from_date: req.query.from_date,
                to_date: req.query.to_date,
            };
            // Support metadata filtering like ?meta_outcome=FLAGGED
            const metadata_filter = {};
            Object.keys(req.query).forEach(key => {
                if (key.startsWith('meta_')) {
                    metadata_filter[key.replace('meta_', '')] = req.query[key];
                }
            });
            const { items, total } = await adminService.getAuditLogs(options, { ...filters, metadata_filter });
            res.json({
                data: items.map(l => ({
                    ...l,
                    id: Number(l.id),
                    admin_id: Number(l.admin_id),
                    target_id: Number(l.target_id),
                    created_at: new Date(l.created_at).toISOString()
                })),
                meta: { total, ...options }
            });
        }
        catch (err) {
            next(err);
        }
    }
    async getNgoDetail(req, res, next) {
        try {
            const id = parseInt(req.params.id, 10);
            const result = await adminService.getNgoDetail(id);
            res.json({ data: result });
        }
        catch (err) {
            next(err);
        }
    }
    async getDonationTrace(req, res, next) {
        try {
            const id = parseInt(req.params.id, 10);
            const result = await adminService.getDonationTrace(id);
            res.json({ data: result });
        }
        catch (err) {
            next(err);
        }
    }
    // --- Bulk Operations ---
    async processBulkAction(ids, actionFn) {
        if (!Array.isArray(ids) || ids.length === 0) {
            throw createError('No IDs provided for bulk action', 400);
        }
        if (ids.length > 50) {
            throw createError('Maximum bulk action size is 50 items', 400);
        }
        const success = [];
        const failed = [];
        for (const id of ids) {
            try {
                await actionFn(id);
                success.push(id);
            }
            catch (err) {
                failed.push({ id, reason: err.message || 'Action failed' });
            }
        }
        return {
            total: ids.length,
            success,
            failed
        };
    }
    async bulkVerifyNgo(req, res, next) {
        try {
            const { ngo_ids, action } = req.body;
            const adminId = req.user.id;
            const ip = req.ip || 'unknown';
            if (action !== 'VERIFY')
                throw createError('Invalid action', 400);
            const results = await this.processBulkAction(ngo_ids, (id) => adminService.verifyNgo(id, adminId, ip));
            res.json(results);
        }
        catch (err) {
            next(err);
        }
    }
    async bulkDonationAction(req, res, next) {
        try {
            const { donation_ids, action } = req.body;
            const adminId = req.user.id;
            const ip = req.ip || 'unknown';
            const type = action === 'APPROVE' ? 'APPROVE_DONATION' : 'REJECT_DONATION';
            const results = await this.processBulkAction(donation_ids, (id) => executeAdminCommand({
                type: type,
                actorAdminId: adminId,
                targetId: id,
                ipAddress: ip,
                metadata: { reason: 'Bulk action' }
            }));
            res.json(results);
        }
        catch (err) {
            next(err);
        }
    }
    async bulkUserStatus(req, res, next) {
        try {
            const { user_ids, status } = req.body;
            const adminId = req.user.id;
            const ip = req.ip || 'unknown';
            const type = status === 'SUSPENDED' ? 'SUSPEND_USER' : 'REACTIVATE_USER';
            const results = await this.processBulkAction(user_ids, (id) => executeAdminCommand({
                type: type,
                actorAdminId: adminId,
                targetId: id,
                ipAddress: ip,
                metadata: { reason: 'Bulk action' }
            }));
            res.json(results);
        }
        catch (err) {
            next(err);
        }
    }
    async bulkCampaignStatus(req, res, next) {
        try {
            const { campaign_ids, status } = req.body;
            const adminId = req.user.id;
            const ip = req.ip || 'unknown';
            const results = await this.processBulkAction(campaign_ids, (id) => executeAdminCommand({
                type: 'UPDATE_CAMPAIGN_STATUS',
                actorAdminId: adminId,
                targetId: id,
                ipAddress: ip,
                metadata: { status }
            }));
            res.json(results);
        }
        catch (err) {
            next(err);
        }
    }
    // --- NGO Verification ---
    async listPendingNgos(_req, res, next) {
        try {
            const ngos = await adminService.getPendingNgos();
            res.json({ data: ngos });
        }
        catch (err) {
            next(err);
        }
    }
    async verifyNgo(req, res, next) {
        try {
            const id = parseInt(req.params.id, 10);
            const adminId = req.user.id;
            const ip = req.ip || 'unknown';
            const result = await adminService.verifyNgo(id, adminId, ip);
            res.json({ message: 'NGO verified successfully', data: result });
        }
        catch (err) {
            next(err);
        }
    }
    async rejectNgo(req, res, next) {
        try {
            const id = parseInt(req.params.id, 10);
            const adminId = req.user.id;
            const { reason } = req.body;
            const ip = req.ip || 'unknown';
            const result = await adminService.rejectNgo(id, adminId, reason || 'No reason provided', ip);
            res.json({ message: 'NGO rejected', data: result });
        }
        catch (err) {
            next(err);
        }
    }
    // --- Financial Safety ---
    async flagDonation(req, res, next) {
        try {
            const id = parseInt(req.params.id, 10);
            const adminId = req.user.id;
            const { reason } = req.body;
            const ip = req.ip || 'unknown';
            const result = await adminService.flagDonation(id, adminId, reason, ip);
            res.json({ message: 'Donation flagged for review', data: result });
        }
        catch (err) {
            next(err);
        }
    }
    async flagWithdrawal(req, res, next) {
        try {
            const id = parseInt(req.params.id, 10);
            const adminId = req.user.id;
            const { reason } = req.body;
            const ip = req.ip || 'unknown';
            const result = await adminService.flagWithdrawal(id, adminId, reason, ip);
            res.json({ message: 'Withdrawal flagged for review', data: result });
        }
        catch (err) {
            next(err);
        }
    }
    async getLedger(_req, res, next) {
        try {
            const ledger = await adminService.getLedger();
            res.json({
                data: {
                    donations: ledger.donations.map(d => ({
                        ...d,
                        id: Number(d.id),
                        amount_pkr: parseFloat(d.amount_pkr),
                        created_at: new Date(d.created_at).toISOString()
                    })),
                    withdrawals: ledger.withdrawals.map(w => ({
                        ...w,
                        id: Number(w.id),
                        amount: parseFloat(w.amount),
                        created_at: new Date(w.created_at).toISOString()
                    })),
                    campaigns: ledger.campaigns.map(c => ({
                        ...c,
                        id: Number(c.id),
                        goal_pkr: parseFloat(c.goal_pkr),
                        raised_pkr: parseFloat(c.raised_pkr),
                        spent_pkr: parseFloat(c.spent_pkr),
                        remaining_balance: parseFloat(c.remaining_balance)
                    }))
                },
                meta: {}
            });
        }
        catch (err) {
            next(err);
        }
    }
    async getMapData(_req, res, next) {
        try {
            const data = await adminService.getMapData();
            res.json({
                data: {
                    tasks: data.tasks.map(t => ({
                        ...t,
                        id: Number(t.id),
                        longitude: parseFloat(t.longitude),
                        latitude: parseFloat(t.latitude)
                    })),
                    volunteers: data.volunteers.map(v => ({
                        ...v,
                        user_id: Number(v.user_id),
                        longitude: parseFloat(v.longitude),
                        latitude: parseFloat(v.latitude)
                    }))
                }
            });
        }
        catch (err) {
            next(err);
        }
    }
}
export const adminController = new AdminController();
//# sourceMappingURL=admin.controller.js.map