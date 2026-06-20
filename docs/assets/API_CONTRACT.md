# Syaahi API Contract

**Version:** v0.1.0
**Base URL (local):** `http://localhost:4000`
**Prefix:** `/api/v1`

## Response Envelope

```json
// Success
{ "success": true, "data": { ... } }

// Error
{ "success": false, "message": "...", "details": {...} }
Auth
Protected endpoints require:

text

Authorization: Bearer <jwt_token>
Status Codes
Code	Meaning
200	OK
201	Created
400	Validation error
401	Unauthenticated
403	Forbidden (not owner)
404	Not found
409	Conflict (duplicate)
429	Rate limited
500	Server error
Endpoints
Health
Method	Path	Auth
GET	/	—
GET	/health	—
Auth
Method	Path	Auth	Body
POST	/api/v1/auth/signup	—	{ email, username, displayName, password }
POST	/api/v1/auth/login	—	{ email, password }
GET	/api/v1/auth/me	✅	—
POST	/api/v1/auth/logout	✅	—
Users
Method	Path	Auth	Body
GET	/api/v1/users/:username	—	—
GET	/api/v1/users/:username/poems	—	?cursor&limit
PATCH	/api/v1/users/me	✅	{ displayName?, bio?, avatarUrl? }
Poems
Method	Path	Auth	Body
GET	/api/v1/poems	—	?emotion&language&theme&cursor&limit
GET	/api/v1/poems/:id	—	—
POST	/api/v1/poems	✅	{ title?, content, language, emotion?, theme? }
PATCH	/api/v1/poems/:id	✅ owner	any subset
DELETE	/api/v1/poems/:id	✅ owner	—
Enums
language: ENGLISH | HINDI | URDU
emotion: LOVE | LONGING | HOPE | SOLITUDE | ANGER | GRATITUDE
Rate Limits (per IP)
Endpoint	Limit
/auth/signup	5 / hour
/auth/login	10 / 15 min
/poems POST	30 / hour
/api/* (global)	300 / 15 min
