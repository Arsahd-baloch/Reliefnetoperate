import { z } from 'zod';

export const sendMessageSchema = z.object({
  text: z.string().min(1).max(5000),
});

export const createRoomSchema = z.object({
  task_id: z.number().int().positive().optional(),
  taskId:  z.number().int().positive().optional(),
}).refine(data => data.task_id !== undefined || data.taskId !== undefined, {
  message: 'task_id is required',
});

export const roomIdParam = z.object({
  roomId: z.coerce.number().int().positive(),
});

export type SendMessageInput = z.infer<typeof sendMessageSchema>;
