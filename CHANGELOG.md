# Changelog

## 2026.10.31-dev
### Added
- 01.4 sync screen after choosing calendars: events counter, progress, status per calendar, "Run in background".
- Offline cache: calendars and events are saved on the phone, shown at once on start and without internet, then refreshed from Google.
- 02.5 search: Google full-text search (titles, notes, places, guests), filters by calendar and "with guests", upcoming and past results, recent searches.
- 03.2 new rows: repeat (never, daily, weekly, monthly, yearly, custom), reminder (calendar default, none, at start, 5 min–1 day), time zone, guests.
- 03.3 custom repeat: every N days/weeks/months/years, weekdays, ends never / on a date / after N times, summary sentence.
- 03.4 invite guests: suggestions from people in your events or any e-mail, guest permissions; also from the event screen ("Invite more people", share icon).
- 03.5 received invitations: organizer, guests, clash with another event, reply Yes / Maybe / No.
- 03.1 shows how a repeating event repeats ("Every 2 weeks on Tuesday and Friday").
- 04.1 calendars: mine (with share), shared with me (with your access level), subscriptions, show/hide, add calendar.
- 04.2 add calendar: new Google calendar, holidays, Google account.
- 04.3 holidays: holiday calendars by country (+ add country), holidays per year, the next three holidays.
- 04.4 share a calendar: people with access and their level (busy only / view / edit / remove), add a person, access by link with copy.
- 04.5 shared with you: owner, your access, choose the marker shape, show in views, share yours back, remove.
- 06.1 empty day: "Nothing planned." with an add button; weekends and holidays read as days off. Holiday events are labelled "Holiday".
- 06.3 conflicting changes: if the event changed in Google while you edited it, choose this phone's version, Google's, or keep both.
### Fixed
- Day view shows the day number with a leading zero ("01"), as in the mockup; button labels shrink instead of being cut.

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
