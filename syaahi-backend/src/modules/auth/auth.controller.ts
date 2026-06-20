import { Request, Response } from 'express';
import bcrypt from 'bcryptjs';
import jwt from 'jsonwebtoken';
import { prisma } from '../../config/prisma';
import { env } from '../../config/env';
import { ApiError } from '../../utils/ApiError';
import { signupSchema, loginSchema } from './auth.schemas';

const signToken = (userId: string, email: string) =>
  jwt.sign({ userId, email }, env.JWT_SECRET, { expiresIn: env.JWT_EXPIRES_IN } as jwt.SignOptions);

export const signup = async (req: Request, res: Response) => {
  const data = signupSchema.parse(req.body);

  const existing = await prisma.user.findFirst({
    where: { OR: [{ email: data.email }, { username: data.username }] },
  });
  if (existing) {
    throw new ApiError(409, 'Email or username already in use');
  }

  const passwordHash = await bcrypt.hash(data.password, 12);

  const user = await prisma.user.create({
    data: {
      email: data.email,
      username: data.username,
      displayName: data.displayName,
      passwordHash,
    },
    select: {
      id: true,
      email: true,
      username: true,
      displayName: true,
      bio: true,
      avatarUrl: true,
      createdAt: true,
    },
  });

  const token = signToken(user.id, user.email);

  res.status(201).json({ success: true, data: { user, token } });
};

export const login = async (req: Request, res: Response) => {
  const { email, password } = loginSchema.parse(req.body);

  const user = await prisma.user.findUnique({ where: { email } });
  if (!user) throw new ApiError(401, 'Invalid credentials');

  const valid = await bcrypt.compare(password, user.passwordHash);
  if (!valid) throw new ApiError(401, 'Invalid credentials');

  const token = signToken(user.id, user.email);

  const { passwordHash: _ph, ...safeUser } = user;
  res.json({ success: true, data: { user: safeUser, token } });
};

export const me = async (req: Request, res: Response) => {
  const user = await prisma.user.findUnique({
    where: { id: req.user!.userId },
    select: {
      id: true,
      email: true,
      username: true,
      displayName: true,
      bio: true,
      avatarUrl: true,
      createdAt: true,
      _count: { select: { poems: true, followers: true, following: true } },
    },
  });

  if (!user) throw new ApiError(404, 'User not found');
  res.json({ success: true, data: { user } });
};

/**
 * POST /api/v1/auth/logout
 * Symbolic logout — client must discard the token.
 * (Real token invalidation requires a blacklist; deferred to post-MVP.)
 */
export const logout = async (req: Request, res: Response) => {
  // Future: persist a "revoked tokens" record here when we add Redis.
  console.log(`👋 User ${req.user!.email} logged out`);

  res.json({
    success: true,
    data: {
      message: 'Logged out. Please discard the token on the client.',
    },
  });
};