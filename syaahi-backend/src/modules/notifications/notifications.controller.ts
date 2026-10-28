import { Request, Response } from 'express';
import { prisma } from '../../config/prisma';
import { ApiError } from '../../utils/ApiError';
import {
  listNotificationsSchema,
  updatePreferencesSchema,
} from './notifications.schemas';

const UUID_RE = /^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/i;

// ─── API 1: GET /api/v1/notifications ───────────────────────────────
export const listNotifications = async (req: Request, res: Response) => {
  const userId = req.user!.userId;

  const parsed = listNotificationsSchema.safeParse(req.query);
  if (!parsed.success) {
    throw new ApiError(400, 'Invalid query parameters', parsed.error.flatten().fieldErrors);
  }

  const { limit, cursor } = parsed.data;

  try {
    const notifications = await prisma.notification.findMany({
      where: { recipientId: userId },
      take: limit + 1,
      ...(cursor && { cursor: { id: cursor }, skip: 1 }),
      orderBy: [{ createdAt: 'desc' }, { id: 'desc' }],
      select: {
        id: true,
        type: true,
        poemId: true,
        readAt: true,
        createdAt: true,
        poem: { select: { id: true, title: true } },
      },
    });

    const hasMore = notifications.length > limit;
    const items = hasMore ? notifications.slice(0, -1) : notifications;
    const nextCursor =
      hasMore && items.length > 0 ? items[items.length - 1].id : null;

    res.json({ success: true, data: { items, nextCursor } });
  } catch (err: any) {
    if (err?.code === 'P2025') {
      throw new ApiError(400, 'Invalid cursor');
    }
    throw err;
  }
};

// ─── API 2: GET /api/v1/notifications/unread-count ──────────────────
export const getUnreadCount = async (req: Request, res: Response) => {
  const userId = req.user!.userId;

  const unreadCount = await prisma.notification.count({
    where: { recipientId: userId, readAt: null },
  });

  res.json({ success: true, data: { unreadCount } });
};

// ─── API 3: PATCH /api/v1/notifications/:id/read ────────────────────
export const markAsRead = async (req: Request, res: Response) => {
  const userId = req.user!.userId;
  const notificationId = req.params.id as string;

  if (!UUID_RE.test(notificationId)) {
    throw new ApiError(400, 'Invalid notification ID');
  }

  // Atomic ownership check: update only if id AND recipientId match AND unread
  const result = await prisma.notification.updateMany({
    where: { id: notificationId, recipientId: userId, readAt: null },
    data: { readAt: new Date() },
  });

  if (result.count === 0) {
    // Distinguish "already read" (idempotent ok) from "not found / not owned" (404)
    const exists = await prisma.notification.findFirst({
      where: { id: notificationId, recipientId: userId },
      select: { id: true },
    });
    if (!exists) {
      throw new ApiError(404, 'Notification not found');
    }
    // Already read — idempotent success, fall through
  }

  res.json({ success: true, data: { read: true } });
};

// ─── API 4: PATCH /api/v1/notifications/read-all ────────────────────
export const markAllAsRead = async (req: Request, res: Response) => {
  const userId = req.user!.userId;

  const result = await prisma.notification.updateMany({
    where: { recipientId: userId, readAt: null },
    data: { readAt: new Date() },
  });

  res.json({ success: true, data: { markedCount: result.count } });
};

// ─── API 5: GET /api/v1/notification-preferences ────────────────────
export const getPreferences = async (req: Request, res: Response) => {
  const userId = req.user!.userId;

  const pref = await prisma.notificationPreference.findUnique({
    where: { userId },
  });

  // No row yet → return schema default without writing
  res.json({
    success: true,
    data: { newPoemAlerts: pref?.newPoemAlerts ?? false },
  });
};

// ─── API 6: PATCH /api/v1/notification-preferences ──────────────────
export const updatePreferences = async (req: Request, res: Response) => {
  const userId = req.user!.userId;

  const parsed = updatePreferencesSchema.safeParse(req.body);
  if (!parsed.success) {
    throw new ApiError(
      400,
      'Invalid request body',
      parsed.error.flatten().fieldErrors
    );
  }

  const { newPoemAlerts } = parsed.data;

  const pref = await prisma.notificationPreference.upsert({
    where: { userId },
    create: { userId, newPoemAlerts },
    update: { newPoemAlerts },
  });

  res.json({
    success: true,
    data: { newPoemAlerts: pref.newPoemAlerts },
  });
};
