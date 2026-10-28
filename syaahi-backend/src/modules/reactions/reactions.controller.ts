import { ReactionType } from '@prisma/client';
import { Request, Response } from 'express';
import { prisma } from '../../config/prisma';
import { ApiError } from '../../utils/ApiError';
import { reactionTypeSchema, REACTION_LABELS } from './reactions.schemas';

/**
 * POST /api/v1/poems/:id/reactions
 * Body: { type: ReactionType }
 *
 * Add an emotional acknowledgement to a poem.
 *
 * Design:
 * - A user may react with multiple different types to the same poem.
 * - A user may not react with the same type twice (unique constraint).
 * - Idempotent: reacting twice with the same type does not error.
 * - Reaction counts are returned but should never be used as popularity metrics.
 */
export const addReaction = async (req: Request, res: Response) => {
  const poemId = req.params.id as string;
  const userId = req.user!.userId;
  const { type } = req.body;

  const validatedType = reactionTypeSchema.parse(type);

  const poem = await prisma.poem.findUnique({
    where: { id: poemId },
    select: { id: true, isPublished: true },
  });

  if (!poem || !poem.isPublished) {
    throw new ApiError(404, 'Poem not found');
  }

  await prisma.reaction.upsert({
    where: { userId_poemId_type: { userId, poemId, type: validatedType as ReactionType } },
    create: { userId, poemId, type: validatedType as ReactionType },
    update: {},
  });

  res.json({
    success: true,
    data: {
      reacted: true,
      type: validatedType,
      label: REACTION_LABELS[validatedType],
      poemId,
    },
  });
};

/**
 * DELETE /api/v1/poems/:id/reactions/:type
 *
 * Remove a specific reaction from a poem.
 * Idempotent: removing a reaction that does not exist does not error.
 */
export const removeReaction = async (req: Request, res: Response) => {
  const poemId = req.params.id as string;
  const userId = req.user!.userId;
  const type = reactionTypeSchema.parse(req.params.type);

  await prisma.reaction.deleteMany({
    where: { userId, poemId, type: type as ReactionType },
  });

  res.json({
    success: true,
    data: {
      reacted: false,
      type,
      poemId,
    },
  });
};

/**
 * GET /api/v1/poems/:id/reactions
 *
 * Return reaction summary for a poem.
 *
 * Returns:
 * - counts per reaction type
 * - human-readable labels
 * - which types the authenticated user has used (if authenticated)
 *
 * Note: counts are informational only.
 * The frontend must not present them as popularity or ranking signals.
 */
export const getReactions = async (req: Request, res: Response) => {
  const poemId = req.params.id as string;
  const userId = req.user?.userId;

  const poem = await prisma.poem.findUnique({
    where: { id: poemId },
    select: { id: true, isPublished: true },
  });

  if (!poem || !poem.isPublished) {
    throw new ApiError(404, 'Poem not found');
  }

  // Get counts grouped by type
  const grouped = await prisma.reaction.groupBy({
    by: ['type'],
    where: { poemId },
    _count: { type: true },
  });

  // Get user's own reactions if authenticated
  const userReactions = userId
    ? await prisma.reaction.findMany({
        where: { poemId, userId },
        select: { type: true },
      })
    : [];

  const userReactionTypes = new Set(userReactions.map((r: { type: string }) => r.type));

  // Build response with all six types, even if count is zero
  const reactions = Object.entries(REACTION_LABELS).map(([type, label]) => {
    const found = grouped.find((g: { type: string; _count: { type: number } }) => g.type === type);
    return {
      type,
      label,
      count: found?._count.type ?? 0,
      reacted: userReactionTypes.has(type as ReactionType),
    };
  });

  res.json({ success: true, data: { poemId, reactions } });
};
