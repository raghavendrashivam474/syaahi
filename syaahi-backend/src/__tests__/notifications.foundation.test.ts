import { PrismaClient, Prisma } from '@prisma/client';

const prisma = new PrismaClient();

async function runTests() {
  console.log("==================================================");
  console.log("  N1 NOTIFICATION DATA FOUNDATION INTEGRITY TESTS  ");
  console.log("==================================================\n");

  let passed = 0;
  let failed = 0;

  function assert(condition: boolean, testName: string, detail?: string) {
    if (condition) {
      console.log(` ✅ PASS: ${testName}`);
      passed++;
    } else {
      console.error(` ❌ FAIL: ${testName} ${detail ? `- ${detail}` : ''}`);
      failed++;
    }
  }

  // Cleanup helper
  const cleanUserIds: string[] = [];

  try {
    // ── Setup Test Entities ──
    const author = await prisma.user.create({
      data: {
        email: `test_author_${Date.now()}@syaahi.test`,
        username: `test_author_${Date.now()}`,
        displayName: 'Test Author',
        passwordHash: 'hashed_password_123',
      },
    });
    cleanUserIds.push(author.id);

    const recipientA = await prisma.user.create({
      data: {
        email: `test_rec_a_${Date.now()}@syaahi.test`,
        username: `test_rec_a_${Date.now()}`,
        displayName: 'Recipient A',
        passwordHash: 'hashed_password_123',
      },
    });
    cleanUserIds.push(recipientA.id);

    const recipientB = await prisma.user.create({
      data: {
        email: `test_rec_b_${Date.now()}@syaahi.test`,
        username: `test_rec_b_${Date.now()}`,
        displayName: 'Recipient B',
        passwordHash: 'hashed_password_123',
      },
    });
    cleanUserIds.push(recipientB.id);

    const poem = await prisma.poem.create({
      data: {
        authorId: author.id,
        title: 'Test Integrity Poem',
        content: 'Testing notification schema persistence constraints.',
      },
    });

    // ── Test 1: Valid Notification Creation ──
    const notiA = await prisma.notification.create({
      data: {
        recipientId: recipientA.id,
        poemId: poem.id,
        type: 'POEM_PUBLISHED',
      },
    });
    assert(
      notiA.id !== undefined && notiA.readAt === null,
      '1. Valid Notification created with correct FKs and default readAt = null'
    );

    // ── Test 2: Duplicate Prevention ([recipientId, poemId, type]) ──
    let caughtDuplicateError = false;
    try {
      await prisma.notification.create({
        data: {
          recipientId: recipientA.id,
          poemId: poem.id,
          type: 'POEM_PUBLISHED',
        },
      });
    } catch (err: any) {
      if (err instanceof Prisma.PrismaClientKnownRequestError && err.code === 'P2002') {
        caughtDuplicateError = true;
      }
    }
    assert(
      caughtDuplicateError,
      '2. Unique constraint [recipientId, poemId, type] blocks duplicate insert (P2002)'
    );

    // ── Test 3: Distinct Recipients Allowed ──
    const notiB = await prisma.notification.create({
      data: {
        recipientId: recipientB.id,
        poemId: poem.id,
        type: 'POEM_PUBLISHED',
      },
    });
    assert(
      notiB.id !== undefined && notiB.id !== notiA.id,
      '3. Distinct recipients receive separate notifications for same poem'
    );

    // ── Test 4: Default Opt-In Preference is False ──
    const prefA = await prisma.notificationPreference.create({
      data: {
        userId: recipientA.id,
      },
    });
    assert(
      prefA.newPoemAlerts === false,
      '4. NotificationPreference newPoemAlerts defaults to false (explicit opt-in)'
    );

    // ── Test 5: Absent Preference Safety ──
    const prefLookupB = await prisma.notificationPreference.findUnique({
      where: { userId: recipientB.id },
    });
    const effectiveOptIn = prefLookupB?.newPoemAlerts ?? false;
    assert(
      prefLookupB === null && effectiveOptIn === false,
      '5. Absent NotificationPreference treats effective opt-in as false'
    );

    // ── Test 6: 1-to-1 Preference Uniqueness ──
    let caughtPrefDuplicate = false;
    try {
      await prisma.notificationPreference.create({
        data: {
          userId: recipientA.id,
          newPoemAlerts: true,
        },
      });
    } catch (err: any) {
      if (err instanceof Prisma.PrismaClientKnownRequestError && err.code === 'P2002') {
        caughtPrefDuplicate = true;
      }
    }
    assert(
      caughtPrefDuplicate,
      '6. NotificationPreference 1-to-1 userId constraint blocks duplicate row'
    );

    // ── Test 7: Cascade Delete on Poem ──
    const dummyPoem = await prisma.poem.create({
      data: {
        authorId: author.id,
        content: 'Temporary poem for cascade test',
      },
    });
    await prisma.notification.create({
      data: {
        recipientId: recipientA.id,
        poemId: dummyPoem.id,
        type: 'POEM_PUBLISHED',
      },
    });
    await prisma.poem.delete({ where: { id: dummyPoem.id } });
    const remainingNotiForDummy = await prisma.notification.findMany({
      where: { poemId: dummyPoem.id },
    });
    assert(
      remainingNotiForDummy.length === 0,
      '7. Deleting a Poem cascades and removes related Notifications'
    );

    // ── Test 8: Cascade Delete on User ──
    const dummyUser = await prisma.user.create({
      data: {
        email: `dummy_user_${Date.now()}@syaahi.test`,
        username: `dummy_user_${Date.now()}`,
        displayName: 'Dummy Cascade User',
        passwordHash: 'hash',
      },
    });
    await prisma.notificationPreference.create({
      data: { userId: dummyUser.id, newPoemAlerts: true },
    });
    await prisma.notification.create({
      data: {
        recipientId: dummyUser.id,
        poemId: poem.id,
        type: 'POEM_PUBLISHED',
      },
    });
    await prisma.user.delete({ where: { id: dummyUser.id } });

    const dummyNotis = await prisma.notification.findMany({
      where: { recipientId: dummyUser.id },
    });
    const dummyPref = await prisma.notificationPreference.findUnique({
      where: { userId: dummyUser.id },
    });
    assert(
      dummyNotis.length === 0 && dummyPref === null,
      '8. Deleting a User cascades and removes their Notifications and Preferences'
    );

  } catch (err: any) {
    console.error('Unexpected test error:', err);
    failed++;
  } finally {
    // ── Cleanup Test Users ──
    if (cleanUserIds.length > 0) {
      await prisma.user.deleteMany({
        where: { id: { in: cleanUserIds } },
      });
    }
    await prisma.$disconnect();
  }

  console.log('\n--------------------------------------------------');
  console.log(`  RESULTS: ${passed} Passed, ${failed} Failed`);
  console.log('--------------------------------------------------');

  if (failed > 0) {
    process.exit(1);
  }
}

runTests();
