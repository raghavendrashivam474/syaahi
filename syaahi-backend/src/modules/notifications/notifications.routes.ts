import { Router } from 'express';
import { asyncHandler } from '../../utils/asyncHandler';
import { authenticate } from '../../middleware/auth';
import {
  listNotifications,
  getUnreadCount,
  markAsRead,
  markAllAsRead,
  getPreferences,
  updatePreferences,
} from './notifications.controller';

// ─── Notification inbox routes (mounted at /api/v1/notifications) ───
export const notificationRouter = Router();

// Static paths BEFORE /:id to prevent Express from matching "unread-count" as an ID
notificationRouter.get('/', authenticate, asyncHandler(listNotifications));
notificationRouter.get('/unread-count', authenticate, asyncHandler(getUnreadCount));
notificationRouter.patch('/read-all', authenticate, asyncHandler(markAllAsRead));
notificationRouter.patch('/:id/read', authenticate, asyncHandler(markAsRead));

// ─── Preference routes (mounted at /api/v1/notification-preferences) ─
export const preferenceRouter = Router();

preferenceRouter.get('/', authenticate, asyncHandler(getPreferences));
preferenceRouter.patch('/', authenticate, asyncHandler(updatePreferences));
