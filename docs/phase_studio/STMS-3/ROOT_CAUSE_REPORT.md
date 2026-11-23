# STMS-3 Root Cause Report

## 1. Executive Summary
During manual acceptance testing following ST-03 (Writing Intelligence), testers could not find how to access Syaahi Studio or view their saved drafts within the Syaahi Flutter application interface.

## 2. Reproduction Steps
1. Launch `syaahi-app` in Flutter Web / Web Browser / Emulator.
2. Sign in as an authenticated user.
3. Observe main navigation options: Home, Discover, Write (center circle icon), Heart, Profile.
4. Click Write icon -> Regular poem composition screen (`WriterScreen`) opens; not Studio draft editor.
5. Click Profile tab -> Displays published works; no option or button to enter Studio or view drafts.
6. Attempt direct URL navigation to `/studio` -> Returns 404 / Not Found screen.

## 3. Confirmed Root Causes

### Root Cause 1: Missing Route Declarations in `AppRouter`
- **Location**: `lib/core/router/app_router.dart`
- **Evidence**: `AppRouter` defined routes for `/home`, `/discover`, `/heart`, `/profile`, `/write`, `/poem/:id`, `/profile/:username`, and `/notifications`. Neither `/studio` nor `/studio/editor` was defined.
- **Impact**: Any internal call (such as `context.push('/studio/editor')` from `StudioHomeScreen`) or manual navigation to `/studio` failed with a 404.

### Root Cause 2: Omitted User-Facing Entry Points
- **Location**: Navigation Shell & Profile Screen.
- **Evidence**:
  - The center navigation button opens `/write` (`WriterScreen`), which is the direct poem composition workflow.
  - The Profile page (`AuthorProfileView`) showed published works but lacked a call-to-action or menu item for Studio / My Drafts.
- **Impact**: Authenticated users had no visual entry point in the UI to discover Studio or access saved drafts.

## 4. Required Corrective Strategy
1. **Router Extension**: Register `/studio` and `/studio/editor` as protected pushed routes in `AppRouter`.
2. **Profile Entry Point**: Add a prominent "Syaahi Studio & Drafts" section/action on the authenticated user's own profile screen (`isOwnProfile == true`).
3. **Writer Screen Link**: Add a helpful entry banner/button on `WriterScreen` for writers who want to open Studio / Drafts instead of quick publishing.
4. **App Bar Action**: Add a Studio icon action to the Profile screen AppBar for rapid access.
5. **Zero Regression**: Retain `WriterScreen` for regular composition, preserving its distinct workflow while ensuring Studio is fully reachable.
