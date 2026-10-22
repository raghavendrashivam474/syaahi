import { PrismaClient } from '@prisma/client';
import jwt from 'jsonwebtoken';
import http from 'http';
import app from '../app';
import { env } from '../config/env';

const prisma = new PrismaClient();

async function runTests() {
  console.log("==================================================");
  console.log("  N2 NOTIFICATION API INTEGRATION TESTS");
  console.log("==================================================\n");

  let passed = 0;
  let failed = 0;

  function assert(condition: boolean, testName: string, detail?: string) {
    if (condition) {
      console.log(` ✅ PASS: ${testName}`);
      passed++;
    } else {
      console.error(` ❌ FAIL: ${testName} ${detail ? '- ' + detail : ''}`);
      failed++;
    }
  }

  // Start Express on a random port
  const server = await new Promise<http.Server>((resolve) => {
    const s = app.listen(0, () => resolve(s));
  });
  const addr = server.address() as { port: number };
  const baseUrl = `http://127.0.0.1:${addr.port}`;

  const cleanUserIds: string[] = [];

  try {
    // ── Setup: 3 users ──
    const ts = Date.now();
    const userA = await prisma.user.create({
      data: { email: `n2a_${ts}@syaahi.test`, username: `n2a_${ts}`, displayName: 'N2 A', passwordHash: 'h' },
    });
    cleanUserIds.push(userA.id);

    const userB = await prisma.user.create({
      data: { email: `n2b_${ts}@syaahi.test`, username: `n2b_${ts}`, displayName: 'N2 B', passwordHash: 'h' },
    });
    cleanUserIds.push(userB.id);

    const author = await prisma.user.create({
      data: { email: `n2auth_${ts}@syaahi.test`, username: `n2auth_${ts}`, displayName: 'N2 Auth', passwordHash: 'h' },
    });
    cleanUserIds.push(author.id);

    const tokenA = jwt.sign({ userId: userA.id, email: userA.email }, env.JWT_SECRET);
    const tokenB = jwt.sign({ userId: userB.id, email: userB.email }, env.JWT_SECRET);

    async function api(path: string, token?: string, opts: RequestInit = {}) {
      const h: Record<string, string> = { 'Content-Type': 'application/json' };
      if (token) h['Authorization'] = `Bearer ${token}`;
      return fetch(`${baseUrl}${path}`, {
        ...opts,
        headers: { ...h, ...(opts.headers as Record<string, string>) },
      });
    }

    // ── Setup: poems + notifications ──
    const poem1 = await prisma.poem.create({ data: { authorId: author.id, title: 'P1', content: 'c' } });
    const poem2 = await prisma.poem.create({ data: { authorId: author.id, title: 'P2', content: 'c' } });
    const poem3 = await prisma.poem.create({ data: { authorId: author.id, title: 'P3', content: 'c' } });

    const n1 = await prisma.notification.create({
      data: { recipientId: userA.id, poemId: poem1.id, type: 'POEM_PUBLISHED' },
    });
    await new Promise(r => setTimeout(r, 15));
    const n2 = await prisma.notification.create({
      data: { recipientId: userA.id, poemId: poem2.id, type: 'POEM_PUBLISHED' },
    });
    await new Promise(r => setTimeout(r, 15));
    const n3 = await prisma.notification.create({
      data: { recipientId: userA.id, poemId: poem3.id, type: 'POEM_PUBLISHED' },
    });

    const nB = await prisma.notification.create({
      data: { recipientId: userB.id, poemId: poem1.id, type: 'POEM_PUBLISHED' },
    });

    // ══════════════════════════════════════
    //  INBOX
    // ══════════════════════════════════════
    console.log('\n── Inbox ──');

    let res = await api('/api/v1/notifications', tokenA);
    let body: any = await res.json();
    assert(res.status === 200 && body.success && body.data.items.length === 3,
      'Inbox: userA gets 3 notifications');

    assert(body.data.items[0].id === n3.id && body.data.items[2].id === n1.id,
      'Inbox: ordered newest-first');

    res = await api('/api/v1/notifications', tokenB);
    body = await res.json();
    assert(body.data.items.length === 1 && body.data.items[0].id === nB.id,
      'Inbox: userB sees only their 1 notification');

    res = await api('/api/v1/notifications?limit=2', tokenA);
    body = await res.json();
    assert(body.data.items.length === 2 && body.data.nextCursor !== null,
      'Inbox: limit=2 returns 2 items + cursor');

    res = await api('/api/v1/notifications?limit=999', tokenA);
    assert(res.status === 400, 'Inbox: limit=999 rejected (>50)');

    res = await api('/api/v1/notifications?limit=0', tokenA);
    assert(res.status === 400, 'Inbox: limit=0 rejected (<1)');

    // Cursor pagination
    res = await api('/api/v1/notifications?limit=2', tokenA);
    body = await res.json();
    const cursor = body.data.nextCursor;
    res = await api(`/api/v1/notifications?limit=2&cursor=${cursor}`, tokenA);
    body = await res.json();
    assert(body.data.items.length === 1 && body.data.nextCursor === null,
      'Inbox: cursor page 2 returns remaining 1 item');

    res = await api('/api/v1/notifications?cursor=not-a-uuid', tokenA);
    assert(res.status === 400, 'Inbox: invalid cursor rejected');

    res = await api('/api/v1/notifications?limit=abc', tokenA);
    assert(res.status === 400, 'Inbox: non-numeric limit rejected');

    // ══════════════════════════════════════
    //  UNREAD COUNT
    // ══════════════════════════════════════
    console.log('\n── Unread Count ──');

    res = await api('/api/v1/notifications/unread-count', tokenA);
    body = await res.json();
    assert(body.data.unreadCount === 3, 'Unread: userA has 3 unread');

    res = await api('/api/v1/notifications/unread-count', tokenB);
    body = await res.json();
    assert(body.data.unreadCount === 1, 'Unread: userB has 1 unread');

    // ══════════════════════════════════════
    //  MARK ONE READ
    // ══════════════════════════════════════
    console.log('\n── Mark One Read ──');

    res = await api(`/api/v1/notifications/${n1.id}/read`, tokenA, { method: 'PATCH' });
    body = await res.json();
    assert(res.status === 200 && body.data.read === true, 'MarkOne: n1 marked read');

    res = await api('/api/v1/notifications/unread-count', tokenA);
    body = await res.json();
    assert(body.data.unreadCount === 2, 'MarkOne: count dropped to 2');

    // Idempotent
    res = await api(`/api/v1/notifications/${n1.id}/read`, tokenA, { method: 'PATCH' });
    body = await res.json();
    assert(res.status === 200 && body.data.read === true, 'MarkOne: idempotent re-read ok');

    // Nonexistent
    res = await api('/api/v1/notifications/00000000-0000-0000-0000-000000000000/read', tokenA, { method: 'PATCH' });
    assert(res.status === 404, 'MarkOne: nonexistent ID → 404');

    // Malformed
    res = await api('/api/v1/notifications/not-a-uuid/read', tokenA, { method: 'PATCH' });
    assert(res.status === 400, 'MarkOne: malformed ID → 400');

    // Cross-user
    res = await api(`/api/v1/notifications/${n2.id}/read`, tokenB, { method: 'PATCH' });
    assert(res.status === 404, 'MarkOne: userB cannot mark userA n2 → 404');

    const n2Check = await prisma.notification.findUnique({ where: { id: n2.id } });
    assert(n2Check?.readAt === null, 'MarkOne: userA n2 still unread after cross-user attempt');

    // ══════════════════════════════════════
    //  MARK ALL READ
    // ══════════════════════════════════════
    console.log('\n── Mark All Read ──');

    res = await api('/api/v1/notifications/read-all', tokenA, { method: 'PATCH' });
    body = await res.json();
    assert(res.status === 200 && body.data.markedCount === 2, 'MarkAll: marked 2 remaining');

    res = await api('/api/v1/notifications/unread-count', tokenA);
    body = await res.json();
    assert(body.data.unreadCount === 0, 'MarkAll: count now 0');

    res = await api('/api/v1/notifications/read-all', tokenA, { method: 'PATCH' });
    body = await res.json();
    assert(body.data.markedCount === 0, 'MarkAll: idempotent → 0 newly marked');

    res = await api('/api/v1/notifications/unread-count', tokenB);
    body = await res.json();
    assert(body.data.unreadCount === 1, 'MarkAll: userB unread untouched');

    // ══════════════════════════════════════
    //  PREFERENCES — READ
    // ══════════════════════════════════════
    console.log('\n── Preferences Read ──');

    res = await api('/api/v1/notification-preferences', tokenA);
    body = await res.json();
    assert(res.status === 200 && body.data.newPoemAlerts === false,
      'PrefRead: missing row → default false');

    const prefCheck = await prisma.notificationPreference.findUnique({ where: { userId: userA.id } });
    assert(prefCheck === null, 'PrefRead: GET did not create a DB row');

    // ══════════════════════════════════════
    //  PREFERENCES — UPDATE
    // ══════════════════════════════════════
    console.log('\n── Preferences Update ──');

    res = await api('/api/v1/notification-preferences', tokenA, {
      method: 'PATCH', body: JSON.stringify({ newPoemAlerts: true }),
    });
    body = await res.json();
    assert(res.status === 200 && body.data.newPoemAlerts === true, 'PrefUpdate: enabled true');

    res = await api('/api/v1/notification-preferences', tokenA);
    body = await res.json();
    assert(body.data.newPoemAlerts === true, 'PrefUpdate: read-back confirms true');

    res = await api('/api/v1/notification-preferences', tokenA, {
      method: 'PATCH', body: JSON.stringify({ newPoemAlerts: false }),
    });
    body = await res.json();
    assert(body.data.newPoemAlerts === false, 'PrefUpdate: disabled false');

    res = await api('/api/v1/notification-preferences', tokenA, {
      method: 'PATCH', body: JSON.stringify({ newPoemAlerts: 'true' }),
    });
    assert(res.status === 400, 'PrefUpdate: string "true" rejected');

    res = await api('/api/v1/notification-preferences', tokenA, {
      method: 'PATCH', body: JSON.stringify({ newPoemAlerts: null }),
    });
    assert(res.status === 400, 'PrefUpdate: null rejected');

    res = await api('/api/v1/notification-preferences', tokenA, {
      method: 'PATCH', body: JSON.stringify({ newPoemAlerts: 1 }),
    });
    assert(res.status === 400, 'PrefUpdate: number 1 rejected');

    res = await api('/api/v1/notification-preferences', tokenA, {
      method: 'PATCH', body: JSON.stringify({ newPoemAlerts: true, spam: true }),
    });
    assert(res.status === 400, 'PrefUpdate: extra fields rejected');

    res = await api('/api/v1/notification-preferences', tokenA, {
      method: 'PATCH', body: JSON.stringify({}),
    });
    assert(res.status === 400, 'PrefUpdate: empty body rejected');

    // Cross-user isolation
    await api('/api/v1/notification-preferences', tokenA, {
      method: 'PATCH', body: JSON.stringify({ newPoemAlerts: true }),
    });
    await api('/api/v1/notification-preferences', tokenB, {
      method: 'PATCH', body: JSON.stringify({ newPoemAlerts: false }),
    });
    const prefA = await prisma.notificationPreference.findUnique({ where: { userId: userA.id } });
    assert(prefA?.newPoemAlerts === true, 'PrefUpdate: userB update did not affect userA');

    // ══════════════════════════════════════
    //  AUTH REJECTION (all 6 endpoints)
    // ══════════════════════════════════════
    console.log('\n── Auth Rejection ──');

    const unauthEndpoints: [string, string][] = [
      ['GET', '/api/v1/notifications'],
      ['GET', '/api/v1/notifications/unread-count'],
      ['PATCH', `/api/v1/notifications/${n1.id}/read`],
      ['PATCH', '/api/v1/notifications/read-all'],
      ['GET', '/api/v1/notification-preferences'],
      ['PATCH', '/api/v1/notification-preferences'],
    ];

    for (const [method, path] of unauthEndpoints) {
      res = await api(path, undefined, { method });
      assert(res.status === 401, `Auth: ${method} ${path} → 401`);
    }

  } catch (err: any) {
    console.error('Unexpected test error:', err);
    failed++;
  } finally {
    if (cleanUserIds.length > 0) {
      await prisma.user.deleteMany({ where: { id: { in: cleanUserIds } } });
    }
    server.close();
    await prisma.$disconnect();
  }

  console.log('\n--------------------------------------------------');
  console.log(`  RESULTS: ${passed} Passed, ${failed} Failed`);
  console.log('--------------------------------------------------');

  if (failed > 0) process.exit(1);
}

runTests();
