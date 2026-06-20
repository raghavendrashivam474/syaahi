```markdown
# Architecture Decision Records (ADRs)

Short, dated records of significant technical choices. Format: context → decision → consequences.

---

## ADR-001: PostgreSQL over MongoDB
**Date:** 2026-06-18 | **Status:** Accepted

**Context:** Need a primary database for users, poems, relationships.

**Decision:** PostgreSQL (hosted on Supabase).

**Why:** Relational data fits SQL naturally. Native full-text search across Hindi/Urdu/English. `pgvector` extension enables future semantic search without re-platforming.

**Trade-off:** Less flexibility than document DB for schema evolution — acceptable cost.

---

## ADR-002: Supabase as Infrastructure, Not Framework
**Date:** 2026-06-18 | **Status:** Accepted

**Context:** Supabase offers managed Postgres, auth, storage.

**Decision:** Use Supabase for **DB hosting only**. Implement our own JWT auth.

**Why:** Avoids vendor lock-in. Auth logic stays portable to any Postgres host (Neon, RDS, self-hosted). Supabase = infra.

**Trade-off:** We rebuild auth basics — acceptable for portability.

---

## ADR-003: Custom JWT Auth, Not Supabase Auth / Clerk
**Date:** 2026-06-19 | **Status:** Accepted

**Decision:** Custom JWT + bcrypt.

**Why:** Full control of token shape, no external dependency, easy to test, portable.

**Trade-off:** We manually implement refresh tokens, email verification, social login later.

---

## ADR-004: Pin Prisma to v6
**Date:** 2026-06-19 | **Status:** Accepted

**Context:** Prisma v7 released; breaks `datasource` block in `schema.prisma`.

**Decision:** Pin to `prisma@^6` and `@prisma/client@^6`.

**Why:** v7 ecosystem too new. Most tutorials & adapters target v6. Upgrade later.

---

## ADR-005: Keep Full Schema Despite MVP Scope
**Date:** 2026-06-20 | **Status:** Accepted

**Context:** Schema includes Reactions, Follows, Rooms — features deferred per roadmap.

**Decision:** Keep models in DB. Don't add endpoints for them.

**Why:** Migration cost > storage cost. Avoids future schema churn.

**Risk:** Mild tech debt; revisit if schema becomes confusing.

---

## ADR-006: Symbolic Logout (No Token Blacklist)
**Date:** 2026-06-20 | **Status:** Accepted

**Context:** JWTs are stateless; true logout requires blacklist.

**Decision:** `/logout` is symbolic — server logs event, client discards token.

**Why:** Avoids adding Redis to MVP. Acceptable for non-sensitive product.

**Upgrade trigger:** Add Redis blacklist when introducing sensitive features.

---

## ADR-007: Rate Limiter In-Memory (No Redis)
**Date:** 2026-06-20 | **Status:** Accepted

**Decision:** `express-rate-limit` default in-memory store.

**Why:** Single-instance MVP. Adding Redis = premature optimization.

**Upgrade trigger:** When deploying multiple backend instances.

---


