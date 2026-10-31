# Changelog

## 2026.10.31-dev
### Added
- 01.4 sync screen after choosing calendars: events counter, progress, status per calendar, "Run in background".
- Offline cache: calendars and events are saved on the phone, shown at once on start and without internet, then refreshed from Google.

## 2026.10.30-dev
### Added
- Android Flutter app `com.kixelar.calendar`; launcher name "Kalendarz" in Polish, "Calendar" in other languages.
- Polish and English UI, dark and light theme from the mockup's design tokens.
- Onboarding: welcome, connect Google Calendar, choose calendars.
- Google Calendar sign-in and reading events of the chosen calendars.
- Year (dot per day), month, week and day views.
- App's own signing key for debug and release builds.
- Mockup fonts: Ndot (numerals), NType82 (text), Lettera Mono (labels), with Space Mono / Space Grotesk for Polish letters.
- Google OAuth web client ID, so "Sign in with Google" works.
- All-day events show a sun icon, centred in the time column.
- Event details: time, title, calendar, place, reminder, notes, guests and their replies.
- New event (+ button) and editing: title, all day, start, end, calendar, place, notes. Saved to Google Calendar.
- Deleting events, for repeating ones: only this, this and following, or all; optionally notify guests.
- Calendar or location labels that do not fit scroll like a ticker: to the end, short pause, start over (still when the system reduces motion).
### Fixed
- Times no longer wrap in lists; header icon buttons are 44px like the mockup; week caption fits.
- Reopening the app no longer asks to pick the Google account: calendar access is restored silently.
