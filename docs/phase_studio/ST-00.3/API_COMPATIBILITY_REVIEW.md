# Syaahi Studio — API & Data Backward Compatibility Review
**Sprint:** ST-00.3  
**Document Status:** API Specification & Compatibility Contract  

---

## 1. Backward Compatibility Principles
1. **Existing Endpoints Intact:** `GET /poems`, `GET /poems/:id`, `POST /poems`, `PATCH /poems/:id`, and `DELETE /poems/:id` retain exact request/response schemas.
2. **Zero Spurious Notifications:** Draft creation and draft auto-saves MUST NOT trigger `createPublicationNotifications()`.
3. **Strict Ownership Control:** All studio endpoints enforce `req.user!.userId` matching draft ownership.

---

## 2. Studio API Extension Surface (`/api/v1/studio/`)

### 2.1 Endpoint Specification Matrix
| Method | Route | Description | Auth Required |
|---|---|---|---|
| `GET` | `/api/v1/studio/drafts` | List current user's active drafts | **Yes** |
| `POST` | `/api/v1/studio/drafts` | Create new unpublished draft | **Yes** |
| `GET` | `/api/v1/studio/drafts/:id` | Fetch single draft details | **Yes** |
| `PATCH` | `/api/v1/studio/drafts/:id` | Update draft content / title / metadata | **Yes** |
| `DELETE` | `/api/v1/studio/drafts/:id` | Delete draft permanently | **Yes** |
| `POST` | `/api/v1/studio/drafts/:id/publish` | Atomic convert draft -> published poem | **Yes** |

---

## 3. Request/Response Contracts

### `POST /api/v1/studio/drafts`
**Request Body:**
```json
{
  "title": "Unfinished Ghazal",
  "content": "First line of thought...",
  "language": "URDU",
  "emotion": "LONGING",
  "theme": "Midnight"
}
```

### Response (201 Created):

```JSON
{
  "success": true,
  "data": {
    "draft": {
      "id": "d3b07384-d113-41e6-a784-001122334455",
      "authorId": "user-uuid",
      "title": "Unfinished Ghazal",
      "content": "First line of thought...",
      "language": "URDU",
      "isPublished": false,
      "createdAt": "2026-11-20T10:00:00.000Z",
      "updatedAt": "2026-11-20T10:00:00.000Z"
    }
  }
}
```

### POST /api/v1/studio/drafts/:id/publish

#### **Response (200 OK)**:

Transitions draft isPublished from false to true, invokes createPublicationNotifications(poemId, authorId), and returns the published Poem model object.
