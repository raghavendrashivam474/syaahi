# N1 Completion Report: Data Foundation & Opt-in Preferences

## 1. Executive Summary and Final Status
The N1 sprint has been successfully executed. The required database models, relationships, indexes, and constraints for Syaahi Notifications v0.1 were added to the Prisma schema. The migration was carefully generated using a schema diff approach to bypass Supabase shadow-database limitations, safely applying the changes without any data loss to existing tables.

**Final Status:** **Ready for owner review**

## 2. Baseline Commit and Branch State
- **Branch:** main
- **Baseline Commit:** 7d5b15d (tag: v-noti_N0)
- **Working Tree:** Clean baseline before N1 changes

## 3. Files Changed and Purpose
- syaahi-backend/prisma/schema.prisma: Added Notification, NotificationPreference, NotificationType enum, and user/poem relations.
- syaahi-backend/prisma/migrations/: Added the N1 migration SQL file.
- syaahi-backend/package.json & package-lock.json: Installed existing Prisma dependencies and added 	est:n1 script.
- syaahi-backend/src/__tests__/notifications.foundation.test.ts: Added N1 data integrity test suite.

## 4. Schema Changes & Constraint Summary
- **Enums Added:** NotificationType (POEM_PUBLISHED)
- **Tables Added:** 
  - Notification: UUID v4 ID, 
ecipientId, poemId, 	ype, nullable 
eadAt, createdAt.
  - NotificationPreference: userId (PK), boolean 
ewPoemAlerts (default False).
- **Constraints Enforced:**
  - @@unique([recipientId, poemId, type]) to prevent duplicate notifications.
  - Cascade deletes on all foreign keys (User and Poem).
- **Indexes Created:** [recipientId, createdAt] (Inbox), [recipientId, readAt] (Unread count).

## 5. Migration Application & Verification
- **Migration Strategy:** Because Supabase does not permit standard Prisma shadow databases, prisma migrate diff was used to generate raw SQL. The SQL was applied statement-by-statement, then officially marked in the _prisma_migrations table via prisma migrate resolve.
- **Data Loss Verification:** A manual row-count script proved that all 18 Users, 84 Poems, 15 Reactions, and 15 Hearts remained untouched.

## 6. Preference Default and Absent-Preference Behavior
- New explicit records default to 
ewPoemAlerts: false.
- Absent preference records evaluate safely to False without requiring assumed consent (proven by automated tests).

## 7. Automated Tests and Results
A custom integration test suite was created (src/__tests__/notifications.foundation.test.ts) and passed 8/8 tests directly against the live database:
1. ✅ Valid Notification created with correct FKs.
2. ✅ Unique constraint blocks duplicate insert (P2002).
3. ✅ Distinct recipients receive separate notifications.
4. ✅ Preference 
ewPoemAlerts defaults to false.
5. ✅ Absent NotificationPreference treats effective opt-in as false.
6. ✅ NotificationPreference 1-to-1 constraint blocks duplicate row.
7. ✅ Deleting a Poem cascades and removes related Notifications.
8. ✅ Deleting a User cascades and removes their Notifications and Preferences.

## 8. Existing-Feature Regression Results
- 
px tsc (build check) succeeded without errors.
- Existing database constraints and counts verified intact. No existing Express controllers or application logic were modified in N1.

## 9. Architecture Decisions Added or Changed
- **No changes to product logic.** The schema implements exact N0 specifications.
- **Operational adaptation:** Documented the required prisma migrate diff workflow for Supabase in this project, circumventing the standard migrate dev shadow-database conflict. No ADR update required, merely a tooling implementation detail.

## 10. Rollback and Recovery Procedure
If needed, rollback can be achieved by deleting the tables directly and updating Prisma history:
```sql
DROP TABLE "Notification";
DROP TABLE "NotificationPreference";
DROP TYPE "NotificationType";
DELETE FROM _prisma_migrations WHERE migration_name = '20261023032914_add_notifications';
``` 

## 11. Known Limitations and Deferred Work

- Device Tokens / FCM: Out of scope for N1, fully deferred to N5.
- Push Provider Setup: Deferred to N5.

## 12. Git Commits and Proposed Tag

- Staging for commit.
- **Proposed Checkpoint Tag:** v-noti_N1

## 13. Exit-Criteria Checklist

- Notification & Preference models match the approved N0 specification.
- Unique constraint and required indexes are present and verified.
- Opt-in defaults to false, including for existing users without a preference row.
- Versioned migration created, applied, and verified without data loss.
- Database-level constraints have automated test coverage.
- No device-token or push-delivery scope leaked into N1.
- Changes limited to the approved N1 scope.
- N1_COMPLETION_REPORT.md is complete.

## 14. Unverified or Failed Checks

- None. All checks passed successfully.
