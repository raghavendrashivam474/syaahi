import { z } from 'zod';

/**
 * Query params for GET /api/v1/notifications
 * Cursor must be a valid UUID (notification ID).
 * Limit is bounded: 1–50, default 20.
 */
export const listNotificationsSchema = z.object({
  limit: z.coerce.number().int().min(1).max(50).default(20),
  cursor: z.string().uuid().optional(),
});

/**
 * Body for PATCH /api/v1/notification-preferences
 * Strict: rejects unknown fields.
 * newPoemAlerts must be a genuine boolean — no coercion.
 */
export const updatePreferencesSchema = z
  .object({
    newPoemAlerts: z.boolean(),
  })
  .strict();
