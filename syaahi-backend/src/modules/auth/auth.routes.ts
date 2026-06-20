import { Router } from 'express';
import { asyncHandler } from '../../utils/asyncHandler';
import { authenticate } from '../../middleware/auth';
import { signupLimiter, loginLimiter } from '../../middleware/rateLimiter';
import { signup, login, me, logout } from './auth.controller';

const router = Router();

router.post('/signup', signupLimiter, asyncHandler(signup));
router.post('/login', loginLimiter, asyncHandler(login));
router.get('/me', authenticate, asyncHandler(me));
router.post('/logout', authenticate, asyncHandler(logout));

export default router;