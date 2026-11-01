// Logic checks, plus screen renders to PNG for comparing with the mockup without a device:
//   $env:CAL_SHOTS='C:\some\folder'; flutter test test/screens_test.dart
import 'dart:convert';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:calendar/google.dart';
import 'package:calendar/l10n/app_localizations.dart';
import 'package:calendar/help.dart';
import 'package:calendar/ics.dart';
import 'package:calendar/main.dart';
import 'package:calendar/notify.dart';
import 'package:calendar/rrule.dart';
import 'package:calendar/screens/calendars.dart';
import 'package:calendar/screens/event.dart';
import 'package:calendar/screens/home.dart';
import 'package:calendar/screens/invite.dart';
import 'package:calendar/screens/repeat.dart';
import 'package:calendar/screens/onboarding.dart';
import 'package:calendar/screens/notifications.dart';
import 'package:calendar/screens/search.dart';
import 'package:calendar/screens/settings.dart';
import 'package:calendar/screens/views.dart';
import 'package:calendar/store.dart';
import 'package:calendar/view.dart';
import 'package:calendar/ui.dart';
import 'package:flutter/material.dart';
import 'package:googleapis/calendar/v3.dart' as gcal;
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart' show DateFormat;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest.dart' as tzdata;

final _out = Platform.environment['CAL_SHOTS'];

/// The mockup's 03.1 example: repeating, with guests, starting in 12 minutes.
Ev _demo() => Ev('Demo sprintu', 'w', DateTime.now().add(const Duration(minutes: 12)), DateTime.now().add(const Duration(minutes: 72)),
    id: 'demo_1', recurringId: 'demo', location: 'Sala 4B', reminder: 15, notes: 'Pokaz nowego widoku tygodnia.',
    guests: const [
      Guest('Marek Wiśniewski', 'marek@example.com', 'accepted'),
      Guest('Ola Zielińska', 'ola@example.com', 'tentative'),
      Guest('Piotr Kamiński', 'piotr@example.com', 'needsAction'),
    ]);

/// A one-off event (no series), for screens where the repeat question would get in the way.
Ev _single() {
  final d = dayOf(DateTime.now());
  return Ev('Demo sprintu', 'w', DateTime(d.year, d.month, d.day, 14), DateTime(d.year, d.month, d.day, 15),
      id: 'single', location: 'Sala 4B', updated: DateTime.now().subtract(const Duration(hours: 1)));
}

/// The mockup's 03.5 example: an invitation from Marek that clashes with another event.
Ev _invitation() {
  final d = dayOf(DateTime.now());
  return Ev('Planowanie Q1', 'p', DateTime(d.year, d.month, d.day + 2, 9, 30), DateTime(d.year, d.month, d.day + 2, 11),
      id: 'inv', organizer: false, organizerName: 'Marek Wiśniewski', location: 'Sala 4B',
      guests: const [
        Guest('Marek Wiśniewski', 'marek@example.com', 'accepted'),
        Guest('Ola Zielińska', 'ola@example.com', 'tentative'),
        Guest('Piotr Kamiński', 'piotr@example.com', 'needsAction'),
        Guest('Anna Nowak', 'anna.nowak@gmail.com', 'needsAction', self: true),
      ]);
}

/// Google account without a network: calendars and events are made up around today.
class _FakeGoogle extends GoogleCalendar {
  @override
  String? get email => 'anna.nowak@gmail.com';
  @override
  Future<bool> restore({bool silentOnly = false}) async => true;
  @override
  Future<List<Cal>> calendars(Set<String>? enabled,
          {Map<String, Shape> shapes = const {}, String? primaryName}) async =>
      [
        Cal('p', 'Osobisty', shared: false, holiday: false, shape: Shape.dot, on: true),
        Cal('w', 'Praca', shared: false, holiday: false, shape: Shape.square, on: true),
        Cal('f', 'Rodzina', shared: false, holiday: false, shape: Shape.half, on: true),
        Cal('ola.zielinska@gmail.com', 'Ola Zielińska', shared: true, holiday: false, shape: Shape.dash, on: true, writable: false, role: 'reader'),
        Cal('design', 'Zespół Design', shared: true, holiday: false, shape: Shape.dash, on: false, role: 'writer'),
        Cal('h', 'Święta w Polsce', shared: false, holiday: true, shape: Shape.ring, on: true),
      ];
  @override
  Future<List<Ev>> events(List<Cal> cals, DateTime from, DateTime to) async {
    final d = dayOf(DateTime.now());
    DateTime at(int day, double h) => DateTime(d.year, d.month, d.day + day, h.floor(), ((h % 1) * 60).round());
    final evs = [
      Ev('Urodziny Oli', 'f', at(0, 0), at(1, 0), allDay: true),
      Ev('Standup zespołu', 'w', at(0, 8.5), at(0, 9), location: 'Zoom'),
      Ev('Warsztaty UX', 'w', at(0, 10), at(0, 12), location: 'Sala konferencyjna, 3 piętro'),
      _demo(),
      _invitation(),
      Ev('Przegląd kodu', 'w', at(2, 10), at(2, 11)),
      Ev('Trening', 'p', at(0, 22), at(0, 23), location: 'Siłownia'),
      Ev('Brunch z Olą', 'ola.zielinska@gmail.com', at(1, 11), at(1, 13), location: 'U Oli'),
      Ev('Koncert', 'p', at(1, 19), at(1, 22), location: 'Stodoła'),
      Ev('Wszystkich Świętych', 'h', DateTime(d.year, 11, 1), DateTime(d.year, 11, 2), allDay: true),
      for (var i = -40; i < 60; i += 3) Ev('Spotkanie', 'w', at(i, 9), at(i, 10 + i % 4)),
    ];
    return evs.where((e) => e.start.isBefore(to) && e.end.isAfter(from)).toList()..sort((a, b) => a.start.compareTo(b.start));
  }

  @override
  Future<List<String>> recurrence(String calId, String seriesId) async => const ['RRULE:FREQ=WEEKLY;INTERVAL=2;BYDAY=FR'];

  @override
  Future<void> save(Ev e, {String? fromCal, required String timeZone, bool force = false}) async {
    if (force) return;
    // Someone moved the meeting in Google meanwhile (06.3).
    throw EditConflict(Ev(e.title, e.calId, e.start.add(const Duration(minutes: 30)), e.end.add(const Duration(minutes: 30)),
        location: 'Sala 2', updated: DateTime.now().subtract(const Duration(minutes: 1))));
  }

  @override
  Future<List<Access>> access(String calId) async => const [
        Access('user:anna.nowak@gmail.com', 'user', 'anna.nowak@gmail.com', 'owner'),
        Access('user:marek@example.com', 'user', 'marek@example.com', 'writer'),
        Access('user:ola@example.com', 'user', 'ola@example.com', 'reader'),
      ];
}

/// Records what an address subscription sends to Google.
class _SubGoogle extends _FakeGoogle {
  final imported = <String>[], deleted = <String>[];
  @override
  Future<String> createCalendar(String name, String timeZone) async => 'sub1';
  @override
  Future<void> importEvent(String calId, gcal.Event e) async => imported.add(e.iCalUID!);
  @override
  Future<List<gcal.Event>> allEvents(String calId) async => [for (final u in imported.toSet()) gcal.Event(id: 'id-$u', iCalUID: u)];
  @override
  Future<void> deleteEvent(String calId, String id) async {
    deleted.add(id);
    imported.removeWhere((u) => 'id-$u' == id);
  }
}

/// No network: every Google call fails, as on a phone without internet.
class _OfflineGoogle extends GoogleCalendar {
  @override
  Future<bool> restore({bool silentOnly = false}) async => throw const SocketException('offline');
  @override
  Future<List<Ev>> events(List<Cal> cals, DateTime from, DateTime to) async => throw const SocketException('offline');
}

Future<void> _fonts() async {
  const dir = 'C:/src/flutter/bin/cache/artifacts/material_fonts';
  // flutter test does not load the app's own fonts (pubspec.yaml): add them from the files.
  final fonts = {
    'Roboto': ['$dir/Roboto-Regular.ttf'],
    'MaterialIcons': ['$dir/MaterialIcons-Regular.otf'],
    'Ndot': ['assets/fonts/Ndot57-Regular.otf'],
    'NType82': ['assets/fonts/NType82-Regular.otf'],
    'Lettera Mono': ['assets/fonts/LetteraMonoLL-Regular.otf'],
    'Space Grotesk': ['assets/fonts/SpaceGrotesk-Regular.otf'],
    'Space Mono': ['assets/fonts/SpaceMono-Regular.otf'],
  };
  for (final f in fonts.entries) {
    final l = FontLoader(f.key);
    for (final file in f.value) {
      l.addFont(Future.value(ByteData.view(Uint8List.fromList(File(file).readAsBytesSync()).buffer)));
    }
    await l.load();
  }
}

void main() {
  test('multi-day and midnight-ending events land on the right days', () {
    final evs = [
      Ev('trip', 'p', DateTime(2026, 12, 30), DateTime(2027, 1, 2), allDay: true), // all-day end is exclusive
      Ev('late', 'p', DateTime(2026, 3, 1, 22), DateTime(2026, 3, 2)), // ends exactly at midnight
      Ev('night', 'p', DateTime(2026, 3, 5, 23), DateTime(2026, 3, 6, 1)),
    ];
    final m = indexByDay(evs, 2026);
    expect(m.keys.toSet(), {DateTime(2026, 12, 30), DateTime(2026, 12, 31), DateTime(2026, 3, 1), DateTime(2026, 3, 5), DateTime(2026, 3, 6)});
    expect(indexByDay(evs, 2027).keys, [DateTime(2027, 1, 1)]);
  });

  test('search finds parts of titles, places, guests and calendars, offline, without Polish letters', () async {
    SharedPreferences.setMockInitialValues({'onboarded': true, 'google': true});
    final online = Store(_FakeGoogle(), Directory.systemTemp.createTempSync());
    await online.start();
    online.on(DateTime.now());
    await Future<void>.delayed(const Duration(milliseconds: 100));
    Future<List<String>> titles(Store s, String q) async => [for (final e in await s.search(q)) e.title];
    expect(await titles(online, 'warszt'), ['Warsztaty UX']); // part of a title
    expect(await titles(online, 'konferencyjna'), ['Warsztaty UX']); // part of the place
    expect((await titles(online, 'wisniew')).toSet(), {'Demo sprintu', 'Planowanie Q1'}); // guest, no Polish letters
    expect(await titles(online, 'zielin brunch'), ['Brunch z Olą']); // every word, one from the calendar name
    expect(await titles(online, 'nic takiego'), isEmpty);
  });

  test('invitations are told apart from own events (Google omits organizer.self when false)', () {
    gcal.Event ev(Map<String, Object?> organizer) => gcal.Event.fromJson({'organizer': organizer});
    expect(organizes(ev({'email': 'marek@example.com', 'displayName': 'Marek'}), 'anna@gmail.com'), isFalse); // invitation
    expect(organizes(ev({'email': 'anna@gmail.com', 'self': true}), 'anna@gmail.com'), isTrue); // own event
    expect(organizes(ev({'email': 'team@group.calendar.google.com'}), 'team@group.calendar.google.com'), isTrue); // shared calendar's own event
    expect(organizes(gcal.Event(), 'anna@gmail.com'), isTrue);
  });

  test('day slots: clashes, overlaps, clipping and the hour range', () {
    final d = DateTime(2026, 10, 30);
    DateTime at(double h) => DateTime(2026, 10, 30).add(Duration(minutes: (h * 60).round()));
    final xs = slotsOf(d, [
      Ev('demo', 'w', at(14), at(15)),
      Ev('review', 'w', at(14.5), at(15.5)),
      Ev('call', 'w', at(15.25), at(16.5)),
      Ev('late', 'p', at(22.25), at(24.5)),
      Ev('all day', 'p', d, at(24), allDay: true),
    ]);
    expect(xs.map((x) => x.e.title), ['demo', 'review', 'call', 'late']);
    expect(xs.map((x) => x.coll), [false, true, true, false]);
    expect(xs.map((x) => x.base), [true, false, false, false]);
    expect(xs.last.end, 1440); // clipped at midnight
    expect(hourRange(xs), (8, 24));
    expect(hourRange(const []), (8, 22));
  });

  test('.ics: import reads zones, all-day, durations, repeats; export round-trips', () {
    tzdata.initializeTimeZones();
    const file = 'BEGIN:VCALENDAR\r\nBEGIN:VTIMEZONE\r\nTZID:Europe/Warsaw\r\nBEGIN:STANDARD\r\nDTSTART:19701025T030000\r\nEND:STANDARD\r\nEND:VTIMEZONE\r\n'
        'BEGIN:VEVENT\r\nUID:a@x\r\nDTSTART;TZID=Europe/Warsaw:20261030T140000\r\nDTEND;TZID=Europe/Warsaw:20261030T150000\r\n'
        'SUMMARY:Demo\\, sprint\r\nLOCATION:Sala 4B\r\nDESCRIPTION:line one\\nline two that is long enough to be\r\n  folded\r\n'
        'RRULE:FREQ=WEEKLY;BYDAY=FR\r\nEXDATE;TZID=Europe/Warsaw:20261106T140000\r\nBEGIN:VALARM\r\nTRIGGER:-PT10M\r\nEND:VALARM\r\nEND:VEVENT\r\n'
        'BEGIN:VEVENT\r\nUID:b@x\r\nDTSTART;VALUE=DATE:20261101\r\nSUMMARY:Wszystkich Świętych\r\nEND:VEVENT\r\n'
        'BEGIN:VEVENT\r\nUID:c@x\r\nDTSTART:20261031T090000Z\r\nDURATION:PT1H30M\r\nSUMMARY:Call\r\nEND:VEVENT\r\n'
        'BEGIN:VEVENT\r\nUID:a@x\r\nRECURRENCE-ID;TZID=Europe/Warsaw:20261113T140000\r\nDTSTART;TZID=Europe/Warsaw:20261113T160000\r\nSUMMARY:Moved\r\nEND:VEVENT\r\n'
        'BEGIN:VEVENT\r\nUID:d@x\r\nSTATUS:CANCELLED\r\nDTSTART:20261031T090000Z\r\nSUMMARY:Gone\r\nEND:VEVENT\r\nEND:VCALENDAR\r\n';
    final evs = parseIcs(file, local: 'Europe/Warsaw');
    expect(evs.map((e) => e.summary), ['Demo, sprint', 'Wszystkich Świętych', 'Call']);
    final demo = evs.first;
    expect(demo.iCalUID, 'a@x');
    expect(demo.start!.dateTime!.toUtc(), DateTime.utc(2026, 10, 30, 13)); // CET, after the October change
    expect(demo.start!.timeZone, 'Europe/Warsaw');
    expect(demo.description, 'line one\nline two that is long enough to be folded');
    expect(demo.recurrence, ['RRULE:FREQ=WEEKLY;BYDAY=FR', 'EXDATE;TZID=Europe/Warsaw:20261106T140000']);
    expect(evs[1].start!.date, DateTime.utc(2026, 11, 1));
    expect(evs[1].end!.date, DateTime.utc(2026, 11, 2));
    expect(evs[2].end!.dateTime!.toUtc(), DateTime.utc(2026, 10, 31, 10, 30));

    final out = writeIcs(evs, local: 'Europe/Warsaw');
    expect(out.split('\r\n').every((line) => utf8.encode(line).length <= 75), isTrue);
    expect(out, contains('DTSTART;TZID=Europe/Warsaw:20261030T140000'));
    expect(out, contains('DTSTART;VALUE=DATE:20261101'));
    final again = parseIcs(out, local: 'Europe/Warsaw');
    String key(e) => '${e.summary}|${e.iCalUID}|${e.description}|${e.recurrence}|${e.start!.toJson()}|${e.end!.toJson()}';
    expect(again.map(key), evs.map(key));
  });

  test('names sort the Polish way', () {
    final names = ['Zimbabwe', 'Łotwa', 'Luksemburg', 'Macedonia', 'Święta Lucia', 'Szwecja', 'Tajlandia']..sort((a, b) => sortKey(a).compareTo(sortKey(b)));
    expect(names, ['Luksemburg', 'Łotwa', 'Macedonia', 'Szwecja', 'Święta Lucia', 'Tajlandia', 'Zimbabwe']);
  });

  test('ISO week numbers', () {
    expect(isoWeek(DateTime(2026, 10, 30)), 44);
    expect(isoWeek(DateTime(2027, 1, 1)), 53); // Friday: belongs to the last week of 2026
    expect(isoWeek(DateTime(2026, 1, 1)), 1);
    expect(isoWeek(DateTime(2024, 12, 30)), 1);
  });

  test('"delete this and following" ends the series just before the occurrence', () {
    expect(endRuleBefore('RRULE:FREQ=WEEKLY;COUNT=10;BYDAY=FR', DateTime.utc(2026, 10, 30, 13), allDay: false),
        'RRULE:FREQ=WEEKLY;BYDAY=FR;UNTIL=20261030T125959Z');
    expect(endRuleBefore('RRULE:FREQ=DAILY;UNTIL=20271231', DateTime(2026, 11, 1), allDay: true), 'RRULE:FREQ=DAILY;UNTIL=20261031');
    expect(endRuleBefore('EXDATE:20261106T130000Z', DateTime(2026, 11, 1), allDay: false), 'EXDATE:20261106T130000Z');
  });

  test('events and calendars come from the disk cache when Google is unreachable', () async {
    SharedPreferences.setMockInitialValues({'onboarded': true, 'google': true});
    final dir = Directory.systemTemp.createTempSync();
    final online = Store(_FakeGoogle(), dir);
    await online.start();
    final today = dayOf(DateTime.now());
    online.on(today);
    await Future<void>.delayed(const Duration(milliseconds: 100));
    final fetched = online.on(today)!;
    expect(fetched, isNotEmpty);

    final offline = Store(_OfflineGoogle(), dir);
    await offline.start();
    expect(offline.signedIn, isTrue);
    expect(offline.cals.map((c) => c.name), contains('Praca'));
    expect(offline.on(today), isNull); // loading: cache is read asynchronously
    await Future<void>.delayed(const Duration(milliseconds: 100));
    expect(offline.on(today)!.map((e) => e.title), fetched.map((e) => e.title));
    expect(offline.error, isNotNull);
  });

  test('address subscription: copies the file, skips it unchanged, drops events that left it', () async {
    SharedPreferences.setMockInitialValues({'onboarded': true, 'google': true});
    String feed(List<String> uids) => [
          'BEGIN:VCALENDAR', 'X-WR-CALNAME:Liga', //
          for (final u in uids) ...['BEGIN:VEVENT', 'UID:$u', 'DTSTART:20261107T150000Z', 'SUMMARY:Mecz $u', 'END:VEVENT'],
          'END:VCALENDAR',
        ].join('\r\n');
    // The test binding answers every HttpClient request with 400; this test talks to its own local server.
    final overrides = HttpOverrides.current;
    HttpOverrides.global = null;
    addTearDown(() => HttpOverrides.global = overrides);
    var body = feed(['a', 'b']);
    final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
    server.listen((r) => r.response
      ..write(body)
      ..close());
    addTearDown(server.close);
    final g = _SubGoogle();
    final store = Store(g, Directory.systemTemp.createTempSync());
    await store.start();

    expect(await store.subscribe('http://127.0.0.1:${server.port}/liga.ics'), 'Liga');
    expect(store.subscriptions, {'sub1': 'http://127.0.0.1:${server.port}/liga.ics'});
    expect(g.imported, ['a', 'b']);
    expect(store.writable.map((c) => c.id), isNot(contains('sub1')));

    await store.refreshSubscriptions(force: true); // same file: nothing sent to Google
    expect(g.imported, ['a', 'b']);

    body = feed(['b']);
    await store.refreshSubscriptions(force: true);
    expect(g.imported, ['b', 'b']); // 'a' left the file and was deleted
    expect(g.deleted, ['id-a']);
  });

  test('repeat rules round-trip and read like the mockup', () async {
    final pl = await AppLocalizations.delegate.load(const Locale('pl'));
    final en = await AppLocalizations.delegate.load(const Locale('en'));
    final r = Rule.parse('RRULE:FREQ=WEEKLY;INTERVAL=2;BYDAY=TU,FR')!;
    expect(r.describe(pl, 'pl'), 'Co 2 tygodnie we wtorek i piątek, bez końca.');
    expect(r.describe(en, 'en'), 'Every 2 weeks on Tuesday and Friday, forever.');
    expect(r.format(), 'RRULE:FREQ=WEEKLY;INTERVAL=2;BYDAY=TU,FR');
    expect(Rule.parse('RRULE:FREQ=WEEKLY;BYDAY=MO,WE,FR;COUNT=10')!.describe(pl, 'pl'),
        'Co tydzień w poniedziałek, środę i piątek, 10 razy.');
    final until = Rule.parse('RRULE:FREQ=DAILY;UNTIL=20261231T225959Z')!;
    expect(until.until, DateTime(2026, 12, 31));
    expect(until.format(), 'RRULE:FREQ=DAILY;UNTIL=20261231T235959Z');
    expect(Rule.parse('RRULE:FREQ=MONTHLY;INTERVAL=3')!.describe(pl, 'pl'), 'Co 3 miesiące, bez końca.');
    expect(Rule.parse('RRULE:FREQ=YEARLY;COUNT=1')!.describe(pl, 'pl'), 'Co rok, 1 raz.');
    // Parts the screen does not edit survive a round trip.
    expect(Rule.parse('RRULE:FREQ=MONTHLY;BYDAY=1MO')!.format(), 'RRULE:FREQ=MONTHLY;BYDAY=1MO');
    expect(Rule.parse('EXDATE:20261106'), isNull);
  });

  test('notification plan: reminders, all-day, daily summary', () async {
    final pl = await AppLocalizations.delegate.load(const Locale('pl'));
    await initializeDateFormatting();
    final now = DateTime(2026, 10, 30, 13, 0);
    final evs = [
      Ev('Demo sprintu', 'w', DateTime(2026, 10, 30, 14), DateTime(2026, 10, 30, 15), id: 'a', reminder: 15, location: 'Sala 4B'),
      Ev('Bez przypomnienia', 'w', DateTime(2026, 10, 30, 16), DateTime(2026, 10, 30, 17), id: 'b', customReminder: true),
      Ev('Domyślne', 'w', DateTime(2026, 10, 31, 10), DateTime(2026, 10, 31, 11), id: 'c'),
      Ev('Odrzucone', 'w', DateTime(2026, 10, 31, 12), DateTime(2026, 10, 31, 13), id: 'd', organizer: false,
          guests: const [Guest('Ja', 'ja@x.pl', 'declined', self: true)]),
      Ev('Wszystkich Świętych', 'h', DateTime(2026, 11, 1), DateTime(2026, 11, 2), id: 'e', allDay: true),
      Ev('Minione', 'w', DateTime(2026, 10, 30, 9), DateTime(2026, 10, 30, 10), id: 'f', reminder: 10),
    ];
    final p = plan(evs, now, const NotifyPrefs(), pl, 'pl');
    final byTitle = {for (final n in p) n.title: n};
    expect(byTitle['Demo sprintu']!.at, DateTime(2026, 10, 30, 13, 45));
    expect(byTitle['Demo sprintu']!.body, 'Za 15 min · 14:00–15:00 · Sala 4B');
    expect(byTitle.containsKey('Bez przypomnienia'), isFalse); // "none" chosen in Google
    expect(byTitle['Domyślne']!.at, DateTime(2026, 10, 31, 9, 50)); // app default: 10 min
    expect(byTitle.containsKey('Odrzucone'), isFalse);
    expect(byTitle['Wszystkich Świętych']!.at, DateTime(2026, 10, 31, 9)); // 9:00 the day before
    expect(byTitle.containsKey('Minione'), isFalse);
    // Summaries: not for today (7:30 has passed), yes for the 31st with its two timed events (declined one left out).
    final summaries = [for (final n in p) if (n.summary) n];
    expect(summaries.map((n) => n.at), [DateTime(2026, 10, 31, 7, 30)]);
    expect(summaries.single.title, 'Dziś: 1 wydarzenie');
    expect(plan(evs, now, const NotifyPrefs(summary: false, allDayAt: -1, defaultReminder: -1), pl, 'pl').map((n) => n.title), ['Demo sprintu']);
  });

  testWidgets('marquee waits, scrolls to the end, then starts over', (t) async {
    await t.pumpWidget(const Directionality(
      textDirection: TextDirection.ltr,
      child: Center(child: SizedBox(width: 60, child: Marquee('A VERY LONG CALENDAR NAME', style: TextStyle(fontSize: 11)))),
    ));
    await t.pump(); // post-frame start
    double x() => t.widget<Transform>(find.byType(Transform)).transform.getTranslation().x;
    await t.pump(const Duration(milliseconds: 1000));
    expect(x(), 0); // still in the first pause
    await t.pump(const Duration(milliseconds: 1000));
    expect(x(), lessThan(0)); // scrolling
    final end = -(25 * 11 - 60.0); // Ahem test font: every glyph is fontSize wide
    await t.pump(Duration(milliseconds: ((-end) / 30 * 1000).round()));
    expect(x(), closeTo(end, 0.5)); // reached the end and holds
    await t.pump(const Duration(milliseconds: 1600));
    expect(x(), greaterThan(end)); // started over
    await t.pumpWidget(const SizedBox()); // dispose the repeating controller
  });

  testWidgets('marquee stays still when the text fits', (t) async {
    await t.pumpWidget(const Directionality(
      textDirection: TextDirection.ltr,
      child: Center(child: SizedBox(width: 200, child: Marquee('SHORT', style: TextStyle(fontSize: 11)))),
    ));
    await t.pump();
    expect(find.byType(Transform), findsNothing);
    expect(t.hasRunningAnimations, isFalse);
  });

  testWidgets('tapping a view tab twice quickly jumps back to today', (t) async {
    await _fonts();
    await initializeDateFormatting();
    SharedPreferences.setMockInitialValues({'onboarded': true, 'google': true});
    t.view.physicalSize = const Size(390, 844);
    t.view.devicePixelRatio = 1;
    t.platformDispatcher.localesTestValue = const [Locale('pl')];
    addTearDown(t.view.reset);
    addTearDown(t.platformDispatcher.clearAllTestValues);
    final store = Store(_FakeGoogle(), Directory.systemTemp.createTempSync());
    await t.runAsync(store.start);
    await t.pumpWidget(App(store));
    await t.pump();
    await t.tap(find.text('DZIEŃ'));
    await t.pump();
    final weekday = DateFormat.EEEE('pl').format(DateTime.now()).toUpperCase();
    expect(find.text(weekday), findsOneWidget);
    for (var i = 0; i < 2; i++) {
      await t.tap(find.byTooltip('Następny'));
      await t.pump(const Duration(seconds: 1));
    }
    expect(find.text(weekday), findsNothing);
    await t.tap(find.text('DZIEŃ'));
    await t.pump(const Duration(milliseconds: 100));
    await t.tap(find.text('DZIEŃ'));
    await t.pump();
    expect(find.text(weekday), findsOneWidget);
    await t.pumpWidget(const SizedBox()); // stops the minute ticker
  });

  group('screens', () {
    setUpAll(() async {
      await _fonts();
      await initializeDateFormatting();
    });

    Future<void> shot(WidgetTester t, String name,
        {int tab = -1,
        bool onboarded = true,
        Brightness b = Brightness.dark,
        Widget Function(Store)? page,
        String? tapText,
        Future<void> Function(WidgetTester)? act,
        Map<String, Object> prefs = const {}}) async {
      SharedPreferences.setMockInitialValues({'onboarded': onboarded, 'google': onboarded, ...prefs});
      t.view.physicalSize = const Size(390, 844);
      t.view.devicePixelRatio = 1;
      t.platformDispatcher.localesTestValue = const [Locale('pl')];
      t.platformDispatcher.platformBrightnessTestValue = b;
      addTearDown(t.view.reset);
      addTearDown(t.platformDispatcher.clearAllTestValues);
      final store = Store(_FakeGoogle(), Directory.systemTemp.createTempSync());
      final key = GlobalKey();
      await t.runAsync(store.start);
      await t.pumpWidget(RepaintBoundary(key: key, child: App(store)));
      await t.pump();
      // Fixed pumps instead of pumpAndSettle: marquees and the minute ticker under the page never settle.
      if (page != null) {
        Navigator.of(t.element(find.byType(Scaffold).first)).push(MaterialPageRoute(builder: (_) => page(store)));
        await t.pump();
        await t.pump(const Duration(milliseconds: 600));
      }
      if (tapText != null) {
        await t.tap(find.text(tapText).last);
        await t.pump();
        await t.pump(const Duration(milliseconds: 600));
      }
      if (tab >= 0) {
        await t.tap(find.text(['ROK', 'MIESIĄC', 'TYDZIEŃ', 'DZIEŃ'][tab]));
        await t.pump();
      }
      await act?.call(t);
      await t.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 50))); // fake event load
      await t.pump();
      expect(t.takeException(), isNull);
      await t.runAsync(() async {
        final img = await t.renderObject<RenderRepaintBoundary>(find.byKey(key)).toImage();
        final data = await img.toByteData(format: ui.ImageByteFormat.png);
        File('$_out/$name.png').writeAsBytesSync(data!.buffer.asUint8List());
      });
      // The minute ticker in Home must not outlive the test.
      await t.pumpWidget(const SizedBox());
    }

    testWidgets('welcome', (t) => shot(t, '01_1_welcome', onboarded: false));
    testWidgets('syncing', (t) async {
      final store = Store(_FakeGoogle(), Directory.systemTemp.createTempSync());
      await t.runAsync(store.start);
      await t.runAsync(store.loadCalendars);
      await shot(t, '01_4_syncing', onboarded: false, page: (_) => Syncing(store));
    });
    testWidgets('choose', (t) async {
      final store = Store(_FakeGoogle(), Directory.systemTemp.createTempSync());
      await t.runAsync(store.start);
      await t.runAsync(store.loadCalendars);
      await shot(t, '01_3_choose', onboarded: false, page: (_) => Choose(store, onboarding: true));
    });
    testWidgets('connect', (t) => shot(t, '01_2_connect', onboarded: false, page: (s) => Connect(s)));
    testWidgets('search', (t) => shot(t, '02_5_search', page: (s) => Search(s, backLabel: 'Miesiąc'), act: (t) async {
          await t.enterText(find.byType(TextField), 'demo');
          await t.pump(const Duration(milliseconds: 500)); // debounce
          await t.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 50)));
          await t.pump();
        }));
    testWidgets('event', (t) => shot(t, '03_1_event', page: (s) => EventDetails(_demo(), s)));
    testWidgets('new event', (t) => shot(t, '03_2_new_event', page: (s) => EventEdit(s)));
    testWidgets('edit event', (t) => shot(t, '03_2_edit_event', page: (s) => EventEdit(s, ev: _demo())));
    testWidgets('custom repeat', (t) => shot(t, '03_3_custom_repeat',
        page: (_) => CustomRepeat(rule: Rule.parse('RRULE:FREQ=WEEKLY;INTERVAL=2;BYDAY=TU,FR')!, start: DateTime.now())));
    testWidgets('invite', (t) => shot(t, '03_4_invite', page: (s) {
          s.on(DateTime.now()); // loads people for suggestions
          return Invite(s,
              subtitle: 'Demo sprintu · Pt 30 paź',
              initial: (guests: const [Guest('Magda Lewandowska', 'magda.l@gmail.com', 'needsAction')], invite: true, modify: false, see: true),
              sendLabel: 'Wyślij');
        }));
    testWidgets('invitation', (t) => shot(t, '03_5_invitation', page: (s) => EventDetails(_invitation(), s)));
    testWidgets('delete dialog', (t) => shot(t, '06_2_delete', page: (s) => EventDetails(_demo(), s), tapText: 'USUŃ'));
    testWidgets('year', (t) => shot(t, '02_1_year', tab: 0));
    testWidgets('month', (t) => shot(t, '02_2_month'));
    testWidgets('week', (t) => shot(t, '02_3_week', tab: 2));
    testWidgets('day', (t) => shot(t, '02_4_day', tab: 3));
    testWidgets('empty day', (t) => shot(t, '06_1_empty_day', tab: 3, act: (t) async {
          for (var i = 0; i < 3; i++) {
            await t.tap(find.byTooltip('Następny'));
            await t.pump();
          }
        }));
    testWidgets('save repeating', (t) => shot(t, '03_2_save_repeating', page: (s) => EventEdit(s, ev: _demo()), tapText: 'ZAPISZ'));
    testWidgets('sync conflict', (t) => shot(t, '06_3_conflict', page: (s) => EventEdit(s, ev: _single()), tapText: 'ZAPISZ', act: (t) async {
          await t.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 50))); // save reaches the fake Google
          await t.pump();
          await t.pump(const Duration(milliseconds: 600));
        }));
    testWidgets('calendars', (t) => shot(t, '04_1_calendars', page: (s) => Calendars(s, backLabel: 'Miesiąc')));
    testWidgets('add calendar', (t) => shot(t, '04_2_add_calendar', page: (s) => AddCalendar(s)));
    testWidgets('markers', (t) => shot(t, 'markers', page: (s) => Scaffold(
          body: Center(
            child: Wrap(spacing: 36, runSpacing: 36, children: [
              for (final m in Shape.values) Transform.scale(scale: 3, child: Marker(m)),
            ]),
          ),
        )));
    testWidgets('subscribe dialog', (t) => shot(t, '04_2_subscribe', page: (s) => AddCalendar(s), tapText: 'Subskrybuj adres'));
    testWidgets('holidays', (t) => shot(t, '04_3_holidays', page: (s) => Holidays(s)));
    testWidgets('share', (t) => shot(t, '04_4_share', page: (s) => Share(s, s.cal('w')!)));
    testWidgets('shared with you', (t) => shot(t, '04_5_shared_with_you', page: (s) => SharedWithYou(s, s.cal('ola.zielinska@gmail.com')!)));
    testWidgets('settings', (t) => shot(t, '05_1_settings', page: (s) => Settings(s, backLabel: 'Miesiąc')));
    testWidgets('appearance', (t) => shot(t, '05_2_appearance', page: (s) => Appearance(s)));
    testWidgets('notifications', (t) => shot(t, '05_3_notifications', page: (s) => Notifications(s)));
    testWidgets('accounts', (t) => shot(t, '05_4_accounts', page: (s) => Accounts(s)));
    testWidgets('data', (t) => shot(t, '05_5_data', page: (s) => DataPrivacy(s)));
    testWidgets('help', (t) => shot(t, '05_6_help', page: (s) => Help(s)));
    testWidgets('help article', (t) => shot(t, '05_7_article', page: (s) => HelpArticle(s, helpFor('pl').first)));
    testWidgets('about', (t) => shot(t, '05_8_about', page: (s) => About(s)));
    testWidgets('custom reminder', (t) => shot(t, '03_2_custom_reminder', page: (s) => EventEdit(s), act: (t) async {
          for (final label in ['Przypomnienie', 'Własne…']) {
            await t.tap(find.text(label).last);
            await t.pump();
            await t.pump(const Duration(milliseconds: 600));
          }
        }));
    testWidgets('day 12h', (t) async {
      addTearDown(() => Look.use24h = true);
      await shot(t, '02_4_day_12h', tab: 3, prefs: {'use24h': false});
    });
    testWidgets('month light', (t) => shot(t, '02_2_month_light', b: Brightness.light));
  }, skip: _out == null);
}
