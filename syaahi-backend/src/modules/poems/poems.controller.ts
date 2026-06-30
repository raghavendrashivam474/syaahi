import { Request, Response } from 'express';
import { prisma } from '../../config/prisma';
import { ApiError } from '../../utils/ApiError';
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

  const poems = await prisma.poem.findMany({
    where: { isPublished: true, ...(emotion && { emotion }), ...(language && { language }), ...(theme && { theme }) },
    take: limit + 1,
    ...(cursor && { cursor: { id: cursor }, skip: 1 }),
    orderBy: { createdAt: 'desc' },
    include: {
      author: { select: { id: true, username: true, displayName: true, avatarUrl: true } },
      _count: { select: { reactions: true } },
    },
  });

  const hasMore = poems.length > limit;
  const items = hasMore ? poems.slice(0, -1) : poems;
  const nextCursor = hasMore ? items[items.length - 1].id : null;

  res.json({ success: true, data: { poems: items, nextCursor } });
};

export const getPoem = async (req: Request, res: Response) => {
  const id = req.params.id as string;

  const poem = await prisma.poem.findUnique({
    where: { id },
    include: {
      author: { select: { id: true, username: true, displayName: true, avatarUrl: true, bio: true } },
      _count: { select: { reactions: true } },
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
