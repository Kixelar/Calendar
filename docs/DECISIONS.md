# Decisions

## 2026-10-30
- **Name**: package `com.kixelar.calendar`; launcher label follows the device language (Kalendarz / Calendar). (owner)
- **Platform**: Android only. (owner)
- **Google from the start**: data comes from Google Calendar right away, no local-only stage. (owner)
- **Stack**: Flutter, as in the owner's other apps; widgets and Glyph will need native Kotlin.
- **No backend**: the phone calls the Calendar API with the user's token (`google_sign_in` + `googleapis`). Nothing to host, nothing stored by us.
- **Google Calendar API, not Android's system calendar (`CalendarContract`)**: considered the system provider (no Google Cloud, no verification, works with any account) and rejected it; the owner wants the Google API, which also allows creating and sharing calendars (04.2, 04.4). (owner)
- **Scope** `https://www.googleapis.com/auth/calendar`: covers reading/editing events, the calendar list and replying to invitations, which the 01.2 screen promises.
- **Events cached per year in memory**: one request per calendar per year feeds all four views (year view needs the whole year anyway).
- **Fonts**: the mockup's Ndot 57, NType82 and Lettera Mono, files supplied by the owner; Space Mono / Space Grotesk fill in missing Polish glyphs (docs/DESIGN.md). (owner)
- **Signing**: the app's own keystore in `<keystore folder>/`, used for debug and release, so one SHA-1 is registered with Google.
- **Google OAuth**: project set up by the owner; web client ID committed in `config.json` (public by design).
- **03.2 first version** has no time zone, repeat, reminder or guests rows (each needs its own screen, 03.3/03.4, or a picker the mockup does not show); new events get the calendar's default reminders from Google.
- **Place and notes** in 03.2 are edited in a small dialog styled like the mockup's `.dlg` (the mockup shows only the rows).
- **All-day icon**: sun, centred in the time column. (owner asked for an icon, then for centring)
- **Left out of the mockup for now** (no function yet, so no dead buttons): search and settings icons, FAB, CalDAV/Outlook button, terms caption.
- **.ics import** (owner, 2026-11-01): `events.import` keeps each event's UID, so importing a file twice updates instead of
  doubling; guests are not invited. Changed single occurrences (RECURRENCE-ID) are skipped. Times with unknown zones
  (e.g. Outlook's Windows names) are read in the phone's zone.
- **.ics export** "Export all": shown calendars except holidays, one file, saved where the user picks (`file_picker`,
  also used for opening the file to import). Times keep their zone (TZID) so repeats follow daylight saving time.
- **Subscribe to address** (04.2, owner 2026-11-01): the Calendar API cannot subscribe to a URL, so the app creates its
  own Google calendar, imports the file into it (events.import, by UID) and every hour checks the file again; unchanged
  files (FNV hash) are skipped, events that left the file are deleted. The calendar is read-only in the app (Google
  itself would allow edits, which the next refresh may overwrite). The address list lives on the phone only (`subs`
  preference): on another phone the calendar stays but stops refreshing.
- **No birthdays** (owner, 2026-11-01): contacts' birthdays (Google's birthday events and the old contacts calendar) are not shown.
- **One Google account**: "Add account" only appears when signed out (owner, 2026-11-01).
- **Holiday countries**: all ISO countries whose Google holiday calendar exists (checked against the public .ics URLs on
  2026-11-01); ids use the app language prefix (pl./en.) and Google's older names where the ISO code does not work.
- **Marker shapes** (owner, 2026-11-01): 24 shapes (`Shape` in google.dart, drawn in ui.dart `_MarkerPainter`); saved by
  index, so new shapes are only ever appended.
- **Feeds with unknown kick-off times**: sports-calendar.com puts matches without a fixed time at 00:00–02:00 local
  (23:00Z); the app shows what the file says, as Google Calendar would.
- **Day clock widget** (owner, 2026-11-01): today only (no all-day, no tomorrow), "Free" when nothing is left; tap opens
  today's day view (intent extra "open"="day").
- **Widget countdown** (owner, 2026-11-01): every widget shows "in 60 / 45 / 30 / 15 min" (`Widgets.step`) and all are
  redrawn by one AlarmManager RTC alarm (`Widgets.schedule` -> `WidgetTick`, does not wake the phone) at quarter hours,
  at those steps before each event, and at its start and end. The app keeps counting by the minute.
- **App lock** (owner, 2026-11-02): `local_auth` with the phone's own fingerprint / face / screen lock code (no app PIN);
  locks at start and after more than a minute away, so a file picker or Google sign-in does not lock it. Needs
  `FlutterFragmentActivity` and AppCompat themes (styles.xml, appcompat dependency).
- **Dropped** (owner, 2026-11-02): 04.5 "Ask for edit rights", 05.5 daily backup.
- **Glyph Interface** (owner, 2026-11-02): a section in Notifications (mockup 05.3), hidden on phones without Glyph
  lights; "Light with reminders" and "Countdown to event" off by default, pattern Pulse / matrix style Glass.
  Kit: `android/app/libs/glyph-matrix-sdk-2.0.aar` (one file for strips and matrix); no API key is needed for apps
  targeting Android 16, the manifest keeps `NothingKey`="test" as Nothing advises (Android 14/15 phones would need a key).
  `Lights.kt`: one RTC_WAKEUP alarm (`LightsTick`) for the next moment, taken from the widget data (`glyph` with the
  settings and reminder times). Strips: reminders flash in the pattern; countdown lights the bar for 5 s at 60/45/30/15
  min (Phone (4a), 6 lights: every 10 min), lights going out from the top; event start blinks every light; a reminder
  wins over a countdown step at the same moment. Matrix: the same moments through `setAppMatrixFrame`, and
  `CountdownToy` (Glyph Toy, AOD) shows the circle emptying from the top ("glass") or clockwise from 12 with the lit
  part on the left ("clock", variant A), a 3x3 plus while timed events remain today, else nothing. Strips show no
  "events left today" dot: they have no Glyph button to call it up (dropped by the owner). Previews approved
  by the owner in chat.
- **Calendars on this phone** (owner, 2026-11-08): work next to a Google account, not instead of it. `local.dart` keeps
  them in `local.json` (app support dir) with events as Google event resources, so `evOf` / `fillEvent` and the .ics
  code serve both; ids start with `local:` and `Store` sends each call to Google or the phone by that prefix. "Continue
  without account" makes "My calendar". Add calendar has a Google / On phone switch (only with Google). Their default
  reminder is the global one. No guests, sharing or invitations; no moving events between Google and the phone; losing
  them on uninstall is accepted (.ics export is the backup). "Disconnect Google" keeps them, "Clear data" does not.
  Repeats (2026-11-08): the series keeps its RRULE; changed or deleted occurrences are separate events with
  recurringEventId / originalStartTime / status cancelled, like Google, so .ics export writes RECURRENCE-ID / EXDATE.
  `occurrences()` in rrule.dart expands rules on the phone; occurrence ids are "series id _ original start ms".
