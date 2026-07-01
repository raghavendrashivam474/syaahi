/**
 * FeedStrategy
 *
 * A pluggable interface for feed sequencing algorithms.
 * All feed strategies must accept a list of poems and options,
 * and return a reordered list of poems.
 *
 * Strategies must be:
 * - Pure (no side effects)
 * - Deterministic (same input always produces same output)
 * - Non-destructive (original array is not mutated)
 */

export interface FeedPoem {
  id: string;
  authorId: string;
  createdAt: Date;
  [key: string]: unknown;
}

export interface FeedOptions {
  /** Number of poems per page */
  pageSize: number;
  /** How many poems to pull from DB before sequencing */
  windowSize: number;
  /** Prevent consecutive poems by the same author when alternatives exist */
  preventConsecutiveAuthors: boolean;
  /** Preserve the natural distribution of authors */
  preserveDistribution: boolean;
}

export const DEFAULT_FEED_OPTIONS: FeedOptions = {
  pageSize: 10,
  windowSize: 50,
  preventConsecutiveAuthors: true,
  preserveDistribution: true,
};

export type FeedStrategy = (poems: FeedPoem[], options: FeedOptions) => FeedPoem[];
