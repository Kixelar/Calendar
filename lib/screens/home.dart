import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

import '../google.dart';
import '../store.dart';
import '../theme.dart';
import '../ui.dart';
import '../view.dart';
import 'calendars.dart';
import 'event.dart';
import 'search.dart';
import 'settings.dart';

/// Main screen with the four views from the mockup: 02.1 year, 02.2 month, 02.3 week, 02.4 day.
class Home extends StatefulWidget {
  const Home(this.store, {super.key});
  final Store store;
  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> with WidgetsBindingObserver {
  int tab = 1;
  DateTime focus = dayOf(DateTime.now());
  late final Timer _tick;

  Store get store => widget.store;

  @override
  void initState() {
    super.initState();
    // Keeps "now" line, "in N min" and past/future dimming current, and runs automatic sync (05.4).
    _tick = Timer.periodic(const Duration(minutes: 1), (_) {
      setState(() {});
      _autoSync();
    });
    WidgetsBinding.instance.addObserver(this);
    store.notifier?.onOpen = _fromNotification;
    WidgetsBinding.instance.addPostFrameCallback((_) => _showCrash());
  }

  /// After a crash the app shows its report once, so the owner can copy it (CrashLog.kt).
  Future<void> _showCrash() async {
    final report = await store.lastCrash();
    if (report == null || !mounted) return;
    final t = Tok.of(context), l = l10n(context);
    await showDialog<void>(
      context: context,
      barrierColor: const Color(0xA3000000),
      builder: (c) => Dialog(
        backgroundColor: t.surfaceRaised,
        insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 48),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8), side: BorderSide(color: t.borderSubtle)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, spacing: 16, children: [
            Text(l.crashTitle, style: T.headlineMd(t.display)),
            Text(l.crashBody, style: T.bodySm(t.secondary)),
            Flexible(
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: t.surface, border: Border.all(color: t.borderSubtle), borderRadius: BorderRadius.circular(6)),
                child: SingleChildScrollView(child: SelectableText(report, style: T.caption(t.primary))),
              ),
            ),
            Row(spacing: 8, children: [
              Expanded(child: Btn(l.close, kind: BtnKind.secondary, onTap: () => Navigator.pop(c))),
              Expanded(
                child: Btn(l.copy, onTap: () async {
                  await Clipboard.setData(ClipboardData(text: report));
                  if (c.mounted) Navigator.pop(c);
                }),
              ),
            ]),
          ]),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _tick.cancel();
    WidgetsBinding.instance.removeObserver(this);
    store.notifier?.onOpen = null;
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState s) {
    if (s == AppLifecycleState.resumed) _autoSync();
  }

  /// Refreshes when automatic sync is on and the last sync is older than the chosen interval.
  void _autoSync() {
    final last = store.lastSync;
    if (!store.signedIn || !store.autoSync) return;
    if (last == null || DateTime.now().difference(last).inMinutes >= store.syncMinutes) store.refresh();
  }

  /// A tapped notification (07.3): open the event, or send the invitation reply chosen on it.
  Future<void> _fromNotification(String payload, String? action) async {
    if (payload.isEmpty) return;
    final j = jsonDecode(payload) as Map;
    final day = DateTime.fromMillisecondsSinceEpoch(j['s'] as int);
    // The day may still be loading right after launch.
    Ev? e;
    for (var i = 0; i < 20 && e == null; i++) {
      e = store.on(day)?.where((x) => x.id == j['i'] && x.calId == j['c']).firstOrNull;
      if (e == null) await Future<void>.delayed(const Duration(milliseconds: 300));
    }
    if (e == null || !mounted) return;
    if (const {'accepted', 'tentative', 'declined'}.contains(action)) {
      try {
        await store.respond(e, action!);
      } catch (err) {
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n(context).failed('$err'))));
      }
      return;
    }
    openEvent(context, e, store);
  }

  void go(DateTime d, int t) => setState(() {
        focus = dayOf(d);
        tab = t;
      });

  @override
  Widget build(BuildContext context) {
    final t = Tok.of(context), l = l10n(context);
    return ListenableBuilder(
      listenable: store,
      builder: (context, _) => Scaffold(
        body: SafeArea(
          child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 0),
              child: SizedBox(
                height: 44,
                child: Row(children: [
                  if (store.signedIn)
                    IconBtn(Icons.search, label: l.search, onTap: () {
                      final back = [l.year, l.month, l.week, l.day][tab];
                      Navigator.push(context, MaterialPageRoute(builder: (_) => Search(store, backLabel: back)));
                    }),
                  // Google could not be reached: the views show what is saved on the phone.
                  if (store.signedIn && store.error != null) Padding(padding: const EdgeInsets.only(left: 4), child: Lbl(l.offline)),
                  const Spacer(),
                  if (store.signedIn)
                    IconBtn(Icons.layers_outlined, label: l.calendars, onTap: () {
                      final back = [l.year, l.month, l.week, l.day][tab];
                      Navigator.push(context, MaterialPageRoute(builder: (_) => Calendars(store, backLabel: back)));
                    }),
                  IconBtn(Icons.tune, label: l.settings, onTap: () {
                    final back = [l.year, l.month, l.week, l.day][tab];
                    Navigator.push(context, MaterialPageRoute(builder: (_) => Settings(store, backLabel: back)));
                  }),
                ]),
              ),
            ),
            Expanded(
              child: RefreshIndicator(
                onRefresh: store.refresh,
                color: t.display,
                backgroundColor: t.surfaceRaised,
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                  children: [
                    ...switch (tab) { 0 => _year(context), 1 => _month(context), 2 => _week(context), _ => _day(context) },
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 8, 24, 32),
              child: Row(children: [
                for (final (i, s) in [l.year, l.month, l.week, l.day].indexed)
                  InkWell(
                    onTap: () => go(focus, i),
                    child: Container(
                      height: 48,
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: Row(spacing: 6, children: [
                        if (i == tab) Container(width: 5, height: 5, decoration: BoxDecoration(color: t.display, shape: BoxShape.circle)),
                        Lbl(s, color: i == tab ? t.display : t.secondary),
                      ]),
                    ),
                  ),
                const Spacer(),
                if (store.signedIn && store.writable.isNotEmpty)
                  Material(
                    color: t.display,
                    shape: const CircleBorder(),
                    child: InkWell(
                      customBorder: const CircleBorder(),
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => EventEdit(store, day: focus))),
                      child: SizedBox.square(dimension: 48, child: Icon(Icons.add, color: t.bg, semanticLabel: l.newEvent)),
                    ),
                  ),
              ]),
            ),
          ]),
        ),
      ),
    );
  }

  bool _holiday(Ev e) => store.cal(e.calId)?.holiday ?? false;

  /// Day number circle shared by month and week views (.num).
  Widget _num(BuildContext c, DateTime d, {bool out = false}) {
    final t = Tok.of(c), today = dayOf(DateTime.now());
    final evs = store.on(d) ?? const [];
    final isToday = d == today, hol = evs.any(_holiday);
    return Container(
      width: 36,
      height: 36,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isToday ? t.display : null,
        border: hol && !isToday ? Border.all(color: t.borderControl) : null,
      ),
      child: Text('${d.day}',
          style: T.displayMd(isToday ? t.bg : out ? t.disabled : Look.dimPast && d.isBefore(today) ? t.secondary : t.display)),
    );
  }

  List<Widget> _month(BuildContext c) {
    final t = Tok.of(c), l = l10n(c), now = DateTime.now(), today = dayOf(now);
    final m = DateTime(focus.year, focus.month);
    final last = DateTime(m.year, m.month + 1, 0);
    final names = l.weekdays.split(','), cols = Look.days;
    final weeks = [for (var w = Look.weekOf(m); !w.isAfter(last); w = DateTime(w.year, w.month, w.day + 7)) w];
    final todays = store.on(today);
    final rest = todays?.where((e) => e.end.isAfter(now)).toList() ?? const <Ev>[];
    return [
      Hero2(
        big: '${m.month}',
        title: DateFormat.LLLL(loc(c)).format(m),
        caption: '${m.year}',
        onMove: (d) => go(DateTime(m.year, m.month + d), 1),
      ),
      const SizedBox(height: 24),
      Row(children: [
        if (Look.weekNumbers) const SizedBox(width: 24),
        for (final wd in cols)
          Expanded(child: SizedBox(height: 24, child: Center(child: Text(names[wd - 1], style: T.labelSm(t.secondary))))),
      ]),
      for (final w in weeks)
        Row(children: [
          if (Look.weekNumbers)
            SizedBox(
              width: 24,
              child: Text('${isoWeek(DateTime(w.year, w.month, w.day + Look.col(DateTime.monday)))}', style: T.labelSm(t.disabled)),
            ),
          for (final wd in cols)
            Expanded(
              child: Builder(builder: (c) {
                final d = DateTime(w.year, w.month, w.day + Look.col(wd));
                final out = d.month != m.month;
                final has = !out && (store.on(d) ?? const []).any((e) => !_holiday(e));
                return InkWell(
                  onTap: () => go(d, 3),
                  child: SizedBox(
                    height: 48,
                    child: Column(mainAxisAlignment: MainAxisAlignment.center, spacing: 3, children: [
                      _num(c, d, out: out),
                      Container(
                        width: 4,
                        height: 4,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: !has ? null : Look.dimPast && d.isBefore(today) ? t.secondary : t.display,
                        ),
                      ),
                    ]),
                  ),
                );
              }),
            ),
        ]),
      Section(
        left: '${l.today} · ${DateFormat.EEEE(loc(c)).format(now)}',
        right: rest.isEmpty ? null : l.moreN(rest.length),
        children: [
          if (todays == null) const _Loading() else if (rest.isEmpty) _empty(c),
          for (final e in rest) EventRow(e, store, now: now),
        ],
      ),
    ];
  }

  List<Widget> _day(BuildContext c) {
    final l = l10n(c), now = DateTime.now();
    final evs = store.on(focus);
    final (all, timed) = splitAllDay(evs ?? const []);
    final isToday = focus == dayOf(now);
    // The now line goes before the first event that has not started yet.
    var nowAt = isToday ? timed.indexWhere((e) => e.start.isAfter(now)) : -1;
    if (isToday && nowAt < 0) nowAt = timed.length;
    return [
      Hero2(
        xl: true,
        big: '${focus.day}'.padLeft(2, '0'),
        title: DateFormat.EEEE(loc(c)).format(focus),
        caption: DateFormat('LLLL y', loc(c)).format(focus).toUpperCase(),
        onMove: (d) => go(DateTime(focus.year, focus.month, focus.day + d), 3),
      ),
      if (all.isNotEmpty) Section(left: l.allDay, children: [for (final e in all) EventRow(e, store, now: now)]),
      Section(
        left: l.schedule,
        right: evs == null ? null : l.eventsN(timed.length),
        children: [
          if (evs == null) const _Loading() else if (timed.isEmpty) _emptyDay(c, free: focus.weekday >= 6 || all.any(_holiday)),
          for (var i = 0; i < timed.length; i++) ...[
            if (i == nowAt) _nowLine(c, now),
            EventRow(timed[i], store, now: now, red: false, border: i + 1 != nowAt),
          ],
          if (nowAt == timed.length && timed.isNotEmpty) _nowLine(c, now),
        ],
      ),
    ];
  }

  Widget _nowLine(BuildContext c, DateTime now) {
    final t = Tok.of(c);
    return SizedBox(
      height: 24,
      child: Row(children: [
        SizedBox(width: 48, child: Text(hm(c, now), style: T.labelSm(t.accentText))),
        const SizedBox(width: 8),
        Container(width: 6, height: 6, decoration: BoxDecoration(color: t.accent, shape: BoxShape.circle)),
        const SizedBox(width: 8),
        Expanded(child: Container(height: 1, color: t.accent)),
      ]),
    );
  }

  List<Widget> _week(BuildContext c) {
    final t = Tok.of(c), l = l10n(c), now = DateTime.now(), today = dayOf(now);
    final first = Look.weekOf(focus), lastDay = DateTime(first.year, first.month, first.day + 6);
    final days = [for (final wd in Look.days) DateTime(first.year, first.month, first.day + Look.col(wd))];
    final names = l.weekdays.split(',');
    final perDay = [for (final d in days) store.on(d)];
    final count = {for (final e in perDay) ...?e}.length;
    final thisWeek = !today.isBefore(first) && !today.isAfter(lastDay);
    final upcoming = [for (var i = 0; i < days.length; i++) if (!thisWeek || !days[i].isBefore(today)) i];
    final next = !thisWeek
        ? null
        : [for (final i in upcoming) ...?perDay[i]].where((e) => !e.allDay && e.start.isAfter(now)).firstOrNull;
    final f = DateFormat('dd.MM', loc(c));
    final tomorrow = DateTime(today.year, today.month, today.day + 1);
    final week = isoWeek(DateTime(first.year, first.month, first.day + Look.col(DateTime.monday)));
    String dayName(DateTime d) => switch (d) {
          _ when d == today => '${l.today} · ${names[d.weekday - 1]} ${d.day}',
          _ when d == tomorrow => '${l.tomorrow} · ${names[d.weekday - 1]} ${d.day}',
          _ => '${names[d.weekday - 1]} ${d.day}',
        };
    return [
      Hero2(
        big: '$week',
        title: l.weekN(week),
        caption: '${f.format(first)}–${f.format(lastDay)} · ${l.eventsN(count)}',
        onMove: (d) => go(DateTime(focus.year, focus.month, focus.day + 7 * d), 2),
      ),
      const SizedBox(height: 24),
      Row(children: [
        for (var i = 0; i < days.length; i++)
          Expanded(
            child: InkWell(
              onTap: () => go(days[i], 3),
              child: Column(spacing: 6, children: [
                Text(names[days[i].weekday - 1], style: T.labelSm(days[i] == today ? t.display : t.secondary)),
                _num(c, days[i]),
                _load(c, perDay[i], days[i].isBefore(today) ? 0.3 : days[i] == today ? 1 : 0.6),
              ]),
            ),
          ),
      ]),
      if (next != null) _nextCard(c, next, now),
      for (final i in upcoming)
        if ((perDay[i] ?? const []).where((e) => e != next && e.end.isAfter(now)).toList() case final evs when evs.isNotEmpty)
          Section(
            left: dayName(days[i]),
            leftColor: days[i] == today ? t.display : null,
            right: '${evs.length}',
            children: [for (final e in evs) EventRow(e, store, now: now, red: next == null)],
          ),
      if (perDay.any((e) => e == null)) const _Loading(),
    ];
  }

  /// Day load bar: share of an 8-hour day taken by timed events.
  Widget _load(BuildContext c, List<Ev>? evs, double opacity) {
    final t = Tok.of(c);
    final hours = (evs ?? const []).where((e) => !e.allDay).fold(0.0, (s, e) => s + e.end.difference(e.start).inMinutes / 60);
    return Container(
      width: 24,
      height: 3,
      alignment: Alignment.centerLeft,
      decoration: BoxDecoration(color: t.dotOff, borderRadius: BorderRadius.circular(2)),
      clipBehavior: Clip.antiAlias,
      child: FractionallySizedBox(
        widthFactor: (hours / 8).clamp(0, 1),
        child: Container(color: t.display.withValues(alpha: opacity)),
      ),
    );
  }

  Widget _nextCard(BuildContext c, Ev e, DateTime now) {
    final t = Tok.of(c), l = l10n(c);
    final when = dayOf(e.start) == dayOf(now) ? l.today : DateFormat.EEEE(loc(c)).format(e.start);
    final mins = (e.start.difference(now).inSeconds + 59) ~/ 60;
    final info = ['${hm(c, e.start)}–${hm(c, e.end)}', if (e.location?.isNotEmpty ?? false) e.location!].join(' · ');
    return Padding(
      padding: const EdgeInsets.only(top: 24),
      child: GestureDetector(
        onTap: () => openEvent(c, e, store),
        child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: t.surface, border: Border.all(color: t.borderControl), borderRadius: BorderRadius.circular(8)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, spacing: 4, children: [
          Row(children: [
            Expanded(child: Lbl('${l.next} · $when ${hm(c, e.start)}')),
            if (mins <= 60) Lbl(l.inMin(mins), color: t.accentText),
          ]),
          const SizedBox(height: 8),
          Text(e.title, style: T.headlineMd(t.display), maxLines: 2, overflow: TextOverflow.ellipsis),
          Row(spacing: 8, children: [
            Marker(store.cal(e.calId)?.shape ?? Shape.dot),
            Expanded(child: Text(info.toUpperCase(), style: T.caption(t.secondary), maxLines: 1, overflow: TextOverflow.ellipsis)),
          ]),
        ]),
        ),
      ),
    );
  }

  List<Widget> _year(BuildContext c) {
    final t = Tok.of(c), l = l10n(c), today = dayOf(DateTime.now());
    final y = focus.year;
    Widget month(int m) {
      final first = DateTime(y, m);
      final len = DateTime(y, m + 1, 0).day;
      final cells = [for (var i = 0; i < Look.col(first.weekday); i++) null, for (var d = 1; d <= len; d++) DateTime(y, m, d)];
      Widget dot(DateTime? d) {
        if (d == null) return const SizedBox(height: 8);
        if (d == today) {
          return Container(width: 8, height: 8, decoration: BoxDecoration(color: t.accent, shape: BoxShape.circle));
        }
        final evs = store.on(d) ?? const [];
        if (evs.any(_holiday)) {
          return Container(
              width: 6, height: 6, decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: t.display, width: 1.5)));
        }
        final n = evs.length;
        return Container(
          width: 6,
          height: 6,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: n == 0 ? t.dotOff : t.display.withValues(alpha: n == 1 ? 0.3 : n == 2 ? 0.6 : 1),
          ),
        );
      }

      return InkWell(
        onTap: () => go(first, 1),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, spacing: 8, children: [
          Lbl(DateFormat.LLL(loc(c)).format(first).replaceAll('.', ''),
              color: today.year == y && today.month == m ? t.display : t.secondary),
          for (var r = 0; r < cells.length; r += 7)
            Row(children: [
              for (var i = r; i < r + 7; i++) Expanded(child: Center(child: dot(i < cells.length ? cells[i] : null))),
            ]),
        ]),
      );
    }

    return [
      Hero2(big: '$y', title: l.year, caption: l.yearHint, onMove: (d) => go(DateTime(y + d), 0)),
      const SizedBox(height: 8),
      for (var r = 0; r < 4; r++)
        Padding(
          padding: const EdgeInsets.only(top: 24),
          child: Row(crossAxisAlignment: CrossAxisAlignment.start, spacing: 24, children: [
            for (var m = r * 3 + 1; m <= r * 3 + 3; m++) Expanded(child: month(m)),
          ]),
        ),
    ];
  }

  /// 06.1: an empty day says so and offers to add something; weekends and holidays read as days off.
  Widget _emptyDay(BuildContext c, {required bool free}) {
    final t = Tok.of(c), l = l10n(c);
    return Padding(
      padding: const EdgeInsets.only(top: 48),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, spacing: 8, children: [
        Text(l.nothingPlanned, style: T.headlineMd(t.display)),
        Text(free ? l.freeDay : l.openDay, style: T.bodySm(t.secondary)),
        if (store.signedIn && store.writable.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 16),
            child: IntrinsicWidth(
              child: Btn(l.addEvent, kind: BtnKind.secondary, icon: Icons.add, onTap: () {
                Navigator.push(c, MaterialPageRoute(builder: (_) => EventEdit(store, day: focus)));
              }),
            ),
          ),
      ]),
    );
  }

  Widget _empty(BuildContext c) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Text(l10n(c).noEvents, style: T.body(Tok.of(c).secondary)),
      );
}

class _Loading extends StatelessWidget {
  const _Loading();
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.all(16),
        child: Center(
          child: SizedBox.square(dimension: 16, child: CircularProgressIndicator(strokeWidth: 1.5, color: Tok.of(context).secondary)),
        ),
      );
}

/// ISO 8601 week number (weeks start on Monday, week 1 holds the first Thursday).
int isoWeek(DateTime d) {
  final u = DateTime.utc(d.year, d.month, d.day);
  final thu = u.add(Duration(days: 4 - d.weekday));
  return thu.difference(DateTime.utc(thu.year)).inDays ~/ 7 + 1;
}
