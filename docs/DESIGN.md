# Design

The source of truth is the owner's mockup [design/mockup.html](design/mockup.html): 33 phone screens (390×844) in groups
01 onboarding, 02 views, 03 events, 04 calendars, 05 settings, 06 states, 07 widgets and notifications.
UI must match it; the owner decides look and behaviour changes.

## Tokens
Copied 1:1 from the mockup's CSS into `lib/theme.dart` (`Tok` colours for dark and light, `T` text styles).
- True black background (OLED) in dark, `#F4F4F4` in light; theme follows the system.
- One signal red (`accent`) per screen at most: "in 12 min", the now line, today in the year grid.
- Depth from 1px borders, never shadows. Pills for buttons, chips and switches.
- Calendars are told apart by **marker shape**, not colour: dot, square, half, diamond (own calendars in order),
  ring (holidays), dashed ring (shared with you). See `Shape` in `lib/google.dart` and `Marker` in `lib/ui.dart`.

## Additions beyond the mockup (owner's requests)
- All-day events: sun icon (`Icons.wb_sunny_outlined`, secondary colour) in the 48px time column instead of a blank.
- Right-hand label in event rows (location or calendar name, max 110px): if it does not fit it scrolls like a
  ticker at 30 px/s, 1.5 s pause at both ends, then jumps back (`Marquee` in `lib/ui.dart`).

## Fonts
Files supplied by the owner, bundled in `assets/fonts/` and declared in `pubspec.yaml`, as the mockup's CSS asks:
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
with fake Google data, in Polish, dark (and one light) theme.
