export interface BroadcastPayload {
    type: 'COORDINATOR_BROADCAST';
    scope: 'REGION' | 'CAMPAIGN' | 'TASK' | 'NGO';
    targetId: string;
    message: string;
    urgency: 'LOW' | 'MEDIUM' | 'HIGH';
    senderId: number;
}
export declare class BroadcastService {
    /**
     * Broadcast an alert to a specific target scope.
     */
    broadcast(payload: BroadcastPayload, ip: string): Promise<{
        total_notified: number;
    }>;
    private getTargetUserIds;
}
export declare const broadcastService: BroadcastService;
//# sourceMappingURL=broadcast.service.d.ts.map