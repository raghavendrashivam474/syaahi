import { Router } from 'express';
import { asyncHandler } from '../../utils/asyncHandler';
import { authenticate } from '../../middleware/auth';
import { writeLimiter } from '../../middleware/rateLimiter';
import {
  createDraft,
  listDrafts,
  getDraft,
  updateDraft,
  deleteDraft,
  publishDraft,
} from './studio.controller';

const router = Router();

// All draft endpoints are authenticated and owner-scoped
router.use(authenticate);

router.get('/', asyncHandler(listDrafts));
router.post('/', writeLimiter, asyncHandler(createDraft));
router.get('/:id', asyncHandler(getDraft));
router.patch('/:id', asyncHandler(updateDraft));
router.delete('/:id', asyncHandler(deleteDraft));
router.post('/:id/publish', writeLimiter, asyncHandler(publishDraft));

export default router;
