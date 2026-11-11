# UX-08: Testing Report

## Static Analysis

```text
flutter analyze
No issues found
```


**Result:** ✅ Clean (0 errors, 0 warnings, 0 info)

## Automated Tests

```text
flutter test
```

**Result:** Pending — run before merge.

## Manual Verification Checklist

### Navigation Shell
- [ ] Five destinations visible in bottom nav (mobile)
- [ ] Central Write button elevated and gold
- [ ] Tapping Home/Discover/Heart/Profile switches tabs
- [ ] Tapping Write pushes editor on top of shell
- [ ] Back from Write returns to previous tab
- [ ] Selected state matches current route
- [ ] Tab state preserved (Feed scroll, filters)

### Feed AppBar
- [ ] Brand mark visible (left)
- [ ] Filter toggle works
- [ ] Notification bell shows unread count
- [ ] Overflow opens "How Syaahi Works"
- [ ] Walkthrough displays correctly
- [ ] No Search, Heart, Profile, Logout icons remain
- [ ] No FAB remains

### Profile
- [ ] Logout button visible in AppBar
- [ ] Logout clears session and redirects to /welcome
- [ ] No back button (shell branch)

### Auth & Guest
- [ ] Guest can access /discover
- [ ] Guest redirected to /welcome for protected routes
- [ ] Authenticated user redirected from /welcome to /home
- [ ] Deep link to /poem/:id works for guest

### Responsive
- [ ] Mobile (<600px): bottom nav visible
- [ ] Desktop (>=600px): nav rail visible
- [ ] No horizontal overflow
- [ ] Safe area respected

### Browser (web)
- [ ] Direct URL /home works
- [ ] Direct URL /discover works
- [ ] Browser back/forward works
- [ ] Refresh preserves route

## Known Limitations

- Navigation rail Write destination uses standard rail styling (not elevated circle like mobile)
- Shell branch screens no longer support browser back to previous tab (use nav bar)
