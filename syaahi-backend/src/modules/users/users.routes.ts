import { Router } from 'express';
import { asyncHandler } from '../../utils/asyncHandler';
import { authenticate } from '../../middleware/auth';
import { getUserProfile, getUserPoems, updateMe } from './users.controller';

const router = Router();

// Order matters: /me before /:username
router.patch('/me', authenticate, asyncHandler(updateMe));
router.get('/:username', asyncHandler(getUserProfile));
router.get('/:username/poems', asyncHandler(getUserPoems));

export default router;