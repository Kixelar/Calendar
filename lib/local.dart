import 'dart:convert';
import 'dart:io';

import 'package:googleapis/calendar/v3.dart' as gcal;

import 'google.dart';

/// 05.4 "On this device": calendars kept only on this phone, in one JSON file (lost on uninstall, owner accepted).
/// Events are stored as Google event resources, so the Google code converts them ([evOf], [fillEvent]) and the .ics
/// import/export works unchanged. Ids start with "local:" so the store can tell them from Google's.
/// shortcut: repeating local events are not expanded yet (TODO stage 3, step 2); the edit screen hides "Repeat".
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

  String createCalendar(String name) {
    final id = 'local:${_id()}';
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

  /// Events of [cals] that overlap [from, to).
  List<Ev> events(List<Cal> cals, DateTime from, DateTime to) => [
        for (final c in cals)
          for (final e in _events[c.id] ?? const <gcal.Event>[])
            if (evOf(e, c) case final ev? when ev.start.isBefore(to) && (ev.end.isAfter(from) || ev.start == from)) ev,
      ]..sort((a, b) => a.start.compareTo(b.start));

  /// Creates [e] (empty id) or updates it; [fromCal] is its local calendar before the edit when it was moved.
  void save(Ev e, {String? fromCal, required String timeZone}) {
    final old = fromCal ?? e.calId, id = e.id.isEmpty ? _id() : e.id;
    final ev = e.id.isEmpty
        ? gcal.Event(id: id, iCalUID: '$id@calendar.kixelar.com')
        : (_events[old] ?? []).firstWhere((x) => x.id == e.id, orElse: () => gcal.Event(id: e.id));
    _events[old]?.removeWhere((x) => x.id == ev.id);
    fillEvent(ev, e, e.start, e.end, timeZone);
    ev
      ..attendees = null // local events have no guests
      ..updated = DateTime.now().toUtc();
    (_events[e.calId] ??= []).add(ev);
    _save();
  }

  void delete(Ev e) {
    _events[e.calId]?.removeWhere((x) => x.id == e.id);
    _save();
  }

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

  /// Every event of a local calendar, for the .ics export.
  List<gcal.Event> allEvents(String calId) => List.of(_events[calId] ?? const []);
}
