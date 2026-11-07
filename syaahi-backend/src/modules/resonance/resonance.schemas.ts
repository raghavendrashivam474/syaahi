import { z } from 'zod';

export const createResponseSchema = z.object({
  content: z
    .string()
    .trim()
    .min(1, 'Response cannot be empty')
    .max(280, 'Response cannot exceed 280 characters'),
});

export const updateResponseSchema = z.object({
  content: z
    .string()
    .trim()
    .min(1, 'Response cannot be empty')
    .max(280, 'Response cannot exceed 280 characters'),
});

export const createReplySchema = z.object({
  content: z
    .string()
    .trim()
    .min(1, 'Reply cannot be empty')
    .max(280, 'Reply cannot exceed 280 characters'),
});

export const updateReplySchema = z.object({
  content: z
    .string()
    .trim()
    .min(1, 'Reply cannot be empty')
    .max(280, 'Reply cannot exceed 280 characters'),
});

export const listResponsesQuerySchema = z.object({
  limit: z.coerce.number().int().min(1).max(50).default(20),
  cursor: z.string().uuid().optional(),
});