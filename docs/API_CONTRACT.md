# 🪶 Syaahi — API Contract

## Version: v0.2.2

**Local Base URL**

```text
http://localhost:4000
```

**Staging Base URL**

```text
TBD (Railway Deployment)
```

**API Prefix**

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

| Code | Meaning               |
| ---- | --------------------- |
| 200  | Success               |
| 201  | Created               |
| 400  | Validation Error      |
| 401  | Unauthenticated       |
| 403  | Forbidden             |
| 404  | Not Found             |
| 409  | Conflict              |
| 429  | Rate Limited          |
| 500  | Internal Server Error |

---

# Authentication

Protected endpoints require:

```http
Authorization: Bearer <jwt_token>
```

JWT tokens are returned by:

* Signup
* Login

Stored client-side using:

```text
flutter_secure_storage
```

---

# System Endpoints

## GET /

Returns API metadata.

### Response

```json
{
  "name": "Syaahi API",
  "version": "0.2.2",
  "status": "ok"
}
```

---

## GET /health

Health endpoint used for deployment verification.

### Response

```json
{
  "status": "healthy",
  "timestamp": "2026-06-20T10:00:00.000Z"
}
```

---

# Authentication Module

## POST /api/v1/auth/signup

Create account.

### Body

```json
{
  "email": "user@example.com",
  "username": "raghav_writes",
  "displayName": "Raghav",
  "password": "Password123!"
}
```

### Response

```json
{
  "success": true,
  "data": {
    "user": {},
    "token": "jwt_token"
  }
}
```

---

## POST /api/v1/auth/login

Authenticate user.

### Body

```json
{
  "email": "user@example.com",
  "password": "Password123!"
}
```

### Response

```json
{
  "success": true,
  "data": {
    "user": {},
    "token": "jwt_token"
  }
}
```

---

## GET /api/v1/auth/me

**Protected**

Returns authenticated user.

### Response

```json
{
  "success": true,
  "data": {
    "user": {}
  }
}
```

---

## POST /api/v1/auth/logout

**Protected**

Current implementation:

```text
Client-side logout only.
```

Token revocation is not yet implemented.

---

# Users Module

## GET /api/v1/users/:username

Returns public profile.

### Response

```json
{
  "success": true,
  "data": {
    "user": {}
  }
}
```

---

## Planned Endpoints

### PATCH /api/v1/users/me

Status:

```text
Planned
```

### GET /api/v1/users/:username/poems

Status:

```text
Planned
```

---

# Poems Module

## GET /api/v1/poems

Returns paginated poem feed.

### Query Parameters

| Parameter | Type   | Required |
| --------- | ------ | -------- |
| cursor    | string | No       |
| limit     | number | No       |

Default:

```text
limit=10
```

---

## Example Request

```http
GET /api/v1/poems?limit=10
```

Next page:

```http
GET /api/v1/poems?cursor=abc123&limit=10
```

---

## Response

```json
{
  "success": true,
  "data": {
    "poems": [
      {
        "id": "uuid",
        "title": "Midnight Rain",
        "content": "Poem content...",
        "language": "ENGLISH",
        "emotion": "LONGING",
        "isPublished": true,
        "createdAt": "2026-06-20T10:00:00.000Z",
        "author": {
          "id": "uuid",
          "username": "raghav_writes",
          "displayName": "Raghav",
          "avatarUrl": null
        }
      }
    ],
    "nextCursor": "next_poem_id_or_null"
  }
}
```

---

## Pagination Behaviour

```text
Initial Request
      ↓
Returns 10 Poems
      ↓
Returns nextCursor
      ↓
Client requests next page
      ↓
More poems returned
      ↓
Repeat until nextCursor = null
```

When:

```text
nextCursor = null
```

The feed has reached the end.

---

## GET /api/v1/poems/:id

Returns a single poem.

### Response

```json
{
  "success": true,
  "data": {
    "poem": {}
  }
}
```

---

## POST /api/v1/poems

**Protected**

Create a poem.

### Body

```json
{
  "title": "Midnight Rain",
  "content": "Poem content...",
  "language": "ENGLISH",
  "emotion": "LONGING",
  "theme": "nature"
}
```

### Response

```json
{
  "success": true,
  "data": {
    "poem": {}
  }
}
```

---

# Planned Poem Endpoints

## PATCH /api/v1/poems/:id

Owner only.

Status:

```text
Planned
```

---

## DELETE /api/v1/poems/:id

Owner only.

Status:

```text
Planned
```

---

# Rate Limiting

| Endpoint          | Limit                     |
| ----------------- | ------------------------- |
| POST /auth/signup | 5 requests/hour           |
| POST /auth/login  | 10 requests/hour          |
| All API routes    | 100 requests / 15 minutes |

Development Mode:

```text
Rate limits are bypassed for seed scripts and local development workflows.
```

Production:

```text
Rate limiting fully enforced.
```

---

# Seed Content

Current development dataset:

```text
10 Accounts
30 Poems
```

Reset command:

```bash
npx tsx scripts/cleanup-and-reseed.ts
```

Purpose:

* Demo content
* UI validation
* Pagination testing
* Local development

---

# Known Limitations

Current technical debt:

```text
No refresh tokens
No email verification
No token revocation
No poem editing
No poem deletion
No automated API tests
```

---

# Changelog

| Version | Changes                                               |
| ------- | ----------------------------------------------------- |
| v0.1.0  | Initial draft                                         |
| v0.2.0  | MVP endpoints documented                              |
| v0.2.1  | Auth and verification updates                         |
| v0.2.2  | Cursor pagination, seed system, feed contract updates |

```
```
