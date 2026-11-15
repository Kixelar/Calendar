# Design

The source of truth is the owner's mockup [design/mockup.html](design/mockup.html): 33 phone screens (390×844) in groups
01 onboarding, 02 views, 03 events, 04 calendars, 05 settings, 06 states, 07 widgets and notifications.
UI must match it; the owner decides look and behaviour changes.

The month, week and day views were reworked from a second mockup, [design/views.html](design/views.html) (2026-11-01),
which replaces 02.2–02.4 of the first one:
- Month: day numbers with a strip under each day (where its events fall between 08 and 22, yellow when they clash);
  the grid stays put and the list of the selected day scrolls under it.
- Week: hour × day grid (08–22, widened for earlier/later events) with the selected day's list below; day names and the
  list header stay pinned while scrolling.
- Day: timeline with cards (side by side when they overlap, solid white/yellow for clashes), free time as dotted lines
  with its length, red now line with "in N min", empty day message in the middle of the axis.
- Tap a day to select it, tap it again to open its day view. Today is red, the selected day white.
- Year (owner, 2026-11-01): the "A dot is a day" caption is gone; "Year" sits on its line next to the big number.

## Tokens
Copied 1:1 from the mockup's CSS into `lib/theme.dart` (`Tok` colours for dark and light, `T` text styles).
- True black background (OLED) in dark, `#F4F4F4` in light; Appearance picks dark, light or the system's.
- One signal red (`accent`) per screen at most: "in 12 min", the now line, today in the year grid.
- Depth from 1px borders, never shadows. Pills for buttons, chips and switches.
- Calendars are told apart by **marker shape**, not colour: 24 shapes, own calendars get unused ones first (dot,
  square, half, diamond...), ring for holidays, dashed ring for shared calendars; the user can pick another. See `Shape` in `lib/google.dart` and `Marker` in `lib/ui.dart`.

## Additions beyond the mockup (owner's requests)
- All-day events: sun icon (`Icons.wb_sunny_outlined`, secondary colour) in the 48px time column instead of a blank.
- Right-hand label in event rows of the views (location or calendar name, max 110px) ends with "…" when too long.
- In event details and invitations a long value runs like a ticker (`Marquee` in `lib/ui.dart`, owner 2026-11-15):
  waits 1.5 s at its start, runs left at 30 px/s followed by a copy until the copy sits where the text began, waits.

## Fonts
Files supplied by the owner, declared in `pubspec.yaml`, as the mockup's CSS asks. Ndot, NType82 and Lettera Mono are
not in the repo (their licences are unclear); they go into `assets/fonts/` before building (README → Build it yourself).
The mockups load them from there too (views.html no longer embeds them):
- **Ndot** (`Ndot57-Regular.otf`): dot-matrix numerals (display styles).
- **NType82** (`NType82-Regular.otf`): headlines and body text.
- **Lettera Mono** (`LetteraMonoLL-Regular.otf`): labels, buttons, times, captions (uppercase + tracking at call sites).
- Ndot and NType82 have no Polish letters (ą ć ę ł ń ś ź ż) nor "–"; Flutter takes those glyphs from
  **Space Mono** (for Ndot) and **Space Grotesk** (for NType82) via `fontFamilyFallback`, same as the mockup's fallback.

Note: the mockup's HTML did not contain the font files, so in a browser it showed Space Grotesk instead of NType82.
The app now shows the real NType82, which looks different from what the browser preview showed.

Other files from the owner's set (Inter, Ndot55/57 Caps, NType82 Headline/Mono, Lettera Light/Medium/italics)
are not used by the mockup and are not bundled. Lettera Mono LL and the Nothing fonts are commercial/proprietary:
check the licence before a public release.

## How to compare with the mockup
`$env:CAL_SHOTS='<folder>'; flutter test test/screens_test.dart` renders the implemented screens to PNG
with fake Google data, in Polish, dark (and one light) theme. `CAL_LANG=en` renders them in English with English
sample data (used for the README, `tool/readme_images.py`).
