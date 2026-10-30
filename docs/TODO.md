# TODO

Screen numbers refer to docs/design/mockup.html.

## Stage 1: Google + views
- [x] 01.1 Welcome, 01.2 Connect Google, 01.3 Choose calendars
- [x] 02.1 Year, 02.2 Month, 02.3 Week, 02.4 Day
- [x] Google Cloud project + `config.json` (owner, docs/GOOGLE.md)
- [x] Test sign-in and event loading on a phone (owner)
- [ ] Confirm the app no longer asks to sign in on every launch (owner)
- [x] Fonts (owner supplied, docs/DESIGN.md)
- [ ] 01.4 Sync progress screen
- [ ] 02.5 Search (top bar search icon is hidden until then)
- [ ] Offline cache of events (now in memory only, refetched on start)

## Stage 2: events
- [ ] 03.1 Event details, 03.2 New event (FAB hidden until then), 03.3 Custom repeat
- [ ] 03.4 Invite guests, 03.5 Received invitation (reply)
- [ ] 06.1 Empty day, 06.2 Delete event, 06.3 Sync conflict

## Stage 3: calendars and settings
- [ ] 04.1 Calendars, 04.2 Add calendar, 04.3 Holidays, 04.4 Share calendar, 04.5 Shared with you
- [ ] 05.1–05.8 Settings, appearance, notifications & Glyph, accounts, data & privacy, help, about (top bar settings icon hidden until then)
- [ ] Terms and privacy policy texts (welcome screen caption from the mockup is left out until they exist)
- [ ] "Other account — CalDAV, Outlook" (01.2 secondary button, left out for now)

## Stage 4: Android extras
- [ ] 07.1/07.2 Home screen widgets (dark, light) — native Kotlin
- [ ] 07.3 Event notifications
- [ ] Glyph interface on Nothing phones (Glyph Developer Kit)
- [x] Release signing key
- [ ] App icon
