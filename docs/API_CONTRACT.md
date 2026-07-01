# 🪶 Syaahi — API Contract

## Version

**v0.3.0-beta**

---

## Base URLs

### Local

```text
http://localhost:4000
```

### Staging

```text
TBD (Deployment)
```

### API Prefix

```text
/api/v1
```

---

# Response Envelope

All API responses follow a consistent structure.

## Success

```json
{
  "success": true,
  "data": {}
}
```

## Error

```json
{
  "success": false,
  "message": "Human readable message",
  "details": {}
}
```

---

# Status Codes

| Code | Meaning |
|------|---------|
| 200 | Success |
| 201 | Created |
| 400 | Validation Error |
| 401 | Authentication Required |
| 403 | Forbidden |
| 404 | Not Found |
| 409 | Conflict |
| 429 | Rate Limited |
| 500 | Internal Server Error |

---

# Authentication

Protected endpoints require

```http
Authorization: Bearer <jwt_token>
```

JWTs are issued by:

- Signup
- Login

Stored client-side using:

```text
flutter_secure_storage
```

---

# System

## GET /

Returns API metadata.

---

## GET /health

Returns service health.

Used for deployment verification and uptime monitoring.

---

# Authentication

| Method | Endpoint | Protected |
|---------|----------|-----------|
| POST | /auth/signup | ❌ |
| POST | /auth/login | ❌ |
| GET | /auth/me | ✅ |
| POST | /auth/logout | ✅ |

Current logout implementation:

```text
Client-side token removal.
```

Refresh tokens and token revocation are not yet implemented.

---

# Users

| Method | Endpoint |
|---------|----------|
| GET | /users/:username |
| PATCH | /users/me |
| GET | /users/:username/poems |

Returned profile includes:

- Basic information
- Published poems
- Languages used
- Themes used

---

# Poems

| Method | Endpoint |
|---------|----------|
| GET | /poems |
| GET | /poems/:id |
| POST | /poems |
| PATCH | /poems/:id |
| DELETE | /poems/:id |

---

## Feed Query Parameters

Supported:

| Parameter | Description |
|-----------|-------------|
| cursor | Cursor pagination |
| limit | Page size |
| language | Filter by language |
| emotion | Filter by emotion |
| theme | Filter by theme |

Example:

```http
GET /api/v1/poems?language=HINDI&emotion=LONGING&limit=10
```

---

## Pagination

Feed uses cursor pagination.

```
Initial Request
        ↓
10 Poems
        ↓
nextCursor
        ↓
Load More
        ↓
Repeat
        ↓
nextCursor = null
```

---

## Feed Ordering

The backend returns poems ordered by **Syaahi Flow**.

Syaahi Flow:

- Preserves recency
- Avoids consecutive poems from the same writer whenever possible
- Does not rank using popularity
- Does not use likes or reactions
- Is deterministic

It is a literary sequencing engine, not a recommendation engine.

---

# Heart

Private saving system.

Unlike bookmarks on traditional platforms, Hearts are intentionally personal.

| Method | Endpoint |
|---------|----------|
| POST | /poems/:id/heart |
| DELETE | /poems/:id/heart |
| GET | /users/me/heart |

Characteristics:

- Private
- No notifications
- No public count
- No popularity ranking

---

# Reactions

Meaningful acknowledgements replacing likes.

| Method | Endpoint |
|---------|----------|
| POST | /poems/:id/reactions |
| DELETE | /poems/:id/reactions/:type |
| GET | /poems/:id/reactions |

Supported reaction types:

```text
FELT_THIS

STAYED_WITH_ME

BEAUTIFULLY_WRITTEN

MADE_ME_THINK

COMFORTED_ME

INSPIRED_ME
```

Each user may react once per reaction type.

---

# Rate Limiting

| Endpoint | Limit |
|----------|-------|
| POST /auth/signup | 5/hour |
| POST /auth/login | 10/hour |
| All API Routes | 100 requests / 15 minutes |

Development:

```text
Rate limits are relaxed for local development and seed workflows.
```

Production:

```text
Strict rate limiting is enforced.
```

---

# Seed Content

Development dataset:

```text
10 Writers

30 Poems

Multiple Languages

Multiple Themes

Multiple Emotions
```

Reset:

```bash
npx tsx scripts/cleanup-and-reseed.ts
```

Purpose:

- UI development
- Pagination testing
- Feed testing
- Demonstrations

---

# Current Limitations

Current Internal Beta limitations:

- No refresh tokens
- No email verification
- No token blacklist
- No automated API test suite
- In-memory rate limiting
- Single-instance deployment assumptions

These are documented and accepted trade-offs.

---

# Changelog

| Version | Highlights |
|---------|------------|
| v0.1.0 | Foundation |
| v0.2.0 | MVP |
| v0.2.1 | Documentation Sprint |
| v0.2.2 | Seed Content, Infinite Scroll, Cursor Pagination |
| v0.3.0-beta | Heart System, Reactions, Feed Filters, Profiles, Syaahi Flow, Internal Beta |