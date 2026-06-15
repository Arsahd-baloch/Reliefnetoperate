import { deliveriesService } from './deliveries.service.js';
import { mapDelivery, mapDeliveryList } from '../../common/mappers/delivery.mapper.js';
import { executeAdminCommand } from '../../admin/commands/admin.command.router.js';
export class DeliveriesController {
    async submit(req, res, next) {
        try {
            if (!req.user) {
                res.status(401).json({ error: 'Auth required' });
                return;
            }
            const delivery = await deliveriesService.submitDelivery(req.body, req.user.id);
            res.status(201).json(mapDelivery(delivery));
        }
        catch (err) {
            next(err);
        }
    }
    async verify(req, res, next) {
        try {
            if (!req.user) {
                res.status(401).json({ error: 'Auth required' });
                return;
            }
            const id = parseInt(req.params.id, 10);
            const body = req.body;
            let result;
            if (req.user.role === 'ADMIN') {
                result = await executeAdminCommand({
                    type: 'VERIFY_DELIVERY',
                    actorAdminId: req.user.id,
                    targetId: id,
                    ipAddress: req.ip,
                    metadata: { verified: body.verified, notes: body.notes },
                });
            }
            else {
                result = await deliveriesService.verifyDelivery(id, req.user.id, body);
            }
            res.json(mapDelivery(result));
        }
        catch (err) {
            next(err);
        }
    }
    async getByTask(req, res, next) {
        try {
            const taskId = parseInt(req.params.taskId, 10);
            const deliveries = await deliveriesService.getByTask(taskId);
            res.json(mapDeliveryList(deliveries));
        }
        catch (err) {
            next(err);
        }
    }
    async beneficiaryConfirm(req, res, next) {
        try {
            if (!req.user) {
                res.status(401).json({ error: 'Auth required' });
                return;
            }
            const deliveryId = parseInt(req.params.id, 10);
            const feedback = await deliveriesService.submitBeneficiaryFeedback(deliveryId, req.user.id, req.body);
            res.status(201).json({ message: 'Feedback submitted', data: feedback });
        }
        catch (err) {
            next(err);
        }
    }
}
export const deliveriesController = new DeliveriesController();
//# sourceMappingURL=deliveries.controller.js.map