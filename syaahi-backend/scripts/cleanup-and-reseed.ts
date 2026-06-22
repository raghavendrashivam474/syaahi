import { PrismaClient } from '@prisma/client';
import bcrypt from 'bcryptjs';

const prisma = new PrismaClient();

const SEED_EMAILS = [
  'raghav@syaahi.com',
  'midnight@syaahi.com',
  'sara@syaahi.com',
  'arjun@syaahi.com',
  'zara@syaahi.com',
  'aarav@syaahi.com',
  'meera@syaahi.com',
  'kabir@syaahi.com',
  'ananya@syaahi.com',
  'rizwan@syaahi.com',
];

interface SeedWriter {
  email: string;
  username: string;
  displayName: string;
  password: string;
  poems: {
    title: string;
    content: string;
    language: 'ENGLISH' | 'HINDI' | 'URDU';
    emotion: 'LOVE' | 'LONGING' | 'HOPE' | 'SOLITUDE' | 'ANGER' | 'GRATITUDE';
    theme: string;
  }[];
}

const writers: SeedWriter[] = [
  {
    email: 'raghav@syaahi.com',
    username: 'raghav_writes',
    displayName: 'Raghav',
    password: 'Syaahi@123',
    poems: [
      {
        title: 'पहली बारिश',
        content: `बारिश की पहली बूंद जब
ज़मीन से मिलती है,
तो मिट्टी की वो खुशबू
कुछ पुरानी यादें दिला जाती है।`,
        language: 'HINDI',
        emotion: 'LONGING',
        theme: 'nature',
      },
      {
        title: 'Still Here',
        content: `I did not write for months.
Not because I had nothing to say.
But because I had too much
and did not know where to begin.

I am beginning here.`,
        language: 'ENGLISH',
        emotion: 'HOPE',
        theme: 'writing',
      },
      {
        title: 'खामोशी',
        content: `कुछ बातें कही नहीं जातीं,
कुछ दर्द सुना नहीं जाता।
खामोशी भी एक ज़बान है,
जो दिल से दिल तक जाता है।`,
        language: 'HINDI',
        emotion: 'SOLITUDE',
        theme: 'silence',
      },
    ],
  },
  {
    email: 'midnight@syaahi.com',
    username: 'midnight_writer',
    displayName: 'Midnight',
    password: 'Syaahi@123',
    poems: [
      {
        title: '3 बजे',
        content: `रात के तीन बजे जब
सब सो जाते हैं,
मेरे ख्याल जागते हैं
और कागज़ पर बिखर जाते हैं।`,
        language: 'HINDI',
        emotion: 'SOLITUDE',
        theme: 'night',
      },
      {
        title: 'Gravity',
        content: `Some people leave
and you feel it
like a shift in gravity.

Everything still works.
You still breathe.
You still wake up.

But the ground
feels different
under your feet.`,
        language: 'ENGLISH',
        emotion: 'LONGING',
        theme: 'loss',
      },
      {
        title: 'कल',
        content: `कल फिर सूरज उगेगा,
कल फिर हवा चलेगी।
आज का ये अंधेरा भी,
कल एक याद बनेगी।`,
        language: 'HINDI',
        emotion: 'HOPE',
        theme: 'tomorrow',
      },
    ],
  },
  {
    email: 'sara@syaahi.com',
    username: 'sara_writes',
    displayName: 'Sara',
    password: 'Syaahi@123',
    poems: [
      {
        title: 'Unsent',
        content: `I wrote you a letter
I never sent.
It sits in my drawer
with all the things
I meant to say
but couldn't.`,
        language: 'ENGLISH',
        emotion: 'LONGING',
        theme: 'letters',
      },
      {
        title: 'Small Things',
        content: `Happiness is not always loud.

Sometimes it is
the first sip of chai
on a cold morning.

A song you forgot you loved.
A message from an old friend.
Rain on a Sunday.

Small things.
Quietly enough.`,
        language: 'ENGLISH',
        emotion: 'GRATITUDE',
        theme: 'everyday',
      },
      {
        title: 'अधूरी बात',
        content: `कुछ बातें होठों पर आकर
रुक जाती हैं।
न जाने किस डर से
दिल में ही दब जाती हैं।`,
        language: 'HINDI',
        emotion: 'LONGING',
        theme: 'unspoken',
      },
    ],
  },
  {
    email: 'arjun@syaahi.com',
    username: 'arjun_kavya',
    displayName: 'Arjun',
    password: 'Syaahi@123',
    poems: [
      {
        title: 'The Reader',
        content: `She reads like
the world outside
does not exist.

Maybe for her
it doesn't.

Maybe that is
the whole point.`,
        language: 'ENGLISH',
        emotion: 'LOVE',
        theme: 'books',
      },
      {
        title: 'वापसी',
        content: `कुछ लोग जाते हैं
और एक खालीपन छोड़ जाते हैं।
कुछ लोग आते हैं
और वो खालीपन भर जाते हैं।`,
        language: 'HINDI',
        emotion: 'HOPE',
        theme: 'people',
      },
      {
        title: 'Enough',
        content: `You do not have to be
extraordinary
every day.

Some days
showing up
is enough.

Some days
existing
is enough.`,
        language: 'ENGLISH',
        emotion: 'HOPE',
        theme: 'self',
      },
    ],
  },
  {
    email: 'zara@syaahi.com',
    username: 'zara_lafz',
    displayName: 'Zara',
    password: 'Syaahi@123',
    poems: [
      {
        title: 'इश्क़',
        content: `इश्क़ वो नहीं जो दिखता है,
इश्क़ वो है जो महसूस होता है।
जब कोई बिना कहे समझे,
तब दिल से दिल जुड़ता है।`,
        language: 'HINDI',
        emotion: 'LOVE',
        theme: 'love',
      },
      {
        title: 'Midnight Chai',
        content: `There is something honest
about making chai at midnight.

No one is watching.
No one is performing.

Just you
and the sound of milk
coming to a boil.`,
        language: 'ENGLISH',
        emotion: 'SOLITUDE',
        theme: 'night',
      },
      {
        title: 'यादें',
        content: `यादें भी अजीब होती हैं,
जब चाहो तब नहीं आतीं।
और जब भूलना चाहो,
तब पीछा नहीं छोड़तीं।`,
        language: 'HINDI',
        emotion: 'LONGING',
        theme: 'memories',
      },
    ],
  },
  {
    email: 'aarav@syaahi.com',
    username: 'aarav_thinks',
    displayName: 'Aarav',
    password: 'Syaahi@123',
    poems: [
      {
        title: 'Who Were You',
        content: `Every few years
you become
a different person.

The old you
did not die.
They just
made room.`,
        language: 'ENGLISH',
        emotion: 'HOPE',
        theme: 'identity',
      },
      {
        title: 'समय',
        content: `समय रुकता नहीं किसी के लिए,
न खुशी में, न गम में।
बस बहता रहता है,
एक नदी की तरह
चुपचाप।`,
        language: 'HINDI',
        emotion: 'SOLITUDE',
        theme: 'time',
      },
      {
        title: 'The Question',
        content: `I do not want answers.

I want better questions.
The kind that keep you
awake at 2am
not with worry
but with wonder.`,
        language: 'ENGLISH',
        emotion: 'HOPE',
        theme: 'existence',
      },
    ],
  },
  {
    email: 'meera@syaahi.com',
    username: 'meera_writes',
    displayName: 'Meera',
    password: 'Syaahi@123',
    poems: [
      {
        title: 'तुम्हारा इंतज़ार',
        content: `तुम्हारा इंतज़ार करना
एक आदत सी हो गई है।
जैसे सुबह की चाय,
जैसे रात की दुआ।`,
        language: 'HINDI',
        emotion: 'LOVE',
        theme: 'waiting',
      },
      {
        title: 'Your Handwriting',
        content: `I still have the note
you left on my desk
that Tuesday.

I cannot throw it away.

Your handwriting
feels like
the closest thing
to having you here.`,
        language: 'ENGLISH',
        emotion: 'LONGING',
        theme: 'memories',
      },
      {
        title: 'पहली मुलाक़ात',
        content: `वो पहली मुलाक़ात
आज भी याद है।
तुमने कुछ नहीं कहा था,
पर आँखों ने
सब कह दिया था।`,
        language: 'HINDI',
        emotion: 'LOVE',
        theme: 'love',
      },
    ],
  },
  {
    email: 'kabir@syaahi.com',
    username: 'kabir_outdoors',
    displayName: 'Kabir',
    password: 'Syaahi@123',
    poems: [
      {
        title: 'River Logic',
        content: `The river does not ask
where it is going.

It just moves.
Around rocks.
Through valleys.
Toward something
larger than itself.

I am trying
to learn from it.`,
        language: 'ENGLISH',
        emotion: 'HOPE',
        theme: 'rivers',
      },
      {
        title: 'बारिश के बाद',
        content: `बारिश के बाद की मिट्टी
कुछ अलग ही महकती है।
जैसे ज़मीन ने
आसमान को
अपने अंदर समेट लिया हो।`,
        language: 'HINDI',
        emotion: 'GRATITUDE',
        theme: 'rain',
      },
      {
        title: 'November',
        content: `November arrives quietly.

No announcement.
Just cooler mornings
and leaves that have
finally decided
to let go.

There is a lesson there.
I am still learning it.`,
        language: 'ENGLISH',
        emotion: 'SOLITUDE',
        theme: 'seasons',
      },
    ],
  },
  {
    email: 'ananya@syaahi.com',
    username: 'ananya_heals',
    displayName: 'Ananya',
    password: 'Syaahi@123',
    poems: [
      {
        title: 'Slowly',
        content: `Healing does not happen
all at once.

It happens in small moments.
A good morning.
A meal you enjoyed.
A laugh you did not expect.

Slowly.
Then all at once.`,
        language: 'ENGLISH',
        emotion: 'HOPE',
        theme: 'healing',
      },
      {
        title: 'शुक्रगुज़ार',
        content: `आज उन छोटी चीज़ों का
शुक्रगुज़ार हूँ,
जो बिना माँगे मिलीं।
धूप, हवा, और
तुम्हारी एक मुस्कान।`,
        language: 'HINDI',
        emotion: 'GRATITUDE',
        theme: 'gratitude',
      },
      {
        title: 'New Soil',
        content: `You cannot grow
in the same soil
that buried you.

Sometimes starting over
is not giving up.

Sometimes it is
the bravest thing
you can do.`,
        language: 'ENGLISH',
        emotion: 'HOPE',
        theme: 'new beginnings',
      },
    ],
  },
  {
    email: 'rizwan@syaahi.com',
    username: 'rizwan_recalls',
    displayName: 'Rizwan',
    password: 'Syaahi@123',
    poems: [
      {
        title: 'पुरानी गलियाँ',
        content: `उन पुरानी गलियों में
अब भी वो खुशबू है,
जो बचपन की यादों में
कहीं दब गई है।
लौटना चाहता हूँ,
पर वो गलियाँ
अब वो नहीं रहीं।`,
        language: 'HINDI',
        emotion: 'LONGING',
        theme: 'nostalgia',
      },
      {
        title: 'City at 6am',
        content: `The city looks different at 6am.

Honest.
Before the noise.
Before everyone puts on
their faces for the day.

I prefer it like this.
Quiet and unperformed.`,
        language: 'ENGLISH',
        emotion: 'SOLITUDE',
        theme: 'city',
      },
      {
        title: 'माँ की रसोई',
        content: `माँ की रसोई की वो खुशबू
आज भी नींद से जगा देती है।
शहर में बहुत कुछ मिला,
पर वो खाना
कहीं नहीं मिला।`,
        language: 'HINDI',
        emotion: 'LONGING',
        theme: 'home',
      },
    ],
  },
];

function shuffle<T>(arr: T[]): T[] {
  const shuffled = [...arr];
  for (let i = shuffled.length - 1; i > 0; i--) {
    const j = Math.floor(Math.random() * (i + 1));
    [shuffled[i], shuffled[j]] = [shuffled[j], shuffled[i]];
  }
  return shuffled;
}

async function cleanup() {
  console.log('\n🧹 CLEANUP PHASE\n');
  console.log('─'.repeat(40));

  // Delete all poems by seed accounts
  const seedUsers = await prisma.user.findMany({
    where: { email: { in: SEED_EMAILS } },
    select: { id: true, email: true },
  });

  if (seedUsers.length === 0) {
    console.log('   No seed accounts found. Clean slate.');
    return;
  }

  const userIds = seedUsers.map((u) => u.id);

  const deletedPoems = await prisma.poem.deleteMany({
    where: { authorId: { in: userIds } },
  });
  console.log(`   🗑️  Deleted ${deletedPoems.count} poems`);

  const deletedUsers = await prisma.user.deleteMany({
    where: { email: { in: SEED_EMAILS } },
  });
  console.log(`   🗑️  Deleted ${deletedUsers.count} accounts`);

  console.log('   ✅ Cleanup complete\n');
}

async function seed() {
  console.log('🪶 SEED PHASE\n');
  console.log('─'.repeat(40));

  // Collect all poems with their writer info
  const allPoems: { writer: SeedWriter; poem: SeedWriter['poems'][0] }[] = [];

  for (const writer of writers) {
    for (const poem of writer.poems) {
      allPoems.push({ writer, poem });
    }
  }

  // Shuffle all poems globally
  const shuffledPoems = shuffle(allPoems);

  // Ensure no two consecutive poems are from the same writer
  const arranged: typeof shuffledPoems = [];
  const remaining = [...shuffledPoems];

  while (remaining.length > 0) {
    const lastWriter = arranged.length > 0 ? arranged[arranged.length - 1].writer.email : null;

    const nextIndex = remaining.findIndex((p) => p.writer.email !== lastWriter);

    if (nextIndex === -1) {
      // Only one writer left, just append
      arranged.push(...remaining);
      break;
    }

    arranged.push(remaining.splice(nextIndex, 1)[0]);
  }

  // Create all accounts first
  const tokens: Map<string, string> = new Map();
  let accountCount = 0;

  for (const writer of writers) {
    const passwordHash = await bcrypt.hash(writer.password, 12);

    const user = await prisma.user.create({
      data: {
        email: writer.email,
        username: writer.username,
        displayName: writer.displayName,
        passwordHash,
      },
    });

    tokens.set(writer.email, user.id);
    accountCount++;
    console.log(`   ✅ Created: ${writer.username}`);
  }

  console.log(`\n   📝 Publishing ${arranged.length} poems in shuffled order...\n`);

  // Publish poems with staggered timestamps
  let poemCount = 0;
  const baseTime = new Date();
  baseTime.setHours(baseTime.getHours() - arranged.length); // spread over past N hours

  for (let i = 0; i < arranged.length; i++) {
    const { writer, poem } = arranged[i];
    const userId = tokens.get(writer.email)!;

    // Each poem gets a timestamp a few minutes apart
    const createdAt = new Date(baseTime.getTime() + i * 20 * 60 * 1000); // 20 min gaps

    await prisma.poem.create({
      data: {
        authorId: userId,
        title: poem.title,
        content: poem.content,
        language: poem.language,
        emotion: poem.emotion,
        theme: poem.theme,
        createdAt,
      },
    });

    poemCount++;
    console.log(`   📝 ${String(poemCount).padStart(2, '0')}. [${writer.username}] ${poem.title}`);
  }

  return { accountCount, poemCount };
}

async function main() {
  console.log('\n🪶 Syaahi — Cleanup & Reseed Script\n');
  console.log('═'.repeat(40));

  await cleanup();
  const { accountCount, poemCount } = await seed();

  console.log('\n' + '═'.repeat(40));
  console.log(`\n🪶 Complete!`);
  console.log(`   Accounts: ${accountCount}`);
  console.log(`   Poems:    ${poemCount}`);
  console.log(`   Order:    Shuffled, no consecutive same-author`);
  console.log(`   Timing:   Spread over ${poemCount * 20} minutes\n`);

  await prisma.$disconnect();
}

main().catch(async (err) => {
  console.error('Script failed:', err);
  await prisma.$disconnect();
  process.exit(1);
});     