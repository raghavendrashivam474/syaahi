const API = 'http://localhost:4000/api/v1';

interface Account {
    email: string;
    username: string;
    displayName: string;
    password: string;
}

interface Poem {
    title: string;
    content: string;
    language: 'ENGLISH' | 'HINDI' | 'URDU';
    emotion: 'LOVE' | 'LONGING' | 'HOPE' | 'SOLITUDE' | 'ANGER' | 'GRATITUDE';
    theme: string;
}

interface Writer {
    account: Account;
    poems: Poem[];
    skipSignup?: boolean;
}

const writers: Writer[] = [
    {
        account: {
            email: 'meera@syaahi.com',
            username: 'meera_writes',
            displayName: 'Meera',
            password: 'Syaahi@123',
        },
        skipSignup: false, poems: [
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
        account: {
            email: 'kabir@syaahi.com',
            username: 'kabir_outdoors',
            displayName: 'Kabir',
            password: 'Syaahi@123',
        },
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
        account: {
            email: 'ananya@syaahi.com',
            username: 'ananya_heals',
            displayName: 'Ananya',
            password: 'Syaahi@123',
        },
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
        account: {
            email: 'rizwan@syaahi.com',
            username: 'rizwan_recalls',
            displayName: 'Rizwan',
            password: 'Syaahi@123',
        },
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

// Shuffle array randomly
function shuffle<T>(arr: T[]): T[] {
    const shuffled = [...arr];
    for (let i = shuffled.length - 1; i > 0; i--) {
        const j = Math.floor(Math.random() * (i + 1));
        [shuffled[i], shuffled[j]] = [shuffled[j], shuffled[i]];
    }
    return shuffled;
}

// Random delay between 1-3 seconds to make timestamps feel natural
function delay(ms: number): Promise<void> {
    return new Promise((resolve) => setTimeout(resolve, ms));
}

async function seed() {
    console.log('\n🪶 Syaahi Seed Script\n');
    console.log('─'.repeat(40));

    let totalPoems = 0;
    let totalAccounts = 0;

    // Shuffle writers so poems appear in random order
    const shuffledWriters = shuffle(writers);

    for (const writer of shuffledWriters) {
        let token: string;

        // Signup or login
        if (writer.skipSignup) {
            console.log(`\n🔑 Logging in: ${writer.account.username}`);
            const loginRes = await fetch(`${API}/auth/login`, {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify({
                    email: writer.account.email,
                    password: writer.account.password,
                }),
            });

            if (!loginRes.ok) {
                console.error(`   ❌ Login failed for ${writer.account.email}`);
                continue;
            }

            const loginData = await loginRes.json();
            token = loginData.data.token;
            console.log(`   ✅ Logged in`);
        } else {
            console.log(`\n📝 Creating account: ${writer.account.username}`);
            const signupRes = await fetch(`${API}/auth/signup`, {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify(writer.account),
            });

            if (!signupRes.ok) {
                const err = await signupRes.json();
                if (err.message?.includes('already')) {
                    console.log(`   ⚠️  Account exists. Logging in instead.`);
                    const loginRes = await fetch(`${API}/auth/login`, {
                        method: 'POST',
                        headers: { 'Content-Type': 'application/json' },
                        body: JSON.stringify({
                            email: writer.account.email,
                            password: writer.account.password,
                        }),
                    });

                    if (!loginRes.ok) {
                        console.error(`   ❌ Login failed for ${writer.account.email}`);
                        continue;
                    }

                    const loginData = await loginRes.json();
                    token = loginData.data.token;
                } else {
                    console.error(`   ❌ Signup failed:`, err.message);
                    continue;
                }
            } else {
                const signupData = await signupRes.json();
                token = signupData.data.token;
                totalAccounts++;
                console.log(`   ✅ Account created`);
            }
        }

        // Shuffle poems for this writer
        const shuffledPoems = shuffle(writer.poems);

        for (const poem of shuffledPoems) {
            // Random delay so timestamps are not identical
            await delay(1000 + Math.random() * 2000);

            console.log(`   📝 Publishing: ${poem.title}`);
            const poemRes = await fetch(`${API}/poems`, {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json',
                    Authorization: `Bearer ${token!}`,
                },
                body: JSON.stringify(poem),
            });

            if (!poemRes.ok) {
                const err = await poemRes.json();
                console.error(`      ❌ Failed: ${err.message}`);
            } else {
                totalPoems++;
                console.log(`      ✅ Published`);
            }
        }
    }

    console.log('\n' + '─'.repeat(40));
    console.log(`\n🪶 Seed complete!`);
    console.log(`   Accounts created: ${totalAccounts}`);
    console.log(`   Poems published:  ${totalPoems}`);
    console.log('');
}

seed().catch((err) => {
    console.error('Seed script failed:', err);
    process.exit(1);
});