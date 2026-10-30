# Status

**Version:** `2026.10.30-dev` (branch `dev`). Nothing released on `main` yet.

## Done
- Flutter Android project `com.kixelar.calendar`, private repo `Kixelar/calendar`.
- Launcher name per device language: "Kalendarz" (pl), "Calendar" (others). In-app texts in Polish and English.
- Design tokens from the mockup, dark and light theme following the system.
- Onboarding 01.1 welcome, 01.2 connect Google, 01.3 choose calendars (also reachable from the main screen's calendars button).
- Views 02.1 year (dot per day), 02.2 month, 02.3 week, 02.4 day (all-day section, schedule, now line), read from Google Calendar.
- Tests: event-to-day indexing, ISO week numbers, PNG renders of all implemented screens.

- Mockup fonts bundled (Ndot, NType82, Lettera Mono + Polish fallbacks).
- Own signing key; Google web client ID in `config.json`.

- Google sign-in and event sync confirmed working on the owner's phone (2026-10-30).

## Waiting for the owner
- **Check on the phone** that reopening the app no longer shows the account picker (silent restore, see docs/ARCHITECTURE.md).

## Next
See docs/TODO.md. Proposed order: event details and create/edit (03.x), then 01.4 sync screen, search, calendars
management (04.x), settings (05.x), empty/delete/conflict states (06.x), widgets and notifications (07.x), Glyph.

## Traps
- Gradle/Java does not run in Claude's sandbox: build APKs in the owner's terminal (docs/WORKFLOW.md).
- `google_sign_in` 7.x gives no refresh token: always get the token through `GoogleCalendar._authorize` before an API call.
- Builds are signed with the app's own key in `<keystore folder>/` (docs/WORKFLOW.md); its SHA-1 goes into the Android
  OAuth client. The first APK (2026-10-30, debug key) must be uninstalled before installing newer ones.
