import { z } from 'zod';

export const updateMeSchema = z.object({
  displayName: z.string().min(1).max(60).optional(),
  bio: z.string().max(280).optional().nullable(),
  avatarUrl: z.string().url().optional().nullable(),
});

export const userPoemsQuerySchema = z.object({
  cursor: z.string().optional(),
  limit: z.coerce.number().int().min(1).max(50).default(20),
});

export type UpdateMeInput = z.infer<typeof updateMeSchema>;