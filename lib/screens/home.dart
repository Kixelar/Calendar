import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../google.dart';
import '../store.dart';
import '../theme.dart';
import '../ui.dart';
import 'onboarding.dart';

/// Main screen with the four views from the mockup: 02.1 year, 02.2 month, 02.3 week, 02.4 day.
class Home extends StatefulWidget {
  const Home(this.store, {super.key});
  final Store store;
  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  int tab = 1;
  DateTime focus = dayOf(DateTime.now());
  late final Timer _tick;

  Store get store => widget.store;

  @override
  void initState() {
    super.initState();
    // Keeps "now" line, "in N min" and past/future dimming current.
    _tick = Timer.periodic(const Duration(minutes: 1), (_) => setState(() {}));
  }

  @override
  void dispose() {
    _tick.cancel();
    super.dispose();
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
                child: Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                  if (store.signedIn)
                    IconBtn(Icons.layers_outlined, label: l.calendars, onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => Choose(store, onboarding: false)));
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
                    if (store.error != null)
                      Padding(padding: const EdgeInsets.only(top: 24), child: Text(l.loadFailed, style: T.bodySm(t.accentText))),
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
          style: T.displayMd(isToday ? t.bg : out ? t.disabled : d.isBefore(today) ? t.secondary : t.display)),
    );
  }

  List<Widget> _month(BuildContext c) {
    final t = Tok.of(c), l = l10n(c), now = DateTime.now(), today = dayOf(now);
    final m = DateTime(focus.year, focus.month);
    final start = DateTime(m.year, m.month, 2 - m.weekday);
    final len = DateTime(m.year, m.month + 1, 0).day;
    final rows = ((m.weekday - 1 + len) / 7).ceil();
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
        for (final w in l.weekdays.split(','))
          Expanded(child: SizedBox(height: 24, child: Center(child: Text(w, style: T.labelSm(t.secondary))))),
      ]),
      for (var r = 0; r < rows; r++)
        Row(children: [
          for (var i = 0; i < 7; i++)
            Expanded(
              child: Builder(builder: (c) {
                final d = DateTime(start.year, start.month, start.day + r * 7 + i);
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
                          color: !has ? null : d.isBefore(today) ? t.secondary : t.display,
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
        big: '${focus.day}',
        title: DateFormat.EEEE(loc(c)).format(focus),
        caption: DateFormat('LLLL y', loc(c)).format(focus).toUpperCase(),
        onMove: (d) => go(DateTime(focus.year, focus.month, focus.day + d), 3),
      ),
      if (all.isNotEmpty) Section(left: l.allDay, children: [for (final e in all) EventRow(e, store, now: now)]),
      Section(
        left: l.schedule,
        right: timed.isEmpty ? null : l.eventsN(timed.length),
        children: [
          if (evs == null) const _Loading() else if (timed.isEmpty) _empty(c),
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
    final mon = DateTime(focus.year, focus.month, focus.day - focus.weekday + 1);
    final days = [for (var i = 0; i < 7; i++) DateTime(mon.year, mon.month, mon.day + i)];
    final names = l.weekdays.split(',');
    final perDay = [for (final d in days) store.on(d)];
    final count = {for (final e in perDay) ...?e}.length;
    final thisWeek = days.contains(today);
    final next = !thisWeek
        ? null
        : [for (final e in perDay.skip(today.weekday - 1)) ...?e].where((e) => !e.allDay && e.start.isAfter(now)).firstOrNull;
    final f = DateFormat('dd.MM', loc(c));
    final tomorrow = DateTime(today.year, today.month, today.day + 1);
    String dayName(int i) => switch (days[i]) {
          final d when d == today => '${l.today} · ${names[i]} ${d.day}',
          final d when d == tomorrow => '${l.tomorrow} · ${names[i]} ${d.day}',
          final d => '${names[i]} ${d.day}',
        };
    return [
      Hero2(
        big: '${isoWeek(mon)}',
        title: l.weekN(isoWeek(mon)),
        caption: '${f.format(days.first)}–${f.format(days.last)} · ${l.eventsN(count)}',
        onMove: (d) => go(DateTime(focus.year, focus.month, focus.day + 7 * d), 2),
      ),
      const SizedBox(height: 24),
      Row(children: [
        for (var i = 0; i < 7; i++)
          Expanded(
            child: InkWell(
              onTap: () => go(days[i], 3),
              child: Column(spacing: 6, children: [
                Text(names[i], style: T.labelSm(days[i] == today ? t.display : t.secondary)),
                _num(c, days[i]),
                _load(c, perDay[i], days[i].isBefore(today) ? 0.3 : days[i] == today ? 1 : 0.6),
              ]),
            ),
          ),
      ]),
      if (next != null) _nextCard(c, next, now),
      for (var i = thisWeek ? today.weekday - 1 : 0; i < 7; i++)
        if ((perDay[i] ?? const []).where((e) => e != next && e.end.isAfter(now)).toList() case final evs when evs.isNotEmpty)
          Section(
            left: dayName(i),
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
    );
  }

  List<Widget> _year(BuildContext c) {
    final t = Tok.of(c), l = l10n(c), today = dayOf(DateTime.now());
    final y = focus.year;
    Widget month(int m) {
      final first = DateTime(y, m);
      final len = DateTime(y, m + 1, 0).day;
      final cells = [for (var i = 1; i < first.weekday; i++) null, for (var d = 1; d <= len; d++) DateTime(y, m, d)];
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
