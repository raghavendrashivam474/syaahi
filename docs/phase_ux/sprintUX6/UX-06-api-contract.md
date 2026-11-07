# UX-06 API Contract: Meaningful Interaction & Resonance

## Overview
This document defines the backend API contracts for Syaahi's Resonance feature (UX-06). Resonance enables readers to leave intentional, reflective written responses (1–280 characters) on published poems and allows poem authors to acknowledge or reply to individual responses (1–280 characters).

---

## Data Models

### ResonanceResponse
| Field | Type | Description |
|---|---|---|
| `id` | String (UUID) | Primary Key |
| `poemId` | String (UUID) | ID of the poem being responded to |
| `userId` | String (UUID) | ID of the responding user |
| `content` | String (1–280 chars) | Reflective response text |
| `createdAt` | DateTime (ISO 8601) | Timestamp of creation |
| `updatedAt` | DateTime (ISO 8601) | Timestamp of last edit |
| `user` | Object | Author object (`id`, `username`, `displayName`, `avatarUrl`) |
| `reply` | Object? | Optional single author reply (`ResonanceReply`) |

### ResonanceReply
| Field | Type | Description |
|---|---|---|
| `id` | String (UUID) | Primary Key |
| `responseId` | String (UUID) | Unique FK to target `ResonanceResponse` (1:1 constraint) |
| `authorId` | String (UUID) | ID of the replying poem author |
| `content` | String (1–280 chars) | Author reply text |
| `createdAt` | DateTime (ISO 8601) | Timestamp of creation |
| `updatedAt` | DateTime (ISO 8601) | Timestamp of last edit |
| `author` | Object | Poem author object (`id`, `username`, `displayName`, `avatarUrl`) |

---

## Endpoints

### 1. Post Response
- **Method:** `POST`
- **Route:** `/api/v1/poems/:poemId/resonances`
- **Auth:** Required (`Bearer <JWT>`)
- **Body:**
  ```json
  {
    "content": "This verse captured a feeling I've carried for years."
  }

```

* **Response (`201 Created`):**
```json
{
  "id": "resp_123",
  "poemId": "poem_456",
  "userId": "user_789",
  "content": "This verse captured a feeling I've carried for years.",
  "createdAt": "2026-11-07T07:30:00.000Z",
  "updatedAt": "2026-11-07T07:30:00.000Z",
  "user": {
    "id": "user_789",
    "username": "reader_one",
    "displayName": "Reader One",
    "avatarUrl": null
  },
  "reply": null
}

```



### 2. List Responses for Poem

* **Method:** `GET`
* **Route:** `/api/v1/poems/:poemId/resonances?cursor=<string>&limit=<number>`
* **Auth:** Optional / Required
* **Response (`200 OK`):**
```json
{
  "responses": [ ... ],
  "nextCursor": "resp_122"
}

```



### 3. Update Response

* **Method:** `PATCH`
* **Route:** `/api/v1/resonances/:responseId`
* **Auth:** Required (Response Owner only)
* **Body:**
```json
{
  "content": "Updated reflective thoughts."
}

```


* **Response (`200 OK`):** Updated `ResonanceResponse` object.

### 4. Delete Response

* **Method:** `DELETE`
* **Route:** `/api/v1/resonances/:responseId`
* **Auth:** Required (Response Owner or Admin)
* **Response (`200 OK`):**
```json
{
  "success": true
}

```



### 5. Post Author Reply

* **Method:** `POST`
* **Route:** `/api/v1/resonances/:responseId/reply`
* **Auth:** Required (Poem Author only)
* **Body:**
```json
{
  "content": "Thank you for sharing your reflection."
}

```


* **Response (`201 Created`):** `ResonanceReply` object.

### 6. Update Author Reply

* **Method:** `PATCH`
* **Route:** `/api/v1/resonance-replies/:replyId`
* **Auth:** Required (Reply Author only)
* **Body:**
```json
{
  "content": "Updated author reply."
}

```


* **Response (`200 OK`):** Updated `ResonanceReply` object.

### 7. Delete Author Reply

* **Method:** `DELETE`
* **Route:** `/api/v1/resonance-replies/:replyId`
* **Auth:** Required (Reply Author or Admin)
* **Response (`200 OK`):**
```json
{
  "success": true
}

```



---

## Notifications Matrix

When a resonance response or reply is posted, in-app notifications are created automatically:

| Event | Type | Recipient | Payload `sourceId` | Link / Context |
| --- | --- | --- | --- | --- |
| User posts response | `RESONANCE_RESPONSE` | Poem Author | `responseId` | Links to Poem Reader |
| Author posts reply | `AUTHOR_REPLY` | Responding User | `replyId` | Links to Poem Reader |

```