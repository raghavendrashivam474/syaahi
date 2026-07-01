import express from 'express';
import cors from 'cors';
import helmet from 'helmet';
import morgan from 'morgan';
import { env } from './config/env';
import { errorHandler } from './middleware/errorHandler';
import authRoutes from './modules/auth/auth.routes';
import poemRoutes from './modules/poems/poems.routes';
import userRoutes from './modules/users/users.routes';
import heartRoutes from './modules/heart/heart.routes';
import reactionRoutes from './modules/reactions/reactions.routes';
import { globalLimiter } from './middleware/rateLimiter';

const app = express();

app.set('trust proxy', 1);

app.use(helmet());
app.use(
  cors({
    origin: (origin, callback) => {
      if (!origin) return callback(null, true);

      if (env.NODE_ENV === 'development' && origin.startsWith('http://localhost')) {
        return callback(null, true);
      }

      const allowed = env.CORS_ORIGIN.split(',').map((o) => o.trim());
      if (allowed.includes(origin)) {
        return callback(null, true);
      }

      callback(new Error('CORS: origin ' + origin + ' not allowed'));
    },
    credentials: true,
  })
);
app.use(express.json({ limit: '1mb' }));
app.use(morgan(env.NODE_ENV === 'development' ? 'dev' : 'combined'));

app.use('/api/', globalLimiter);

app.get('/', (_req, res) => {
  res.json({ name: 'Syaahi API', version: '0.2.0', status: 'ok' });
});

app.get('/health', (_req, res) => {
  res.json({ status: 'healthy', timestamp: new Date().toISOString() });
});

app.use('/api/v1/auth', authRoutes);
app.use('/api/v1/poems', poemRoutes);
app.use('/api/v1/users', userRoutes);
app.use('/api/v1/poems', heartRoutes);
app.use('/api/v1/users', heartRoutes);
app.use('/api/v1/poems', reactionRoutes);

app.use((_req, res) => {
  res.status(404).json({ success: false, message: 'Route not found' });
});

app.use(errorHandler);

export default app;
