import { executeAdminCommand } from '../../admin/commands/admin.command.router.js';
export class UsersController {
    async suspend(req, res, next) {
        try {
            if (!req.user)
                return;
            const id = parseInt(req.params.id, 10);
            const user = await executeAdminCommand({ type: 'SUSPEND_USER', actorAdminId: req.user.id, targetId: id, ipAddress: req.ip });
            res.json(user);
        }
        catch (err) {
            next(err);
        }
    }
    async reactivate(req, res, next) {
        try {
            if (!req.user)
                return;
            const id = parseInt(req.params.id, 10);
            const user = await executeAdminCommand({ type: 'REACTIVATE_USER', actorAdminId: req.user.id, targetId: id, ipAddress: req.ip });
            res.json(user);
        }
        catch (err) {
            next(err);
        }
    }
}
export const usersController = new UsersController();
//# sourceMappingURL=users.controller.js.map