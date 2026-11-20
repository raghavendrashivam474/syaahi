# Syaahi Studio — Product Boundaries

## 1. In Scope (Studio)
Studio owns the pre-publication creative lifecycle. This includes:
- Draft creation, editing, and automatic saving.
- Structured poetic formatting (lines, stanzas, alignment).
- Word exploration tools (synonyms, rhymes, contextual alternatives, translations).
- Poetry format templates (Free verse, Couplets, Ghazal, Sonnet, Haiku, Conversational).
- Private fragments/snippets collection.
- Draft history, version tracking, and revision comparison.
- Reading previews, themes, and visual export formats.

## 2. Out of Scope (Studio)
Studio does not replace or control the following systems:
- Social networking features, public feeds, or discovery algorithms.
- User registration, authentication, and profile management.
- The existing **Hearts** (personal poem-saving) and **Reactions** (meaningful interaction) systems.
- Public engagement metrics (like counts, follower counts, etc.).
- An AI poem generation service that composes poetry for the user.
- Self-hosted language model servers or expensive recurring paid APIs.

## 3. Ownership Matrix

| Area | Ownership | Interaction rule |
|---|---|---|
| Authentication & Profiles | Existing Syaahi Platform | Studio consumes the authenticated session and user ID. It does not modify auth logic. |
| Feed & Syaahi Flow | Existing Syaahi Platform | Studio only publishes to it via existing API. It does not alter feed ranking or flow behavior. |
| Hearts & Reactions | Existing Syaahi Platform | Studio does not interact with or modify Hearts/Reactions. |
| Notifications | Existing Syaahi Platform | Studio triggers publication events via existing APIs; notifications logic remains untouched. |
| Writing Workspace | **Syaahi Studio** | Core ownership. Editor, local persistence, formats, tools. |
| Drafts & Fragments | **Syaahi Studio** | Managed within Studio until explicitly converted into a publishable Poem. |
| Publication API | Existing Syaahi Platform | Studio passes the final structured poem content to the existing `POST /poems` endpoint. |

## 4. Privacy & Data Ownership
- Drafts and fragments are private by default. They are not visible to other users, the feed, or discovery modules.
- Local-first architecture means drafts and fragments exist on the user's device before being synced to the Syaahi PostgreSQL database.
- Writers retain complete ownership of their words. No third-party AI service receives keystrokes or drafts without explicit, user-triggered intent.
