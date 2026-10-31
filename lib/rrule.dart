import 'package:intl/intl.dart';

import 'l10n/app_localizations.dart';

enum Freq { daily, weekly, monthly, yearly }

/// The part of an RFC 5545 RRULE that the 03.3 screen edits: every [interval] [freq], on [days] (weekly, 1 = Monday),
/// ending never, on [until] or after [count] times. Other parts (BYMONTHDAY...) are kept in [extra] untouched.
class Rule {
  const Rule(this.freq, {this.interval = 1, this.days = const {}, this.until, this.count, this.extra = const []});
  final Freq freq;
  final int interval;
  final Set<int> days;
  final DateTime? until; // date only, inclusive
  final int? count;
  final List<String> extra;

  static const _byday = ['MO', 'TU', 'WE', 'TH', 'FR', 'SA', 'SU'];

  /// Parses `RRULE:FREQ=...;...` (with or without the prefix); null for anything it cannot read.
  static Rule? parse(String line) {
    final body = line.startsWith('RRULE:') ? line.substring(6) : line;
    Freq? freq;
    var interval = 1;
    var days = <int>{};
    DateTime? until;
    int? count;
    final extra = <String>[];
    for (final part in body.split(';')) {
      final i = part.indexOf('=');
      if (i < 0) continue;
      final k = part.substring(0, i), v = part.substring(i + 1);
      switch (k) {
        case 'FREQ':
          freq = Freq.values.where((f) => f.name.toUpperCase() == v).firstOrNull;
        case 'INTERVAL':
          interval = int.tryParse(v) ?? 1;
        case 'BYDAY':
          // Plain weekdays only; "1MO" (first Monday) style is outside what the screen edits.
          if (v.split(',').every(_byday.contains)) {
            days = {for (final d in v.split(',')) _byday.indexOf(d) + 1};
          } else {
            extra.add(part);
          }
        case 'UNTIL':
          until = DateTime.tryParse(v.length >= 8 ? '${v.substring(0, 4)}-${v.substring(4, 6)}-${v.substring(6, 8)}' : '');
        case 'COUNT':
          count = int.tryParse(v);
        default:
          extra.add(part);
      }
    }
    return freq == null ? null : Rule(freq, interval: interval, days: days, until: until, count: count, extra: extra);
  }

  /// RRULE line for Google; UNTIL is the end of that day in UTC, so the last day still counts.
  String format() {
    String two(int n) => n.toString().padLeft(2, '0');
    final u = until;
    return 'RRULE:${[
      'FREQ=${freq.name.toUpperCase()}',
      if (interval > 1) 'INTERVAL=$interval',
      if (freq == Freq.weekly && days.isNotEmpty) 'BYDAY=${[for (final d in days.toList()..sort()) _byday[d - 1]].join(',')}',
      ...extra,
      if (u != null) 'UNTIL=${u.year}${two(u.month)}${two(u.day)}T235959Z' else if (count != null) 'COUNT=$count',
    ].join(';')}';
  }

  /// "Co 2 tygodnie we wtorek i piątek, bez końca." / "Every 2 weeks on Tuesday and Friday, forever."
  String describe(AppLocalizations l, String locale) {
    final every = switch (freq) {
      Freq.daily => l.everyDays(interval),
      Freq.weekly => l.everyWeeks(interval),
      Freq.monthly => l.everyMonths(interval),
      Freq.yearly => l.everyYears(interval),
    };
    var s = every;
    if (freq == Freq.weekly && days.isNotEmpty) {
      final sorted = days.toList()..sort();
      final on = l.weekdaysOn.split(','), plain = l.weekdaysAcc.split(',');
      final names = [on[sorted.first - 1], for (final d in sorted.skip(1)) plain[d - 1]];
      s += ' ${names.length == 1 ? names.first : '${names.sublist(0, names.length - 1).join(', ')} ${l.and} ${names.last}'}';
    }
    final u = until;
    s += u != null ? l.ruleUntil(DateFormat.yMMMd(locale).format(u)) : count != null ? l.ruleCount(count!) : l.ruleForever;
    return '$s.';
  }

  Rule copyWith({Freq? freq, int? interval, Set<int>? days, DateTime? until, int? count, bool clearEnd = false}) => Rule(
        freq ?? this.freq,
        interval: interval ?? this.interval,
        days: days ?? this.days,
        until: clearEnd ? null : until ?? this.until,
        count: clearEnd ? null : count ?? this.count,
        extra: extra,
      );
}
