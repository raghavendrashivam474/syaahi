import { Router } from 'express';
import { asyncHandler } from '../../utils/asyncHandler';
import { authenticate } from '../../middleware/auth';
import { writeLimiter } from '../../middleware/rateLimiter';
import {
  createResponse,
  listResponses,
  updateResponse,
  deleteResponse,
  createReply,
  updateReply,
  deleteReply,
} from './resonance.controller';

const router = Router();

// Poem response routes
router.post(
  '/poems/:poemId/resonances',
  authenticate,
  writeLimiter,
  asyncHandler(createResponse)
);

router.get(
  '/poems/:poemId/resonances',
  asyncHandler(listResponses)
);

// Response modification routes
router.patch(
  '/resonances/:responseId',
  authenticate,
  asyncHandler(updateResponse)
);

router.delete(
  '/resonances/:responseId',
  authenticate,
  asyncHandler(deleteResponse)
);

// Author reply routes
router.post(
  '/resonances/:responseId/reply',
  authenticate,
  writeLimiter,
  asyncHandler(createReply)
);

router.patch(
  '/resonance-replies/:replyId',
  authenticate,
  asyncHandler(updateReply)
);

router.delete(
  '/resonance-replies/:replyId',
  authenticate,
  asyncHandler(deleteReply)
);

export default router;