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

## Fonts (open question)
The mockup uses Nothing's fonts: **Ndot 57** (dot-matrix numerals), **NType82** (sans) and **Lettera Mono** (labels).
They are not bundled (licensing unclear, files not in the mockup). For now the app uses the system sans and
`monospace`. Waiting for the owner's decision on which fonts to ship.

## How to compare with the mockup
`$env:CAL_SHOTS='<folder>'; flutter test test/screens_test.dart` renders the implemented screens to PNG
with fake Google data, in Polish, dark (and one light) theme.
