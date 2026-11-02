# TODO

Screen numbers refer to docs/design/mockup.html; the month, week and day views follow docs/design/views.html.

## Stage 1: Google + views
- [x] 01.1 Welcome, 01.2 Connect Google, 01.3 Choose calendars, 01.4 Sync progress
- [x] 02.1 Year, 02.2 Month, 02.3 Week, 02.4 Day, 02.5 Search
- [x] Views rework after docs/design/views.html (confirmed by the owner, 2026-11-01)
- [x] Google Cloud project + `config.json` (owner, docs/GOOGLE.md), fonts (owner)
- [x] Offline cache of events (JSON files per year in the app support folder)

## Stage 2: events
- [x] 03.1 Event details, 03.2 New / edit event (repeat, reminder, time zone, guests), 03.3 Custom repeat
- [x] 03.4 Invite guests, 03.5 Received invitation (reply)
- [x] 06.1 Empty day, 06.2 Delete event, 06.3 Sync conflict

## Stage 3: calendars and settings
- [x] 04.1 Calendars, 04.2 Add calendar, 04.3 Holidays, 04.4 Share calendar, 04.5 Shared with you
- [x] 05.1–05.8 Settings, appearance, notifications, accounts, data & privacy, help, about
- [x] 05.4 background sync when the app is closed (JobScheduler, SyncJob.kt), "Wi-Fi only"
- [x] 04.2 / 05.5 import an .ics file into a Google calendar (2026-11-01)
- [x] 05.5 export the shown calendars to an .ics file (2026-11-01)
- [x] 04.2 "Subscribe to address" (.ics / webcal): own calendar refreshed hourly by the app (2026-11-01)
- [x] 05.5 app lock: fingerprint, face or screen lock code (2026-11-02)
- [x] Marker shape menu (24 shapes) from the calendar list and 04.5 (2026-11-02)
- [ ] 05.8 update check (later)
- [ ] 05.4 "On this device": full local calendars (agreed 2026-11-02, later). Plan, in steps:
      1. local calendars and events (no repeat), views, search, reminders, widgets, .ics import/export;
      2. repeating local events with exceptions (this / following / all);
      3. without a Google account: holidays (public Google holiday .ics) and address subscriptions into local calendars.
      Decided: no moving events between Google and local; losing local data on uninstall is an accepted risk.

## Stage 4: Android extras
- [x] 07.1/07.2 Home screen widgets, following the app theme (confirmed on the phone)
- [x] 07.3 Event notifications
- [x] Release signing key, app icon
- [x] Glyph interface on Nothing phones (Lights.kt, Glyph Developer Kit), not run on a Glyph phone
  - [ ] Check on a real Nothing phone: lights from the background (the kit's README says "only foreground
        applications"), strip order top/bottom, the matrix toy and its preview image

## Stage 5: languages and onboarding (owner, 2026-11-02)
- [ ] Translate the app into more languages (now Polish and English); the owner picks which. Covers lib/l10n/*.arb,
      Android strings (launcher name, widget names, Glyph toy) and the widget/notification texts sent from Dart
- [ ] Onboarding rework with an extra panel to choose the app language (the owner designs the look)
- [ ] One step indicator on every onboarding panel: the welcome screen (01.1) marks the step with dots, the others
      say "Step 1 of 3"; the owner decides which style stays

## At the end
- [ ] Terms and privacy policy texts, support address; then 05.6 contact rows, 05.8 terms rows, welcome screen caption
- [ ] First release: merge `dev` into `main`, tag, GitHub Release (only when the owner says so)

## Not doing
- 04.5 "Ask for edit rights" and 05.5 daily backup: dropped (owner, 2026-11-02).
- 03.5 "Add to" another calendar and "Propose another time", 04.4 "Invited" state: the Google Calendar API has no way to do these.
- Google Tasks (owner, 2026-10-31).
- For now: CalDAV / Outlook / iCloud, holiday filters and name days (04.3) (owner).
