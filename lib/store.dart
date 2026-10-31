import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'google.dart';

DateTime dayOf(DateTime t) => DateTime(t.year, t.month, t.day);

/// App state: Google account, chosen calendars and events per year.
/// Calendars and events are also kept on disk ([_dir]) so the app opens instantly and works offline;
/// Google refreshes them in the background.
class Store extends ChangeNotifier {
  Store([GoogleCalendar? g, this._dir]) : g = g ?? GoogleCalendar();
  final GoogleCalendar g;
  late final SharedPreferences _p;
  Directory? _dir;

  bool ready = false, signedIn = false;
  List<Cal> cals = [];
  String? error;
  final _days = <int, Map<DateTime, List<Ev>>>{};
  final _loading = <int>{};

  /// True once the user finished onboarding (with Google or "continue without account").
  bool get onboarded => _p.getBool('onboarded') ?? false;
  // Saved at sign-in: a silent restore on start has no account object to read it from.
  String? get email => g.email ?? _p.getString('email');
  Cal? cal(String id) => cals.where((c) => c.id == id).firstOrNull;
  SharedPreferences get prefs => _p;

  File _file(String name) => File('${_dir!.path}/$name.json');

  Object? _read(String name) {
    try {
      final f = _file(name);
      return f.existsSync() ? jsonDecode(f.readAsStringSync()) : null;
    } catch (_) {
      return null; // a broken cache is only a missed shortcut; Google has the data
    }
  }

  Future<Object?> _readAsync(String name) async {
    try {
      final f = _file(name);
      return await f.exists() ? jsonDecode(await f.readAsString()) : null;
    } catch (_) {
      return null;
    }
  }

  void _write(String name, Object json) {
    try {
      _file(name).writeAsStringSync(jsonEncode(json));
    } catch (_) {}
  }

  Future<void> start() async {
    _p = await SharedPreferences.getInstance();
    _dir ??= await getApplicationSupportDirectory();
    // Installs from before the cache had no 'google' flag; a saved calendar list means they signed in.
    signedIn = onboarded && (_p.getBool('google') ?? _p.getStringList('calendars') != null);
    if (signedIn) {
      cals = [for (final c in (_read('calendars') as List?) ?? const []) Cal.fromJson((c as Map).cast())];
    }
    ready = true;
    notifyListeners();
    if (!signedIn) return;
    try {
      if (!await g.restore()) return await _lostAccess();
      await loadCalendars();
      _days.clear(); // refetch the years already shown from the cache
      notifyListeners();
    } catch (e) {
      error = '$e'; // offline: keep showing the cache
      notifyListeners();
    }
  }

  /// Access was revoked (or the account removed): back to the welcome screen to connect again.
  Future<void> _lostAccess() async {
    signedIn = false;
    await _p.setBool('onboarded', false);
    await _p.setBool('google', false);
    notifyListeners();
  }

  Future<void> signIn() async {
    await g.signIn();
    signedIn = true;
    await _p.setBool('google', true);
    if (g.email != null) await _p.setString('email', g.email!);
    await loadCalendars();
  }

  Future<void> loadCalendars() async {
    final saved = _p.getStringList('calendars');
    cals = await g.calendars(saved?.toSet());
    _write('calendars', [for (final c in cals) c.toJson()]);
    notifyListeners();
  }

  Future<void> toggle(Cal c, bool on) async {
    c.on = on;
    await _p.setStringList('calendars', [for (final c in cals) if (c.on) c.id]);
    _write('calendars', [for (final c in cals) c.toJson()]);
    _days.clear();
    notifyListeners();
  }

  Future<void> finishOnboarding() async {
    await _p.setBool('onboarded', true);
    if (signedIn) await _p.setStringList('calendars', [for (final c in cals) if (c.on) c.id]);
    notifyListeners();
  }

  List<Ev> _visible(Iterable<Ev> evs) {
    final on = {for (final c in cals) if (c.on) c.id};
    return [for (final e in evs) if (on.contains(e.calId)) e];
  }

  /// Stores a freshly fetched year in memory and on disk (also used by the 01.4 sync screen).
  void putYear(int year, List<Ev> evs) {
    _days[year] = indexByDay(_visible(evs), year);
    _write('events_$year', [for (final e in evs) e.toJson()]);
    notifyListeners();
  }

  /// Events on [day], or null while that year is still loading.
  List<Ev>? on(DateTime day) {
    final y = _days[day.year];
    if (y == null) {
      _load(day.year);
      return null;
    }
    return y[dayOf(day)] ?? const [];
  }

  Future<void> _load(int year) async {
    if (!_loading.add(year)) return;
    // Read asynchronously: on() runs during build, so nothing here may notify before the first await.
    if (await _readAsync('events_$year') case final List cached when signedIn) {
      _days[year] = indexByDay(_visible([for (final e in cached) Ev.fromJson((e as Map).cast())]), year);
      notifyListeners();
    }
    if (signedIn) {
      try {
        putYear(year, await g.events([for (final c in cals) if (c.on) c], DateTime(year), DateTime(year + 1)));
        error = null;
      } catch (e) {
        error = '$e';
        _days[year] ??= {};
      }
    } else {
      _days[year] = {};
    }
    _loading.remove(year);
    notifyListeners();
  }

  /// Calendars a new event can go to: shown and writable, holidays excluded.
  List<Cal> get writable => [for (final c in cals) if (c.on && c.writable && !c.holiday) c];

  /// Device time zone as an IANA id (MainActivity.kt); UTC where the channel is missing (tests).
  Future<String> timeZone() async {
    try {
      return await const MethodChannel('calendar/device').invokeMethod<String>('timeZone') ?? 'UTC';
    } on MissingPluginException {
      return 'UTC';
    }
  }

  Future<void> save(Ev e, {String? fromCal}) async {
    await g.save(e, fromCal: fromCal, timeZone: await timeZone());
    _days.clear();
    notifyListeners();
  }

  Future<void> respond(Ev e, String status) async {
    await g.respond(e, status);
    _days.clear();
    notifyListeners();
  }

  /// Everyone who appeared as a guest in loaded events, for invite suggestions (03.4).
  List<Guest> get people {
    final seen = <String, Guest>{};
    for (final y in _days.values) {
      for (final day in y.values) {
        for (final e in day) {
          for (final g in e.guests) {
            if (!g.self && g.email.isNotEmpty) seen.putIfAbsent(g.email, () => g);
          }
        }
      }
    }
    return seen.values.toList()..sort((a, b) => a.name.compareTo(b.name));
  }

  Future<void> delete(Ev e, DeleteScope scope, {required bool notify}) async {
    await g.delete(e, scope, notify: notify);
    _days.clear();
    notifyListeners();
  }

  Future<void> refresh() async {
    _days.clear();
    try {
      if (signedIn) await loadCalendars();
    } catch (e) {
      error = '$e'; // offline pull-to-refresh: the cache stays on screen
    }
    notifyListeners();
  }
}

/// Puts each event under every day of [year] it touches (multi-day events appear on each day).
Map<DateTime, List<Ev>> indexByDay(List<Ev> evs, int year) {
  final m = <DateTime, List<Ev>>{};
  for (final e in evs) {
    var d = dayOf(e.start);
    // A timed event ending exactly at midnight does not touch the next day; all-day ends are exclusive already.
    final last = e.end.isAfter(e.start) ? dayOf(e.end.subtract(const Duration(microseconds: 1))) : d;
    while (!d.isAfter(last)) {
      if (d.year == year) (m[d] ??= []).add(e);
      d = DateTime(d.year, d.month, d.day + 1);
    }
  }
  return m;
}
