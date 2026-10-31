import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'dart:ui' show Locale, PlatformDispatcher;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'google.dart';
import 'l10n/app_localizations.dart';
import 'notify.dart';
import 'view.dart';

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
  Notifier? notifier; // null in tests
  List<Cal> cals = [];
  String? error;
  final _days = <int, Map<DateTime, List<Ev>>>{};
  final _loading = <int>{};

  /// True once the user finished onboarding (with Google or "continue without account").
  bool get onboarded => _p.getBool('onboarded') ?? false;
  // Saved at sign-in: a silent restore on start has no account object to read it from.
  String? get email => g.email ?? _p.getString('email');
  String? get name => g.user?.displayName ?? _p.getString('name');
  Cal? cal(String id) => cals.where((c) => c.id == id).firstOrNull;
  SharedPreferences get prefs => _p;

  // 05.2 / 05.4 settings, kept in SharedPreferences.
  String get theme => _p.getString('theme') ?? 'system'; // dark, light, system
  int get weekStart => _p.getInt('weekStart') ?? DateTime.monday;
  bool get use24h => _p.getBool('use24h') ?? true;
  bool get weekNumbers => _p.getBool('weekNumbers') ?? false;
  bool get weekends => _p.getBool('weekends') ?? true;
  bool get showDeclined => _p.getBool('showDeclined') ?? false;
  bool get dotDigits => _p.getBool('dotDigits') ?? true;
  bool get dimPast => _p.getBool('dimPast') ?? true;
  bool get autoSync => _p.getBool('autoSync') ?? true;
  int get syncMinutes => _p.getInt('syncMinutes') ?? 15;
  DateTime? get lastSync => switch (_p.getInt('lastSync')) { final ms? => DateTime.fromMillisecondsSinceEpoch(ms), _ => null };

  bool get hideOnLock => _p.getBool('hideOnLock') ?? true;
  NotifyPrefs get notifyPrefs => NotifyPrefs(
        defaultReminder: _p.getInt('defaultReminder') ?? 10,
        allDayAt: _p.getInt('allDayAt') ?? 9 * 60,
        summary: _p.getBool('summary') ?? true,
        summaryAt: _p.getInt('summaryAt') ?? 7 * 60 + 30,
        invites: _p.getBool('notifyInvites') ?? true,
        sharedChanges: _p.getBool('notifyShared') ?? true,
        hideOnLock: hideOnLock,
      );

  // Notifications are built outside any widget, so they take the phone's language directly.
  String get _lang => PlatformDispatcher.instance.locale.languageCode == 'pl' ? 'pl' : 'en';
  AppLocalizations get _l => lookupAppLocalizations(Locale(_lang));

  /// Events of the next 8 days from what is loaded, for scheduling reminders.
  List<Ev> get _soon {
    final now = DateTime.now();
    return [
      for (var d = 0; d < 8; d++) ...?_days[DateTime(now.year, now.month, now.day + d).year]?[DateTime(now.year, now.month, now.day + d)],
    ];
  }

  Future<void> reschedule() async => notifier?.reschedule(plan(_soon, DateTime.now(), notifyPrefs, _l, _lang), _l, notifyPrefs);

  /// After a fresh sync: reminders, plus notifications for new invitations and others' changes in shared calendars.
  Future<void> _afterSync(List<Ev> evs, DateTime? previous) async {
    final n = notifier;
    if (n == null) return;
    await reschedule();
    final now = DateTime.now(), p = notifyPrefs;
    String key(Ev e) => '${e.id}|${e.start.millisecondsSinceEpoch}';
    final open = [for (final e in evs) if (e.isInvitation && e.me!.status == 'needsAction' && e.end.isAfter(now)) e];
    final seen = _p.getStringList('seenInvites');
    // The first sync only remembers what is there, so installing the app does not flood the shade.
    if (seen != null && p.invites) {
      for (final e in open.where((e) => !seen.contains(key(e)))) {
        await n.invitation(e, _l, _lang, p);
      }
    }
    await _p.setStringList('seenInvites', [for (final e in open) key(e)]);
    if (previous != null && p.sharedChanges) {
      final changed = <String, int>{};
      for (final e in evs) {
        if ((cal(e.calId)?.shared ?? false) && (e.updated?.isAfter(previous) ?? false)) changed[e.calId] = (changed[e.calId] ?? 0) + 1;
      }
      for (final c in changed.entries) {
        await n.sharedChanged(cal(c.key)!, c.value, _l, p);
      }
    }
  }

  /// Saves one setting (bool, int or String) and redraws everything.
  Future<void> set(String key, Object value) async {
    switch (value) {
      case bool v:
        await _p.setBool(key, v);
      case int v:
        await _p.setInt(key, v);
      case String v:
        await _p.setString(key, v);
    }
    if (key == 'showDeclined') _days.clear();
    notifyListeners();
    await reschedule(); // reminder settings, or which events count
  }

  /// Copies the view settings to [Look] for widgets without a Store (called by App on every change).
  void applyLook() {
    if (!ready) return;
    Look.use24h = use24h;
    Look.dotDigits = dotDigits;
    Look.dimPast = dimPast;
    Look.weekNumbers = weekNumbers;
    Look.weekends = weekends;
    Look.weekStart = weekStart;
  }

  /// Events in the loaded current year, for the 05.4 sync card.
  int get eventCount => {for (final d in (_days[DateTime.now().year] ?? const {}).values) ...d}.length;

  /// 05.4 "Disconnect Google" and 05.5 "Clear data on this device": drops the cache and settings here;
  /// nothing changes in Google. Back to the welcome screen.
  Future<void> forget() async {
    try {
      await g.signOut();
    } catch (_) {} // already signed out or offline: local data goes anyway
    for (final f in _dir!.listSync().whereType<File>().where((f) => f.path.endsWith('.json'))) {
      f.deleteSync();
    }
    await _p.clear();
    cals = [];
    _days.clear();
    signedIn = false;
    error = null;
    notifyListeners();
  }

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
    if (g.user?.displayName case final n?) await _p.setString('name', n);
    await loadCalendars();
  }

  /// Marker shapes the user picked per calendar (04.5), stored as calendar id -> Shape index.
  Map<String, Shape> get _shapes {
    final raw = _p.getString('shapes');
    if (raw == null) return const {};
    return {for (final e in (jsonDecode(raw) as Map).entries) e.key as String: Shape.values[e.value as int]};
  }

  Future<void> setShape(Cal c, Shape s) async {
    await _p.setString('shapes', jsonEncode({for (final e in {..._shapes, c.id: s}.entries) e.key: e.value.index}));
    await loadCalendars();
  }

  Future<void> loadCalendars() async {
    final saved = _p.getStringList('calendars');
    cals = await g.calendars(saved?.toSet(), shapes: _shapes);
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
    return [for (final e in evs) if (on.contains(e.calId) && (showDeclined || e.me?.status != 'declined')) e];
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
        final evs = await g.events([for (final c in cals) if (c.on) c], DateTime(year), DateTime(year + 1));
        putYear(year, evs);
        error = null;
        if (year == DateTime.now().year) {
          final previous = lastSync;
          await _p.setInt('lastSync', DateTime.now().millisecondsSinceEpoch);
          await _afterSync(evs, previous);
        }
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

  /// App version, build number and Android release (MainActivity.kt); empty in tests.
  Future<Map<String, String>> deviceInfo() async {
    try {
      return (await const MethodChannel('calendar/device').invokeMapMethod<String, String>('info')) ?? const {};
    } on MissingPluginException {
      return const {};
    }
  }

  Future<void> save(Ev e, {String? fromCal, bool force = false}) async {
    await g.save(e, fromCal: fromCal, timeZone: await timeZone(), force: force);
    _days.clear();
    notifyListeners();
  }

  /// Adds a calendar to the list and shows it (holidays, a shared calendar).
  Future<void> addCalendar(String id) async {
    await g.addCalendar(id);
    await _p.setStringList('calendars', {..._p.getStringList('calendars') ?? const <String>[], id}.toList());
    await loadCalendars();
    _days.clear();
    notifyListeners();
  }

  Future<void> createCalendar(String name) async {
    await g.createCalendar(name, await timeZone());
    // A new calendar is enabled: its id is not known before the list reloads, so enable whatever is new.
    final before = {for (final c in cals) c.id};
    await loadCalendars();
    for (final c in cals.where((c) => !before.contains(c.id))) {
      await toggle(c, true);
    }
  }

  Future<void> removeCalendar(Cal c) async {
    await g.removeCalendar(c.id);
    await loadCalendars();
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
