import { Request, Response } from 'express';
import { prisma } from '../../config/prisma';
import { ApiError } from '../../utils/ApiError';
import { createDraftSchema, updateDraftSchema, listDraftsSchema } from './studio.schemas';
import { createPublicationNotifications } from '../notifications/notification.service';

/**
 * POST /api/v1/studio/drafts
 * Create a new draft for the authenticated user
 */
export const createDraft = async (req: Request, res: Response) => {
  const userId = req.user!.userId;
  const data = createDraftSchema.parse(req.body);

  const draft = await prisma.draft.create({
    data: {
      ...(data.id && { id: data.id }),
      ownerId: userId,
      title: data.title,
      content: data.content,
      language: data.language,
      emotion: data.emotion,
      theme: data.theme,
      version: data.version ?? 1,
    },
  });

  res.status(201).json({ success: true, data: { draft } });
};

/**
 * GET /api/v1/studio/drafts
 * List owner-scoped drafts
 */
export const listDrafts = async (req: Request, res: Response) => {
  const userId = req.user!.userId;
  const { limit, cursor, updatedAfter } = listDraftsSchema.parse(req.query);

  const drafts = await prisma.draft.findMany({
    where: {
      ownerId: userId,
      isPublished: false,
      ...(updatedAfter && { updatedAt: { gt: new Date(updatedAfter) } }),
    },
    take: limit + 1,
    ...(cursor && { cursor: { id: cursor }, skip: 1 }),
    orderBy: { updatedAt: 'desc' },
  });

  const hasMore = drafts.length > limit;
  const items = hasMore ? drafts.slice(0, -1) : drafts;
  const nextCursor = hasMore && items.length > 0 ? items[items.length - 1].id : null;

  res.json({
    success: true,
    data: {
      drafts: items,
      nextCursor,
    },
  });
};

/**
 * GET /api/v1/studio/drafts/:id
 * Retrieve a single owned draft
 */
export const getDraft = async (req: Request, res: Response) => {
  const userId = req.user!.userId;
  const id = req.params.id as string;

  const draft = await prisma.draft.findUnique({
    where: { id },
  });

  if (!draft || draft.ownerId !== userId) {
    throw new ApiError(404, 'Draft not found');
  }

  res.json({ success: true, data: { draft } });
};

/**
 * PATCH /api/v1/studio/drafts/:id
 * Update an owned draft
 */
export const updateDraft = async (req: Request, res: Response) => {
  const userId = req.user!.userId;
  const id = req.params.id as string;

  const existing = await prisma.draft.findUnique({
    where: { id },
    select: { ownerId: true, isPublished: true, version: true },
  });

  if (!existing || existing.ownerId !== userId) {
    throw new ApiError(404, 'Draft not found');
  }

  if (existing.isPublished) {
    throw new ApiError(400, 'Cannot modify a published draft');
  }

  const data = updateDraftSchema.parse(req.body);

  const updated = await prisma.draft.update({
    where: { id },
    data: {
      ...(data.title !== undefined && { title: data.title }),
      ...(data.content !== undefined && { content: data.content }),
      ...(data.language && { language: data.language }),
      ...(data.emotion !== undefined && { emotion: data.emotion }),
      ...(data.theme !== undefined && { theme: data.theme }),
      version: data.version ?? existing.version + 1,
    },
  });

  res.json({ success: true, data: { draft: updated } });
};

/**
 * DELETE /api/v1/studio/drafts/:id
 * Delete an owned draft
 */
export const deleteDraft = async (req: Request, res: Response) => {
  const userId = req.user!.userId;
  const id = req.params.id as string;

  const existing = await prisma.draft.findUnique({
    where: { id },
    select: { ownerId: true },
  });

  if (!existing || existing.ownerId !== userId) {
    throw new ApiError(404, 'Draft not found');
  }

  await prisma.draft.delete({ where: { id } });

  res.json({ success: true, message: 'Draft deleted successfully' });
};

/**
 * POST /api/v1/studio/drafts/:id/publish
 * Controlled Publication: Converts a draft into a public Poem atomically
 */
export const publishDraft = async (req: Request, res: Response) => {
  const userId = req.user!.userId;
  const id = req.params.id as string;

  const draft = await prisma.draft.findUnique({
    where: { id },
    include: { publishedPoem: true },
  });

  if (!draft || draft.ownerId !== userId) {
    throw new ApiError(404, 'Draft not found');
  }

  if (draft.isPublished || draft.publishedPoem) {
    // Idempotent recovery: return the existing published poem if already published
    if (draft.publishedPoem) {
      const existingPoem = await prisma.poem.findUnique({
        where: { id: draft.publishedPoem.id },
        include: {
          author: { select: { id: true, username: true, displayName: true, avatarUrl: true } },
          _count: { select: { reactions: true, hearts: true } },
        },
      });
      return res.json({ success: true, data: { poem: existingPoem } });
    }
    throw new ApiError(400, 'Draft has already been published');
  }

  if (!draft.content || draft.content.trim().length === 0) {
    throw new ApiError(400, 'Cannot publish an empty draft');
  }

  // Transaction: Create Poem, update Draft state, trigger notifications
  const poem = await prisma.$transaction(async (tx) => {
    const createdPoem = await tx.poem.create({
      data: {
        authorId: userId,
        title: draft.title,
        content: draft.content,
        language: draft.language,
        emotion: draft.emotion,
        theme: draft.theme,
        isPublished: true,
        draftId: draft.id,
      },
      include: {
        author: { select: { id: true, username: true, displayName: true, avatarUrl: true } },
        _count: { select: { reactions: true, hearts: true } },
      },
    });

    await tx.draft.update({
      where: { id: draft.id },
      data: { isPublished: true },
    });

    return createdPoem;
  });

  // Trigger publication notifications exactly once
  await createPublicationNotifications(poem.id, userId);

  res.status(201).json({ success: true, data: { poem } });
};
