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

/// Starts of a series beginning at [start] (local wall time, so daylight saving keeps the hour) that fall in
/// [from, to), from its RRULE and EXDATE [lines] (calendars on this phone; Google expands its own).
/// Reads FREQ, INTERVAL, COUNT, UNTIL, BYDAY (plain or "2MO" / "-1FR"), BYMONTHDAY and BYMONTH.
/// shortcut: EXDATE with a TZID is read as local wall time; fine while files come from the phone's own zone.
List<DateTime> occurrences(List<String> lines, DateTime start, DateTime from, DateTime to, {bool allDay = false}) {
  final rule = lines.where((l) => l.startsWith('RRULE:')).firstOrNull;
  if (rule == null) return [if (!start.isBefore(from) && start.isBefore(to)) start];
  final p = {for (final part in rule.substring(6).split(';')) if (part.contains('=')) part.split('=')[0]: part.split('=')[1]};
  final freq = p['FREQ'], interval = int.tryParse(p['INTERVAL'] ?? '') ?? 1, count = int.tryParse(p['COUNT'] ?? '');
  final until = _icsTime(p['UNTIL']), untilDay = allDay || p['UNTIL']?.length == 8; // a date-only UNTIL counts its whole day
  const names = ['MO', 'TU', 'WE', 'TH', 'FR', 'SA', 'SU'];
  // BYDAY entries as (ordinal or 0, weekday 1..7).
  final byDay = [
    for (final d in (p['BYDAY'] ?? '').split(',').where((d) => d.length >= 2))
      (int.tryParse(d.substring(0, d.length - 2)) ?? 0, names.indexOf(d.substring(d.length - 2)) + 1),
  ];
  final byMonthDay = [for (final d in (p['BYMONTHDAY'] ?? '').split(',')) ?int.tryParse(d)];
  final byMonth = [for (final m in (p['BYMONTH'] ?? '').split(',')) ?int.tryParse(m)];
  final ex = {
    for (final l in lines.where((l) => l.startsWith('EXDATE')))
      for (final v in l.substring(l.indexOf(':') + 1).split(','))
        if (_icsTime(v.trim()) case final t?) (v.trim().length == 8 ? dayKey(t) : t.millisecondsSinceEpoch),
  };
  DateTime at(int y, int m, int d) => DateTime(y, m, d, start.hour, start.minute, start.second);

  /// Days of month [m] in year [y] the rule picks (null when the month has none of them).
  List<DateTime> inMonth(int y, int m) {
    final last = DateTime(y, m + 1, 0).day;
    if (byMonthDay.isNotEmpty) {
      return [for (final d in byMonthDay) if (d.abs() <= last) at(y, m, d > 0 ? d : last + d + 1)];
    }
    if (byDay.isNotEmpty) {
      final out = <DateTime>[];
      for (final (n, wd) in byDay) {
        final all = [for (var d = 1; d <= last; d++) if (DateTime(y, m, d).weekday == wd) at(y, m, d)];
        if (n == 0) {
          out.addAll(all);
        } else if (n.abs() <= all.length) {
          out.add(all[n > 0 ? n - 1 : all.length + n]);
        }
      }
      return out;
    }
    return [if (start.day <= last) at(y, m, start.day)];
  }

  final out = <DateTime>[];
  var n = 0;
  for (var k = 0; k < 5000; k++) {
    final List<DateTime> period;
    switch (freq) {
      case 'DAILY':
        period = [at(start.year, start.month, start.day + k * interval)];
      case 'WEEKLY':
        final monday = start.day - start.weekday + 1 + k * 7 * interval;
        final days = byDay.isEmpty ? [start.weekday] : [for (final (_, wd) in byDay) wd];
        period = [for (final wd in days.toSet().toList()..sort()) at(start.year, start.month, monday + wd - 1)];
      case 'MONTHLY':
        period = inMonth(start.year, start.month + k * interval);
      case 'YEARLY':
        final y = start.year + k * interval;
        period = [
          for (final m in byMonth.isEmpty ? [start.month] : byMonth)
            ...(byMonthDay.isEmpty && byDay.isEmpty ? [if (start.day <= DateTime(y, m + 1, 0).day) at(y, m, start.day)] : inMonth(y, m)),
        ];
      default:
        return [if (!start.isBefore(from) && start.isBefore(to)) start];
    }
    period.sort();
    for (final t in period) {
      if (t.isBefore(start)) continue;
      if (until != null && (untilDay ? dayKey(t) > dayKey(until) : t.isAfter(until))) return out;
      if (count != null && n >= count) return out;
      n++;
      if (!t.isBefore(to)) return out;
      if (!t.isBefore(from) && !ex.contains(t.millisecondsSinceEpoch) && !ex.contains(dayKey(t))) out.add(t);
    }
  }
  return out;
}

/// 20261109 for that day, to compare dates.
int dayKey(DateTime t) => t.year * 10000 + t.month * 100 + t.day;

/// "20261109", "20261109T100000" (local) or "20261109T090000Z" (UTC) as a local time.
DateTime? _icsTime(String? v) {
  if (v == null || v.length < 8) return null;
  final d = DateTime.tryParse('${v.substring(0, 8)}${v.length > 8 ? v.substring(8) : ''}');
  return d?.toLocal();
}

/// The RRULE [line] of a series that started at [first], for a new series starting at [from] ("this and following"):
/// a COUNT becomes the occurrences still left; UNTIL and everything else stay.
String continueRule(String line, DateTime first, DateTime from, {bool allDay = false}) {
  final parts = line.substring(6).split(';');
  final count = parts.where((p) => p.startsWith('COUNT=')).map((p) => int.tryParse(p.substring(6))).firstOrNull;
  if (count == null) return line;
  final left = count - occurrences([line], first, first, from, allDay: allDay).length;
  return 'RRULE:${[for (final p in parts) p.startsWith('COUNT=') ? 'COUNT=${left < 1 ? 1 : left}' : p].join(';')}';
}
