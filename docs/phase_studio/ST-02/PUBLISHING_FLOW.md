# ST-02 Publishing Workflow Completion

- **Module**: Studio
- **Version**: 1.0.0

---

## 1. Controlled Idempotent Publishing Journey

1. **Pre-Publication Flush**: Pending autosave timer is flushed to Drift database.
2. **Validation**: Rejects publication if content.trim().isEmpty.
3. **Pre-Publication Sync**: Fresh or modified local drafts are synced via _syncService.syncDraft(draft) before calling /api/v1/studio/drafts/:id/publish.
4. **Backend Transaction**: Backend executes single Prisma transaction creating Poem, linking draftId, setting Draft.isPublished = true, and triggering single notification set.
5. **Idempotency Guarantee**: Subsequent publish attempts return existing Poem with HTTP 200.
6. **Post-Publish Integration**: Frontend marks local draft isPublished = true, clears active draft state, reloads draft list, and navigates seamlessly to /poem/:id.
