import { emitToUser } from '../chat/chat.gateway.js';

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
export class NotificationService {
  /**
   * Notify a beneficiary about a task status update.
   */
  notifyTaskUpdate(beneficiaryId: number, taskId: number, taskTitle: string, status: string) {
    const payload: NotificationPayload = {
      type: 'TASK_STATUS_UPDATE',
      taskId,
      title: 'Task Update',
      message: `Your request "${taskTitle}" is now ${status.toLowerCase().replace('_', ' ')}.`,
      timestamp: new Date().toISOString(),
    };
    emitToUser(beneficiaryId, 'notification', payload);
  }

  /**
   * Notify a beneficiary when their task is claimed by a volunteer.
   */
  notifyTaskClaimed(beneficiaryId: number, taskId: number, taskTitle: string, volunteerName: string) {
    const payload: NotificationPayload = {
      type: 'TASK_CLAIMED',
      taskId,
      title: 'Helper Found',
      message: `${volunteerName} has claimed your request "${taskTitle}".`,
      timestamp: new Date().toISOString(),
    };
    emitToUser(beneficiaryId, 'notification', payload);
  }

  /**
   * Notify a beneficiary when a delivery is submitted.
   */
  notifyDeliverySubmitted(beneficiaryId: number, taskId: number, taskTitle: string) {
    const payload: NotificationPayload = {
      type: 'DELIVERY_SUBMITTED',
      taskId,
      title: 'Aid Delivered',
      message: `Items for "${taskTitle}" have been delivered. Please confirm receipt.`,
      timestamp: new Date().toISOString(),
    };
    emitToUser(beneficiaryId, 'notification', payload);
  }

  /**
   * Notify a coordinator about a critical update in their scope.
   */
  notifyCoordinatorTaskUpdate(coordinatorId: number, taskId: number, taskTitle: string, event: string) {
    const payload: NotificationPayload = {
      type: 'TASK_STATUS_UPDATE',
      taskId,
      title: 'Field Update',
      message: `Task "${taskTitle}" is now ${event.toLowerCase().replace('_', ' ')}.`,
      timestamp: new Date().toISOString(),
    };
    emitToUser(coordinatorId, 'notification', payload);
  }

  /**
   * Notify a donor about a new item request.
   */
  notifyInKindRequest(donorId: number, donationId: number, donationTitle: string, beneficiaryName: string) {
    const payload: NotificationPayload = {
      type: 'INKIND_REQUESTED',
      taskId: donationId,
      title: 'New Donation Request',
      message: `${beneficiaryName} has requested your item: "${donationTitle}".`,
      timestamp: new Date().toISOString(),
    };
    emitToUser(donorId, 'notification', payload);
  }

  /**
   * Notify a beneficiary that their item request was accepted.
   */
  notifyInKindAccepted(beneficiaryId: number, donationId: number, donationTitle: string) {
    const payload: NotificationPayload = {
      type: 'INKIND_ACCEPTED',
      taskId: donationId,
      title: 'Item Request Accepted',
      message: `Great news! Your request for "${donationTitle}" has been accepted.`,
      timestamp: new Date().toISOString(),
    };
    emitToUser(beneficiaryId, 'notification', payload);
  }

  /**
   * Notify a beneficiary that their item request was rejected.
   */
  notifyInKindRejected(beneficiaryId: number, donationId: number, donationTitle: string) {
    const payload: NotificationPayload = {
      type: 'INKIND_REJECTED',
      taskId: donationId,
      title: 'Item Request Rejected',
      message: `Sorry, your request for "${donationTitle}" was not accepted this time.`,
      timestamp: new Date().toISOString(),
    };
    emitToUser(beneficiaryId, 'notification', payload);
  }

  /**
   * Notify a donor that the beneficiary has confirmed receipt.
   */
  notifyInKindCompleted(donorId: number, donationId: number, donationTitle: string) {
    const payload: NotificationPayload = {
      type: 'INKIND_COMPLETED',
      taskId: donationId,
      title: 'Donation Completed',
      message: `The beneficiary has confirmed receipt of "${donationTitle}". Thank you for your help!`,
      timestamp: new Date().toISOString(),
    };
    emitToUser(donorId, 'notification', payload);
  }

  /**
   * Notify a volunteer that a task has been assigned to them by an admin.
   */
  notifyTaskAssigned(volunteerId: number, taskId: number, taskTitle: string) {
    const payload: NotificationPayload = {
      type: 'TASK_ASSIGNED',
      taskId,
      title: 'Task Assigned',
      message: `You have been assigned to the task "${taskTitle}".`,
      timestamp: new Date().toISOString(),
    };
    emitToUser(volunteerId, 'notification', payload);
  }

  /**
   * Notify admin about an emergency escalation.
   */
  notifyAdminEmergency(adminId: number, targetId: number, reason: string) {
    const payload: NotificationPayload = {
      type: 'EMERGENCY_ESCALATION',
      taskId: targetId,
      title: 'EMERGENCY ALERT',
      message: `Critical escalation: ${reason}`,
      timestamp: new Date().toISOString(),
    };
    emitToUser(adminId, 'notification', payload);
  }
}

export const notificationService = new NotificationService();
