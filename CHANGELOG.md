# Changelog

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
- All-day events show a sun icon in the time column.
- Calendar or location labels that do not fit scroll like a ticker: to the end, short pause, start over (still when the system reduces motion).
### Fixed
- Times no longer wrap in lists; header icon buttons are 44px like the mockup; week caption fits.
- Reopening the app no longer asks to pick the Google account: calendar access is restored silently.
