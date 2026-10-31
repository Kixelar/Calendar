import 'package:flutter/material.dart';

import 'view.dart';

/// Design tokens copied from the mockup (docs/design/mockup.html, "Nothing-inspired" tokens).
class Tok {
  final Color bg, surface, surfaceRaised, borderSubtle, borderControl;
  final Color display, primary, secondary, disabled, accent, accentText, dotOff, success, warning;
  const Tok._(this.bg, this.surface, this.surfaceRaised, this.borderSubtle, this.borderControl, this.display, this.primary,
      this.secondary, this.disabled, this.accent, this.accentText, this.dotOff, this.success, this.warning);

  static const dark = Tok._(Color(0xFF000000), Color(0xFF111111), Color(0xFF1A1A1A), Color(0xFF222222), Color(0xFF7A7A7A),
      Color(0xFFFFFFFF), Color(0xFFE8E8E8), Color(0xFF999999), Color(0xFF666666), Color(0xFFD71921), Color(0xFFFF4D55),
      Color(0xFF333333), Color(0xFF4A9E5C), Color(0xFFD4A843));
  static const light = Tok._(Color(0xFFF4F4F4), Color(0xFFFFFFFF), Color(0xFFF0F0F0), Color(0xFFE2E2E2), Color(0xFF858585),
      Color(0xFF000000), Color(0xFF1A1A1A), Color(0xFF666666), Color(0xFF999999), Color(0xFFD71921), Color(0xFFD71921),
      Color(0xFFD0D0D0), Color(0xFF2A7A3B), Color(0xFF8A6500));

  static Tok of(BuildContext c) => Theme.of(c).brightness == Brightness.dark ? dark : light;
}

// Fonts from pubspec.yaml. Ndot and NType82 have no ą ć ę ł ń ś ź ż or "–", so those glyphs come from the fallback (as in the mockup).
const _sans = 'NType82', _mono = 'Lettera Mono';
const _fallback = {'Ndot': ['Space Mono'], _sans: ['Space Grotesk']};
// "Dot digits" off in 05.2 sets the big numerals in the mono face instead.
String get _dot => Look.dotDigits ? 'Ndot' : _mono;

TextStyle _s(String f, double size, double lh, Color c, [double track = 0]) => TextStyle(
    fontFamily: f, fontFamilyFallback: _fallback[f], fontSize: size, height: lh / size, letterSpacing: size * track, color: c);

class T {
  static TextStyle displayXl(Color c) => _s(_dot, 56, 56, c);
  static TextStyle displayLg(Color c) => _s(_dot, 40, 40, c);
  static TextStyle displayMd(Color c) => _s(_dot, 20, 24, c);
  static TextStyle headlineLg(Color c) => _s(_sans, 32, 35, c);
  static TextStyle headlineMd(Color c) => _s(_sans, 24, 30, c);
  static TextStyle body(Color c) => _s(_sans, 16, 22, c);
  static TextStyle bodySm(Color c) => _s(_sans, 14, 20, c);
  static TextStyle labelMd(Color c) => _s(_mono, 14, 20, c, 0.06); // uppercase at call site
  static TextStyle labelSm(Color c) => _s(_mono, 11, 12, c, 0.08); // uppercase at call site
  static TextStyle caption(Color c) => _s(_mono, 12, 16, c);
}

ThemeData buildTheme(Brightness b) {
  final t = b == Brightness.dark ? Tok.dark : Tok.light;
  return ThemeData(
    brightness: b,
    scaffoldBackgroundColor: t.bg,
    colorScheme: ColorScheme.fromSeed(seedColor: t.display, brightness: b, surface: t.bg, primary: t.display),
    fontFamily: _sans,
    fontFamilyFallback: _fallback[_sans],
    textTheme: TextTheme(bodyMedium: T.body(t.primary)),
    splashFactory: NoSplash.splashFactory,
  );
}
