# 🪶 Syaahi — Roadmap

> Where emotions become words.

This roadmap reflects the long-term vision for Syaahi.

Features are prioritized by emotional value and user impact rather than technical complexity.

---

# Guiding Question

Before any feature is built, ask:

> Does this help people express, preserve, or revisit emotions?

If the answer is no, it probably does not belong in Syaahi.

---

# Released

## v0.1.0 — Foundation

### Backend

* Express.js setup
* TypeScript configuration
* Prisma ORM integration
* Supabase PostgreSQL integration
* Environment validation with Zod
* Modular architecture
* Health check endpoint

### Outcome

Development foundation established.

---

## v0.2.0 — MVP

### Authentication

* Registration
* Login
* JWT authentication
* Session recovery
* Logout

### Poems

* Create poem
* Read poem
* Feed
* Author profiles

### Frontend

* Flutter Web application
* Riverpod state management
* Repository pattern
* Secure token storage

### Outcome

First complete user journey operational.

---

## v0.2.1 — Documentation & Verification

### Documentation

* Architecture documentation
* API contract
* Roadmap
* Progress log
* Vision document
* Contributing guide
* Founder handover

### Verification

* Full local verification completed
* Authentication verified
* Feed verified
* Poem creation verified

### Outcome

Project became maintainable and transferable.

---

## v0.2.2 — Feed & Seed Content Improvements

### Feed

* Cursor-based pagination
* Infinite scrolling
* Pull-to-refresh
* End-of-feed indicator

### Development Environment

* Seed content system
* Writer personas
* Reusable reseed script

### Dataset

```text id="axkvhe"
10 Accounts
30 Poems
Multiple Writing Styles
Multiple Emotions
```

### Outcome

Application became demo-ready and scalable.

---

# Current Milestone

## v0.3.0 — Deployment Sprint

### Backend

* [ ] Deploy to Railway
* [ ] Configure production environment variables
* [ ] Verify database connectivity
* [ ] Verify health endpoint

### Frontend

* [ ] Deploy Flutter Web to Vercel
* [ ] Configure API_BASE_URL
* [ ] Verify production routing

### Validation

* [ ] Complete staging verification
* [ ] Verify full user journey
* [ ] Share public URLs

### Outcome

Public staging environment available.

---

# Planned

## v0.4.0 — Testing Sprint

Goal:

Increase reliability before introducing major features.

### Backend

* [ ] API regression tests
* [ ] Repository tests
* [ ] Authentication tests

### Frontend

* [ ] Widget tests
* [ ] State management tests
* [ ] Integration tests

---

## v0.5.0 — Journals

Private by default.

### Features

* [ ] Create journal entry
* [ ] Edit journal entry
* [ ] Archive journal entry
* [ ] Search journal entries

### Why Journals?

Poetry is occasional.

Journaling creates a habit of returning.

The journal becomes a personal emotional archive over time.

---

## v0.6.0 — Personal Archive

A timeline of your own words.

### Features

* [ ] Personal writing timeline
* [ ] Memory view
* [ ] Emotional history
* [ ] On This Day

### Why Archives?

The most meaningful feature is not writing.

It is rediscovering.

---

## v0.7.0 — Letters After Midnight

Anonymous letters and anonymous replies.

### Features

* [ ] Anonymous letter creation
* [ ] Anonymous replies
* [ ] Reporting system
* [ ] Abuse prevention
* [ ] Moderation tools

### Important

Moderation architecture must be completed before implementation begins.

---

## v0.8.0 — Time Capsules

Write to your future self.

### Features

* [ ] Scheduled delivery
* [ ] Locked after sealing
* [ ] Future notification
* [ ] Time capsule archive

### Why Time Capsules?

Few digital experiences are as meaningful as hearing from your past self.

---

## v0.9.0 — Community Circles

Small communities, not public audiences.

### Features

* [ ] Writing circles
* [ ] Monthly prompts
* [ ] Poetry challenges
* [ ] Circle sharing
* [ ] Private and public circles

### Why Circles?

Meaningful connection matters more than audience growth.

---

## v1.0.0 — First Public Release

Requirements:

* Stable deployment
* Automated testing
* Journals
* Archive system
* Core moderation tools
* Production monitoring

---

# Explicitly Out of Scope

The following features are intentionally excluded.

| Feature                   | Reason                                         |
| ------------------------- | ---------------------------------------------- |
| Followers & Following     | Encourages audience building over expression   |
| Like Counts               | Optimizes for validation instead of reflection |
| Trending Feed             | Creates engagement loops                       |
| Algorithmic Ranking       | Prioritizes attention over meaning             |
| AI-Generated Poetry       | Contradicts human expression                   |
| Creator Monetization      | Premature for current mission                  |
| NFT / Blockchain Features | No alignment with product goals                |

---

# Version Strategy

```text id="8p6jgd"
v0.x.x → Early development
v1.0.0 → First stable public release
v1.x.x → Feature additions
v2.0.0 → Major platform evolution
```

---

# Long-Term Vision

Syaahi should eventually become:

```text id="z4ep2x"
Poetry
Journals
Letters
Archives
Time Capsules
Memories
```

A place where people can preserve who they were, and rediscover those moments years later.
