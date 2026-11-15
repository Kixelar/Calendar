# Changelog

## 2026.11.15 (first release)
### Changed
- Much lighter syncing with Google: the app asks Google what changed since last time (sync tokens) and fetches again
  only the calendars that changed, instead of the whole year of every calendar on every start, refresh, background run
  and edit. An unchanged calendar now costs one tiny request.
- Changed single events (yours or made elsewhere) are put in place straight from Google's change list; only a changed
  repeating series makes the app fetch that calendar's year again. Google sends only the event fields the app uses.
- Automatic refreshes reload the list of calendars at most every 6 hours (pulling down still reloads it every time).
### Fixed
- A repeating event deleted elsewhere (e.g. on the computer) stayed in the app: Google reports only the series' id,
  and its occurrences were not matched to it.
- Pull to refresh did nothing in the month view on tall screens (the grid stays put there, and a short list never
  scrolled); it now works on the grid and on the list, and in the other views when they are short too.
### Changed
- Places and calendar names in the month, week and day lists end with "…" when too long, instead of scrolling.
- In event details (and invitations) a long value no longer ends in "…": it waits at its start, runs left until the
  start comes round again and waits, like a news ticker (owner).

## 2026.11.08-dev
### Added
- Calendars on this phone ("On this device", 05.4), with or without a Google account: "Continue without account"
  makes "My calendar"; new calendars, events (create, edit, move between phone calendars, delete), search, reminders
  (the global default), widgets, Glyph, .ics import and export. Calendars → "On this device" lists them (show/hide,
  shape, delete); Accounts shows the "On this device" row. Data stays in one file on the phone (lost on uninstall).
- Add calendar: with a Google account a Google / On phone switch says where a new calendar or an import goes.
- Repeating events on this phone, with the same choices as Google: change or delete one occurrence, this and following,
  or all. Repeats from imported .ics files (RRULE with COUNT / UNTIL / BYDAY / BYMONTHDAY / BYMONTH, EXDATE) show too.
- Without a Google account: holidays by country (Google's public holiday files) and address subscriptions, kept in
  read-only calendars on this phone and refreshed hourly when the app is opened. With an account they stay in Google.
### Fixed
- "This and following" on a repeating Google event: the new series now keeps the old end date, and a "N times" series
  keeps only the occurrences that were left (before: it repeated forever).
### Changed
- An existing event can only move to calendars of the same kind (Google or phone); phone events have no guests.
- "Disconnect Google" keeps the calendars on this phone; "Clear data" removes them too.
- Settings pages (Appearance, Notifications, Accounts, Data and privacy, Help) no longer repeat "Settings" above their
  title; the back button says it (owner).
- Onboarding starts with a language panel, and every panel shows the welcome screen's step bars (language, welcome,
  Google, calendars) instead of "Step 1 of 3".
- The app is in 8 languages: Polish, English, German, Spanish, French, Italian, Portuguese and Dutch (help articles,
  notifications and widgets too). Appearance → Language picks one or follows the phone; the launcher and widget names
  follow the phone's language.
- Update screens, not active yet (no update check): a "new version" card above the view tabs, a full screen with
  what's new and "Download and install", and an Updates row with a red dot in About (owner chose all three).
### Removed
- "Skip" on the welcome screen (owner); "Continue without account" stays.

## 2026.11.02-dev
### Added
- Glyph Interface on Nothing phones (Settings → Notifications, shown only on phones with Glyph lights; built without a
  test device): light with reminders (Pulse, Blink or Steady), countdown to event (the bar lights for 5 s at 60/45/30/15
  min before, every 10 min on Phone (4a); every light blinks when the event starts), and a "Calendar countdown" Glyph
  Toy for the matrix on Phone (3) / (4a) Pro (circle emptying like a glass or a clock, a small plus while events are left
  today). Both switches are off by default.
### Changed
- Add calendar: the "Google account" option is gone while a Google account is signed in.
### Added
- App lock (Settings → Data and privacy): asks for the fingerprint, face or screen lock code when the app opens and after a minute away.
- Marker shape menu: tap a calendar's marker in Calendars (or the marker row of a shared calendar) to pick one of the 24 shapes.
- Calendars → Subscriptions: a holiday country can be removed there too (bin icon), not only in Holidays.
### Fixed
- The now line's time and the letters in round avatars are centred (Lettera Mono's capitals sit high in their line).
- "Check" in Settings → Accounts ran the background test on mobile data even with "Wi-Fi only" on.

## 2026.11.01-dev
### Added
- Day clock widget (2×2, resizable): 24-hour dial with today's timed events (grey past, white to come, yellow clashes) and a red hand for now; the middle shows the next event's time and title, "in 60 / 45 / 30 / 15 min" before it, "now · until" during it, or "Free". A tap opens today's day view. A tap opens today's day view.
- All widgets count down the same way: "in 60 / 45 / 30 / 15 min" before the next event, and are redrawn at those moments, every quarter hour and when an event starts or ends (before: minutes that could be up to 30 min stale).
- 18 more calendar marker shapes (24 in all, approved by the owner); each own calendar gets a shape no other calendar uses (22 for own calendars, filled ones first).
- Calendars: own calendars (not the primary one) can be deleted, after a confirmation.
- 04.2 Subscribe to address (.ics or webcal://): the app copies the file into a new read-only Google calendar and refreshes it every hour (also in background sync); events that leave the file are deleted. Subscriptions are listed under Calendars → Subscriptions, with Unsubscribe. The address is typed in a dialog, like a place or a guest.
- Holidays: every country Google has a holiday calendar for (244, names in the phone's language); a country can be removed. Names sort the Polish way (Łotwa after Luksemburg, not after Zimbabwe).
- Tapping a view tab (year, month, week, day) twice quickly jumps back to today.
- Import an .ics file into a Google calendar (Add calendar → Import file, Settings → Data and privacy); importing the same file again updates its events.
- Export all shown calendars to one .ics file (Settings → Data and privacy → Export all).
- Settings → Accounts → "Wi-Fi only": automatic and background sync wait for Wi-Fi (pull to refresh always syncs).
### Fixed
- Widgets follow the app's theme setting (Appearance → Dark / Light); "System" keeps following the phone's dark mode.
### Changed
- Address subscriptions are much faster: events go to Google 4 at a time (waiting and trying again when Google reports its rate limit), and a refresh sends only events that changed. A subscription that fails is taken back, so no half-filled calendar stays behind.
- Contacts' birthdays are no longer shown: the Birthdays calendar and birthday events are gone (owner).
- Settings: the account row at the top opens accounts and sync (the separate "Accounts and sync" row is gone); without an account it says "Not signed in".
- Accounts: "Add account" only when no Google account is signed in.
- Event details: the "more" button (it only deleted) is gone; Delete stays at the bottom.
- Month, week and day views redesigned after the new mockup (docs/design/views.html): event strips under month days,
  hour grid in the week, timeline with cards, free time and clashes in the day; tap a day to select it, again to open it.
- Year view: "A dot is a day" removed; "Year" moved to its line next to the big number.
- Headers of all views keep the same gap between the big number and its text (as in the year view).
- 1×1 date widget uses the card colour of the theme (dark circle, white digit in dark mode), like the other widgets.

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
- 05.1 settings with account status; 05.2 appearance: theme (dark / light / system), first day of the week, 24/12 h, week numbers, show weekends, declined invitations, dot digits, dim past events.
- 05.3 notifications: default reminder, all-day reminder the day before, daily summary; new invitations and changes in shared calendars.
- 05.4 accounts: last sync, sync now, automatic sync every 5–60 min (while the app is open), disconnect Google.
- 05.5 data and privacy: hide notification details on the lock screen, clear data on this device.
- 05.6 / 05.7 help with four how-to articles; 05.8 about: version, build, Android, time zone, licences, typefaces.
- 07.3 notifications: event reminders with "Snooze 5 min" and "Details", invitations with Yes / Maybe / No, daily summary, changes in shared calendars.
- 07.1 / 07.2 home screen widgets, dark and light with the system: month (4×4), today (4×2), week (4×1), date (2×2), next event (2×2 and 2×1), date (1×1). Dates update by themselves; events come from the last sync.
- App icon: "31" in dots with the red dot (adaptive, with a monochrome layer for themed icons); white status bar icon for notifications.
- Search works offline and finds parts of words in titles, places, notes, guests, organizers and calendar names (case and Polish letters ignored); recent searches removed.
- "Offline" label next to the search icon when Google cannot be reached (signed-in only), instead of a load error.
- Calendars: the primary calendar is called "Personal" instead of the account e-mail; birthdays and other people's calendars have their own sections.
- Custom reminder (any number of minutes, hours or days, up to 4 weeks) for events and as the default.
- Background sync every 15–60 min while online, also when the app is closed: reminders, invitation notifications and widgets stay fresh.
- Calendars as in Google: the primary calendar shows the account name, contacts' birthdays are their own "Birthdays" calendar (Google keeps them as birthday events in the primary calendar), hidden calendars are listed.
- The repeat of an existing series can be changed; saving an occurrence asks: only this, this and following, or all.
- Hints under week numbers, weekends, declined invitations and dimming in Appearance.
- 12-hour times: AM/PM on a small second line so they fit; widgets show 12-hour times too.
- Widgets switch between light and dark with the system theme; the widget picker shows previews (Polish/English, light/dark).
- Background sync could not be scheduled at all: the network-state permission (added by WorkManager before) was missing.
- Background sync no longer restarts its timer on every app start (it never got to run); "Check" in Settings → Accounts runs a test in about a minute.
- Settings → Accounts shows the last background sync run and its error, if any.
- Crash report: if the app (or a widget, reminder or background sync) crashes, a separate screen opens at once with the report and a Copy button (works even when the app dies at start).
### Fixed
- Icon: the last dot is white like the others (the grey one was hard to see); the red sixth dot stays.
- The app crashed at start since background sync was added (version with WorkManager). WorkManager is removed; background sync now uses Android's JobScheduler (SyncJob.kt) and skips runs while the app is on screen.
- Widgets cannot crash the app any more (errors go to the crash report) and their bitmaps stay under ~2 MB.
- Invitations from others were treated as own events (Google omits `organizer.self` when false): the reply screen, invitation notifications and the conflict row now work; the notification says how many events it clashes with.
- Widgets: text and numbers centred by their glyph bounds; blocks centred in the widget.
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
