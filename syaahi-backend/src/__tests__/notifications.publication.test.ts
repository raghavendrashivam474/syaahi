import { PrismaClient } from '@prisma/client';
import jwt from 'jsonwebtoken';
import http from 'http';
import app from '../app';
import { env } from '../config/env';

const prisma = new PrismaClient();

async function runTests() {
  console.log('==================================================');
  console.log('  N3 PUBLICATION EVENT NOTIFICATION TESTS');
  console.log('==================================================\n');

  let passed = 0;
  let failed = 0;

  function assert(condition: boolean, testName: string, detail?: string) {
    if (condition) {
      console.log(`  PASS: ${testName}`);
      passed++;
    } else {
      console.error(`  FAIL: ${testName} ${detail ? '- ' + detail : ''}`);
      failed++;
    }
  }

  const server = await new Promise<http.Server>((resolve) => {
    const s = app.listen(0, () => resolve(s));
  });
  const addr = server.address() as { port: number };
  const baseUrl = `http://127.0.0.1:${addr.port}`;

  const cleanUserIds: string[] = [];

  try {
    // ── Setup: 4 users ──
    const ts = Date.now();

    const author = await prisma.user.create({
      data: {
        email: `n3author_${ts}@syaahi.test`,
        username: `n3author_${ts}`,
        displayName: 'N3 Author',
        passwordHash: 'h',
      },
    });
    cleanUserIds.push(author.id);

    const recipientIn = await prisma.user.create({
      data: {
        email: `n3recin_${ts}@syaahi.test`,
        username: `n3recin_${ts}`,
        displayName: 'N3 Opted In',
        passwordHash: 'h',
      },
    });
    cleanUserIds.push(recipientIn.id);

    const recipientOut = await prisma.user.create({
      data: {
        email: `n3recout_${ts}@syaahi.test`,
        username: `n3recout_${ts}`,
        displayName: 'N3 Opted Out',
        passwordHash: 'h',
      },
    });
    cleanUserIds.push(recipientOut.id);

    const recipientNone = await prisma.user.create({
      data: {
        email: `n3recnone_${ts}@syaahi.test`,
        username: `n3recnone_${ts}`,
        displayName: 'N3 No Pref',
        passwordHash: 'h',
      },
    });
    cleanUserIds.push(recipientNone.id);

    // ── Setup: preferences ──
    await prisma.notificationPreference.create({
      data: { userId: recipientIn.id, newPoemAlerts: true },
    });
    await prisma.notificationPreference.create({
      data: { userId: recipientOut.id, newPoemAlerts: false },
    });
    // recipientNone: no preference row (default = false)

    const authorToken = jwt.sign(
      { userId: author.id, email: author.email },
      env.JWT_SECRET
    );
    const recipientInToken = jwt.sign(
      { userId: recipientIn.id, email: recipientIn.email },
      env.JWT_SECRET
    );

    async function api(path: string, token?: string, opts: RequestInit = {}) {
      const h: Record<string, string> = { 'Content-Type': 'application/json' };
      if (token) h['Authorization'] = `Bearer ${token}`;
      return fetch(`${baseUrl}${path}`, {
        ...opts,
        headers: { ...h, ...(opts.headers as Record<string, string>) },
      });
    }

    // ════════════════════════════════════════════════════════════════
    //  TEST 1: POST poem creates notification for opted-in recipient
    // ════════════════════════════════════════════════════════════════
    console.log('\n-- Test 1: Publication creates notification for opted-in user --');

    const res1 = await api('/api/v1/poems', authorToken, {
      method: 'POST',
      body: JSON.stringify({
        title: 'N3 Test Poem 1',
        content: 'Content for notification test',
      }),
    });
    const body1: any = await res1.json();
    assert(res1.status === 201 && body1.success, '1a. Poem created successfully');

    const poem1Id = body1.data.poem.id;

    const notisForIn = await prisma.notification.findMany({
      where: { recipientId: recipientIn.id, poemId: poem1Id, type: 'POEM_PUBLISHED' },
    });
    assert(
      notisForIn.length === 1,
      '1b. Opted-in recipient received exactly 1 POEM_PUBLISHED notification'
    );
    assert(
      notisForIn[0]?.readAt === null,
      '1c. New notification is unread (readAt = null)'
    );

    // ════════════════════════════════════════════════════════════════
    //  TEST 2: Author does NOT receive self-notification (ADR-025)
    // ════════════════════════════════════════════════════════════════
    console.log('\n-- Test 2: Author self-notification excluded (ADR-025) --');

    const notisForAuthor = await prisma.notification.findMany({
      where: { recipientId: author.id, poemId: poem1Id },
    });
    assert(
      notisForAuthor.length === 0,
      '2. Author received 0 notifications for own poem (ADR-025)'
    );

    // ════════════════════════════════════════════════════════════════
    //  TEST 3: Opted-out user does NOT receive notification
    // ════════════════════════════════════════════════════════════════
    console.log('\n-- Test 3: Opted-out user excluded --');

    const notisForOut = await prisma.notification.findMany({
      where: { recipientId: recipientOut.id, poemId: poem1Id },
    });
    assert(
      notisForOut.length === 0,
      '3. Opted-out recipient received 0 notifications'
    );

    // ════════════════════════════════════════════════════════════════
    //  TEST 4: No-preference user does NOT receive notification
    // ════════════════════════════════════════════════════════════════
    console.log('\n-- Test 4: No-preference user excluded (default false) --');

    const notisForNone = await prisma.notification.findMany({
      where: { recipientId: recipientNone.id, poemId: poem1Id },
    });
    assert(
      notisForNone.length === 0,
      '4. No-preference recipient received 0 notifications (default opt-out)'
    );

    // ════════════════════════════════════════════════════════════════
    //  TEST 5: PATCH false -> true triggers notifications
    // ════════════════════════════════════════════════════════════════
    console.log('\n-- Test 5: PATCH isPublished false -> true triggers notifications --');

    // Create an unpublished poem directly (API always publishes)
    const draftPoem = await prisma.poem.create({
      data: {
        authorId: author.id,
        title: 'N3 Draft Poem',
        content: 'Draft content',
        isPublished: false,
      },
    });

    // Verify no notifications exist for the draft
    const draftNotisBefore = await prisma.notification.findMany({
      where: { poemId: draftPoem.id },
    });
    assert(
      draftNotisBefore.length === 0,
      '5a. Draft poem has 0 notifications before publish'
    );

    // Publish via PATCH
    const res5 = await api(`/api/v1/poems/${draftPoem.id}`, authorToken, {
      method: 'PATCH',
      body: JSON.stringify({ isPublished: true }),
    });
    const body5: any = await res5.json();
    assert(res5.status === 200 && body5.success, '5b. PATCH publish succeeded');

    const draftNotisAfter = await prisma.notification.findMany({
      where: { recipientId: recipientIn.id, poemId: draftPoem.id, type: 'POEM_PUBLISHED' },
    });
    assert(
      draftNotisAfter.length === 1,
      '5c. Opted-in recipient notified after false -> true transition'
    );

    // ════════════════════════════════════════════════════════════════
    //  TEST 6: PATCH on already-published poem does NOT re-notify
    // ════════════════════════════════════════════════════════════════
    console.log('\n-- Test 6: Editing published poem does not re-notify --');

    const countBefore = await prisma.notification.count({
      where: { recipientId: recipientIn.id, poemId: poem1Id },
    });

    const res6 = await api(`/api/v1/poems/${poem1Id}`, authorToken, {
      method: 'PATCH',
      body: JSON.stringify({ title: 'Updated Title' }),
    });
    assert(res6.status === 200, '6a. PATCH edit succeeded');

    const countAfter = await prisma.notification.count({
      where: { recipientId: recipientIn.id, poemId: poem1Id },
    });
    assert(
      countAfter === countBefore,
      '6b. Editing published poem did not create additional notification'
    );

    // ════════════════════════════════════════════════════════════════
    //  TEST 7: Duplicate protection
    // ════════════════════════════════════════════════════════════════
    console.log('\n-- Test 7: Duplicate protection --');

    // The draft poem was already published in Test 5.
    // Try to PATCH it again with isPublished: true (already true now).
    const res7 = await api(`/api/v1/poems/${draftPoem.id}`, authorToken, {
      method: 'PATCH',
      body: JSON.stringify({ isPublished: true }),
    });
    assert(res7.status === 200, '7a. Re-PATCH isPublished:true succeeded');

    const dupNotis = await prisma.notification.count({
      where: { recipientId: recipientIn.id, poemId: draftPoem.id },
    });
    assert(
      dupNotis === 1,
      '7b. No duplicate notification after re-publish attempt (still 1)'
    );

    // ════════════════════════════════════════════════════════════════
    //  TEST 8: N2 Inbox integration
    // ════════════════════════════════════════════════════════════════
    console.log('\n-- Test 8: N2 Inbox shows N3-created notifications --');

    const res8 = await api('/api/v1/notifications', recipientInToken);
    const body8: any = await res8.json();
    assert(res8.status === 200 && body8.success, '8a. Inbox request succeeded');

    // recipientIn should have notifications for poem1 and draftPoem
    const poemIds = body8.data.items.map((n: any) => n.poemId);
    assert(
      poemIds.includes(poem1Id),
      '8b. Inbox contains notification for poem1'
    );
    assert(
      poemIds.includes(draftPoem.id),
      '8c. Inbox contains notification for draftPoem (published via PATCH)'
    );

    // Verify notification shape
    const sampleNoti = body8.data.items.find((n: any) => n.poemId === poem1Id);
    assert(
      sampleNoti?.type === 'POEM_PUBLISHED' && sampleNoti?.readAt === null,
      '8d. Notification has correct type and unread status'
    );

    // ════════════════════════════════════════════════════════════════
    //  TEST 9: N2 Unread Count integration
    // ════════════════════════════════════════════════════════════════
    console.log('\n-- Test 9: N2 Unread Count reflects N3 notifications --');

    const res9 = await api('/api/v1/notifications/unread-count', recipientInToken);
    const body9: any = await res9.json();
    assert(
      res9.status === 200 && body9.data.unreadCount >= 2,
      '9. Unread count >= 2 for recipientIn (poem1 + draftPoem)'
    );

    // Author should have 0 notifications
    const res9a = await api('/api/v1/notifications/unread-count', authorToken);
    const body9a: any = await res9a.json();
    assert(
      body9a.data.unreadCount === 0,
      '9b. Author unread count is 0 (ADR-025 confirmed via API)'
    );

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