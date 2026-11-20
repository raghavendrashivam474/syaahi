import { prisma } from '../config/prisma';
import jwt from 'jsonwebtoken';
import { env } from '../config/env';
import app from '../app';
import http from 'http';

function createToken(userId: string, email: string) {
  return jwt.sign({ userId, email }, env.JWT_SECRET, { expiresIn: '1h' });
}

let server: http.Server;
let baseUrl: string;

async function request(
  method: string,
  path: string,
  token?: string,
  body?: Record<string, any>
) {
  const headers: Record<string, string> = { 'Content-Type': 'application/json' };
  if (token) headers['Authorization'] = `Bearer ${token}`;

  const res = await fetch(`${baseUrl}${path}`, {
    method,
    headers,
    body: body ? JSON.stringify(body) : undefined,
  });

  const json = await res.json().catch(() => ({}));
  return { status: res.status, body: json };
}

async function runStudioTests() {
  console.log('==================================================');
  console.log('  ST-01 STUDIO DRAFT API AUTOMATED TESTS');
  console.log('==================================================');

  // Setup test HTTP server
  await new Promise<void>((resolve) => {
    server = app.listen(0, () => {
      const address = server.address() as any;
      baseUrl = `http://localhost:${address.port}`;
      resolve();
    });
  });

  let passed = 0;
  let failed = 0;

  function assert(condition: boolean, name: string) {
    if (condition) {
      console.log(` ✅ PASS: ${name}`);
      passed++;
    } else {
      console.log(` ❌ FAIL: ${name}`);
      failed++;
    }
  }

  // Create test users
  const userA = await prisma.user.create({
    data: {
      email: `test_studio_a_${Date.now()}@syaahi.test`,
      username: `studio_user_a_${Date.now()}`,
      displayName: 'Studio Author A',
      passwordHash: 'hashed_pw',
    },
  });

  const userB = await prisma.user.create({
    data: {
      email: `test_studio_b_${Date.now()}@syaahi.test`,
      username: `studio_user_b_${Date.now()}`,
      displayName: 'Studio Author B',
      passwordHash: 'hashed_pw',
    },
  });

  const tokenA = createToken(userA.id, userA.email);
  const tokenB = createToken(userB.id, userB.email);

  let draftIdA: string;

  try {
    // 1. Unauthenticated Request Rejection
    const unauthRes = await request('GET', '/api/v1/studio/drafts');
    assert(unauthRes.status === 401, 'Unauthenticated draft request rejected with 401');

    // 2. Create Draft (User A)
    const createRes = await request('POST', '/api/v1/studio/drafts', tokenA, {
      title: 'First Studio Draft',
      content: 'Whispers in the quiet night...',
      language: 'ENGLISH',
      emotion: 'SOLITUDE',
    });
    assert(createRes.status === 201 && createRes.body.data.draft.id, 'User A created a draft');
    draftIdA = createRes.body.data.draft.id;

    // 3. List Drafts (User A)
    const listARes = await request('GET', '/api/v1/studio/drafts', tokenA);
    assert(
      listARes.status === 200 && listARes.body.data.drafts.length === 1,
      'User A lists their draft'
    );

    // 4. Cross-User Isolation: List Drafts (User B)
    const listBRes = await request('GET', '/api/v1/studio/drafts', tokenB);
    assert(
      listBRes.status === 200 && listBRes.body.data.drafts.length === 0,
      'User B lists 0 drafts (User A draft isolated)'
    );

    // 5. Retrieve Draft (User A)
    const getARes = await request('GET', `/api/v1/studio/drafts/${draftIdA}`, tokenA);
    assert(
      getARes.status === 200 && getARes.body.data.draft.title === 'First Studio Draft',
      'User A retrieves their draft'
    );

    // 6. Cross-User Isolation: Get Draft (User B)
    const getBRes = await request('GET', `/api/v1/studio/drafts/${draftIdA}`, tokenB);
    assert(
      getBRes.status === 404,
      'User B attempted access to User A draft -> 404 Not Found'
    );

    // 7. Update Draft (User A)
    const updateRes = await request('PATCH', `/api/v1/studio/drafts/${draftIdA}`, tokenA, {
      title: 'Updated Studio Draft',
      content: 'Updated content of the poem...',
    });
    assert(
      updateRes.status === 200 && updateRes.body.data.draft.title === 'Updated Studio Draft',
      'User A updated their draft'
    );

    // 8. Cross-User Isolation: Update Draft (User B)
    const updateBRes = await request('PATCH', `/api/v1/studio/drafts/${draftIdA}`, tokenB, {
      title: 'Hacked Title',
    });
    assert(updateBRes.status === 404, 'User B attempted update on User A draft -> 404');

    // 9. Public Feed Isolation: Ensure draft does not appear in /api/v1/poems
    const feedRes = await request('GET', '/api/v1/poems');
    const inFeed = feedRes.body.data?.poems?.some((p: any) => p.title === 'Updated Studio Draft');
    assert(!inFeed, 'Unpublished draft does NOT leak into public feed');

    // 10. Controlled Draft Publication
    const publishRes = await request(
      'POST',
      `/api/v1/studio/drafts/${draftIdA}/publish`,
      tokenA
    );
    assert(
      publishRes.status === 201 && publishRes.body.data.poem.id,
      'Controlled draft publication created a public Poem'
    );

    const poemId = publishRes.body.data.poem.id;

    // 11. Feed Verification: Published poem IS visible in public feed
    const feedAfterRes = await request('GET', '/api/v1/poems');
    const nowInFeed = feedAfterRes.body.data?.poems?.some((p: any) => p.id === poemId);
    assert(nowInFeed, 'Published poem IS present in public feed');

    // 12. Idempotent Publication / Double Publish Guard
    const rePublishRes = await request(
      'POST',
      `/api/v1/studio/drafts/${draftIdA}/publish`,
      tokenA
    );
    assert(
      rePublishRes.status === 200 && rePublishRes.body.data.poem.id === poemId,
      'Re-publish request is idempotent and returns existing poem'
    );

    // 13. Delete Draft (User A)
    const draft2Res = await request('POST', '/api/v1/studio/drafts', tokenA, {
      content: 'Draft to delete',
    });
    const draft2Id = draft2Res.body.data.draft.id;

    const delBRes = await request('DELETE', `/api/v1/studio/drafts/${draft2Id}`, tokenB);
    assert(delBRes.status === 404, 'User B attempted deletion of User A draft -> 404');

    const delARes = await request('DELETE', `/api/v1/studio/drafts/${draft2Id}`, tokenA);
    assert(delARes.status === 200, 'User A deleted their draft');

  } finally {
    // Cleanup test data
    await prisma.draft.deleteMany({ where: { ownerId: { in: [userA.id, userB.id] } } });
    await prisma.poem.deleteMany({ where: { authorId: { in: [userA.id, userB.id] } } });
    await prisma.user.deleteMany({ where: { id: { in: [userA.id, userB.id] } } });

    server.close();
  }

  console.log('--------------------------------------------------');
  console.log(`  RESULTS: ${passed} Passed, ${failed} Failed`);
  console.log('--------------------------------------------------');

  if (failed > 0) process.exit(1);
}

runStudioTests().catch((e) => {
  console.error('Test runner fatal error:', e);
  process.exit(1);
});
