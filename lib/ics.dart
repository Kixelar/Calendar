import 'dart:convert';

import 'package:googleapis/calendar/v3.dart' as gcal;
import 'package:timezone/timezone.dart' as tz;

/// iCalendar (.ics) files for 04.2 / 05.5 import and export. Times with a TZID use the timezone database
/// (initialised by notify.dart); an unknown zone (e.g. Outlook's Windows names) falls back to [local].

/// VEVENTs of [text] as Google events ready for `events.import`. Cancelled events and changed occurrences of a
/// series (RECURRENCE-ID) are left out.
/// shortcut: changed occurrences are skipped; import them with originalStartTime if people miss them.
List<gcal.Event> parseIcs(String text, {required String local}) {
  final lines = text.replaceAll('\r\n', '\n').replaceAll('\r', '\n').replaceAll(RegExp(r'\n[ \t]'), '').split('\n');
  final out = <gcal.Event>[];
  List<(String, Map<String, String>, String)>? ev;
  var depth = 0; // nested blocks such as VALARM inside a VEVENT
  for (final line in lines) {
    final colon = _colon(line);
    if (colon < 0) continue;
    final head = line.substring(0, colon).split(';'), value = line.substring(colon + 1);
    final name = head.first.toUpperCase();
    if (name == 'BEGIN') {
      if (ev != null) {
        depth++;
      } else if (value.toUpperCase() == 'VEVENT') {
        ev = [];
      }
    } else if (name == 'END') {
      if (depth > 0) {
        depth--;
      } else if (ev != null) {
        if (_event(ev, local) case final e?) out.add(e);
        ev = null;
      }
    } else if (ev != null && depth == 0) {
      final params = {
        for (final p in head.skip(1))
          if (p.contains('=')) p.substring(0, p.indexOf('=')).toUpperCase(): p.substring(p.indexOf('=') + 1).replaceAll('"', ''),
      };
      ev.add((name, params, value));
    }
  }
  return out;
}

// First colon outside a quoted parameter value.
int _colon(String line) {
  var quoted = false;
  for (var i = 0; i < line.length; i++) {
    if (line[i] == '"') quoted = !quoted;
    if (line[i] == ':' && !quoted) return i;
  }
  return -1;
}

gcal.Event? _event(List<(String, Map<String, String>, String)> props, String local) {
  String? get(String n) => props.where((p) => p.$1 == n).firstOrNull?.$3;
  if (get('RECURRENCE-ID') != null || get('STATUS')?.toUpperCase() == 'CANCELLED') return null;
  final dtStart = props.where((p) => p.$1 == 'DTSTART').firstOrNull;
  if (dtStart == null) return null;
  final start = _time(dtStart.$3, dtStart.$2, local);
  if (start == null) return null;
  final dtEnd = props.where((p) => p.$1 == 'DTEND').firstOrNull;
  var end = dtEnd == null ? null : _time(dtEnd.$3, dtEnd.$2, local);
  if (end == null) {
    final dur = _duration(get('DURATION'));
    end = start.date != null
        ? gcal.EventDateTime(date: start.date!.add(dur ?? const Duration(days: 1)))
        : gcal.EventDateTime(dateTime: start.dateTime!.add(dur ?? Duration.zero), timeZone: start.timeZone);
  }
  final uid = get('UID') ?? 'calendar-${(dtStart.$3 + (get('SUMMARY') ?? '')).hashCode.toUnsigned(32)}@kixelar';
  return gcal.Event(
    iCalUID: uid,
    summary: _unescape(get('SUMMARY') ?? ''),
    location: get('LOCATION') == null ? null : _unescape(get('LOCATION')!),
    description: get('DESCRIPTION') == null ? null : _unescape(get('DESCRIPTION')!),
    start: start,
    end: end,
    recurrence: [
      for (final p in props)
        if (const {'RRULE', 'EXRULE', 'RDATE', 'EXDATE'}.contains(p.$1))
          '${p.$1}${[for (final e in p.$2.entries) ';${e.key}=${e.value}'].join()}:${p.$3}',
    ],
  );
}

/// The calendar's own name (X-WR-CALNAME), if the file gives one.
String? icsName(String text) {
  final m = RegExp(r'^X-WR-CALNAME[^:\r\n]*:(.*)$', multiLine: true).firstMatch(text);
  final name = m == null ? '' : _unescape(m[1]!.trim());
  return name.isEmpty ? null : name;
}

/// DATE ("20261101"), UTC ("20261101T090000Z"), zoned (TZID=Europe/Warsaw) or floating (taken as [local]) time.
gcal.EventDateTime? _time(String v, Map<String, String> params, String local) {
  final m = RegExp(r'^(\d{4})(\d{2})(\d{2})(?:T(\d{2})(\d{2})(\d{2})?(Z)?)?$').firstMatch(v.trim());
  if (m == null) return null;
  int g(int i) => int.parse(m.group(i) ?? '0');
  if (m.group(4) == null || params['VALUE']?.toUpperCase() == 'DATE') return gcal.EventDateTime(date: DateTime.utc(g(1), g(2), g(3)));
  if (m.group(7) != null) return gcal.EventDateTime(dateTime: DateTime.utc(g(1), g(2), g(3), g(4), g(5), g(6)), timeZone: local);
  final zone = _zone(params['TZID']) ?? _zone(local) ?? tz.UTC;
  return gcal.EventDateTime(dateTime: tz.TZDateTime(zone, g(1), g(2), g(3), g(4), g(5), g(6)), timeZone: zone.name);
}

tz.Location? _zone(String? id) {
  if (id == null) return null;
  try {
    return tz.getLocation(id.startsWith('/') ? id.substring(1) : id);
  } catch (_) {
    return null;
  }
}

// "PT1H30M", "P1D", "P2W".
Duration? _duration(String? v) {
  final m = RegExp(r'^([+-])?P(?:(\d+)W)?(?:(\d+)D)?(?:T(?:(\d+)H)?(?:(\d+)M)?(?:(\d+)S)?)?$').firstMatch(v?.trim() ?? '');
  if (m == null) return null;
  int g(int i) => int.parse(m.group(i) ?? '0');
  return Duration(days: g(2) * 7 + g(3), hours: g(4), minutes: g(5), seconds: g(6));
}

String _unescape(String s) => s.replaceAllMapped(RegExp(r'\\([nN,;\\])'), (m) => m[1]!.toLowerCase() == 'n' ? '\n' : m[1]!);

String _escape(String s) => s.replaceAll('\\', '\\\\').replaceAll(';', r'\;').replaceAll(',', r'\,').replaceAll('\n', r'\n');

/// One .ics file with [events] as Google lists them with singleEvents=false: changed occurrences become VEVENTs with a
/// RECURRENCE-ID, cancelled ones an EXDATE of their series. Timed events keep their zone (TZID) so repeats follow
/// daylight saving time.
String writeIcs(List<gcal.Event> events, {required String local}) {
  final out = StringBuffer('BEGIN:VCALENDAR\r\nVERSION:2.0\r\nPRODID:-//Kixelar//Calendar//EN\r\nCALSCALE:GREGORIAN\r\n');
  final masters = {for (final e in events) if (e.recurringEventId == null) e.id: e};
  String uid(gcal.Event e) => e.iCalUID ?? '${e.id}@google.com';
  final exdates = <String, List<String>>{};
  for (final e in events.where((e) => e.recurringEventId != null && e.status == 'cancelled')) {
    if (e.originalStartTime case final o?) (exdates[e.recurringEventId!] ??= []).add(_prop('EXDATE', o, local));
  }
  for (final e in events) {
    if (e.status == 'cancelled' || e.start == null) continue;
    final series = e.recurringEventId == null ? null : masters[e.recurringEventId];
    out
      ..write(_fold('BEGIN:VEVENT'))
      ..write(_fold('UID:${uid(series ?? e)}'))
      ..write(_fold('DTSTAMP:${_utc(e.updated ?? DateTime.now())}'))
      ..write(_fold(_prop('DTSTART', e.start!, local)));
    if (e.end != null) out.write(_fold(_prop('DTEND', e.end!, local)));
    if (e.originalStartTime case final o? when series != null) out.write(_fold(_prop('RECURRENCE-ID', o, local)));
    out.write(_fold('SUMMARY:${_escape(e.summary ?? '')}'));
    if (e.location?.isNotEmpty ?? false) out.write(_fold('LOCATION:${_escape(e.location!)}'));
    if (e.description?.isNotEmpty ?? false) out.write(_fold('DESCRIPTION:${_escape(e.description!)}'));
    for (final r in e.recurrence ?? const <String>[]) {
      out.write(_fold(r));
    }
    for (final x in exdates[e.id] ?? const <String>[]) {
      out.write(_fold(x));
    }
    out.write(_fold('END:VEVENT'));
  }
  out.write('END:VCALENDAR\r\n');
  return out.toString();
}

String _two(int n) => '$n'.padLeft(2, '0');
String _date(DateTime d) => '${d.year}${_two(d.month)}${_two(d.day)}';
String _utc(DateTime t) {
  final u = t.toUtc();
  return '${_date(u)}T${_two(u.hour)}${_two(u.minute)}${_two(u.second)}Z';
}

String _prop(String name, gcal.EventDateTime t, String local) {
  if (t.date != null) return '$name;VALUE=DATE:${_date(t.date!)}';
  final zone = _zone(t.timeZone) ?? _zone(local);
  if (zone == null) return '$name:${_utc(t.dateTime!)}';
  final w = tz.TZDateTime.from(t.dateTime!, zone);
  return '$name;TZID=${zone.name}:${_date(w)}T${_two(w.hour)}${_two(w.minute)}${_two(w.second)}';
}

/// Content line folded at 75 bytes (RFC 5545), never inside a UTF-8 character.
String _fold(String line) {
  final out = StringBuffer();
  var bytes = 0;
  for (final r in line.runes) {
    final ch = String.fromCharCode(r), n = utf8.encode(ch).length;
    if (bytes + n > 75) {
      out.write('\r\n ');
      bytes = 1;
    }
    out.write(ch);
    bytes += n;
  }
  out.write('\r\n');
  return out.toString();
}
