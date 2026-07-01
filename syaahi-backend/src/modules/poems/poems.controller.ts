import { Request, Response } from 'express';
import { prisma } from '../../config/prisma';
import { ApiError } from '../../utils/ApiError';
import { syaahiFlow, DEFAULT_FEED_OPTIONS } from '../../utils/feed';
import { createPoemSchema, listPoemsSchema, updatePoemSchema } from './poems.schemas';

export const createPoem = async (req: Request, res: Response) => {
  const data = createPoemSchema.parse(req.body);

  const poem = await prisma.poem.create({
    data: { ...data, authorId: req.user!.userId },
    include: {
      author: { select: { id: true, username: true, displayName: true, avatarUrl: true } },
    },
  });

  res.status(201).json({ success: true, data: { poem } });
};

export const listPoems = async (req: Request, res: Response) => {
  const { emotion, language, theme, cursor, limit } = listPoemsSchema.parse(req.query);

  const windowSize = DEFAULT_FEED_OPTIONS.windowSize;

  // Fetch a larger window than requested so Syaahi Flow has room to sequence
  // Cursor applies to the window fetch, not the final page
  const raw = await prisma.poem.findMany({
    where: {
      isPublished: true,
      ...(emotion && { emotion }),
      ...(language && { language }),
      ...(theme && { theme }),
    },
    take: windowSize,
    ...(cursor && { cursor: { id: cursor }, skip: 1 }),
    orderBy: { createdAt: 'desc' },
    include: {
      author: { select: { id: true, username: true, displayName: true, avatarUrl: true } },
      _count: { select: { reactions: true, hearts: true } },
    },
  });

  // Apply Syaahi Flow sequencing
  const sequenced = syaahiFlow(raw, {
    ...DEFAULT_FEED_OPTIONS,
    pageSize: limit + 1, // fetch one extra to determine hasMore
  });

  const hasMore = sequenced.length > limit;
  const items = hasMore ? sequenced.slice(0, -1) : sequenced;
  const nextCursor = hasMore && items.length > 0 ? items[items.length - 1].id : null;

  res.json({ success: true, data: { poems: items, nextCursor } });
};

export const getPoem = async (req: Request, res: Response) => {
  const id = req.params.id as string;

  const poem = await prisma.poem.findUnique({
    where: { id },
    include: {
      author: { select: { id: true, username: true, displayName: true, avatarUrl: true, bio: true } },
      _count: { select: { reactions: true, hearts: true } },
    },
  });

  if (!poem || !poem.isPublished) throw new ApiError(404, 'Poem not found');
  res.json({ success: true, data: { poem } });
};

/**
 * PATCH /api/v1/poems/:id
 * Update own poem
 */
export const updatePoem = async (req: Request, res: Response) => {
  const data = updatePoemSchema.parse(req.body);
  const id = req.params.id as string;

  const existing = await prisma.poem.findUnique({
    where: { id },
    select: { authorId: true },
  });

  if (!existing) throw new ApiError(404, 'Poem not found');

  if (existing.authorId !== req.user!.userId) {
    throw new ApiError(403, 'You can only edit your own poems');
  }

  const poem = await prisma.poem.update({
    where: { id },
    data,
    include: {
      author: {
        select: { id: true, username: true, displayName: true, avatarUrl: true },
      },
    },
  });

  res.json({ success: true, data: { poem } });
};

/**
 * DELETE /api/v1/poems/:id
 * Delete own poem
 */
export const deletePoem = async (req: Request, res: Response) => {
  const id = req.params.id as string;

  const existing = await prisma.poem.findUnique({
    where: { id },
    select: { authorId: true },
  });

  if (!existing) throw new ApiError(404, 'Poem not found');

  if (existing.authorId !== req.user!.userId) {
    throw new ApiError(403, 'You can only delete your own poems');
  }

  await prisma.poem.delete({ where: { id } });

  res.json({ success: true, data: { id, deleted: true } });
};
