import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'google.dart';

DateTime dayOf(DateTime t) => DateTime(t.year, t.month, t.day);

/// App state: Google account, chosen calendars and events cached per year.
class Store extends ChangeNotifier {
  Store([GoogleCalendar? g]) : g = g ?? GoogleCalendar();
  final GoogleCalendar g;
  late final SharedPreferences _p;

  bool ready = false, signedIn = false;
  List<Cal> cals = [];
  String? error;
  // shortcut: events live only in memory and are refetched per year on start; add an offline cache when sync lands.
  final _days = <int, Map<DateTime, List<Ev>>>{};
  final _loading = <int>{};

  /// True once the user finished onboarding (with Google or "continue without account").
  bool get onboarded => _p.getBool('onboarded') ?? false;
  // Saved at sign-in: a silent restore on start has no account object to read it from.
  String? get email => g.email ?? _p.getString('email');
  Cal? cal(String id) => cals.where((c) => c.id == id).firstOrNull;

  Future<void> start() async {
    _p = await SharedPreferences.getInstance();
    if (onboarded) {
      try {
        signedIn = await g.restore();
        if (signedIn) await loadCalendars();
      } catch (e) {
        error = '$e';
      }
    }
    ready = true;
    notifyListeners();
  }

  Future<void> signIn() async {
    await g.signIn();
    signedIn = true;
    if (g.email != null) await _p.setString('email', g.email!);
    await loadCalendars();
  }

  Future<void> loadCalendars() async {
    final saved = _p.getStringList('calendars');
    cals = await g.calendars(saved?.toSet());
    notifyListeners();
  }

  Future<void> toggle(Cal c, bool on) async {
    c.on = on;
    await _p.setStringList('calendars', [for (final c in cals) if (c.on) c.id]);
    _days.clear();
    notifyListeners();
  }

  Future<void> finishOnboarding() async {
    await _p.setBool('onboarded', true);
    if (signedIn) await _p.setStringList('calendars', [for (final c in cals) if (c.on) c.id]);
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
    if (!signedIn) {
      _days[year] = {};
      return;
    }
    if (!_loading.add(year)) return;
    try {
      final evs = await g.events([for (final c in cals) if (c.on) c], DateTime(year), DateTime(year + 1));
      _days[year] = indexByDay(evs, year);
      error = null;
    } catch (e) {
      error = '$e';
      _days[year] = {};
    }
    _loading.remove(year);
    notifyListeners();
  }

  /// Calendars a new event can go to: shown and writable, holidays excluded.
  List<Cal> get writable => [for (final c in cals) if (c.on && c.writable && !c.holiday) c];

  Future<void> save(Ev e, {String? fromCal}) async {
    await g.save(e, fromCal: fromCal);
    _days.clear();
    notifyListeners();
  }

  Future<void> delete(Ev e, DeleteScope scope, {required bool notify}) async {
    await g.delete(e, scope, notify: notify);
    _days.clear();
    notifyListeners();
  }

  Future<void> refresh() async {
    _days.clear();
    if (signedIn) await loadCalendars();
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
