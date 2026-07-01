import { Request, Response } from 'express';
import { prisma } from '../../config/prisma';
import { ApiError } from '../../utils/ApiError';

/**
 * POST /api/v1/poems/:id/heart
 *
 * Commit a poem to heart.
 *
 * Behaviour:
 * - Private to the reader. Author is never notified.
 * - No public count is exposed.
 * - Idempotent: committing twice does not error, returns current state.
 */
export const commitToHeart = async (req: Request, res: Response) => {
  const poemId = req.params.id as string;
  const userId = req.user!.userId;

  const poem = await prisma.poem.findUnique({
    where: { id: poemId },
    select: { id: true, isPublished: true },
  });

  if (!poem || !poem.isPublished) {
    throw new ApiError(404, 'Poem not found');
  }

  await prisma.heart.upsert({
    where: { userId_poemId: { userId, poemId } },
    create: { userId, poemId },
    update: {},
  });

  res.json({ success: true, data: { hearted: true, poemId } });
};

/**
 * DELETE /api/v1/poems/:id/heart
 *
 * Remove a poem from heart.
 *
 * Behaviour:
 * - Idempotent: removing a poem not in heart does not error.
 */
export const removeFromHeart = async (req: Request, res: Response) => {
  const poemId = req.params.id as string;
  const userId = req.user!.userId;

  await prisma.heart.deleteMany({
    where: { userId, poemId },
  });

  res.json({ success: true, data: { hearted: false, poemId } });
};

/**
 * GET /api/v1/users/me/heart
 *
 * Return all poems the authenticated user has committed to heart.
 *
 * Returns Poem[] not Heart[].
 * The frontend does not need to know about the Heart join record.
 *
 * Ordered by most recently hearted first.
 * Supports cursor-based pagination.
 */
export const getMyHeart = async (req: Request, res: Response) => {
  const userId = req.user!.userId;
  const cursor = req.query.cursor as string | undefined;
  const limit = Math.min(Number(req.query.limit ?? 20), 50);

  const hearts = await prisma.heart.findMany({
    where: { userId },
    take: limit + 1,
    ...(cursor && { cursor: { id: cursor }, skip: 1 }),
    orderBy: { createdAt: 'desc' },
    include: {
      poem: {
        include: {
          author: {
            select: { id: true, username: true, displayName: true, avatarUrl: true },
          },
          _count: { select: { reactions: true } },
        },
      },
    },
  });

  const hasMore = hearts.length > limit;
  const items = hasMore ? hearts.slice(0, -1) : hearts;
  const nextCursor = hasMore && items.length > 0 ? items[items.length - 1].id : null;

  // Return Poem[] not Heart[]
  const poems = items.map((h: { poem: object }) => h.poem);

  res.json({ success: true, data: { poems, nextCursor } });
};

/**
 * GET /api/v1/poems/:id/heart/status
 *
 * Check if the authenticated user has hearted a specific poem.
 * Used by the reader screen to show correct heart state.
 */
export const getHeartStatus = async (req: Request, res: Response) => {
  const poemId = req.params.id as string;
  const userId = req.user!.userId;

  const heart = await prisma.heart.findUnique({
    where: { userId_poemId: { userId, poemId } },
    select: { id: true },
  });

  res.json({ success: true, data: { hearted: heart !== null, poemId } });
};
