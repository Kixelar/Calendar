# Architecture

Flutter app, Android only. No backend: the phone talks to the Google Calendar API with the user's own token.

```
lib/
  main.dart              App: theme (system light/dark), localisation, picks Welcome or Home
  theme.dart             Design tokens from the mockup (colours Tok, text styles T)
  google.dart            Google sign-in + Calendar API (GoogleCalendar), models Cal / Ev, marker Shape
  store.dart             App state (ChangeNotifier): account, chosen calendars, events cached per year
  ui.dart                Shared widgets mirroring the mockup's CSS classes (Lbl, Section, RowItem, Toggle, Btn, Hero2, EventRow, Marker, Marquee)
  l10n/app_en.arb        English strings (template)
  l10n/app_pl.arb        Polish strings
  screens/onboarding.dart  01.1 Welcome, 01.2 Connect, 01.3 Choose (also used as the calendar picker later)
  screens/home.dart        02.1 year, 02.2 month, 02.3 week, 02.4 day views + bottom view tabs and + button
  screens/event.dart       03.1 event details, 03.2 new/edit event, 06.2 delete dialog, calendar picker
android/app/src/main/res/values*/strings.xml   Launcher name per device language
test/screens_test.dart   Logic tests + PNG renders of screens with a fake Google account
```

## Data flow
1. `Store.start()` reads `SharedPreferences` (`onboarded`, `calendars` = ids of enabled calendars) and tries a silent
   Google sign-in (`GoogleCalendar.restore`).
2. Views ask `Store.on(day)`. If that year is not loaded, it fetches all events of the enabled calendars for the
   whole year (`events.list`, `singleEvents=true` so recurring events come expanded) and indexes them by day
   (`indexByDay`; multi-day events appear on every day they touch). Until then `on()` returns `null` (spinner).
3. Pull-to-refresh or toggling a calendar clears the cache.

## Writing events
- `GoogleCalendar.save`: new events are inserted; existing ones are fetched (`events.get`), changed and sent back
  with `events.update`, so fields the app does not edit (guests, reminders, conference links) survive. Changing the
  calendar first calls `events.move`. Editing an occurrence of a repeating event changes only that occurrence.
- `GoogleCalendar.delete`: "only this" deletes the occurrence, "all" deletes the series, "this and following" rewrites
  the series' RRULE with `UNTIL` just before the occurrence (`endRuleBefore`, tested), or deletes the series if it is
  the first occurrence. "Notify guests" maps to `sendUpdates=all|none`.
- After any write the per-year cache is cleared and refetched.
- Edit is offered only when the event's calendar is writable and this calendar organizes the event
  (`organizer.self`); invitations from others can be deleted from your calendar but not edited.

## Google auth
`google_sign_in` 7.x: `authenticate()` signs in, `authorizationClient.authorizeScopes()` grants the Calendar scope.
The plugin hands out no refresh token, so every API call first asks the platform for a current access token
(`_authorize`). Needs the web client ID at build time (`GOOGLE_SERVER_CLIENT_ID`, docs/GOOGLE.md).

On app start `restore()` asks only for authorization (no user object): Android returns a token silently for the
account that granted access before. It does **not** start with `attemptLightweightAuthentication`, because on Android
that shows an account bottom sheet whenever One Tap auto-select is unavailable (it did on every launch). Lightweight
sign-in is only the fallback. The account email is saved in `SharedPreferences` at sign-in for display.

## Localisation
Flutter `gen-l10n` (`l10n.yaml`, ARB files). Dates use `intl` with the device locale. Weekday short names
(PN, WT... / MO, TU...) are in the ARB files because `intl` abbreviations differ from the mockup.
