# TODO

Screen numbers refer to docs/design/mockup.html.

## Stage 1: Google + views
- [x] 01.1 Welcome, 01.2 Connect Google, 01.3 Choose calendars
- [x] 02.1 Year, 02.2 Month, 02.3 Week, 02.4 Day
- [x] Google Cloud project + `config.json` (owner, docs/GOOGLE.md)
- [x] Test sign-in and event loading on a phone (owner)
- [x] Confirm the app no longer asks to sign in on every launch (owner)
- [x] Fonts (owner supplied, docs/DESIGN.md)
- [x] 01.4 Sync progress screen
- [x] 02.5 Search
- [x] Offline cache of events (JSON files per year in the app support folder)

## Stage 2: events
- [x] 03.1 Event details (time, title, calendar, place, reminder, notes, guests with replies; edit, delete)
- [x] 03.2 New / edit event: title, all day, start, end, calendar, place, notes
- [x] 03.2 rows: time zone (read-only, device zone), repeat, reminder, guests
- [x] 03.1 repeat description, share and "more" icons; notifications switch waits for 07.3
- [x] 03.3 Custom repeat
- [x] 03.4 Invite guests, 03.5 Received invitation (reply)
- [ ] 03.5 "Add to" another calendar and "Propose another time": the Calendar API has no call for either (left out)
- [x] 06.2 Delete event (only this / this and following / all, notify guests)
- [x] 06.1 Empty day, 06.3 Sync conflict (compares Google's `updated` time when saving)

## Stage 3: calendars and settings
- [x] 04.1 Calendars, 04.3 Holidays, 04.4 Share calendar, 04.5 Shared with you
- [x] 04.2 Add calendar: new Google calendar, holidays, Google account
- [ ] 04.2 "Subscribe to address" (.ics / webcal) and "Import file": the Calendar API cannot add URL subscriptions; needs an in-app .ics importer (owner decision)
- [ ] 04.3 "Show" filters (days off / religious / name days / special days): Google holiday calendars do not mark these kinds, name days do not exist there (owner decision)
- [ ] 04.4 "Invited" state for people who have not accepted: the ACL API does not report it
- [ ] 04.5 "Ask for edit rights": needs sending an e-mail (url_launcher), left out
- [ ] 05.1–05.8 Settings, appearance, notifications & Glyph, accounts, data & privacy, help, about (top bar settings icon hidden until then)
- [ ] Terms and privacy policy texts (welcome screen caption from the mockup is left out until they exist)
- [ ] "Other account — CalDAV, Outlook" (01.2 secondary button, left out for now)

## Stage 4: Android extras
- [ ] 07.1/07.2 Home screen widgets (dark, light) — native Kotlin
- [ ] 07.3 Event notifications
- [ ] Glyph interface on Nothing phones (Glyph Developer Kit)
- [x] Release signing key
- [ ] App icon
