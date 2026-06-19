# 🪶 Syaahi Backend

Backend service for **Syaahi** — a platform for poetry, letters, journals, and human expression.

## Overview

Syaahi aims to provide a thoughtful digital space where people can write, discover, preserve, and revisit their emotions through words.

This repository contains the backend API and database layer powering the Syaahi ecosystem.

---

## Current Status

🚧 Early Development Phase

### Implemented

* Express.js server setup
* TypeScript configuration
* Prisma ORM integration
* PostgreSQL database connection (Supabase)
* Environment configuration
* Modular project architecture
* Health check endpoint

### In Progress

* Authentication module
* Poems module
* User module

### Planned

* Letters
* Journals
* Time Capsules
* Emotional Discovery
* Communities (Circles)
* Audio Poetry
* Creator Profiles

---

## Tech Stack

* Node.js
* Express.js
* TypeScript
* Prisma
* PostgreSQL (Supabase)
* JWT Authentication (Planned)

---

## Project Structure

```text
src/
├── config/
├── middleware/
├── modules/
│   ├── auth/
│   ├── poems/
│   └── users/
├── utils/
├── app.ts
└── server.ts
```

## Getting Started

### Install Dependencies

```bash
npm install
```

### Configure Environment

Create a `.env` file:

```env
DATABASE_URL=
DIRECT_URL=
JWT_SECRET=
```

### Run Development Server

```bash
npm run dev
```

Server runs at:

```text
http://localhost:4000
```

---

## Health Check

```http
GET /
```

Response:

```json
{
  "name": "Syaahi API",
  "version": "0.1.0",
  "status": "ok"
}
```

---

## Development Roadmap

### Phase 1

* Poems CRUD
* User Management
* Basic Authentication

### Phase 2

* Emotional Discovery
* User Profiles
* Archive System

### Phase 3

* Letters After Midnight
* Time Capsules
* Audio Poetry

---

## Vision

> Where emotions become words.

Syaahi is being built as a home for poetry, reflection, memories, and meaningful human expression.

---

## Author

**Raghavendra Singh**

Built with ☕, midnight thoughts, and a love for words.
