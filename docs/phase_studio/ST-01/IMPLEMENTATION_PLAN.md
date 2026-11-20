# ST-01 Work Package Execution Plan

## Phase Sequencing
1. **Phase 1 — Backend Draft Foundation (ST-01.2 & ST-01.3 backend parts)**
   - Prisma schema migration (\Draft\ model + relations).
   - Zod validation schemas (\createDraftSchema\, \updateDraftSchema\).
   - Draft Controller & Routes (\/api/v1/studio/drafts\).
   - Controlled publication endpoint (\/api/v1/studio/drafts/:id/publish\).
   - Backend automated tests (\src/__tests__/studio.drafts.test.ts\).

2. **Phase 2 — Local Persistence Foundation (ST-01.4 & ST-01.5)**
   - Add \drift\, \drift_flutter\, \sqlite3_flutter_libs\ to \pubspec.yaml\.
   - Implement local SQLite database schema for drafts.
   - Implement \LocalDraftRepository\ abstraction.
   - Define \DraftPoem\ domain model and mapper layers.
   - Local persistence repository tests.

3. **Phase 3 — Studio Module & Editor Foundation (ST-01.1 & ST-01.6)**
   - Setup \syaahi-app/lib/features/studio/\ feature module structure.
   - Register \/studio\ routes in \pp_router.dart\.
   - Implement Studio Riverpod state notifier and state representation.
   - Implement debounced autosave mechanism (500ms debounce).
   - Sync service integration between local repository and remote API.

4. **Phase 4 — Studio User Interface & Publication Integration (ST-01.3 & ST-01.7)**
   - Build Studio Home / Draft List screen.
   - Build Studio Writing / Editor screen.
   - Mobile-first keyboard interaction & save status indicators.
   - Integrate Controlled Publication workflow to existing Reader/Poem ecosystem.

5. **Phase 5 — Delivery, Documentation & Tags**
   - Full regression suite execution.
   - Complete documentation set in \docs/phase_studio/ST-01/\.
   - Verify Git status and create tag \-ST-ST01-impl\ or equivalent release tag.
