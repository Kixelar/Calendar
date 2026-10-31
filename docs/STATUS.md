# Status

**Version:** `2026.10.31-dev` (branch `dev`). Nothing released on `main` yet.

## Done (all mockup screens that the Google Calendar API supports)
- 01 onboarding: welcome, connect Google, choose calendars, sync progress.
- 02 views: year, month, week, day, search.
- 03 events: details, new/edit (repeat, reminder, time zone, guests, calendar, place, notes), custom repeat, invite guests, received invitation.
- 04 calendars: list, add (new Google calendar, holidays, Google account), holidays by country, sharing (ACL, link), shared with you.
- 05 settings: hub, appearance, notifications, accounts and sync, data and privacy, help + articles, about.
- 06 states: empty day, delete (one / following / all), edit conflict.
- 07 widgets (7 sizes, dark/light) and notifications (reminders, all-day, daily summary, invitations, shared changes).
- Offline cache, own signing key, mockup fonts, Polish and English, launcher name per device language.
- Confirmed on the owner's phone: sign-in, silent restore, event create/edit/delete incl. repeating (2026-10-30/31).
- Tests: `flutter test` (logic: day index, ISO weeks, RRULE, delete-following, cache, notification plan, marquee) and
  PNG renders of every screen (`CAL_SHOTS`).

## Not checked on a device yet
- Everything added on 2026-10-31 after the event writes: search, repeat/guests/invitations, calendars and sharing,
  settings, notifications (exact alarms, snooze, actions), home screen widgets (drawn natively; not seen on a screen).

## Waiting for the owner (decisions or material)
- **App icon** (graphics from the owner).
- **Glyph Interface** (05.3 section, 07.3 countdown): needs the Nothing Glyph Developer Kit.
- **Terms and privacy policy** texts (welcome caption, 05.8 rows) and a **support address** (05.6 contact rows).
- **.ics**: subscribe by URL (04.2), import / export file (05.5). The Calendar API cannot add URL subscriptions;
  it needs an in-app importer. Same question for daily backup and app lock.
- **CalDAV / Outlook / iCloud** accounts (01.2, 04.2): a separate sync engine.
- **Holiday filters** (04.3 "days off / religious / name days"): Google holiday calendars do not carry these kinds; name days do not exist there.
- **Background sync when the app is closed** (05.4): needs WorkManager and Google auth outside the app; notifications
  and widgets are refreshed only when the app runs (date widgets still update by themselves).

## Traps
- Gradle/Java does not run in Claude's sandbox: build APKs in the owner's terminal (docs/WORKFLOW.md), and run
  `flutter pub get` there after adding packages (different pub cache).
- Build numbers must keep growing: 30000000 + minutes since 2026-01-01 UTC, and never below the last one sent
  (30436891 on 2026-10-31).
- `google_sign_in` 7.x gives no refresh token: always get the token through `GoogleCalendar._authorize` before an API call.
- Builds are signed with the app's own key in `<keystore folder>/` (docs/WORKFLOW.md); its SHA-1 is in the Android OAuth client.
- ARB files: append keys as text; re-dumping them with a JSON tool reformats the whole file.
