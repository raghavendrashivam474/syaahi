import { Router } from 'express';
import { asyncHandler } from '../../utils/asyncHandler';
import { authenticate } from '../../middleware/auth';
import {
  commitToHeart,
  removeFromHeart,
  getMyHeart,
  getHeartStatus,
} from './heart.controller';

const router = Router();

/**
 * All heart routes require authentication.
 * Hearts are private — no public endpoints.
 */

// My Heart collection
router.get('/me/heart', authenticate, asyncHandler(getMyHeart));

// Poem-level heart actions
router.get('/:id/heart/status', authenticate, asyncHandler(getHeartStatus));
router.post('/:id/heart', authenticate, asyncHandler(commitToHeart));
router.delete('/:id/heart', authenticate, asyncHandler(removeFromHeart));

export default router;
