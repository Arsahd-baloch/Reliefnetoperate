export declare const TaskStatus: {
    readonly OPEN: "OPEN";
    readonly ASSIGNED: "ASSIGNED";
    readonly CLAIMED: "CLAIMED";
    readonly IN_PROGRESS: "IN_PROGRESS";
    readonly SUBMITTED: "SUBMITTED";
    readonly COORDINATOR_VERIFIED: "COORDINATOR_VERIFIED";
    readonly PAID: "PAID";
    readonly FLAGGED: "FLAGGED";
    readonly CANCELLED: "CANCELLED";
};
export declare const DonationStatus: {
    readonly PENDING: "PENDING";
    readonly CONFIRMED: "CONFIRMED";
    readonly REJECTED: "REJECTED";
    readonly REFUNDED: "REFUNDED";
};
export declare const VolunteerType: {
    readonly INDEPENDENT: "INDEPENDENT";
    readonly NGO: "NGO";
};
export declare const WithdrawalStatus: {
    readonly PENDING: "PENDING";
    readonly APPROVED: "APPROVED";
    readonly REJECTED: "REJECTED";
};
export declare const CampaignStatus: {
    readonly DRAFT: "DRAFT";
    readonly PENDING_APPROVAL: "PENDING_APPROVAL";
    readonly ACTIVE: "ACTIVE";
    readonly PAUSED: "PAUSED";
    readonly CLOSED: "CLOSED";
    readonly REJECTED: "REJECTED";
    readonly COMPLETED: "COMPLETED";
};
export declare const PgErrorCode: {
    readonly TRIGGER_EXCEPTION: "P0001";
    readonly UNIQUE_VIOLATION: "23505";
    readonly CHECK_VIOLATION: "23514";
    readonly FOREIGN_KEY_VIOLATION: "23503";
    readonly NOT_NULL_VIOLATION: "23502";
};
export declare const TriggerMessage: {
    readonly TASK_STATUS_TRANSITION: "Invalid task status transition";
    readonly CANNOT_CLAIM: "cannot claim a task";
    readonly NOT_BENEFICIARY: "is not the beneficiary";
    readonly FEEDBACK_NO_BENEFICIARY: "has no associated task beneficiary";
};
export declare const CheckConstraint: {
    readonly WALLET_BALANCE: "ngo_profiles_wallet_balance_check";
    readonly TOTAL_EARNED: "volunteer_profiles_total_earned_check";
    readonly AMOUNT_POSITIVE: "donations_amount_positive";
    readonly BUDGET_NON_NEGATIVE: "tasks_budget_non_negative";
};
export declare const UniqueConstraint: {
    readonly LEDGER_EVENT: "ledger_entries_unique_event";
};
//# sourceMappingURL=enums.d.ts.map