import { SubmitDeliveryInput, VerifyDeliveryInput } from './deliveries.schema.js';
export declare class DeliveriesService {
    /**
     * Submit delivery proof. Supports partial fulfillment.
     */
    submitDelivery(input: SubmitDeliveryInput & {
        quantity_delivered: number;
    }, volunteerId: number): Promise<any>;
    /**
     * Verify a delivery (coordinator/admin).
     */
    verifyDelivery(deliveryId: number, verifiedBy: number, input: VerifyDeliveryInput & {
        ip?: string;
    }): Promise<any>;
    /**
     * Submit beneficiary feedback for a delivery.
     */
    submitBeneficiaryFeedback(deliveryId: number, beneficiaryId: number, input: {
        confirmation_status: string;
        rating?: number;
        comment?: string;
    }): Promise<any>;
    /**
     * Get deliveries for a task.
     */
    getByTask(taskId: number): Promise<any[]>;
}
export declare const deliveriesService: DeliveriesService;
//# sourceMappingURL=deliveries.service.d.ts.map