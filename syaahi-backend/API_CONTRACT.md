# Syaahi API Contract — v0.1.0

**Base URL (local):** `http://localhost:4000`
**API Prefix:** `/api/v1`

## Response Envelope

Success:
```json
{ "success": true, "data": { ... } }
Error:

JSON

{ "success": false, "message": "...", "details": {...} }
Status Codes
200 OK, 201 Created
400 Validation error
401 Unauthenticated
403 Forbidden (not your resource)
404 Not found
409 Conflict (duplicate email/username)
429 Rate limited
500 Server error
Auth Header
For protected endpoints:

text

Authorization: Bearer <jwt_token>
Endpoints
POST /api/v1/auth/signup
Body: { email, username, displayName, password }
Response: { user, token }

POST /api/v1/auth/login
Body: { email, password }
Response: { user, token }

GET /api/v1/auth/me (auth)
Response: { user: { ..., _count: { poems, followers, following } } }

POST /api/v1/auth/logout (auth)
Response: { message }

GET /api/v1/users/:username
Response: { user: { ..., _count } }

GET /api/v1/users/:username/poems?cursor&limit
Response: { poems[], nextCursor }

PATCH /api/v1/users/me (auth)
Body: { displayName?, bio?, avatarUrl? }
Response: { user }

GET /api/v1/poems?emotion&language&theme&cursor&limit
Response: { poems[], nextCursor }

GET /api/v1/poems/:id
Response: { poem }

POST /api/v1/poems (auth)
Body: { title?, content, language, emotion?, theme? }

language: ENGLISH | HINDI | URDU
emotion: LOVE | LONGING | HOPE | SOLITUDE | ANGER | GRATITUDE
Response: { poem }
PATCH /api/v1/poems/:id (auth, owner only)
Body: any subset of poem fields + isPublished?
Response: { poem }

DELETE /api/v1/poems/:id (auth, owner only)
Response: { id, deleted: true }