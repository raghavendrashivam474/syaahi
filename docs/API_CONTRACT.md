# 🪶 Syaahi — API Contract

**Version:** v0.2.0
**Base URL (local):** `http://localhost:4000`
**Base URL (staging):** TBD after Railway deployment
**API Prefix:** `/api/v1`

---

## Response Envelope

Every response follows this shape.

**Success:**
```json
{
  "success": true,
  "data": { ... }
}
Error:

JSON

{
  "success": false,
  "message": "Human readable message",
  "details": { ... }
}
Status Codes
Code	Meaning
200	OK
201	Created
400	Validation error
401	Unauthenticated
403	Forbidden (not your resource)
404	Not found
409	Conflict (duplicate email/username)
429	Rate limited
500	Server error
Authentication
Protected endpoints require a JWT token in the header:

text

Authorization: Bearer <jwt_token>
Tokens are returned on signup and login.
Tokens must be stored securely on the client (flutter_secure_storage).

Endpoints
System
text

GET /
Returns API name, version, and status.

Response:

JSON

{
  "name": "Syaahi API",
  "version": "0.1.0",
  "status": "ok"
}
text

GET /health
Health check for Railway uptime monitoring.

Response:

JSON

{
  "status": "healthy",
  "timestamp": "2026-06-20T10:00:00.000Z"
}
Authentication
text

POST /api/v1/auth/signup
Register a new user.

Body:

JSON

{
  "email": "user@example.com",
  "username": "raghav_writes",
  "displayName": "Raghav",
  "password": "minimum8chars"
}
Validation:

email — valid email format
username — 3 to 30 characters, lowercase letters, numbers, underscore only
displayName — 1 to 60 characters
password — 8 to 100 characters
Response: 201

JSON

{
  "success": true,
  "data": {
    "user": {
      "id": "uuid",
      "email": "user@example.com",
      "username": "raghav_writes",
      "displayName": "Raghav",
      "bio": null,
      "avatarUrl": null,
      "createdAt": "2026-06-20T10:00:00.000Z"
    },
    "token": "jwt_token"
  }
}
text

POST /api/v1/auth/login
Login with email and password.

Body:

JSON

{
  "email": "user@example.com",
  "password": "yourpassword"
}
Response: 200

JSON

{
  "success": true,
  "data": {
    "user": {
      "id": "uuid",
      "email": "user@example.com",
      "username": "raghav_writes",
      "displayName": "Raghav",
      "bio": null,
      "avatarUrl": null,
      "createdAt": "2026-06-20T10:00:00.000Z"
    },
    "token": "jwt_token"
  }
}
text

GET /api/v1/auth/me          [protected]
Get the currently authenticated user.

Response: 200

JSON

{
  "success": true,
  "data": {
    "user": {
      "id": "uuid",
      "email": "user@example.com",
      "username": "raghav_writes",
      "displayName": "Raghav",
      "bio": null,
      "avatarUrl": null,
      "createdAt": "2026-06-20T10:00:00.000Z",
      "_count": {
        "poems": 4,
        "followers": 0,
        "following": 0
      }
    }
  }
}
text

POST /api/v1/auth/logout     [protected]
Logout the current user.

Note: Token revocation is not yet implemented.
The client must discard the token on logout.

Response: 200

JSON

{
  "success": true,
  "data": {
    "message": "Logged out. Please discard the token on the client."
  }
}
Users
text

GET /api/v1/users/:username
Get a user profile by username.

Response: 200

JSON

{
  "success": true,
  "data": {
    "user": {
      "id": "uuid",
      "username": "raghav_writes",
      "displayName": "Raghav",
      "bio": null,
      "avatarUrl": null,
      "createdAt": "2026-06-20T10:00:00.000Z",
      "_count": {
        "poems": 4,
        "followers": 0,
        "following": 0
      }
    }
  }
}
text

🔜 GET /api/v1/users/:username/poems?cursor&limit
Get poems by a specific user with pagination.

Status: Planned — not yet implemented.

text

🔜 PATCH /api/v1/users/me     [protected]
Update the authenticated user's profile.

Status: Planned — not yet implemented.

Planned body:

JSON

{
  "displayName": "New Name",
  "bio": "A short bio",
  "avatarUrl": "https://..."
}
Poems
text

GET /api/v1/poems
Get the poem feed.

Response: 200

JSON

{
  "success": true,
  "data": {
    "poems": [
      {
        "id": "uuid",
        "title": "Midnight Rain",
        "content": "the poem content here",
        "language": "ENGLISH",
        "emotion": "LONGING",
        "theme": null,
        "audioUrl": null,
        "isPublished": true,
        "createdAt": "2026-06-20T10:00:00.000Z",
        "author": {
          "id": "uuid",
          "username": "raghav_writes",
          "displayName": "Raghav",
          "avatarUrl": null
        }
      }
    ]
  }
}
Note: Pagination is not yet implemented. Returns all published poems.
Cursor-based pagination is planned before Sprint 3.

text

GET /api/v1/poems/:id
Get a single poem by ID.

Response: 200

JSON

{
  "success": true,
  "data": {
    "poem": {
      "id": "uuid",
      "title": "Midnight Rain",
      "content": "the poem content here",
      "language": "ENGLISH",
      "emotion": "LONGING",
      "theme": null,
      "audioUrl": null,
      "isPublished": true,
      "createdAt": "2026-06-20T10:00:00.000Z",
      "author": {
        "id": "uuid",
        "username": "raghav_writes",
        "displayName": "Raghav",
        "avatarUrl": null
      }
    }
  }
}
text

POST /api/v1/poems            [protected]
Create a new poem.

Body:

JSON

{
  "title": "Midnight Rain",
  "content": "the poem content here",
  "language": "ENGLISH",
  "emotion": "LONGING",
  "theme": "nature"
}
Validation:

title — optional, max 200 characters
content — required, non-empty
language — ENGLISH | HINDI | URDU
emotion — optional, LOVE | LONGING | HOPE | SOLITUDE | ANGER | GRATITUDE
theme — optional string
Response: 201

JSON

{
  "success": true,
  "data": {
    "poem": {
      "id": "uuid",
      "title": "Midnight Rain",
      "content": "the poem content here",
      "language": "ENGLISH",
      "emotion": "LONGING",
      "theme": "nature",
      "isPublished": true,
      "createdAt": "2026-06-20T10:00:00.000Z",
      "author": {
        "id": "uuid",
        "username": "raghav_writes",
        "displayName": "Raghav",
        "avatarUrl": null
      }
    }
  }
}
text

🔜 PATCH /api/v1/poems/:id    [protected, owner only]
Update a poem.

Status: Planned — not yet implemented.

text

🔜 DELETE /api/v1/poems/:id   [protected, owner only]
Delete a poem.

Status: Planned — not yet implemented.

Rate Limits
Endpoint	Limit
POST /auth/signup	5 requests per hour per IP
POST /auth/login	10 requests per hour per IP
All /api/ routes	100 requests per 15 min per IP
Exceeding a limit returns 429 Too Many Requests.

Changelog
Version	Date	Changes
v0.1.0	2026-06	Initial contract draft
v0.2.0	2026-06	Updated to reflect actual implementation, marked planned endpoints
