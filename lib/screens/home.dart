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
import 'views.dart';

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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showCrash();
      _widgetOpen();
    });
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
    if (s == AppLifecycleState.resumed) {
      store.reloadPrefs().then((_) => _autoSync()); // the background job may have synced meanwhile
      _widgetOpen();
    }
  }

  /// The day clock widget opens today's day view (Widgets.kt ClockWidget.tap).
  Future<void> _widgetOpen() async {
    if (await store.takeOpen() == 'day' && mounted) go(DateTime.now(), 3);
  }

  /// Refreshes when automatic sync is on and the last sync is older than the chosen interval.
  Future<void> _autoSync() async {
    final last = store.lastSync;
    if (!store.signedIn || !store.autoSync) return;
    if (last != null && DateTime.now().difference(last).inMinutes < store.syncMinutes) return;
    if (store.wifiOnly && await store.metered()) return; // pull to refresh still syncs
    await store.refresh();
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

  DateTime? _lastTap;

  /// A view tab; tapped twice quickly it jumps to today's day, week, month or year.
  void _tab(int i) {
    final now = DateTime.now(), quick = i == tab && _lastTap != null && now.difference(_lastTap!) < const Duration(milliseconds: 400);
    _lastTap = now;
    go(quick ? now : focus, i);
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
              child: Stack(children: [
                Positioned.fill(
                  child: RefreshIndicator(
                    onRefresh: store.refresh,
                    color: t.display,
                    backgroundColor: t.surfaceRaised,
                    child: tab == 1
                        ? _month(context)
                        : CustomScrollView(slivers: [
                            ...switch (tab) { 0 => _year(context), 2 => _week(context), _ => _day(context) },
                            const SliverToBoxAdapter(child: SizedBox(height: 54)),
                          ]),
                  ),
                ),
                // Content fades out above the bottom bar (.fade).
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  height: 54,
                  child: IgnorePointer(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          stops: const [0, .85],
                          colors: [t.bg.withValues(alpha: 0), t.bg],
                        ),
                      ),
                    ),
                  ),
                ),
              ]),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 8, 24, 32),
              child: Row(children: [
                for (final (i, s) in [l.year, l.month, l.week, l.day].indexed)
                  InkWell(
                    onTap: () => _tab(i),
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

  /// Tapping a day selects it; tapping the selected day again opens its day view.
  void _pick(DateTime d) => d == focus ? go(d, 3) : setState(() => focus = d);

  /// Header line and rows of the selected day, shared by the month and week views.
  (Widget, List<Widget>) _list(BuildContext c, DateTime now) {
    final l = l10n(c), today = dayOf(now), evs = store.on(focus);
    final slots = slotsOf(focus, evs ?? const []);
    final name = DateFormat.EEEE(loc(c)).format(focus);
    final left = switch (focus) {
      _ when focus == today => '${l.today} · $name',
      _ when focus == DateTime(today.year, today.month, today.day + 1) => '${l.tomorrow} · $name',
      _ => '${l.weekdays.split(',')[focus.weekday - 1]} ${focus.day}',
    };
    return (
      ListBar(left, dayCounts(c, focus, slots, now)),
      evs == null ? const [_Loading()] : evs.isEmpty ? [_empty(c)] : dayRows(c, store, focus, evs, slots, now),
    );
  }

  Widget _month(BuildContext c) {
    final t = Tok.of(c), now = DateTime.now(), today = dayOf(now);
    final m = DateTime(focus.year, focus.month);
    final last = DateTime(m.year, m.month + 1, 0);
    final names = l10n(c).weekdays.split(','), cols = Look.days;
    final weeks = [for (var w = Look.weekOf(m); !w.isAfter(last); w = DateTime(w.year, w.month, w.day + 7)) w];
    final (bar, rows) = _list(c, now);
    final fixed = <Widget>[
      Hero2(
        big: '${m.month}',
        title: DateFormat.LLLL(loc(c)).format(m),
        caption: '${m.year}',
        onMove: (d) {
          final n = DateTime(m.year, m.month + d);
          go(n.year == today.year && n.month == today.month ? today : n, 1);
        },
      ),
      Padding(
        padding: const EdgeInsets.fromLTRB(16, 6, 16, 0),
        child: Row(children: [
          if (Look.weekNumbers) const SizedBox(width: 24),
          for (final wd in cols)
            Expanded(child: Center(child: Text(names[wd - 1], style: T.labelSm(t.secondary).copyWith(fontSize: 10, letterSpacing: 1.4)))),
        ]),
      ),
      Padding(
        padding: const EdgeInsets.fromLTRB(16, 6, 16, 12),
        child: Column(spacing: 2, children: [
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
                    final evs = store.on(d) ?? const <Ev>[];
                    return GestureDetector(
                      onTap: () => _pick(d),
                      behavior: HitTestBehavior.opaque,
                      child: Padding(
                        padding: const EdgeInsets.only(top: 5, bottom: 6),
                        child: Column(spacing: 9, children: [
                          dayNum(c, d, sel: d == focus, out: d.month != m.month, hol: evs.any(_holiday)),
                          DayStrip(slotsOf(d, evs), now),
                        ]),
                      ),
                    );
                  }),
                ),
            ]),
        ]),
      ),
      bar,
    ];
    return LayoutBuilder(builder: (c, box) {
      // The grid stays put and only the list scrolls; on short screens everything scrolls together.
      if (box.maxHeight < 360 + 59.0 * weeks.length) return ListView(children: [...fixed, ...rows, const SizedBox(height: 54)]);
      return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        ...fixed,
        Expanded(child: ListView(padding: const EdgeInsets.only(bottom: 54), children: rows)),
      ]);
    });
  }

  List<Widget> _week(BuildContext c) {
    final l = l10n(c), now = DateTime.now();
    final first = Look.weekOf(focus), lastDay = DateTime(first.year, first.month, first.day + 6);
    final days = [for (final wd in Look.days) DateTime(first.year, first.month, first.day + Look.col(wd))];
    final perDay = [for (final d in days) store.on(d) ?? const <Ev>[]];
    final slots = [for (final (i, d) in days.indexed) slotsOf(d, perDay[i])];
    final hol = [for (final evs in perDay) evs.any(_holiday)];
    final f = DateFormat('dd.MM', loc(c));
    final week = isoWeek(DateTime(first.year, first.month, first.day + Look.col(DateTime.monday)));
    final (bar, rows) = _list(c, now);
    return [
      SliverToBoxAdapter(
        child: Hero2(
          big: '$week',
          title: l.weekN(week),
          caption: '${f.format(first)}–${f.format(lastDay)}',
          onMove: (d) => go(DateTime(focus.year, focus.month, focus.day + 7 * d), 2),
        ),
      ),
      SliverPersistentHeader(pinned: true, delegate: _Pinned(76, WeekDays(days: days, hol: hol, sel: focus, onTap: _pick))),
      SliverToBoxAdapter(
        child: WeekGrid(days: days, slots: slots, hol: hol, hours: hourRange(slots.expand((s) => s)), sel: focus, onTap: _pick),
      ),
      const SliverToBoxAdapter(child: SizedBox(height: 14)),
      SliverPersistentHeader(pinned: true, delegate: _Pinned(41, bar)),
      SliverList.list(children: rows),
    ];
  }

  List<Widget> _day(BuildContext c) {
    final t = Tok.of(c), l = l10n(c), now = DateTime.now();
    final evs = store.on(focus);
    final all = (evs ?? const <Ev>[]).where((e) => e.allDay).toList();
    final slots = slotsOf(focus, evs ?? const []);
    final coll = slots.where((x) => x.coll).length;
    final next = evs != null && slots.isEmpty ? _nextAfter(focus) : null;
    final right = <(String, Color?)>[
      if (coll > 0) (l.clashesN(coll), t.warning),
      if (focus == dayOf(now)) (l.moreN(slots.where((x) => x.e.end.isAfter(now)).length), null),
      if (next != null) ('${l.next} · ${l.weekdays.split(',')[next.start.weekday - 1]} ${hm(c, next.start)}', null),
    ];
    return [
      SliverToBoxAdapter(
        child: Hero2(
          big: '${focus.day}',
          title: DateFormat.EEEE(loc(c)).format(focus),
          caption: DateFormat('LLLL y', loc(c)).format(focus),
          onMove: (d) => go(DateTime(focus.year, focus.month, focus.day + d), 3),
        ),
      ),
      SliverList.list(children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 2, 24, 10),
          child: Row(spacing: 10, children: [Lbl(l.eventsN(slots.length)), Expanded(child: counts(c, right))]),
        ),
        for (final (i, e) in all.indexed)
          GestureDetector(
            onTap: () => openEvent(c, e, store),
            child: Container(
              margin: EdgeInsets.fromLTRB(24, 0, 24, i == all.length - 1 ? 26 : 8),
              height: 28,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(border: Border.all(color: t.borderSubtle), borderRadius: BorderRadius.circular(8)),
              child: Row(spacing: 10, children: [
                Marker(store.cal(e.calId)?.shape ?? Shape.dot),
                Expanded(child: Text(e.title, maxLines: 1, overflow: TextOverflow.ellipsis, style: T.caption(t.display).copyWith(letterSpacing: 1.2))),
                Lbl(_holiday(e) ? l.holiday : l.allDay),
              ]),
            ),
          ),
        if (all.isEmpty) const SizedBox(height: 16),
        if (evs == null)
          const _Loading()
        else
          DayTimeline(
            day: focus,
            slots: slots,
            store: store,
            off: focus.weekday >= 6 || all.any(_holiday),
            onAdd: store.signedIn && store.writable.isNotEmpty
                ? () => Navigator.push(c, MaterialPageRoute(builder: (_) => EventEdit(store, day: focus)))
                : null,
          ),
      ]),
    ];
  }

  /// First timed event after [d] within a month, for "Next · Mon 08:30" on an empty day.
  Ev? _nextAfter(DateTime d) {
    for (var i = 1; i <= 31; i++) {
      final evs = store.on(DateTime(d.year, d.month, d.day + i));
      if (evs == null) return null;
      if (evs.where((e) => !e.allDay).firstOrNull case final e?) return e;
    }
    return null;
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
      SliverToBoxAdapter(child: Hero2(big: '$y', caption: l.year, onMove: (d) => go(DateTime(y + d), 0))),
      SliverPadding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        sliver: SliverList.list(children: [
          for (var r = 0; r < 4; r++)
            Padding(
              padding: EdgeInsets.only(top: r == 0 ? 8 : 24),
              child: Row(crossAxisAlignment: CrossAxisAlignment.start, spacing: 24, children: [
                for (var m = r * 3 + 1; m <= r * 3 + 3; m++) Expanded(child: month(m)),
              ]),
            ),
        ]),
      ),
    ];
  }

  Widget _empty(BuildContext c) =>
      Padding(padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 28), child: Lbl(l10n(c).noEvents));
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

/// Header that stays at the top while the week scrolls (.dayrow, .listbar.stick).
class _Pinned extends SliverPersistentHeaderDelegate {
  _Pinned(this.height, this.child);
  final double height;
  final Widget child;
  @override
  double get minExtent => height;
  @override
  double get maxExtent => height;
  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) =>
      SizedBox.expand(child: ColoredBox(color: Tok.of(context).bg, child: child));
  @override
  bool shouldRebuild(_Pinned old) => true;
}
