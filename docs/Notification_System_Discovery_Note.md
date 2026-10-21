# Syaahi — Notification System Discovery Note

**Date:** 21 October 2026  
**Status:** Initial inspection complete; design pending  
**Scope:** Existing architecture and requirements discovery only

## 1. Objective

Explore a minimal, secure, and evolvable notification capability for Syaahi, initially motivated by notifying users when a new poem is published.

This phase is limited to documenting the existing implementation and identifying design considerations. No implementation or sprint assignments are authorized yet.

## 2. Existing Architecture

### Backend
- Node.js, Express, TypeScript, Prisma, and PostgreSQL.
- API base path: `/api/v1`.
- Existing modules include authentication, users, poems, hearts, and reactions.
- Standard success and error response envelopes are already established.
- No notification routes or dedicated notification infrastructure were identified in the inspected code.

### Flutter application
- Flutter application using Riverpod for state management, GoRouter for navigation, and Dio for API requests.
- `PoemsRepository` handles poem creation, retrieval, feed pagination, hearts, and reactions.
- `WriterNotifier.publish()` creates a poem through the repository and refreshes the feed after success.
- The writer screen presents publishing as an explicit user action.

### Database
- The Prisma schema contains User, Poem, Heart, Reaction, Follow, Room, RoomMember, and PoemRoom models, among others.
- The existence of a database model does not establish that its corresponding feature is usable in the application.

## 3. Publication Lifecycle Findings

- `createPoemSchema` accepts poem content and metadata but does not accept `isPublished`.
- The Poem model defaults `isPublished` to `true`.
- `updatePoemSchema` permits changing `isPublished`.
- The feed filters for published poems.
- Individual poem retrieval hides unpublished poems from ordinary retrieval.

**Design implication:** A new poem created already published and an existing poem transitioning to published are distinct potential events. Editing an already-published poem should not automatically be treated as a new publication.

The existing backend publication path is a candidate event boundary, subject to further design validation.

## 4. Product Constraints

- The immediate use case is new-poem notifications.
- A usable follow workflow has not been established through the inspected routes and Flutter code.
- We should not introduce a follow system solely to support notifications.
- The intended recipient audience remains undecided: possibilities include opt-in readers or users participating in a relevant existing feature, if confirmed active.
- Notification delivery expectations—an in-app inbox, push notifications, or both—remain undecided.

## 5. Security Considerations

Security auditing is already a priority for Syaahi. Notification design must account for:

- Recipient-specific authorization and data isolation.
- The existing database access paths and their permissions.
- Avoiding disclosure of unpublished poems or private data.
- Duplicate prevention when publication events are retried.
- Appropriate validation, rate limiting, and error handling.

The Flutter app uses the Dio-backed poem repository, and the backend uses Prisma. The complete relationship between Express, Supabase, and direct database access still needs confirmation.

No database permission changes or broad access-control modifications should be made without mapping the existing access paths first.

## 6. Encoding and Documentation Observation

A previous diagnostic found no obvious mojibake markers in the inspected architecture, API contract, and Prisma schema files, and Git status was clean at that point.

Some copied terminal output nevertheless displayed corrupted characters. The precise cause has not been conclusively established. Documentation and encoding cleanup should be delegated for later review, with changes limited to verified problems and checked through Git diffs.

## 7. Decisions Still Open

1. Who should receive new-poem notifications?
2. What precisely counts as a publication event?
3. Should the initial release provide in-app notifications, push notifications, or both?
4. Where should notification records be stored and accessed?
5. How should unread state, pagination, and notification dismissal work?
6. What security controls and tests are required before release?

## 8. Agreed Boundaries and Next Step

- Inspection findings are documented; the detailed design is not yet approved.
- No code changes, schema migrations, or sprint assignments are authorized at this stage.
- The integrity engine remains deferred and outside this initiative.
- The security audit remains a priority.
- The next step is to agree on a minimal notification design, including recipient rules, event semantics, storage, access control, and delivery expectations. Only then should the work be decomposed into sprints.

**Current status: Discovery documented — awaiting design agreement.**