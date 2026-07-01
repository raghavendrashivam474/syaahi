import { Router } from 'express';
import { asyncHandler } from '../../utils/asyncHandler';
import { authenticate } from '../../middleware/auth';
import { addReaction, removeReaction, getReactions } from './reactions.controller';

const router = Router();

// Public — anyone can see reactions on a poem
router.get('/:id/reactions', asyncHandler(getReactions));

// Authenticated — only logged-in users can react
router.post('/:id/reactions', authenticate, asyncHandler(addReaction));
router.delete('/:id/reactions/:type', authenticate, asyncHandler(removeReaction));

export default router;
