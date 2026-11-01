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
- [ ] 04.5 "Ask for edit rights": the API cannot ask; only an e-mail to the owner from the user's mail app (owner thinks it over)
- [ ] 05.5 app lock (later), daily backup (owner decision)
- [ ] 05.8 update check (later)
- [ ] 05.4 "On this device" account: no local calendars (owner decision)

## Stage 4: Android extras
- [x] 07.1/07.2 Home screen widgets, following the app theme (confirmed on the phone)
- [x] 07.3 Event notifications
- [x] Release signing key, app icon
- [ ] Glyph interface on Nothing phones (Glyph Developer Kit): agreed without tests, the owner's phone has no Glyph lights

## At the end
- [ ] Terms and privacy policy texts, support address; then 05.6 contact rows, 05.8 terms rows, welcome screen caption
- [ ] First release: merge `dev` into `main`, tag, GitHub Release (only when the owner says so)

## Not doing
- 03.5 "Add to" another calendar and "Propose another time", 04.4 "Invited" state: the Google Calendar API has no way to do these.
- Google Tasks (owner, 2026-10-31).
- For now: CalDAV / Outlook / iCloud, holiday filters and name days (04.3) (owner).
