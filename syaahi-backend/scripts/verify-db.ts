import { prisma } from '../src/config/prisma';

async function verify() {
  console.log('\n=== 📊 DATABASE VERIFICATION ===\n');

  // 1. Count all tables
  const counts = {
    users: await prisma.user.count(),
    poems: await prisma.poem.count(),
    reactions: await prisma.reaction.count(),
    follows: await prisma.follow.count(),
    rooms: await prisma.room.count(),
    roomMembers: await prisma.roomMember.count(),
    poemRooms: await prisma.poemRoom.count(),
  };
  console.log('Table row counts:', counts);

  // 2. Users with password hash safety check
  console.log('\n--- USERS ---');
  const users = await prisma.user.findMany({
    select: {
      id: true,
      email: true,
      username: true,
      displayName: true,
      bio: true,
      passwordHash: true,
      createdAt: true,
      _count: { select: { poems: true } },
    },
  });

  users.forEach((u) => {
    const hashPrefix = u.passwordHash.substring(0, 7);
    const isBcrypt = hashPrefix.startsWith('$2');
    console.log({
      id: u.id,
      email: u.email,
      username: u.username,
      displayName: u.displayName,
      bio: u.bio,
      poemCount: u._count.poems,
      passwordHashPrefix: hashPrefix + '...',
      isBcryptFormat: isBcrypt ? '✅ YES' : '❌ NO (DANGER!)',
      createdAt: u.createdAt,
    });
  });

  // 3. Poems with author relation
  console.log('\n--- POEMS ---');
  const poems = await prisma.poem.findMany({
    include: {
      author: { select: { username: true, displayName: true } },
    },
  });

  poems.forEach((p) => {
    console.log({
      id: p.id,
      title: p.title,
      contentPreview: p.content.substring(0, 50) + '...',
      language: p.language,
      emotion: p.emotion,
      theme: p.theme,
      isPublished: p.isPublished,
      author: p.author.username + ' (' + p.author.displayName + ')',
      createdAt: p.createdAt,
    });
  });

  // 4. FK integrity (orphan check via raw count)
  console.log('\n--- FK INTEGRITY ---');
  const allPoemAuthorIds = await prisma.poem.findMany({
    select: { authorId: true },
  });
  const allUserIds = await prisma.user.findMany({ select: { id: true } });
  const userIdSet = new Set(allUserIds.map((u) => u.id));
  const orphans = allPoemAuthorIds.filter((p) => !userIdSet.has(p.authorId));
  console.log(
    'Orphan poems (FK to non-existent user):',
    orphans.length,
    orphans.length === 0 ? '✅' : '❌'
  );

  // 5. Deferred tables check
  console.log('\n--- DEFERRED TABLES (should be 0) ---');
  console.log('Reactions:', counts.reactions, counts.reactions === 0 ? '✅' : '⚠️');
  console.log('Follows:', counts.follows, counts.follows === 0 ? '✅' : '⚠️');
  console.log('Rooms:', counts.rooms, counts.rooms === 0 ? '✅' : '⚠️');

  console.log('\n=== ✅ VERIFICATION COMPLETE ===\n');

  await prisma.$disconnect();
}

verify().catch((e) => {
  console.error('❌ Verification failed:', e);
  process.exit(1);
});