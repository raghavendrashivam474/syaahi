import { z } from 'zod';

export const createDraftSchema = z.object({
  id: z.string().uuid().optional(), // Client-side UUID for sync matching
  title: z.string().max(200).optional().nullable(),
  content: z.string().max(10000).default(''),
  language: z.enum(['ENGLISH', 'HINDI', 'URDU']).default('ENGLISH'),
  emotion: z.enum(['LOVE', 'LONGING', 'HOPE', 'SOLITUDE', 'ANGER', 'GRATITUDE']).optional().nullable(),
  theme: z.string().max(50).optional().nullable(),
  version: z.number().int().min(1).optional().default(1),
});

export const updateDraftSchema = z.object({
  title: z.string().max(200).optional().nullable(),
  content: z.string().max(10000).optional(),
  language: z.enum(['ENGLISH', 'HINDI', 'URDU']).optional(),
  emotion: z.enum(['LOVE', 'LONGING', 'HOPE', 'SOLITUDE', 'ANGER', 'GRATITUDE']).optional().nullable(),
  theme: z.string().max(50).optional().nullable(),
  version: z.number().int().min(1).optional(),
}).refine((data) => Object.keys(data).length > 0, {
  message: 'At least one field must be provided for update',
});

export const listDraftsSchema = z.object({
  limit: z.coerce.number().int().min(1).max(100).default(50),
  cursor: z.string().uuid().optional(),
  updatedAfter: z.string().datetime().optional(),
});
