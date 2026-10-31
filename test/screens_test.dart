// Logic checks, plus screen renders to PNG for comparing with the mockup without a device:
//   $env:CAL_SHOTS='C:\some\folder'; flutter test test/screens_test.dart
import 'dart:io';
import 'dart:ui' as ui;

import 'package:calendar/google.dart';
import 'package:calendar/main.dart';
import 'package:calendar/screens/event.dart';
import 'package:calendar/screens/home.dart';
import 'package:calendar/screens/onboarding.dart';
import 'package:calendar/screens/search.dart';
import 'package:calendar/store.dart';
import 'package:calendar/ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:shared_preferences/shared_preferences.dart';

final _out = Platform.environment['CAL_SHOTS'];

/// The mockup's 03.1 example: repeating, with guests, starting in 12 minutes.
Ev _demo() => Ev('Demo sprintu', 'w', DateTime.now().add(const Duration(minutes: 12)), DateTime.now().add(const Duration(minutes: 72)),
    id: 'demo_1', recurringId: 'demo', location: 'Sala 4B', reminder: 15, notes: 'Pokaz nowego widoku tygodnia.',
    guests: const [
      Guest('Marek Wiśniewski', 'marek@example.com', 'accepted'),
      Guest('Ola Zielińska', 'ola@example.com', 'tentative'),
      Guest('Piotr Kamiński', 'piotr@example.com', 'needsAction'),
    ]);

/// Google account without a network: calendars and events are made up around today.
class _FakeGoogle extends GoogleCalendar {
  @override
  String? get email => 'anna.nowak@gmail.com';
  @override
  Future<bool> restore() async => true;
  @override
  Future<List<Cal>> calendars(Set<String>? enabled) async => [
        Cal('p', 'Osobisty', shared: false, holiday: false, shape: Shape.dot, on: true),
        Cal('w', 'Praca', shared: false, holiday: false, shape: Shape.square, on: true),
        Cal('f', 'Rodzina', shared: false, holiday: false, shape: Shape.half, on: true),
        Cal('o', 'Ola Zielińska', shared: true, holiday: false, shape: Shape.dash, on: true),
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
      Ev('Trening', 'p', at(0, 22), at(0, 23), location: 'Siłownia'),
      Ev('Brunch z Olą', 'o', at(1, 11), at(1, 13), location: 'U Oli'),
      Ev('Koncert', 'p', at(1, 19), at(1, 22), location: 'Stodoła'),
      Ev('Wszystkich Świętych', 'h', DateTime(d.year, 11, 1), DateTime(d.year, 11, 2), allDay: true),
      for (var i = -40; i < 60; i += 3) Ev('Spotkanie', 'w', at(i, 9), at(i, 10 + i % 4)),
    ];
    return evs.where((e) => e.start.isBefore(to) && e.end.isAfter(from)).toList()..sort((a, b) => a.start.compareTo(b.start));
  }

  @override
  Future<List<Ev>> search(List<Cal> cals, String query) async {
    final d = dayOf(DateTime.now());
    return [
      Ev('Demo wersji 2.0', 'w', DateTime(d.year, d.month - 1, 18, 11), DateTime(d.year, d.month - 1, 18, 12), location: 'Zoom'),
      Ev('Demo sprintu', 'w', DateTime(d.year, d.month, d.day - 14, 14), DateTime(d.year, d.month, d.day - 14, 15), location: 'Sala 4B'),
      _demo(),
      Ev('Demo sprintu', 'w', DateTime(d.year, d.month, d.day + 14, 14), DateTime(d.year, d.month, d.day + 14, 15), location: 'Sala 4B'),
    ];
  }
}

/// No network: every Google call fails, as on a phone without internet.
class _OfflineGoogle extends GoogleCalendar {
  @override
  Future<bool> restore() async => throw const SocketException('offline');
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
        Future<void> Function(WidgetTester)? act}) async {
      SharedPreferences.setMockInitialValues({'onboarded': onboarded, 'google': onboarded});
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
    testWidgets('delete dialog', (t) => shot(t, '06_2_delete', page: (s) => EventDetails(_demo(), s), tapText: 'USUŃ'));
    testWidgets('year', (t) => shot(t, '02_1_year', tab: 0));
    testWidgets('month', (t) => shot(t, '02_2_month'));
    testWidgets('week', (t) => shot(t, '02_3_week', tab: 2));
    testWidgets('day', (t) => shot(t, '02_4_day', tab: 3));
    testWidgets('month light', (t) => shot(t, '02_2_month_light', b: Brightness.light));
  }, skip: _out == null);
}
