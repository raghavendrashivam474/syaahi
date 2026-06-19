import { Request, Response } from 'express';
import { prisma } from '../../config/prisma';
import { ApiError } from '../../utils/ApiError';
import { createPoemSchema, listPoemsSchema } from './poems.schemas';

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
  const poem = await prisma.poem.findUnique({
    where: { id: req.params.id },
    include: {
      author: { select: { id: true, username: true, displayName: true, avatarUrl: true, bio: true } },
      _count: { select: { reactions: true } },
    },
  });

  if (!poem || !poem.isPublished) throw new ApiError(404, 'Poem not found');
  res.json({ success: true, data: { poem } });
};