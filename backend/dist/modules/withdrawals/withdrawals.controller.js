import { withdrawalsService } from './withdrawals.service.js';
import { mapWithdrawal, mapWithdrawalList } from '../../common/mappers/withdrawal.mapper.js';
import { executeAdminCommand } from '../../admin/commands/admin.command.router.js';
export class WithdrawalsController {
    async create(req, res, next) {
        try {
            if (!req.user) {
                res.status(401).json({ error: 'Auth required' });
                return;
            }
            const withdrawal = await withdrawalsService.createWithdrawal(req.body, req.user.id);
            res.status(201).json(mapWithdrawal(withdrawal));
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
            const result = await executeAdminCommand({ type: 'APPROVE_WITHDRAWAL', actorAdminId: req.user.id, targetId: id, ipAddress: req.ip });
            res.json(mapWithdrawal(result));
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
            const result = await executeAdminCommand({ type: 'REJECT_WITHDRAWAL', actorAdminId: req.user.id, targetId: id, ipAddress: req.ip });
            res.json(mapWithdrawal(result));
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
            const withdrawals = await withdrawalsService.getWithdrawalsByNgo(req.user.id);
            res.json(mapWithdrawalList(withdrawals));
        }
        catch (err) {
            next(err);
        }
    }
}
export const withdrawalsController = new WithdrawalsController();
//# sourceMappingURL=withdrawals.controller.js.map