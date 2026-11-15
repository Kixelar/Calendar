# Status

**Version:** `2026.11.15-dev` (branch `dev`). Nothing released on `main` yet.

## Done (all mockup screens that the Google Calendar API supports)
- 01 onboarding: language, welcome, connect Google, choose calendars, sync progress (step bars on each panel).
- 02 views: year, month, week, day, search.
- 03 events: details, new/edit (repeat, reminder, time zone, guests, calendar, place, notes), custom repeat, invite guests, received invitation.
- 04 calendars: list, add (new calendar in Google or on the phone, holidays, subscriptions, .ics import, Google account),
  holidays by country, sharing (ACL, link), shared with you.
- Calendars on this device (with or without Google), including repeats, holidays and subscriptions without an account.
- 05 settings: hub, appearance, notifications, accounts and sync, data and privacy, help + articles, about.
- 06 states: empty day, delete (one / following / all), edit conflict.
- 07 widgets (8: month, today, week, next, next small, date, date small, day clock; dark/light) and notifications
  (reminders, all-day, daily summary, invitations, shared changes). Glyph Interface (not run on a Glyph phone).
- Update screens (home card, full screen, About row); the update check that feeds them is still to do.
- Offline cache, own signing key, mockup fonts, 8 languages (pl, en, de, es, fr, it, pt, nl; chosen in onboarding or Appearance), launcher
  and widget names per device language.
- Confirmed on the owner's phone: sign-in, silent restore, event create/edit/delete incl. repeating (2026-10-30/31).
- Tests: `flutter test` (logic: day index, ISO weeks, RRULE, delete-following, cache, notification plan, marquee) and
  PNG renders of every screen (`CAL_SHOTS`).

## Checked on the owner's phone
- Everything listed above, including notifications, widgets, background sync and the views rework (2026-11-01).

## Open
- Owner asked what happens when an invitation notification is dismissed: nothing is sent; the invitation stays
  unanswered in Google, the app does not notify about it again (`seenInvites`), and it can still be answered from the
  event (03.5 screen).
- Confirmed by the owner (2026-11-02): .ics import/export, address subscriptions, day clock widget, deleting own calendars, holiday countries, double tap for today. Wi-Fi only: the "Check" test ignored it (fixed 2026-11-02), waiting for a re-check.
- Owner's list of 2026-11-01 (no birthdays, account row, one account, all holiday countries, no "more" button, double tap = today): built, waiting for the owner's check.

## Resolved
- Crash at start (2026-10-31) was caused by WorkManager (it initialises before app code); removed in 30436952,
  background sync moved to JobScheduler. Confirmed working on the owner's phone.
- Background sync never ran: scheduling threw `SecurityException: ACCESS_NETWORK_STATE required for jobs with a
  connectivity constraint` (WorkManager used to add that permission). Added in 30437159; confirmed on the owner's phone
  (widgets update with the app closed, 2026-11-01).

- Widget theme: widgets ignored the app's own theme setting; fixed in 30438477, confirmed by the owner (2026-11-01).
  1×1 widget restyled to the theme's card colour (owner's choice, 30438483).
- Views rework (month/week/day after docs/design/views.html, year header): confirmed by the owner (2026-11-01).

## Waiting for the owner (decisions or material)
- **Glyph Interface** (05.3): built 2026-11-02 to the owner's choices, but never run on a phone with Glyph lights (the
  owner's has none). Needs someone with a Nothing phone (lights or matrix) to check; see DECISIONS.
- **Terms and privacy policy** texts and a **support address**: at the very end, together.
- **Update check**: screens done; where releases live is the owner's call (proposed a public releases-only
  repo, since the app cannot read a private repo's releases). More languages (cs, sk, sv, da, fi, tr): maybe later.
- Dropped (owner, 2026-11-02): ask for edit rights, daily backup. (2026-11-08): launcher icon showing today's date.
- **CalDAV / Outlook / iCloud**, **holiday filters / name days**: dropped for now (owner).

## Traps
- Diagnose on the phone over USB: `adb shell dumpsys jobscheduler` (job history, constraints), `adb logcat`,
  `adb shell cmd jobscheduler run -f com.kixelar.calendar 31` (force a background run). Use MSYS_NO_PATHCONV=1 in Git Bash.
- Gradle/Java does not run in Claude's sandbox ("Unable to establish loopback connection", even with the sandbox
  off): build APKs in the owner's terminal (docs/WORKFLOW.md), and run `flutter pub get` there after adding packages
  (different pub cache).
- adb over Wi-Fi (wireless debugging) finds the phone only when adb runs outside Claude's sandbox; inside it the mDNS
  list stays empty.
- Build numbers must keep growing: 30000000 + minutes since 2026-01-01 UTC, and never below the last one sent
  (30458561 on 2026-11-15).
- `google_sign_in` 7.x gives no refresh token: always get the token through `GoogleCalendar._authorize` before an API call.
- Builds are signed with the app's own key in `<keystore folder>/` (docs/WORKFLOW.md); its SHA-1 is in the Android OAuth client.
- ARB files: append keys as text; re-dumping them with a JSON tool reformats the whole file.
