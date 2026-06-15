import { adminSnapshotService } from './admin.snapshot.service.js';
export class AdminSnapshotController {
    async getSystemSnapshot(_req, res, next) {
        try {
            const snapshot = await adminSnapshotService.getSystemSnapshot();
            res.json(snapshot);
        }
        catch (err) {
            next(err);
        }
    }
    async getOperationalOverview(_req, res, next) {
        try {
            const overview = await adminSnapshotService.getOperationalOverview();
            res.json(overview);
        }
        catch (err) {
            next(err);
        }
    }
}
export const adminSnapshotController = new AdminSnapshotController();
//# sourceMappingURL=admin.snapshot.controller.js.map