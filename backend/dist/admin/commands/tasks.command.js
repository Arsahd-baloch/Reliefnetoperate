import { tasksService } from '../../modules/tasks/tasks.service.js';
export async function handleTaskCommand(command) {
    return tasksService.updateTask(command.targetId, command.metadata, command.actorAdminId, 'ADMIN');
}
//# sourceMappingURL=tasks.command.js.map