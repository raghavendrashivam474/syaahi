import rateLimit from 'express-rate-limit';

/**
 * Global safety-net limiter — applied to all routes.
 */
export const globalLimiter = rateLimit({
  windowMs: 15 * 60 * 1000, // 15 minutes
  max: 300,
  standardHeaders: true,
  legacyHeaders: false,
  message: {
    success: false,
    message: 'Too many requests, please try again later.',
  },
});

/**
 * Auth limiter — strict to prevent brute force.
 * 10 login attempts per 15 minutes per IP.
 */
export const loginLimiter = rateLimit({
  windowMs: 15 * 60 * 1000,
  max: 10,
  standardHeaders: true,
  legacyHeaders: false,
  skipSuccessfulRequests: true,
  // Skip rate limiting in development (allows seeding)
  skip: () => process.env.NODE_ENV === 'development',
  message: {
    success: false,
    message: 'Too many login attempts. Try again in 15 minutes.',
  },
});

/**
 * Signup limiter — prevents mass account creation.
 * 5 signups per hour per IP.
 */
export const signupLimiter = rateLimit({
  windowMs: 60 * 60 * 1000,
  max: 5,
  standardHeaders: true,
  legacyHeaders: false,
  // Skip rate limiting in development (allows seeding)
  skip: () => process.env.NODE_ENV === 'development',
  message: {
    success: false,
    message: 'Too many signup attempts. Try again in an hour.',
  },
});

/**
 * Write-action limiter — anti-spam for creates.
 * 30 writes per hour per IP.
 */
export const writeLimiter = rateLimit({
  windowMs: 60 * 60 * 1000, // 1 hour
  max: 30,
  standardHeaders: true,
  legacyHeaders: false,
  message: {
    success: false,
    message: 'You are writing too fast. Slow down and breathe.',
  },
});