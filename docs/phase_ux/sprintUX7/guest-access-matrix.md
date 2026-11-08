# UX-07 Guest Access Matrix

Generated from reconnaissance of `app_router.dart` redirect logic.

## Redirect Logic Summary

The `_redirect()` function in `app_router.dart` defines:
- **isProtected** = routes that require authentication
- **Guest redirect** → `/welcome` when accessing protected routes
- **Auth redirect** → `/home` when logged-in user visits `/welcome` or `/auth/*`

## Route Access Table

| Route | Screen | Guest | Authenticated | Backend Auth Required | UX Response if Restricted |
|---|---|---|---|---|---|
| `/` | SplashScreen | ✅ Yes | ✅ Yes | No | — |
| `/welcome` | WelcomeScreen | ✅ Yes | ❌ Redirected to /home | No | — |
| `/auth/signup` | SignupScreen | ✅ Yes | ❌ Redirected to /home | No | — |
| `/auth/login` | LoginScreen | ✅ Yes | ❌ Redirected to /home | No | — |
| `/home` | HomeScreen | ❌ Redirected to /welcome | ✅ Yes | Yes (feed API) | Explain auth needed; offer Sign In |
| `/write` | WriterScreen | ❌ Redirected to /welcome | ✅ Yes | Yes (publish API) | Explain auth needed; offer Join |
| `/poem/:id` | ReaderScreen | ✅ Yes | ✅ Yes | No (public poems) | — |
| `/heart` | HeartScreen | ❌ Redirected to /welcome | ✅ Yes | Yes (user data) | Explain auth needed; offer Sign In |
| `/profile` | ProfileScreen (own) | ❌ Redirected to /welcome | ✅ Yes | Yes (user data) | Explain auth needed; offer Sign In |
| `/profile/:username` | AuthorProfileScreen | ✅ Yes | ✅ Yes | No (public profile) | — |
| `/discover` | DiscoveryScreen | ❌ Redirected to /welcome | ✅ Yes | Varies | Explain auth needed; offer Sign In |
| `/notifications` | NotificationsScreen | ❌ Redirected to /welcome | ✅ Yes | Yes (user data) | Explain auth needed; offer Sign In |

## Guest-Accessible Actions (within allowed routes)

| Action | Location | Guest Allowed | Notes |
|---|---|---|---|
| Read a poem | ReaderScreen | ✅ Yes | Public poems only |
| View author profile | AuthorProfileScreen | ✅ Yes | Public data |
| Heart a poem | ReaderScreen | ❌ No | Requires auth — show explanation |
| Respond to a poem | ReaderScreen / ResonanceSection | ❌ No | Requires auth — show explanation |
| Write a poem | WriterScreen | ❌ No | Route itself is protected |
| Follow an author | AuthorProfileScreen | ❌ No | Requires auth (if feature exists) |

## Key Decisions for UX-07

1. **Guest discovery path:** Splash → Welcome → `/poem/:id` (via public links) and `/profile/:username`.
2. **The `/discover` route is currently protected.** UX-07.2 may need to expose a limited public discovery path, OR guide guests to public poems through the welcome experience.
3. **Heart and Respond** must show a calm, clear auth prompt when a guest attempts them.
4. **No backend changes needed** — the existing API client already handles guest requests (proceeds without Authorization header).

## ⚠️ Open Question

The `/discover` route is currently behind the auth wall. The UX-07 spec says guests should have "limited exploration." Options:
- **Option A:** Keep `/discover` protected; guests explore via public poem links and author profiles only.
- **Option B:** Make `/discover` public but limit the data shown (requires backend coordination).
- **Option C:** Create a separate public browse path for guests.

**Recommendation:** Option A for UX-07 (no backend changes). The welcome experience can surface a few public poems for guests to read. Revisit in a future sprint if needed.
