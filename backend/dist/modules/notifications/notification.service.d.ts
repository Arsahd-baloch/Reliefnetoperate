export interface NotificationPayload {
    type: string;
    taskId: number;
    title: string;
    message: string;
    timestamp: string;
}
/**
 * Service to handle system notifications via Socket.IO.
 */
export declare class NotificationService {
    /**
     * Notify a beneficiary about a task status update.
     */
    notifyTaskUpdate(beneficiaryId: number, taskId: number, taskTitle: string, status: string): void;
    /**
     * Notify a beneficiary when their task is claimed by a volunteer.
     */
    notifyTaskClaimed(beneficiaryId: number, taskId: number, taskTitle: string, volunteerName: string): void;
    /**
     * Notify a beneficiary when a delivery is submitted.
     */
    notifyDeliverySubmitted(beneficiaryId: number, taskId: number, taskTitle: string): void;
    /**
     * Notify a coordinator about a critical update in their scope.
     */
    notifyCoordinatorTaskUpdate(coordinatorId: number, taskId: number, taskTitle: string, event: string): void;
    /**
     * Notify a donor about a new item request.
     */
    notifyInKindRequest(donorId: number, donationId: number, donationTitle: string, beneficiaryName: string): void;
    /**
     * Notify a beneficiary that their item request was accepted.
     */
    notifyInKindAccepted(beneficiaryId: number, donationId: number, donationTitle: string): void;
    /**
     * Notify a beneficiary that their item request was rejected.
     */
    notifyInKindRejected(beneficiaryId: number, donationId: number, donationTitle: string): void;
    /**
     * Notify a donor that the beneficiary has confirmed receipt.
     */
    notifyInKindCompleted(donorId: number, donationId: number, donationTitle: string): void;
    /**
     * Notify a volunteer that a task has been assigned to them by an admin.
     */
    notifyTaskAssigned(volunteerId: number, taskId: number, taskTitle: string): void;
    /**
     * Notify admin about an emergency escalation.
     */
    notifyAdminEmergency(adminId: number, targetId: number, reason: string): void;
}
export declare const notificationService: NotificationService;
//# sourceMappingURL=notification.service.d.ts.map