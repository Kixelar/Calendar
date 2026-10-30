// Logic checks, plus screen renders to PNG for comparing with the mockup without a device:
//   $env:CAL_SHOTS='C:\some\folder'; flutter test test/screens_test.dart
import 'dart:io';
import 'dart:ui' as ui;

import 'package:calendar/google.dart';
import 'package:calendar/main.dart';
import 'package:calendar/screens/home.dart';
import 'package:calendar/screens/onboarding.dart';
import 'package:calendar/store.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:shared_preferences/shared_preferences.dart';

final _out = Platform.environment['CAL_SHOTS'];

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
      Ev('Warsztaty UX', 'w', at(0, 10), at(0, 12), location: 'Sala 2'),
      Ev('Demo sprintu', 'w', DateTime.now().add(const Duration(minutes: 12)), DateTime.now().add(const Duration(minutes: 72)),
          location: 'Sala 4B'),
      Ev('Trening', 'p', at(0, 22), at(0, 23), location: 'Siłownia'),
      Ev('Brunch z Olą', 'o', at(1, 11), at(1, 13), location: 'U Oli'),
      Ev('Koncert', 'p', at(1, 19), at(1, 22), location: 'Stodoła'),
      Ev('Wszystkich Świętych', 'h', DateTime(d.year, 11, 1), DateTime(d.year, 11, 2), allDay: true),
      for (var i = -40; i < 60; i += 3) Ev('Spotkanie', 'w', at(i, 9), at(i, 10 + i % 4)),
    ];
    return evs.where((e) => e.start.isBefore(to) && e.end.isAfter(from)).toList()..sort((a, b) => a.start.compareTo(b.start));
  }
}

Future<void> _fonts() async {
  const dir = 'C:/src/flutter/bin/cache/artifacts/material_fonts';
  final fonts = {
    'Roboto': ['$dir/Roboto-Regular.ttf'],
    'MaterialIcons': ['$dir/MaterialIcons-Regular.otf'],
    'monospace': ['C:/Windows/Fonts/consola.ttf'],
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

  group('screens', () {
    setUpAll(() async {
      await _fonts();
      await initializeDateFormatting();
    });

    Future<void> shot(WidgetTester t, String name, {int tab = -1, bool onboarded = true, Brightness b = Brightness.dark, Widget? page}) async {
      SharedPreferences.setMockInitialValues({'onboarded': onboarded});
      t.view.physicalSize = const Size(390, 844);
      t.view.devicePixelRatio = 1;
      t.platformDispatcher.localesTestValue = const [Locale('pl')];
      t.platformDispatcher.platformBrightnessTestValue = b;
      addTearDown(t.view.reset);
      addTearDown(t.platformDispatcher.clearAllTestValues);
      final store = Store(_FakeGoogle());
      final key = GlobalKey();
      await t.runAsync(store.start);
      await t.pumpWidget(RepaintBoundary(key: key, child: App(store)));
      await t.pump();
      if (page != null) {
        Navigator.of(t.element(find.byType(Scaffold).first)).push(MaterialPageRoute(builder: (_) => page));
        await t.pumpAndSettle();
      }
      if (tab >= 0) {
        await t.tap(find.text(['ROK', 'MIESIĄC', 'TYDZIEŃ', 'DZIEŃ'][tab]));
        await t.pump();
      }
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
    testWidgets('choose', (t) async {
      final store = Store(_FakeGoogle());
      await t.runAsync(store.start);
      await t.runAsync(store.loadCalendars);
      await shot(t, '01_3_choose', onboarded: false, page: Choose(store, onboarding: true));
    });
    testWidgets('connect', (t) => shot(t, '01_2_connect', onboarded: false, page: Connect(Store(_FakeGoogle()))));
    testWidgets('year', (t) => shot(t, '02_1_year', tab: 0));
    testWidgets('month', (t) => shot(t, '02_2_month'));
    testWidgets('week', (t) => shot(t, '02_3_week', tab: 2));
    testWidgets('day', (t) => shot(t, '02_4_day', tab: 3));
    testWidgets('month light', (t) => shot(t, '02_2_month_light', b: Brightness.light));
  }, skip: _out == null);
}
