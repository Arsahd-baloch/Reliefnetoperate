import { executeAdminCommand } from '../../admin/commands/admin.command.router.js';
import { systemStateService } from '../../system/state/system.state.service.js';
import { STATE_DESCRIPTIONS } from '../../system/state/system.state.js';
export class AdminSystemController {
    async getSystemState(_req, res, next) {
        try {
            const state = systemStateService.getCurrentState();
            res.json({
                state,
                description: STATE_DESCRIPTIONS[state],
                allowed_actions: systemStateService.getAllowedActions(),
                blocked_categories: systemStateService.getBlockedCategories(),
            });
        }
        catch (err) {
            next(err);
        }
    }
    async setSystemState(req, res, next) {
        try {
            if (!req.user) {
                res.status(401).json({ error: 'Auth required' });
                return;
            }
            const { state, reason } = req.body;
            const result = await executeAdminCommand({
                type: 'SET_SYSTEM_STATE',
                actorAdminId: req.user.id,
                targetId: 0,
                metadata: { state, reason },
            });
            res.json(result);
        }
        catch (err) {
            next(err);
        }
    }
}
export const adminSystemController = new AdminSystemController();
//# sourceMappingURL=admin.system.controller.js.map