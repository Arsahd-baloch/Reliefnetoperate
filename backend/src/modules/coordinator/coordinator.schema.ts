import { z } from 'zod';

export const flagFraudSchema = z.object({
  entity:  z.string().min(1),
  id:      z.number().int().positive(),
  payload: z.record(z.unknown()).optional().default({}),
});

export const escalateSchema = z.object({
  entity:  z.string().min(1),
  id:      z.number().int().positive(),
  payload: z.record(z.unknown()).optional().default({}),
});

export const emergencyEscalateSchema = z.object({
  severity:      z.enum(['LOW', 'MEDIUM', 'HIGH', 'CRITICAL']),
  reason:        z.string().min(5),
  target_entity: z.string().min(1),
  target_id:     z.number().int().positive(),
  affected_tasks: z.array(z.number().int().positive()).optional(),
});

export const broadcastSchema = z.object({
  message: z.string().min(1).max(1000),
  scope:   z.string().optional(),
});

export type FlagFraudInput        = z.infer<typeof flagFraudSchema>;
export type EscalateInput         = z.infer<typeof escalateSchema>;
export type EmergencyEscalateInput = z.infer<typeof emergencyEscalateSchema>;
export type BroadcastInput        = z.infer<typeof broadcastSchema>;
