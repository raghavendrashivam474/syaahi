import { Request, Response } from 'express';
import { prisma } from '../../config/prisma';
import { ApiError } from '../../utils/ApiError';
import { updateMeSchema, userPoemsQuerySchema } from './users.schemas';

/**
 * GET /api/v1/users/:username
 * Public profile of any user
 */
export const getUserProfile = async (req: Request, res: Response) => {
  const username = req.params.username as string;

  const user = await prisma.user.findUnique({
    where: { username },
    select: {
      id: true,
      username: true,
      displayName: true,
      bio: true,
      avatarUrl: true,
      createdAt: true,
      _count: {
        select: { poems: true, followers: true, following: true },
      },
    },
  });

  if (!user) throw new ApiError(404, 'User not found');

  res.json({ success: true, data: { user } });
};

/**
 * GET /api/v1/users/:username/poems
 * Paginated poems by a specific user
 */
export const getUserPoems = async (req: Request, res: Response) => {
  const username = req.params.username as string;
  const { cursor, limit } = userPoemsQuerySchema.parse(req.query);

  const user = await prisma.user.findUnique({
    where: { username },
    select: { id: true },
  });
  if (!user) throw new ApiError(404, 'User not found');

  const poems = await prisma.poem.findMany({
    where: { authorId: user.id, isPublished: true },
    take: limit + 1,
    ...(cursor && { cursor: { id: cursor }, skip: 1 }),
    orderBy: { createdAt: 'desc' },
    include: {
      author: {
        select: { id: true, username: true, displayName: true, avatarUrl: true },
      },
      _count: { select: { reactions: true } },
    },
  });

  const hasMore = poems.length > limit;
  const items = hasMore ? poems.slice(0, -1) : poems;
  const nextCursor = hasMore ? items[items.length - 1].id : null;

  res.json({ success: true, data: { poems: items, nextCursor } });
};

/**
 * PATCH /api/v1/users/me
 * Update authenticated user's profile
 */
export const updateMe = async (req: Request, res: Response) => {
  const data = updateMeSchema.parse(req.body);

  if (Object.keys(data).length === 0) {
    throw new ApiError(400, 'No fields to update');
  }

  const user = await prisma.user.update({
    where: { id: req.user!.userId },
    data,
    select: {
      id: true,
      email: true,
      username: true,
      displayName: true,
      bio: true,
      avatarUrl: true,
      createdAt: true,
      updatedAt: true,
    },
  });

  res.json({ success: true, data: { user } });
};
