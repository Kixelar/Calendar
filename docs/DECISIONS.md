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
