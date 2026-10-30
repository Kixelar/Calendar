# Decisions

## 2026-10-30
- **Name**: package `com.kixelar.calendar`; launcher label follows the device language (Kalendarz / Calendar). (owner)
- **Platform**: Android only. (owner)
- **Google from the start**: data comes from Google Calendar right away, no local-only stage. (owner)
- **Stack**: Flutter, as in the owner's other apps; widgets and Glyph will need native Kotlin.
- **No backend**: the phone calls the Calendar API with the user's token (`google_sign_in` + `googleapis`). Nothing to host, nothing stored by us.
- **Scope** `https://www.googleapis.com/auth/calendar`: covers reading/editing events, the calendar list and replying to invitations, which the 01.2 screen promises.
- **Events cached per year in memory**: one request per calendar per year feeds all four views (year view needs the whole year anyway).
- **Fonts**: system fonts as stand-ins until the owner decides (Nothing's fonts are not bundled).
- **Left out of the mockup for now** (no function yet, so no dead buttons): search and settings icons, FAB, CalDAV/Outlook button, terms caption.
