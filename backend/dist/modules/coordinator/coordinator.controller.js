import { coordinatorService } from './coordinator.service.js';
export class CoordinatorController {
    async listVolunteers(req, res, next) {
        try {
            if (!req.user)
                return;
            const volunteers = await coordinatorService.getVolunteersInScope(req.user.id);
            res.json({ data: volunteers });
        }
        catch (err) {
            next(err);
        }
    }
}
export const coordinatorController = new CoordinatorController();
//# sourceMappingURL=coordinator.controller.js.map