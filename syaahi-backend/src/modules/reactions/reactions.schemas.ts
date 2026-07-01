import { z } from 'zod';

export const reactionTypeSchema = z.enum([
  'FELT_THIS',
  'STAYED_WITH_ME',
  'BEAUTIFULLY_WRITTEN',
  'MADE_ME_THINK',
  'COMFORTED_ME',
  'INSPIRED_ME',
]);

export type ReactionTypeInput = z.infer<typeof reactionTypeSchema>;

/**
 * Human-readable labels for each reaction type.
 * Used in API responses so the frontend does not need to map them.
 */
export const REACTION_LABELS: Record<ReactionTypeInput, string> = {
  FELT_THIS: 'I Felt This',
  STAYED_WITH_ME: 'This Stayed With Me',
  BEAUTIFULLY_WRITTEN: 'Beautifully Written',
  MADE_ME_THINK: 'Made Me Think',
  COMFORTED_ME: 'Comforted Me',
  INSPIRED_ME: 'Inspired Me',
};
