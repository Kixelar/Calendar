# Architecture

Flutter app, Android only. No backend: the phone talks to the Google Calendar API with the user's own token.

```
lib/
  main.dart              App: theme (dark / light / system setting), app language, picks the language panel or Home
  theme.dart             Design tokens from the mockup (colours Tok, text styles T)
  google.dart            Google sign-in + Calendar API (GoogleCalendar), models Cal / Ev, marker Shape
  local.dart             Calendars on this phone (LocalCalendar): one JSON file, events as Google event resources
  store.dart             App state (ChangeNotifier): account, chosen calendars, events cached per year
  ui.dart                Shared widgets mirroring the mockup's CSS classes (Lbl, Section, RowItem, Toggle, Btn, Hero2, EventRow, Marker, Marquee)
  l10n/app_en.arb        English strings (template)
  l10n/app_*.arb         pl, de, es, fr, it, pt, nl
  screens/onboarding.dart  language panel, 01.1 Welcome, 01.2 Connect, 01.3 Choose (also the calendar picker), 01.4 Syncing
  screens/home.dart        02.1 year, 02.2 month, 02.3 week, 02.4 day views + bottom view tabs and + button
  screens/views.dart       parts of those views (docs/design/views.html): Slot/slotsOf (clash flags), month strip, day rows, week grid, day timeline
  screens/repeat.dart      03.3 custom repeat; rules live in lib/rrule.dart (parse, format, Polish/English sentence; tested)
  screens/invite.dart      03.4 invite guests (suggestions = guests of loaded events, Store.people)
  screens/search.dart      02.5 search in the events on the phone (`Store.search`: substrings, Polish letters folded, two years back and ahead)
  screens/calendars.dart   .ics import/export flows (file_picker), 04.1 calendars, 04.2 add, 04.3 holidays (Google holiday calendars by country), 04.4 share (ACL), 04.5 shared with you
  screens/settings.dart    05.1 settings, 05.2 appearance, 05.4 accounts, 05.5 data, 05.6/05.7 help (texts in lib/help.dart), 05.8 about
  screens/notifications.dart  05.3 notification settings and the Glyph section (only on phones with Glyph lights)
  notify.dart              07.3 notifications: plan() (pure, tested) + Notifier (flutter_local_notifications)
  ics.dart                 .ics import (parseIcs → Google events) and export (writeIcs, TZID times, folded lines); tested
  screens/lock.dart        05.5 app lock: Lock wraps the whole app (MaterialApp.builder), askDeviceAuth (local_auth)
  view.dart                `Look`: 05.2 view settings as globals for widgets without a Store (time format, fonts, week layout)
  screens/event.dart       03.1 event details, 03.2 new/edit event, 06.2 delete dialog, calendar picker
android/app/src/main/res/values*/strings.xml   Launcher name and widget names per device language
android/app/src/main/kotlin/.../Device.kt         Channel `calendar/device` (app and background engines): time zone, version info, widget data, Glyph
lib/screens/update.dart           05.8 new version: home card, full screen, About row (fed by Store.update)
tool/readme_images.py             README images from the test screenshots (CAL_LANG=en CAL_SHOTS=...)
android/app/src/main/kotlin/.../Lights.kt        05.3 Glyph Interface: strip lights, countdown, matrix Glyph Toy (CountdownToy)
android/app/libs/glyph-matrix-sdk-2.0.aar         Nothing's Glyph Developer Kit (strips and matrix in one file)
android/app/src/main/kotlin/.../Widgets.kt       07.1/07.2 home screen widgets (8), res/xml/widget_*.xml
test/screens_test.dart   Logic tests + PNG renders of screens with a fake Google account
```

## Data flow
1. `Store.start()` reads `SharedPreferences` (`onboarded`, `calendars` = ids of enabled calendars) and tries a silent
   Google sign-in (`GoogleCalendar.restore`).
2. Views ask `Store.on(day)`. If that year is not loaded, it fetches all events of the enabled calendars for the
   whole year (`events.list`, `singleEvents=true` so recurring events come expanded) and indexes them by day
   (`indexByDay`; multi-day events appear on every day they touch). Until then `on()` returns `null` (spinner).
3. Pull-to-refresh or toggling a calendar clears the in-memory index.

## Offline cache and incremental sync
`Store` keeps `calendars.json` and `events_<year>.json` (`{cals: [...], events: [...]}`: the Google events of that year
and the calendars they were fetched for) in the app support folder (`path_provider`). On start the saved calendars are
shown at once and each year is read from its file (asynchronously: `on()` runs during build).

Keeping it current (`Store._sync`): per Google calendar the app keeps a sync token (`syncTokens` preference) and asks
`GoogleCalendar.changes` what changed since (events.list with `syncToken`; 410 → a new token and a full fetch). When
all changes are single events (no `recurrence`, no `recurringEventId`) they are put in place or removed in every cached
year that holds the calendar (`_patch`), with no further request; a changed series makes the calendar be fetched again
(Google expands its repeats). Event requests ask only for the fields the app reads (`_evFields`). Otherwise changed
calendars are fetched again (`events.list` with `singleEvents`, so Google still expands
repeats), for the years in memory and the current one; other cached years drop them from `cals`, so `_load` fetches
them when opened. `_load` fetches only calendars a year's cache lacks or that have no token yet (getting the token
first, `track`). Runs on start, pull to refresh, automatic and background sync, and after every write to Google (only
that calendar). Switching a calendar on drops its token and its place in cached years. Without internet the files stay
on screen and `error` is set.
If Google says access is gone (`restore()` returns false) the app goes back to the welcome screen.
The `google` preference marks a signed-in install (older installs: a saved calendar list).

## Birthdays
Not shown (owner, 2026-11-01): `evOf` (google.dart) drops events with `eventType: birthday` (Google keeps contacts'
birthdays in the primary calendar) and `calendars()` leaves out the old `#contacts@` calendar.

## Address subscriptions (04.2)
`Store.subscribe` downloads the .ics (dart:io HttpClient, webcal:// read as https://), creates a Google calendar and
copies the events (`_copyFeed`: events.import, then deletes events whose UID left the file). `refreshSubscriptions`
repeats it at most hourly from `refresh()` and the background job (`syncNow`). Calendar id → address is the `subs`
preference; such calendars are read-only in the app (`writable`, event details). Without a Google account the copy goes to
a calendar on this phone instead and is replaced whole on every change (`LocalCalendar.replaceEvents`).

## Day clock widget
`ClockWidget` (Widgets.kt) draws the dial from the events the app sends (`Store.updateWidgets`, strings "free" and
"until"); `Widgets.schedule` sets the next redraw of all widgets (`WidgetTick` receiver). Its tap passes `open=day` to MainActivity,
which Dart reads once via Device "takeOpen" (`Home._widgetOpen`). Preview: `tool/widget_previews.py` `clock`.

## Holidays
`holidayCodes` (calendars.dart) lists ISO countries with a Google holiday calendar; `holidayId(code, lang)` builds the
calendar id (language prefix = the app language), `holidayCode(id)` reads it back. Country names come from Android
(`Device.kt` "countries"). Without a Google account the holidays come from Google's public file (`holidayUrl`) into a
phone calendar with id "local:" + the Google id, refreshed like a subscription.

## Writing events
Calendars on this phone (`local:` ids) go to `LocalCalendar` with the same choices; the rest below is Google.

- `GoogleCalendar.save`: new events are inserted; existing ones are fetched (`events.get`), changed and sent back
  with `events.update`, so fields the app does not edit (guests, reminders, conference links) survive. Changing the
  calendar first calls `events.move`. Editing an occurrence of a repeating event changes only that occurrence.
- `GoogleCalendar.delete`: "only this" deletes the occurrence, "all" deletes the series, "this and following" rewrites
  the series' RRULE with `UNTIL` just before the occurrence (`endRuleBefore`, tested), or deletes the series if it is
  the first occurrence. "Notify guests" maps to `sendUpdates=all|none`.
- After any write the per-year cache is cleared and refetched.
- Editing an occurrence asks for the scope (`_SaveScopeDialog`): "only this" updates the occurrence; "all" updates the
  series (times shifted by the same amount, new rule if changed, EXDATEs kept); "this and following" ends the old
  series before the occurrence and inserts a new series from it (`GoogleCalendar.saveSeries`).
- Repeating events: a new or single event gets `recurrence` (one RRULE line from `Rule.format`); timed events are sent
  with the device's IANA time zone (MainActivity.kt channel `calendar/device`), which Google requires for series.
  Occurrences (`recurringId` set) never carry a rule; their rule text is read from the series (`GoogleCalendar.recurrence`).
- Guests: the attendee list is rebuilt from the screen's list, keeping existing attendees (and their replies) by e-mail;
  `sendUpdates=all` whenever there are guests. Reminders: `customReminder` false = calendar default, else one popup override.
- Conflicts (06.3): `Ev.updated` is Google's last-change time when the event was loaded. `save` re-reads the event and
  throws `EditConflict` if Google's copy is newer; the user keeps this phone's version (`force`), Google's, or both
  (`Ev.asNew` saves a separate copy).
- Invitations (`Ev.isInvitation`: someone else organizes and you are a guest) open the 03.5 screen;
  `GoogleCalendar.respond` patches your attendee status and notifies the organizer.
- Edit is offered only when the event's calendar is writable and this calendar organizes the event
  (`organizer.self`); invitations from others can be deleted from your calendar but not edited.

## Notifications (07.3)
After each fresh sync of the current year `Store._afterSync` calls `plan()` for the next 7 days and replaces all scheduled
notifications (exact alarms, `USE_EXACT_ALARM`): event reminders (Google's reminder; the app's default when the calendar
has none; nothing when "none" was chosen), all-day events the day before, a daily summary. New invitations and others'
changes in shared calendars are shown at once (the first sync only remembers what exists). "Snooze 5 min" runs in a
background isolate (`notificationTapBackground`); other actions open the app and Home handles them (`_fromNotification`).
The background sync job (below) reschedules them too, so they stay current while the app is closed.

## Home screen widgets (07.1 / 07.2)
Each widget is an `AppWidgetProvider` that draws one bitmap with Canvas, using the app's font files from
`flutter_assets` (NType82 falls back to Space Grotesk for Polish letters on Android 10+). Colours follow the app's theme
setting (or the system in "System"). Dates are computed natively; one alarm (`Widgets.schedule` → `WidgetTick`) redraws
all widgets every quarter hour, at the 60/45/30/15 min countdown steps and when events start or end. Events and strings
come from `Store.updateWidgets` (next 14 days, sent after every sync and setting change). Tapping a widget opens the
app (the day clock opens today's day view). Every update sends a light and a dark bitmap; `layout/widget_image.xml` shows the light
one and `layout-night/` the dark one, so the launcher follows the system theme. Picker previews are PNGs made by
`tool/widget_previews.py` (same layout, sample day from the mockup) in `drawable{,-pl}{,-night}-nodpi`.

## Background sync (05.4)
`Store.scheduleBackground` asks Android (channel `scheduleSync`) to run `SyncJob` (framework JobScheduler, no
WorkManager: that library made the app crash at start) every N minutes (min 15) when online, skipped while the app is
on screen (`MainActivity.visible`). The job starts a Flutter engine without UI and runs `backgroundSync` in main.dart: `Store.start(background:
true)` (silent Google access only, never signs out), `syncNow()`, which saves the year, reschedules reminders, shows
invitation notifications and updates widgets; then it calls `done`. `Device.kt` serves the channel on both engines.
Preferences are reloaded before comparing sync state, since each engine keeps its own copy. Each run records its time
and result (`bgLast`, `bgResult`), shown in Settings → Accounts.

## Crash report
`CalendarApp` (CrashLog.kt) installs an uncaught-exception handler for the whole process (app, widgets, notification
receivers, SyncJob) that writes `files/crash.txt`. `CrashActivity` (plain Android, own `:crash` process) opens at once with
the report and a Copy button; Home also shows an unread report on the next start (`Store.lastCrash`). Widget drawing errors are recorded the same way without crashing.

## Settings
05.x settings live in SharedPreferences (`Store.set`). `App` copies the view ones to `Look` on every change.

## Google auth
`google_sign_in` 7.x: `authenticate()` signs in, `authorizationClient.authorizeScopes()` grants the Calendar scope.
The plugin hands out no refresh token, so every API call first asks the platform for a current access token
(`_authorize`). Needs the web client ID at build time (`GOOGLE_SERVER_CLIENT_ID`, docs/GOOGLE.md).

On app start `restore()` asks only for authorization (no user object): Android returns a token silently for the
account that granted access before. It does **not** start with `attemptLightweightAuthentication`, because on Android
that shows an account bottom sheet whenever One Tap auto-select is unavailable (it did on every launch). Lightweight
sign-in is only the fallback. The account email is saved in `SharedPreferences` at sign-in for display.

## Localisation
Flutter `gen-l10n` (`l10n.yaml`, ARB files), 8 languages. The `language` setting ("system" or a code) sets
`MaterialApp.locale`; notifications and widgets use the same choice (`appLang` in notify.dart). Dates use `intl` in that
language. Android resources (launcher, widget and Glyph toy names) follow the phone's language only. Weekday short names
(PN, WT... / MO, TU...) are in the ARB files because `intl` abbreviations differ from the mockup.
