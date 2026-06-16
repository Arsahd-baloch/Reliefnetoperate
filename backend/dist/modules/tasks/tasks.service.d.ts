import { CreateTaskInput, UpdateTaskInput } from './tasks.schema.js';
interface TaskRow {
    id: number;
    campaign_id: number | null;
    beneficiary_id: number | null;
    created_by: number;
    claimed_by: number | null;
    coordinator_id: number | null;
    source_type: string;
    title: string;
    description: string | null;
    category: string | null;
    family_size: number;
    items_needed: Record<string, unknown>;
    latitude: number;
    longitude: number;
    location_text: string | null;
    radius_km: number;
    budget_pkr: number;
    urgency: string;
    status: string;
    view_count: number;
    created_at: string;
    updated_at: string;
    created_by_name?: string;
    claimed_by_name?: string;
    coordinator_name?: string;
}
export declare class TasksService {
    /**
     * Create a new task.
     */
    createTask(input: CreateTaskInput, createdBy: number): Promise<TaskRow>;
    /**
     * Get ALL open tasks. Optional filter by source type.
     */
    getAvailableTasks(sourceType?: string): Promise<TaskRow[]>;
    /**
     * Get task by ID with full details.
     */
    getTaskById(id: number): Promise<TaskRow>;
    /**
     * Get all tasks for a beneficiary — both self-created requests and NGO-assigned tasks.
     */
    getMyTasks(userId: number): Promise<TaskRow[]>;
    /**
     * Get all tasks assigned to a specific coordinator.
     */
    getCoordinatorTasks(userId: number): Promise<TaskRow[]>;
    /**
     * Update a task. NGO and BENEFICIARY roles are restricted to tasks they created.
     * Non-admin/non-coordinator can only update if status is 'OPEN'.
     */
    updateTask(id: number, input: UpdateTaskInput, userId: number, role: string): Promise<any>;
    /**
     * ASSIGN A TASK (DISPATCH)
     * Admin/Coordinator forces assignment of an OPEN task to a specific volunteer.
     */
    assignTask(taskId: number, volunteerId: number, adminId: number): Promise<{
        success: boolean;
    }>;
    /**
     * CLAIM A TASK — RACE-CONDITION SAFE
     *
     * Uses BEGIN + SELECT ... FOR UPDATE + COMMIT.
     * Only one volunteer can claim an OPEN task.
     * This is the critical section for concurrency safety.
     */
    claimTask(taskId: number, volunteerId: number): Promise<any>;
    /**
     * Start a claimed task — transitions CLAIMED → IN_PROGRESS.
     */
    startTask(taskId: number, volunteerId: number): Promise<TaskRow>;
    /**
     * Unclaim a task — transitions CLAIMED → OPEN and releases the volunteer.
     * Only works when status = CLAIMED (not after starting).
     */
    unclaimTask(taskId: number, volunteerId: number): Promise<TaskRow>;
    /**
     * Record a task view.
     */
    recordView(taskId: number, userId: number): Promise<void>;
    /**
     * Get task events timeline.
     */
    getTaskEvents(taskId: number): Promise<any[]>;
}
export declare const tasksService: TasksService;
export {};
//# sourceMappingURL=tasks.service.d.ts.map