import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'dart:ui' show Locale, PlatformDispatcher;
import 'package:googleapis/calendar/v3.dart' as gcal;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'google.dart';
import 'ics.dart';
import 'l10n/app_localizations.dart';
import 'notify.dart';
import 'package:timezone/data/latest.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;
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
  bool get wifiOnly => _p.getBool('wifiOnly') ?? false;
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

  Future<void> reschedule() async {
    await notifier?.reschedule(plan(_soon, DateTime.now(), notifyPrefs, _l, _lang), _l, notifyPrefs);
    await updateWidgets();
  }

  /// Sends the next 14 days of events and the strings widgets need to Widgets.kt (07.1 / 07.2).
  Future<void> updateWidgets() async {
    final now = DateTime.now(), l = _l;
    final evs = {
      for (var d = 0; d < 14; d++) ...?_days[DateTime(now.year, now.month, now.day + d).year]?[DateTime(now.year, now.month, now.day + d)],
    };
    final json = jsonEncode({
      'lang': _lang,
      'weekStart': weekStart,
      'weekdays': l.weekdays,
      // Kotlin fills the number in with String.format.
      'more': l.moreN(999).replaceAll('999', '%d'),
      'inMin': l.inMin(999).replaceAll('999', '%d'),
      'today': l.today,
      'tomorrow': l.tomorrow,
      'noEvents': l.noEvents,
      'free': l.freeNow,
      'until': l.ongoingUntil('%s'),
      'use24h': use24h,
      'theme': theme,
      'events': [
        for (final e in evs) {'t': e.title, 's': e.start.millisecondsSinceEpoch, 'e': e.end.millisecondsSinceEpoch, 'a': e.allDay},
      ],
    });
    try {
      await const MethodChannel('calendar/device').invokeMethod<void>('widgets', json);
    } on MissingPluginException {
      // tests: no Android side
    }
  }

  /// Last background sync run (SyncJob): when, and "ok" or the error.
  ({DateTime at, String result})? get lastBackground => switch ((_p.getInt('bgLast'), _p.getString('bgResult'))) {
        (final ms?, final r?) => (at: DateTime.fromMillisecondsSinceEpoch(ms), result: r),
        _ => null,
      };

  /// Re-reads preferences written by the background sync engine (it keeps its own copy).
  Future<void> reloadPrefs() async {
    await _p.reload();
    notifyListeners();
  }

  Future<void> noteBackground(String result) async {
    await _p.setInt('bgLast', DateTime.now().millisecondsSinceEpoch);
    await _p.setString('bgResult', result);
  }

  /// Fetches the current year now and waits for it (background sync job).
  Future<void> syncNow() async {
    await refreshSubscriptions();
    await _load(DateTime.now().year);
  }

  /// A view a widget tap asked for ("day"), once; null when none or in tests.
  Future<String?> takeOpen() async {
    try {
      return await const MethodChannel('calendar/device').invokeMethod<String>('takeOpen');
    } on MissingPluginException {
      return null;
    }
  }

  /// True on mobile data (or another metered network), where "Wi-Fi only" holds automatic sync back.
  Future<bool> metered() async {
    try {
      return await const MethodChannel('calendar/device').invokeMethod<bool>('metered') ?? false;
    } on MissingPluginException {
      return false; // tests
    }
  }

  /// Asks Android to run the sync job every [syncMinutes] (at least 15) while online, or stops it (05.4).
  Future<void> scheduleBackground() async {
    try {
      await const MethodChannel('calendar/device')
          .invokeMethod<void>('scheduleSync', {'minutes': signedIn && autoSync ? syncMinutes : 0, 'wifiOnly': wifiOnly});
    } on MissingPluginException {
      // tests
    }
  }

  /// Asks for one background run in about a minute (the app must be left for it to run).
  Future<void> testBackground() async {
    try {
      await const MethodChannel('calendar/device').invokeMethod<void>('testSync');
    } on MissingPluginException {
      // tests
    }
  }

  /// After a fresh sync: reminders, plus notifications for new invitations and others' changes in shared calendars.
  Future<void> _afterSync(List<Ev> evs, DateTime? previous) async {
    final n = notifier;
    if (n == null) return;
    await _p.reload(); // the background job and the app keep separate copies of the preferences
    await reschedule();
    final now = DateTime.now(), p = notifyPrefs;
    String key(Ev e) => '${e.id}|${e.start.millisecondsSinceEpoch}';
    final open = [for (final e in evs) if (e.isInvitation && e.me!.status == 'needsAction' && e.end.isAfter(now)) e];
    final seen = _p.getStringList('seenInvites');
    // The first sync only remembers what is there, so installing the app does not flood the shade.
    if (seen != null && p.invites) {
      for (final e in open.where((e) => !seen.contains(key(e)))) {
        await n.invitation(e, _l, _lang, p, clashes: clashes(e).length);
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
    if (key == 'autoSync' || key == 'syncMinutes' || key == 'wifiOnly') await scheduleBackground();
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

  /// [background]: started by the Android sync job (main.dart `backgroundSync`); it never signs out on failure.
  Future<void> start({bool background = false}) async {
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
      if (!await g.restore(silentOnly: background)) {
        if (background) throw StateError('no silent access'); // the app decides when it is opened
        return await _lostAccess();
      }
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
    cals = await g.calendars(saved?.toSet(), shapes: _shapes, primaryName: name ?? _l.personal);
    error = null; // Google answered: online again
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

  /// Calendars to ask Google for: the shown ones.
  List<Cal> get _toFetch => [for (final c in cals) if (c.on) c];

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
        final evs = await g.events(_toFetch, DateTime(year), DateTime(year + 1));
        putYear(year, evs);
        error = null;
        if (year == DateTime.now().year) {
          await _p.reload();
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

  /// 02.5: finds events whose title, place, notes, guests, organizer or calendar contain every word of [query]
  /// (any case, Polish letters optional). Works offline: it reads the loaded and cached years, two back and two ahead.
  Future<List<Ev>> search(String query) async {
    final words = fold(query).split(RegExp(r'\s+')).where((w) => w.isNotEmpty).toList();
    if (words.isEmpty) return const [];
    final now = DateTime.now(), found = <String, Ev>{};
    for (var y = now.year - 2; y <= now.year + 2; y++) {
      final Iterable<Ev> evs = _days[y] != null
          ? {for (final d in _days[y]!.values) ...d}
          : switch (await _readAsync('events_$y')) {
              final List cached when signedIn => _visible([for (final e in cached) Ev.fromJson((e as Map).cast())]),
              _ => const <Ev>[],
            };
      for (final e in evs) {
        final hay = fold([
          e.title, e.location, e.notes, e.organizerName, cal(e.calId)?.name,
          for (final g in e.guests) '${g.name} ${g.email}',
        ].nonNulls.join(' '));
        if (words.every(hay.contains)) found['${e.calId}|${e.id}|${e.start.millisecondsSinceEpoch}'] = e;
      }
    }
    return found.values.toList()..sort((a, b) => a.start.compareTo(b.start));
  }

  /// Other timed events on the same day that overlap [e] (03.5 conflict row, invitation notification).
  List<Ev> clashes(Ev e) => e.allDay
      ? const []
      : [
          for (final o in on(e.start) ?? const <Ev>[])
            if (o.id != e.id && !o.allDay && o.me?.status != 'declined' && o.start.isBefore(e.end) && o.end.isAfter(e.start)) o,
        ];

  /// Calendars a new event can go to: shown and writable, holidays excluded.
  List<Cal> get writable => [
        for (final c in cals)
          if (c.on && c.writable && !c.holiday && !subscriptions.containsKey(c.id)) c, // subscriptions are read-only copies
      ];

  /// Device time zone as an IANA id (MainActivity.kt); UTC where the channel is missing (tests).
  Future<String> timeZone() async {
    try {
      return await const MethodChannel('calendar/device').invokeMethod<String>('timeZone') ?? 'UTC';
    } on MissingPluginException {
      return 'UTC';
    }
  }

  /// The report of a crash since the last start (CrashLog.kt), or null. Read once.
  Future<String?> lastCrash() async {
    try {
      return await const MethodChannel('calendar/device').invokeMethod<String>('lastCrash');
    } on MissingPluginException {
      return null;
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

  /// Events of an .ics file (04.2 / 05.5), ready to import.
  Future<List<gcal.Event>> readIcs(String text) async {
    if (!tz.timeZoneDatabase.isInitialized) tzdata.initializeTimeZones();
    return parseIcs(text, local: await timeZone());
  }

  /// Adds [evs] to [calId] one by one; [progress] gets how many are done. Returns how many failed.
  Future<int> importIcs(List<gcal.Event> evs, String calId, void Function(int) progress) async {
    var failed = 0;
    for (final (i, e) in evs.indexed) {
      try {
        await g.importEvent(calId, e);
      } catch (_) {
        failed++;
      }
      progress(i + 1);
    }
    _days.clear();
    notifyListeners();
    return failed;
  }

  /// All events of the shown calendars (holidays left out) as one .ics file (05.5 "Export all").
  Future<String> exportIcs() async {
    if (!tz.timeZoneDatabase.isInitialized) tzdata.initializeTimeZones();
    final all = [
      for (final c in cals)
        if (c.on && !c.holiday && !c.id.startsWith('#')) ...await g.allEvents(c.id),
    ];
    return writeIcs(all, local: await timeZone());
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

  /// Address subscriptions (04.2): calendar id → .ics address. The Calendar API cannot subscribe to an address, so the
  /// app creates its own Google calendar and copies the file into it every hour (refreshSubscriptions).
  Map<String, String> get subscriptions => {...?(jsonDecode(_p.getString('subs') ?? '{}') as Map?)?.cast<String, String>()};

  /// Subscribes to an .ics / webcal:// address and returns the new calendar's name.
  Future<String> subscribe(String address) async {
    final url = address.trim().replaceFirst(RegExp('^webcal://', caseSensitive: false), 'https://');
    final text = await _download(url);
    if (!tz.timeZoneDatabase.isInitialized) tzdata.initializeTimeZones();
    if (parseIcs(text, local: 'UTC').isEmpty && !text.contains('BEGIN:VCALENDAR')) throw FormatException(_l.notIcs);
    final name = icsName(text) ?? Uri.parse(url).host;
    final id = await g.createCalendar(name, await timeZone());
    await _p.setString('subs', jsonEncode({...subscriptions, id: url}));
    try {
      await _copyFeed(id, text);
    } catch (_) {
      // A half-filled calendar would stay behind (and a second try would make another): take it back.
      await _p.setString('subs', jsonEncode({...subscriptions}..remove(id)));
      await _p.remove('subEv.$id');
      try {
        await g.deleteCalendar(id);
      } catch (_) {}
      rethrow;
    }
    await loadCalendars();
    if (cal(id) case final c? when !c.on) await toggle(c, true);
    _days.clear();
    notifyListeners();
    return name;
  }

  /// Deletes a subscription's calendar.
  Future<void> unsubscribe(Cal c) async {
    await deleteCalendar(c);
    await _p.setString('subs', jsonEncode({...subscriptions}..remove(c.id)));
    await _p.remove('subHash.${c.id}');
    await _p.remove('subEv.${c.id}');
  }

  /// Deletes an own calendar and all its events from Google (not the primary one).
  Future<void> deleteCalendar(Cal c) async {
    await g.deleteCalendar(c.id);
    await loadCalendars();
    _days.clear();
    notifyListeners();
  }

  /// Copies every subscription's file again when the last check is an hour old (or [force]); errors wait for the next try.
  Future<void> refreshSubscriptions({bool force = false}) async {
    final last = _p.getInt('subAt');
    if (!signedIn || subscriptions.isEmpty) return;
    if (!force && last != null && DateTime.now().millisecondsSinceEpoch - last < 55 * 60000) return;
    await _p.setInt('subAt', DateTime.now().millisecondsSinceEpoch);
    for (final MapEntry(key: id, value: url) in subscriptions.entries) {
      try {
        await _copyFeed(id, await _download(url));
      } catch (_) {
        // offline or the address is gone for now
      }
    }
  }

  /// Puts the file's events into calendar [id] and deletes events that left the file. Skipped when the file is unchanged.
  Future<void> _copyFeed(String id, String text) async {
    final hash = '${text.length}:${fnv(text)}';
    if (_p.getString('subHash.$id') == hash) return;
    if (!tz.timeZoneDatabase.isInitialized) tzdata.initializeTimeZones();
    final evs = parseIcs(text, local: await timeZone());
    // Only events that changed since the last copy are sent (UID -> hash of the event), 8 at a time.
    final sent = {...?(jsonDecode(_p.getString('subEv.$id') ?? '{}') as Map?)?.cast<String, String>()};
    final now = {for (final e in evs) e.iCalUID!: '${fnv(jsonEncode(e))}'};
    await _each([for (final e in evs) if (sent[e.iCalUID] != now[e.iCalUID]) e], (e) => _retry(() => g.importEvent(id, e)));
    final gone = sent.keys.where((u) => !now.containsKey(u)).toSet();
    if (gone.isNotEmpty) {
      final drop = [for (final e in await g.allEvents(id)) if (e.recurringEventId == null && gone.contains(e.iCalUID)) e.id!];
      await _each(drop, (e) => _retry(() => g.deleteEvent(id, e)));
    }
    await _p.setString('subEv.$id', jsonEncode(now));
    await _p.setString('subHash.$id', hash);
    _days.clear();
  }

  /// Runs [f] on [call] again after 1, 2, 4, 8 and 16 s while Google says the rate limit is hit (403 / 429).
  static Future<void> _retry(Future<void> Function() call) async {
    for (var wait = 1;; wait *= 2) {
      try {
        return await call();
      } on gcal.DetailedApiRequestError catch (e) {
        final limit = e.status == 429 || (e.status == 403 && (e.message ?? '').toLowerCase().contains('rate limit'));
        if (!limit || wait > 16) rethrow;
        await Future<void>.delayed(Duration(seconds: wait));
      }
    }
  }

  /// Runs [f] on every item, [at] at a time (Google's per-user write limit allows only a few at once).
  static Future<void> _each<T>(List<T> items, Future<void> Function(T) f, {int at = 4}) async {
    var next = 0;
    Future<void> worker() async {
      while (next < items.length) {
        await f(items[next++]);
      }
    }

    await Future.wait([for (var i = 0; i < at; i++) worker()]);
  }

  Future<String> _download(String url) async {
    final client = HttpClient()..connectionTimeout = const Duration(seconds: 20);
    try {
      final res = await (await client.getUrl(Uri.parse(url))).close().timeout(const Duration(seconds: 60));
      if (res.statusCode != 200) throw HttpException('HTTP ${res.statusCode}', uri: Uri.parse(url));
      return await res.transform(const Utf8Decoder(allowMalformed: true)).join();
    } finally {
      client.close();
    }
  }

  /// Country names for ISO [codes] in [lang], from Android; empty in tests (the codes are shown instead).
  Future<Map<String, String>> countryNames(List<String> codes, String lang) async {
    try {
      return await const MethodChannel('calendar/device').invokeMapMethod<String, String>('countries', {'codes': codes, 'lang': lang}) ?? const {};
    } on MissingPluginException {
      return const {};
    }
  }

  Future<void> removeCalendar(Cal c) async {
    await g.removeCalendar(c.id);
    await loadCalendars();
    _days.clear();
    notifyListeners();
  }

  Future<void> saveSeries(Ev e, DeleteScope scope, {required DateTime originalStart}) async {
    await g.saveSeries(e, scope, originalStart: originalStart, timeZone: await timeZone());
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
      await refreshSubscriptions();
    } catch (e) {
      error = '$e'; // offline pull-to-refresh: the cache stays on screen
    }
    notifyListeners();
  }
}

/// FNV-1a hash of [s] (stable between app runs, unlike String.hashCode), to tell whether a subscribed file changed.
int fnv(String s) {
  var h = 0x811c9dc5;
  for (final b in utf8.encode(s)) {
    h = ((h ^ b) * 0x01000193) & 0xffffffff;
  }
  return h;
}

/// Lower case without Polish diacritics, so "zielinska" finds "Zielińska".
String fold(String s) {
  const from = 'ąćęłńóśźż', to = 'acelnoszz';
  final b = StringBuffer();
  for (final ch in s.toLowerCase().split('')) {
    final i = from.indexOf(ch);
    b.write(i < 0 ? ch : to[i]);
  }
  return b.toString();
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
