# UX-08: Navigation Shell & Information Architecture

## Objective

Restructure Syaahi's navigation from a flat route architecture with an overcrowded Feed AppBar into a predictable, destination-oriented navigation shell.

## Scope

- Five-destination bottom navigation (Home, Discover, Write, My Heart, Profile)
- Visually elevated central Write action
- Contextual, screen-specific AppBars
- Consolidated Feed overflow menu
- Responsive navigation (mobile bottom nav, desktop nav rail)
- Profile as the central account-management destination

## Workstreams

| ID | Workstream | Status |
|---|---|---|
| UX-08.S1 | Reconnaissance & Architecture Baseline | Complete |
| UX-08.S2 | Primary Navigation Shell | Complete |
| UX-08.S3 | Contextual AppBar & Overflow | Complete |
| UX-08.S4 | Responsive & Routing Integration | Complete |
| UX-08.S5 | Regression, Documentation & Release | In Progress |

## Acceptance Criteria

| ID | Criterion | Status |
|---|---|---|
| AC-01 | Five primary destinations via navigation shell | ✅ |
| AC-02 | Central Write opens existing editor | ✅ |
| AC-03 | Selected state reflects current route | ✅ |
| AC-04 | Feed AppBar: brand + Filter + Notifications + Overflow | ✅ |
| AC-05 | How Syaahi Works opens existing walkthrough | ✅ |
| AC-06 | Discover accessible to guest users | ✅ |
| AC-07 | My Heart retains all functionality | ✅ |
| AC-08 | Profile provides account management + Logout | ✅ |
| AC-09 | Logout preserves auth/session lifecycle | ✅ |
| AC-10 | Reader and poem-detail actions functional | ✅ |
| AC-11 | Notifications remain functional | ✅ |
| AC-12 | Mobile respects safe areas and keyboard | ✅ |
| AC-13 | Wide-screen has responsive treatment | ✅ |
| AC-14 | Direct URL and browser navigation work | ✅ |
| AC-15 | No feature unintentionally removed or duplicated | ✅ |
| AC-16 | No unnecessary dependencies introduced | ✅ |
| AC-17 | Architectural changes documented | ✅ |
| AC-18 | Existing regression tests pass | ✅ |

## Final Status

**Pending release tag and merge.**
