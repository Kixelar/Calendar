import 'dart:convert';
import 'dart:io';

import 'package:googleapis/calendar/v3.dart' as gcal;

import 'google.dart';
import 'rrule.dart';

/// 05.4 "On this device": calendars kept only on this phone, in one JSON file (lost on uninstall, owner accepted).
/// Events are stored as Google event resources, so the Google code converts them ([evOf], [fillEvent]) and the .ics
/// import/export works unchanged. Ids start with "local:" so the store can tell them from Google's.
/// A repeating event is kept like Google keeps it: the series with its RRULE, plus changed or cancelled occurrences
/// as separate events (recurringEventId + originalStartTime). Occurrence ids are "`<series id>_<original start ms>`".
class LocalCalendar {
  LocalCalendar(this._file) {
    try {
      if (_file.existsSync()) {
        final j = jsonDecode(_file.readAsStringSync()) as Map<String, Object?>;
        for (final c in j['cals'] as List) {
          _names[(c as Map)['id'] as String] = c['name'] as String;
        }
        for (final e in (j['events'] as Map).entries) {
          _events[e.key as String] = [for (final v in e.value as List) gcal.Event.fromJson((v as Map).cast())];
        }
      }
    } catch (_) {
      // A broken file must not stop the app; it is overwritten by the next change.
    }
  }

  final File _file;
  final _names = <String, String>{}; // calendar id -> name, in creation order
  final _events = <String, List<gcal.Event>>{};

  static bool isLocal(String calId) => calId.startsWith('local:');

  void _save() => _file.writeAsStringSync(jsonEncode({
        'cals': [for (final e in _names.entries) {'id': e.key, 'name': e.value}],
        'events': {for (final e in _events.entries) e.key: [for (final v in e.value) v.toJson()]},
      }));

  String _id() => '${DateTime.now().microsecondsSinceEpoch}';

  /// Local calendars as (id, name).
  List<(String, String)> get calendars => [for (final e in _names.entries) (e.key, e.value)];

  /// A new calendar; [id] (after "local:") is given for holiday calendars, which keep Google's id.
  String createCalendar(String name, {String? id}) {
    id = 'local:${id ?? _id()}';
    _names[id] = name;
    _events[id] = [];
    _save();
    return id;
  }

  void deleteCalendar(String id) {
    _names.remove(id);
    _events.remove(id);
    _save();
  }

  /// Events of [cals] that overlap [from, to), repeating ones expanded.
  List<Ev> events(List<Cal> cals, DateTime from, DateTime to) {
    final out = <Ev>[];
    bool inRange(Ev e) => e.start.isBefore(to) && (e.end.isAfter(from) || e.start == from);
    for (final c in cals) {
      final list = _events[c.id] ?? const <gcal.Event>[];
      final changed = {for (final x in list) if (x.recurringEventId != null) x.id!: x};
      for (final x in list.where((x) => x.recurringEventId == null)) {
        final base = evOf(x, c);
        if (base == null) continue;
        if (x.recurrence?.any((r) => r.startsWith('RRULE:')) != true) {
          if (inRange(base)) out.add(base);
          continue;
        }
        final length = base.end.difference(base.start), days = dayDiff(base.start, base.end);
        // Occurrences that start before [from] can still reach into it.
        for (final t in occurrences(x.recurrence!, base.start, from.subtract(length), to, allDay: base.allDay)) {
          final id = '${x.id}_${t.millisecondsSinceEpoch}';
          final Ev? ev = switch (changed[id]) {
            final y? => y.status == 'cancelled' ? null : evOf(y, c),
            _ => _copy(base, id, x.id!, t, base.allDay ? DateTime(t.year, t.month, t.day + days) : t.add(length)),
          };
          if (ev != null && inRange(ev)) out.add(ev);
        }
      }
    }
    return out..sort((a, b) => a.start.compareTo(b.start));
  }

  static int dayDiff(DateTime a, DateTime b) => DateTime.utc(b.year, b.month, b.day).difference(DateTime.utc(a.year, a.month, a.day)).inDays;

  Ev _copy(Ev b, String id, String series, DateTime start, DateTime end) => Ev(b.title, b.calId, start, end,
      id: id, allDay: b.allDay, location: b.location, notes: b.notes, recurringId: series,
      reminder: b.reminder, customReminder: b.customReminder, updated: b.updated);

  gcal.Event? _find(String calId, String id) => (_events[calId] ?? const <gcal.Event>[]).where((x) => x.id == id).firstOrNull;

  /// Original start of an occurrence, from its id.
  static DateTime _original(Ev e) => DateTime.fromMillisecondsSinceEpoch(int.parse(e.id.split('_').last));

  static gcal.EventDateTime _when(DateTime t, bool allDay) =>
      allDay ? gcal.EventDateTime(date: DateTime(t.year, t.month, t.day)) : gcal.EventDateTime(dateTime: t);

  static DateTime _startOf(gcal.EventDateTime? t) =>
      t?.dateTime?.toLocal() ?? (t?.date == null ? DateTime(0) : DateTime(t!.date!.year, t.date!.month, t.date!.day));

  /// Creates [e] (empty id) or updates it; [fromCal] is its local calendar before the edit when it was moved.
  /// An occurrence ([Ev.recurringId]) is saved as a change of that occurrence only.
  void save(Ev e, {String? fromCal, required String timeZone}) {
    final old = fromCal ?? e.calId;
    if (e.recurringId != null) {
      final series = _find(old, e.recurringId!);
      if (series == null) return;
      final ev = _find(old, e.id) ?? gcal.Event(id: e.id, recurringEventId: series.id, originalStartTime: _when(_original(e), e.allDay));
      _events[old]!.removeWhere((x) => x.id == e.id);
      fillEvent(ev, e, e.start, e.end, timeZone);
      ev
        ..attendees = null
        ..status = null
        ..updated = DateTime.now().toUtc();
      _events[old]!.add(ev);
      return _save();
    }
    final id = e.id.isEmpty ? _id() : e.id;
    final ev = e.id.isEmpty ? gcal.Event(id: id, iCalUID: '$id@calendar.kixelar.com') : _find(old, e.id) ?? gcal.Event(id: e.id);
    // A moved series takes its changed occurrences along.
    final mine = [for (final x in _events[old] ?? const <gcal.Event>[]) if (x.id == ev.id || x.recurringEventId == ev.id) x];
    _events[old]?.removeWhere(mine.contains);
    fillEvent(ev, e, e.start, e.end, timeZone);
    if (e.recurrence != null) ev.recurrence = e.recurrence!.isEmpty ? null : e.recurrence;
    ev
      ..attendees = null // local events have no guests
      ..updated = DateTime.now().toUtc();
    (_events[e.calId] ??= []).addAll([ev, for (final x in mine) if (x.id != ev.id) x]);
    _save();
  }

  /// "This and following" or "all" for an edited occurrence, as [GoogleCalendar.saveSeries] does it.
  void saveSeries(Ev e, DeleteScope scope, {required DateTime originalStart, required String timeZone}) {
    final list = _events[e.calId], master = _find(e.calId, e.recurringId!);
    if (list == null || master == null) return;
    final orig = _original(e), first = _startOf(master.start);
    final rule = e.recurrence ?? [for (final r in master.recurrence ?? const <String>[]) if (r.startsWith('RRULE:')) r];
    final shift = e.start.difference(originalStart), length = e.end.difference(e.start);
    if (scope == DeleteScope.all || !orig.isAfter(first)) {
      final start = first.add(shift);
      final keep = [for (final r in master.recurrence ?? const <String>[]) if (!r.startsWith('RRULE:')) r];
      fillEvent(master, e, start, start.add(length), timeZone);
      master
        ..attendees = null
        ..updated = DateTime.now().toUtc()
        ..recurrence = rule.isEmpty ? null : [...rule, ...keep];
      // Changed occurrences belonged to the old times; the whole series takes the new ones.
      list.removeWhere((x) => x.recurringEventId == master.id);
      return _save();
    }
    master.recurrence = [for (final r in master.recurrence ?? const <String>[]) endRuleBefore(r, orig, allDay: e.allDay)];
    list.removeWhere((x) => x.recurringEventId == master.id && !_startOf(x.originalStartTime).isBefore(orig));
    final id = _id();
    final next = gcal.Event(id: id, iCalUID: '$id@calendar.kixelar.com');
    fillEvent(next, e, e.start, e.end, timeZone);
    final rules = [
      for (final r in rule)
        e.recurrence != null ? r : continueRule(r, first, orig, allDay: e.allDay),
    ];
    next
      ..attendees = null
      ..updated = DateTime.now().toUtc()
      ..recurrence = rules.isEmpty ? null : rules;
    list.add(next);
    _save();
  }

  /// Deletes an event, or for an occurrence: just it, it and the following ones, or the whole series (06.2).
  void delete(Ev e, DeleteScope scope) {
    final list = _events[e.calId];
    if (list == null) return;
    final series = e.recurringId == null ? null : _find(e.calId, e.recurringId!);
    if (series == null) {
      list.removeWhere((x) => x.id == e.id || x.recurringEventId == e.id);
      return _save();
    }
    final orig = _original(e), first = _startOf(series.start);
    if (scope == DeleteScope.one) {
      list
        ..removeWhere((x) => x.id == e.id)
        ..add(gcal.Event(id: e.id, recurringEventId: series.id, originalStartTime: _when(orig, e.allDay), status: 'cancelled'));
    } else if (scope == DeleteScope.all || !orig.isAfter(first)) {
      list.removeWhere((x) => x.id == series.id || x.recurringEventId == series.id);
    } else {
      series.recurrence = [for (final r in series.recurrence ?? const <String>[]) endRuleBefore(r, orig, allDay: e.allDay)];
      list.removeWhere((x) => x.recurringEventId == series.id && !_startOf(x.originalStartTime).isBefore(orig));
    }
    _save();
  }

  /// RRULE / EXDATE lines of a series, for the repeat text and the edit screen.
  List<String> recurrence(String calId, String seriesId) => _find(calId, seriesId)?.recurrence ?? const [];

  /// Adds or replaces (same iCalUID) an event from an .ics file.
  void importEvent(String calId, gcal.Event e) {
    final list = _events[calId] ??= [];
    final i = list.indexWhere((x) => e.iCalUID != null && x.iCalUID == e.iCalUID);
    final ev = gcal.Event.fromJson(jsonDecode(jsonEncode(e)) as Map<String, dynamic>) // toJson keeps nested objects
      ..id = i < 0 ? _id() : list[i].id
      ..attendees = null;
    if (i < 0) {
      list.add(ev);
    } else {
      list[i] = ev;
    }
    _save();
  }

  /// Puts [evs] (a subscribed file, holidays) in place of everything [calId] had.
  void replaceEvents(String calId, List<gcal.Event> evs) {
    _events[calId] = [
      for (final e in evs) gcal.Event.fromJson(jsonDecode(jsonEncode(e)) as Map<String, dynamic>)..id = e.iCalUID ?? _id(),
    ];
    _save();
  }

  /// Every event of a local calendar, for the .ics export.
  List<gcal.Event> allEvents(String calId) => List.of(_events[calId] ?? const []);
}
