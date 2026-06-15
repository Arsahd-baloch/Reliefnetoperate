export declare class CoordinatorIntelligenceService {
    /**
     * Get operational intelligence metrics for a coordinator.
     */
    getOperationalIntelligence(coordinatorId: number): Promise<{
        stuck_tasks: any[];
        verification_stats: {
            verified: number;
            flagged: number;
        };
        top_volunteers: any[];
        ngo_performance: any[];
    }>;
    /**
     * Get heuristically detected fraud signals.
     */
    getFraudSignals(coordinatorId: number): Promise<{
        gps_mismatches: any[];
        high_risk_volunteers: any[];
    }>;
    /**
     * Flag fraud or suspicious behavior.
     */
    flagFraud(coordinatorId: number, targetEntity: string, targetId: number, payload: any, ip: string): Promise<{
        success: boolean;
    }>;
    /**
     * Escalate an issue to Admin.
     */
    escalateIssue(coordinatorId: number, targetEntity: string, targetId: number, payload: any, ip: string): Promise<{
        success: boolean;
    }>;
    /**
     * Escalate an emergency situation to Admin.
     */
    emergencyEscalate(coordinatorId: number, input: {
        severity: string;
        reason: string;
        target_entity: string;
        target_id: number;
        affected_tasks?: number[];
    }, ip: string): Promise<{
        success: boolean;
    }>;
    /**
     * Generate report metrics.
     */
    getInsightReports(coordinatorId: number, period: string): Promise<any>;
    /**
     * Get history of escalations sent by this coordinator.
     */
    getEscalationHistory(coordinatorId: number): Promise<any[]>;
}
export declare const coordinatorIntelligenceService: CoordinatorIntelligenceService;
//# sourceMappingURL=coordinator.intelligence.service.d.ts.map