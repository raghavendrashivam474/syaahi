# Current Syaahi Data Flow Analysis
**Sprint:** ST-00.3  
**Document Status:** Code-Verified Data Flow Trace  

---

## 1. Primary Workflows & Sequence Traces

### 1.1 Poem Creation & Immediate Publication Flow
Currently, writing a poem immediately publishes it. There is no intermediate server-side draft state in the creation flow.

```text
[User] -> Keystrokes -> [WriterScreen RAM TextEditingController]
|
+-> Tap "Publish" -> [writerProvider.publish()]
|
+-> [PoemsRepository.createPoem()]
|
+-> POST /api/v1/poems {title, content, language, emotion, theme}
|
+-> [Express Middleware (auth, writeLimiter)]
|
+-> [createPoemSchema Zod Validation]
|
+-> [PoemsController.createPoem]
|
+-> Prisma.poem.create({ data: { ..., isPublished: true } })
|
+-> [NotificationService.createPublicationNotifications]
|
+-> Prisma.notification.createMany (POEM_PUBLISHED)
```

**Key Observation:** createPoemSchema does not expose isPublished. The creation endpoint hardcodes immediate publication and triggers notifications to all opted-in followers automatically.

---

### 1.2 Feed Query & Syaahi Flow Sequencing

```text
[FeedScreen] -> Mount / Pull Refresh -> [feedProvider.load()]
|
+-> [PoemsRepository.listPoems(cursor, limit, filters)]
|
+-> GET /api/v1/poems?limit=10&emotion=...&language=...
|
+-> [PoemsController.listPoems]
|
+-> Prisma.poem.findMany({ where: { isPublished: true }, take: windowSize })
|
+-> [syaahiFlow(raw, options)] (Algorithmic re-ordering & variety filter)
|
+-> Return { poems, nextCursor }
```

**Key Observation:** Unpublished poems (isPublished: false) are strictly excluded by the Prisma where: { isPublished: true } query filter before entering the syaahiFlow algorithm.

---

### 1.3 Publication State Transition via Update (PATCH)

```text
[Author] -> Action: Publish Draft -> [PoemsRepository.updatePoem(id, { isPublished: true })]
|
+-> PATCH /api/v1/poems/:id { isPublished: true }
|
+-> [PoemsController.updatePoem]
|
+-> Fetch existing poem: select authorId, isPublished
+-> Validate ownership (authorId === req.user.userId)
+-> Prisma.poem.update(...)
+-> Check condition: existing.isPublished === false && updated.isPublished === true
|
+--- (TRUE) --> [createPublicationNotifications(id, authorId)]
+--- (FALSE) --> Skip notification triggering
```

**Key Seam for Studio:** This transition seam (existing.isPublished === false -> updated.isPublished === true) is the exact path Studio will use when converting a remote draft into a published poem.

---

### 1.4 Heart & Reaction Workflows
- **Heart (Private Save):** Executed via POST /api/v1/poems/:id/heart. Idempotent save stored in the Heart model. Replaces public "likes" with a private bookmark behavior.
- **Reaction (Meaningful Response):** Executed via POST /api/v1/poems/:id/reactions with explicit types (FELT_THIS, STAYED_WITH_ME, BEAUTIFULLY_WRITTEN, MADE_ME_THINK, COMFORTED_ME, INSPIRED_ME).
