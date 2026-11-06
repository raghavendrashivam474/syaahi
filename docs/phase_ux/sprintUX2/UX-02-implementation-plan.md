# UX-02 Implementation Plan

**Sprint:** UX-02 — Profile & Author Experience
**Status:** Proposed (awaiting approval)
**Depends on:** ADR-UX02-author-profile-experience.md

---

## 1. Proposed Folder Structure

```text
lib/features/profile/
├── data/
│ └── profile_repository.dart
├── state/
│ └── profile_providers.dart
├── presentation/
│ ├── author_profile_screen.dart
│ └── author_profile_view.dart
└── profile_screen.dart
```

## 2. Implementation Sequence

### UX-02.S2 — Foundation
| Step | Task | Files |
|---|---|---|
| S2.1 | Create AuthorProfile model | shared/models/author_profile.dart |
| S2.2 | Create ProfileRepository | features/profile/data/profile_repository.dart |
| S2.3 | Create profile providers | features/profile/state/profile_providers.dart |
| S2.4 | Add /profile/:username route | core/router/app_router.dart |
| S2.5 | Create AuthorProfileView | features/profile/presentation/author_profile_view.dart |
| S2.6 | Create AuthorProfileScreen | features/profile/presentation/author_profile_screen.dart |
| S2.7 | Refactor ProfileScreen | features/profile/profile_screen.dart |

### UX-02.S3 — Published Works Polish
| Step | Task |
|---|---|
| S3.1 | Cursor-based load-more |
| S3.2 | Empty state |
| S3.3 | Error state with retry |
| S3.4 | Loading skeleton |
| S3.5 | Author not found (404) |

### UX-02.S4 — Navigation Integration
| Step | Task |
|---|---|
| S4.1 | Author tap in feed cards |
| S4.2 | Byline tap in reader |
| S4.3 | Attribution tap in reader |
| S4.4 | Manual navigation verification |

### UX-02.S5 — Regression and Release
| Step | Task |
|---|---|
| S5.1 | flutter analyze |
| S5.2 | flutter test |
| S5.3 | Manual regression |
| S5.4 | Responsive check |
| S5.5 | Git diff review |
| S5.6 | Completion report |

## 3. Files Summary

**5 new, 4 modified, 0 deleted.**

*Awaiting approval.*
