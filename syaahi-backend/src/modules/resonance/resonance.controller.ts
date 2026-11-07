import { Request, Response } from 'express';
import { prisma } from '../../config/prisma';
import { ApiError } from '../../utils/ApiError';
import {
  createResponseSchema,
  updateResponseSchema,
  createReplySchema,
  updateReplySchema,
  listResponsesQuerySchema,
} from './resonance.schemas';
import {
  createResonanceNotification,
  createReplyNotification,
} from '../notifications/notification.service';

/**
 * POST /api/v1/poems/:poemId/resonances
 * Submit a meaningful written response to a poem
 */
export const createResponse = async (req: Request, res: Response) => {
  const poemId = req.params.poemId as string;
  const userId = req.user!.userId;
  const { content } = createResponseSchema.parse(req.body);

  const poem = await prisma.poem.findUnique({
    where: { id: poemId },
    select: { id: true, authorId: true, isPublished: true },
  });

  if (!poem || !poem.isPublished) {
    throw new ApiError(404, 'Poem not found');
  }

  const response = await prisma.resonanceResponse.create({
    data: {
      poemId,
      userId,
      content,
    },
    include: {
      user: {
        select: {
          id: true,
          username: true,
          displayName: true,
          avatarUrl: true,
        },
      },
      reply: {
        include: {
          author: {
            select: {
              id: true,
              username: true,
              displayName: true,
              avatarUrl: true,
            },
          },
        },
      },
    },
  });

  // Best-effort notification to poem author
  await createResonanceNotification(
    poemId,
    poem.authorId,
    userId,
    response.id
  );

  res.status(201).json({ success: true, data: { response } });
};

/**
 * GET /api/v1/poems/:poemId/resonances
 * List responses for a poem with user & reply info
 */
export const listResponses = async (req: Request, res: Response) => {
  const poemId = req.params.poemId as string;
  const { limit, cursor } = listResponsesQuerySchema.parse(req.query);

  const poem = await prisma.poem.findUnique({
    where: { id: poemId },
    select: { id: true, isPublished: true },
  });

  if (!poem || !poem.isPublished) {
    throw new ApiError(404, 'Poem not found');
  }

  const items = await prisma.resonanceResponse.findMany({
    where: { poemId },
    take: limit + 1,
    ...(cursor && { cursor: { id: cursor }, skip: 1 }),
    orderBy: { createdAt: 'asc' },
    include: {
      user: {
        select: {
          id: true,
          username: true,
          displayName: true,
          avatarUrl: true,
        },
      },
      reply: {
        include: {
          author: {
            select: {
              id: true,
              username: true,
              displayName: true,
              avatarUrl: true,
            },
          },
        },
      },
    },
  });

  const hasMore = items.length > limit;
  const responses = hasMore ? items.slice(0, -1) : items;
  const nextCursor =
    hasMore && responses.length > 0 ? responses[responses.length - 1].id : null;

  res.json({ success: true, data: { responses, nextCursor } });
};

/**
 * PATCH /api/v1/resonances/:responseId
 * Edit user's own response
 */
export const updateResponse = async (req: Request, res: Response) => {
  const responseId = req.params.responseId as string;
  const userId = req.user!.userId;
  const { content } = updateResponseSchema.parse(req.body);

  const existing = await prisma.resonanceResponse.findUnique({
    where: { id: responseId },
    select: { id: true, userId: true },
  });

  if (!existing) {
    throw new ApiError(404, 'Resonance response not found');
  }

  if (existing.userId !== userId) {
    throw new ApiError(403, 'You can only edit your own response');
  }

  const response = await prisma.resonanceResponse.update({
    where: { id: responseId },
    data: { content },
    include: {
      user: {
        select: {
          id: true,
          username: true,
          displayName: true,
          avatarUrl: true,
        },
      },
      reply: {
        include: {
          author: {
            select: {
              id: true,
              username: true,
              displayName: true,
              avatarUrl: true,
            },
          },
        },
      },
    },
  });

  res.json({ success: true, data: { response } });
};

/**
 * DELETE /api/v1/resonances/:responseId
 * Delete user's own response
 */
export const deleteResponse = async (req: Request, res: Response) => {
  const responseId = req.params.responseId as string;
  const userId = req.user!.userId;

  const existing = await prisma.resonanceResponse.findUnique({
    where: { id: responseId },
    select: { id: true, userId: true },
  });

  if (!existing) {
    throw new ApiError(404, 'Resonance response not found');
  }

  if (existing.userId !== userId) {
    throw new ApiError(403, 'You can only delete your own response');
  }

  await prisma.resonanceResponse.delete({
    where: { id: responseId },
  });

  res.json({ success: true, message: 'Response deleted successfully' });
};

/**
 * POST /api/v1/resonances/:responseId/reply
 * Poem author replies to a reader's response
 */
export const createReply = async (req: Request, res: Response) => {
  const responseId = req.params.responseId as string;
  const userId = req.user!.userId;
  const { content } = createReplySchema.parse(req.body);

  const response = await prisma.resonanceResponse.findUnique({
    where: { id: responseId },
    select: {
      id: true,
      userId: true,
      poemId: true,
      poem: { select: { authorId: true } },
      reply: { select: { id: true } },
    },
  });

  if (!response) {
    throw new ApiError(404, 'Resonance response not found');
  }

  if (response.poem.authorId !== userId) {
    throw new ApiError(403, 'Only the author of the poem can reply to this response');
  }

  if (response.reply) {
    throw new ApiError(400, 'This response already has an author reply');
  }

  const reply = await prisma.resonanceReply.create({
    data: {
      responseId,
      authorId: userId,
      content,
    },
    include: {
      author: {
        select: {
          id: true,
          username: true,
          displayName: true,
          avatarUrl: true,
        },
      },
    },
  });

  // Best-effort notification to original responder
  await createReplyNotification(
    response.poemId,
    response.userId,
    userId,
    reply.id
  );

  res.status(201).json({ success: true, data: { reply } });
};

/**
 * PATCH /api/v1/resonance-replies/:replyId
 * Edit author's own reply
 */
export const updateReply = async (req: Request, res: Response) => {
  const replyId = req.params.replyId as string;
  const userId = req.user!.userId;
  const { content } = updateReplySchema.parse(req.body);

  const existing = await prisma.resonanceReply.findUnique({
    where: { id: replyId },
    select: { id: true, authorId: true },
  });

  if (!existing) {
    throw new ApiError(404, 'Reply not found');
  }

  if (existing.authorId !== userId) {
    throw new ApiError(403, 'You can only edit your own reply');
  }

  const reply = await prisma.resonanceReply.update({
    where: { id: replyId },
    data: { content },
    include: {
      author: {
        select: {
          id: true,
          username: true,
          displayName: true,
          avatarUrl: true,
        },
      },
    },
  });

  res.json({ success: true, data: { reply } });
};

/**
 * DELETE /api/v1/resonance-replies/:replyId
 * Delete author's own reply
 */
export const deleteReply = async (req: Request, res: Response) => {
  const replyId = req.params.replyId as string;
  const userId = req.user!.userId;

  const existing = await prisma.resonanceReply.findUnique({
    where: { id: replyId },
    select: { id: true, authorId: true },
  });

  if (!existing) {
    throw new ApiError(404, 'Reply not found');
  }

  if (existing.authorId !== userId) {
    throw new ApiError(403, 'You can only delete your own reply');
  }

  await prisma.resonanceReply.delete({
    where: { id: replyId },
  });

  res.json({ success: true, message: 'Reply deleted successfully' });
};