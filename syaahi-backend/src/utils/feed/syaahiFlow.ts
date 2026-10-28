/**
 * Syaahi Flow — Literary Sequencing Engine
 *
 * Syaahi Flow is not a recommendation engine.
 * It is a literary sequencing engine.
 *
 * Its purpose is to improve the reading experience by distributing
 * poems from different authors naturally across the feed, without
 * introducing popularity ranking, randomisation, or engagement signals.
 *
 * Design Principles:
 * - Deterministic: same input always produces same output
 * - Pure: no side effects, original array is never mutated
 * - Chronologically aware: recency is preserved as much as possible
 * - Author-aware: avoids consecutive poems by the same author
 * - Distribution-preserving: natural platform distribution is maintained
 * - Engagement-blind: reactions, hearts, and views play no role
 *
 * Algorithm:
 * 1. Accept a window of poems (pre-sorted by createdAt DESC from DB)
 * 2. Group poems by author, preserving internal chronological order
 * 3. Interleave author groups using a round-robin pass
 * 4. On each position, prefer the most recent poem from any author
 *    who did not write the previous poem
 * 5. If all remaining poems are from the same author, allow consecutive
 * 6. Return the sequenced window, sliced to pageSize
 *
 * Named: Syaahi Flow
 * Version: 1.0.0
 */

import { FeedPoem, FeedOptions, FeedStrategy } from './feedStrategy';

export const syaahiFlow: FeedStrategy = (
  poems: FeedPoem[],
  options: FeedOptions
): FeedPoem[] => {
  if (poems.length === 0) return [];
  if (poems.length === 1) return [poems[0]];

  // Work on a shallow copy — never mutate the original
  const pool = [...poems];

  // Group poems by author, each group sorted by createdAt DESC (most recent first)
  const authorGroups = new Map<string, FeedPoem[]>();

  for (const poem of pool) {
    const group = authorGroups.get(poem.authorId) ?? [];
    group.push(poem);
    authorGroups.set(poem.authorId, group);
  }

  // Each group is already in DESC order because the pool came from DB sorted DESC
  // Convert to array of queues (each queue = one author's poems, most recent first)
  const queues: FeedPoem[][] = Array.from(authorGroups.values());

  const result: FeedPoem[] = [];
  let lastAuthorId: string | null = null;

  while (result.length < options.windowSize && queues.some((q) => q.length > 0)) {
    // Among all non-empty queues, find the best candidate:
    // - Not the same author as last placed poem (if alternatives exist)
    // - Most recent createdAt among eligible candidates

    const nonEmpty = queues.filter((q) => q.length > 0);

    if (nonEmpty.length === 0) break;

    // Prefer queues from different authors than last placed
    const eligible = options.preventConsecutiveAuthors
      ? nonEmpty.filter((q) => q[0].authorId !== lastAuthorId)
      : nonEmpty;

    // If all remaining are from same author, fall back to all non-empty
    const candidates = eligible.length > 0 ? eligible : nonEmpty;

    // Among candidates, pick the queue whose head poem is most recent
    let bestQueue = candidates[0];
    for (let i = 1; i < candidates.length; i++) {
      if (candidates[i][0].createdAt > bestQueue[0].createdAt) {
        bestQueue = candidates[i];
      }
    }

    // Take the head poem from the best queue
    const chosen = bestQueue.shift()!;
    result.push(chosen);
    lastAuthorId = chosen.authorId;
  }

  return result.slice(0, options.pageSize);
};
