import { z } from 'zod';

export const createPoemSchema = z.object({
  title: z.string().max(200).optional(),
  content: z.string().min(1).max(10000),
  language: z.enum(['ENGLISH', 'HINDI', 'URDU']).default('ENGLISH'),
  emotion: z.enum(['LOVE', 'LONGING', 'HOPE', 'SOLITUDE', 'ANGER', 'GRATITUDE']).optional(),
  theme: z.string().max(50).optional(),
});

export const listPoemsSchema = z.object({
  emotion: z.enum(['LOVE', 'LONGING', 'HOPE', 'SOLITUDE', 'ANGER', 'GRATITUDE']).optional(),
  language: z.enum(['ENGLISH', 'HINDI', 'URDU']).optional(),
  theme: z.string().optional(),
  cursor: z.string().optional(),
  limit: z.coerce.number().int().min(1).max(50).default(20),
});