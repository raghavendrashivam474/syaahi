# 🪶 Syaahi — Roadmap

> Where emotions become words.

This roadmap reflects the product vision for Syaahi.
Features are ordered by depth of emotional value, not by technical complexity.

---

## Guiding Question

Before any feature is built, ask:

> "Does this help people express, preserve, or revisit emotions?"

If the answer is no, it does not belong in Syaahi.

---

## Released

### v0.1.0 — Foundation
- Express.js server setup
- TypeScript configuration
- Prisma ORM integration
- PostgreSQL connection via Supabase
- Environment validation
- Modular project architecture
- Health check endpoint

### v0.2.0 — MVP ✅
- User registration and login
- JWT authentication
- Session persistence
- Poem creation
- Poem feed
- Poem reader
- Author profiles
- Flutter Web application
- End-to-end user journey working

---

## In Progress

### v0.3.0 — Stability and Deployment
- [ ] Backend deployed to Railway
- [ ] Frontend deployed to Vercel
- [ ] Public staging environment live
- [ ] Environment variables documented
- [ ] Documentation complete
- [ ] Basic test coverage

---

## Planned

### v0.4.0 — Journals
Private by default. A space for daily reflection.

- [ ] Create journal entry
- [ ] Edit journal entry
- [ ] Archive journal entry
- [ ] Search journal entries
- [ ] Journal entries never public unless explicitly shared

**Why journals:**
Poetry is occasional. Journaling creates a habit of returning.
The journal becomes a personal emotional archive over time.

---

### v0.5.0 — Personal Archive
A timeline of your own words.

- [ ] Personal writing timeline
- [ ] Memory view (revisit old poems and entries)
- [ ] Emotional history (what did I write when I was hopeful? lonely?)
- [ ] On this day (resurface old writing)

**Why archives:**
The most meaningful feature of Syaahi is not what you write today.
It is rediscovering what you wrote years ago.

---

### v0.6.0 — Letters After Midnight
Anonymous letters. Anonymous replies.

- [ ] Write an anonymous letter
- [ ] Receive an anonymous reply
- [ ] Reporting system
- [ ] Rate limiting per session
- [ ] Moderation tools

**Note:**
Moderation architecture will be designed before this feature begins.
Anonymous systems require safety infrastructure from day one.

---

### v0.7.0 — Time Capsules
Write to your future self.

- [ ] Write a message with a future delivery date
- [ ] Receive the message on the chosen date
- [ ] Cannot be edited after sealing
- [ ] Notification on delivery

**Why time capsules:**
A letter to yourself five years from now is one of the most
emotionally meaningful things a person can write.

---

### v0.8.0 — Community Circles
Small writing communities, not public feeds.

- [ ] Create a writing circle
- [ ] Monthly prompts
- [ ] Poetry challenges
- [ ] Share poems within a circle
- [ ] Circle is invite-only or open

**Why circles and not followers:**
Syaahi is not optimising for audience size.
It is optimising for meaningful connection between writers.

---

### v0.9.0 — Audio Poetry
Your words, your voice.

- [ ] Record a poem narration
- [ ] Listen to poems in audio mode
- [ ] Audio attached to written poem
- [ ] Calm, distraction-free listening experience

---

## Explicitly Out of Scope

These features will not be built without a deliberate founder decision to reconsider:

| Feature                    | Reason                                              |
|----------------------------|-----------------------------------------------------|
| Followers and following     | Shifts focus from expression to audience building   |
| Like counts                | Optimises for validation, not depth                 |
| Trending / algorithmic feed | Builds engagement loops, not meaningful discovery   |
| Infinite scroll            | Designed to consume time, not preserve it           |
| AI-generated poetry        | Contradicts the human expression core value         |
| Creator monetisation       | Premature and misaligned with current vision        |
| NFT or blockchain features | Not relevant to the product mission                 |

---

## Version Naming Convention

```text
v0.x.0  → Feature releases during early development
v1.0.0  → First stable public release
v1.x.0  → Feature additions post-launch
v2.0.0  → Major platform evolution
