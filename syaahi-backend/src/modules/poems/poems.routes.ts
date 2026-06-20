import { Router } from 'express';
import { asyncHandler } from '../../utils/asyncHandler';
import { authenticate } from '../../middleware/auth';
import {
  createPoem,
  listPoems,
  getPoem,
  updatePoem,
  deletePoem,
} from './poems.controller';

const router = Router();

router.get('/', asyncHandler(listPoems));
router.get('/:id', asyncHandler(getPoem));
router.post('/', authenticate, asyncHandler(createPoem));
router.patch('/:id', authenticate, asyncHandler(updatePoem));
router.delete('/:id', authenticate, asyncHandler(deletePoem));

export default router;