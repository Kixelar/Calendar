import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../google.dart';
import '../store.dart';
import '../theme.dart';
import '../ui.dart';
import '../view.dart';

/// Building blocks of the month, week and day views from the 2026-11-01 mockup (docs/design/views.html).

/// A timed event placed on one day, in minutes from midnight, with the mockup's overlap flags.
class Slot {
  Slot(this.e, this.s, this.end);
  final Ev e;
  final int s, end;
  bool coll = false; // starts while an earlier event is still on: drawn yellow
  bool base = false; // a later event starts inside it
}

/// Timed events of [day], sorted, clipped to the day and flagged like the mockup's build().
List<Slot> slotsOf(DateTime day, List<Ev> evs) {
  int min(DateTime t) => t.isBefore(day) ? 0 : dayOf(t) == day ? t.hour * 60 + t.minute : 1440;
  final out = [for (final e in evs) if (!e.allDay) Slot(e, min(e.start), math.max(min(e.end), min(e.start)))]
    ..sort((a, b) => a.s != b.s ? a.s - b.s : a.end - b.end);
  for (var k = 0; k < out.length; k++) {
    out[k].coll = out.take(k).any((y) => y.end > out[k].s);
  }
  for (final x in out) {
    x.base = !x.coll && out.any((y) => y != x && y.s > x.s && y.s < x.end);
  }
  return out;
}

/// Hours shown by the week grid and day axis: 08–22, widened to fit earlier or later events.
(int, int) hourRange(Iterable<Slot> xs) => xs.isEmpty
    ? (8, 22)
    : (math.min(8, xs.map((x) => x.s).reduce(math.min) ~/ 60), math.max(22, (xs.map((x) => x.end).reduce(math.max) / 60).ceil()));

bool pastEv(Ev e, DateTime now) => Look.dimPast && !e.allDay && !e.end.isAfter(now);

/// Fill of an event in the month strip and week grid: white, grey when past, yellow when it clashes.
Color fillOf(Tok t, Slot x, DateTime now) {
  final past = pastEv(x.e, now);
  return x.coll ? (past ? t.warning.withValues(alpha: .6) : t.warning) : (past ? t.disabled : t.display);
}

String hourLabel(int h) => Look.use24h ? '${h % 24}'.padLeft(2, '0') : '${h % 12 == 0 ? 12 : h % 12}${h % 24 < 12 ? 'AM' : 'PM'}';

/// "In 12 min", "In 1 h 5 min".
String soonText(BuildContext c, int mins) {
  final l = l10n(c);
  if (mins < 60) return l.inMin(mins);
  return mins % 60 == 0 ? l.inH(mins ~/ 60) : l.inHM(mins ~/ 60, mins % 60);
}

/// Minutes until [e] starts, rounded up.
int minsTo(Ev e, DateTime now) => (e.start.difference(now).inSeconds + 59) ~/ 60;

/// Day number circle (.d / .mn): red today, white when selected, ring on holidays.
Widget dayNum(BuildContext c, DateTime d, {required bool sel, bool out = false, bool hol = false}) {
  final t = Tok.of(c), today = dayOf(DateTime.now());
  final isToday = d == today;
  return Container(
    width: 34,
    height: 34,
    alignment: Alignment.center,
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      color: sel ? t.display : isToday ? t.accent : null,
      border: Border.all(color: sel ? t.display : hol && !isToday ? t.borderControl : Colors.transparent),
    ),
    child: Text('${d.day}',
        style: T.displayMd(sel ? t.bg : isToday ? Colors.white : out ? t.dotOff : Look.dimPast && d.isBefore(today) ? t.disabled : t.display)),
  );
}

/// Thin bar under a month day: where its events fall between 08:00 and 22:00 (.strip).
class DayStrip extends StatelessWidget {
  const DayStrip(this.slots, this.now, {super.key});
  final List<Slot> slots;
  final DateTime now;
  @override
  Widget build(BuildContext context) {
    final t = Tok.of(context);
    return FractionallySizedBox(
      widthFactor: .78,
      child: Container(
        height: 3,
        decoration: BoxDecoration(color: t.borderSubtle, borderRadius: BorderRadius.circular(2)),
        clipBehavior: Clip.antiAlias,
        child: LayoutBuilder(builder: (c, box) {
          final w = box.maxWidth;
          return Stack(children: [
            for (final x in slots)
              if (_span(x) case (final a, final b))
                Positioned(left: (a - 480) / 840 * w, width: math.max((b - a) / 840, .05) * w, top: 0, bottom: 0, child: ColoredBox(color: fillOf(t, x, now))),
          ]);
        }),
      ),
    );
  }

  // Events outside 08–22 show as a stub at the matching end.
  (int, int) _span(Slot x) {
    final a = math.max(x.s, 480), b = math.min(x.end, 1320);
    if (b > a) return (a, b);
    return x.end <= 480 ? (480, 500) : (1300, 1320);
  }
}

/// Header line above a day's list (.listbar): "Today · Friday" and "2 clashes · 5 more".
class ListBar extends StatelessWidget {
  const ListBar(this.left, this.right, {super.key});
  final String left;
  final List<(String, Color?)> right;
  @override
  Widget build(BuildContext context) {
    final t = Tok.of(context);
    return Container(
      height: 41,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(color: t.bg, border: Border.symmetric(horizontal: BorderSide(color: t.borderSubtle))),
      child: Row(spacing: 10, children: [
        Lbl(left, color: t.display),
        Expanded(child: counts(context, right)),
      ]),
    );
  }
}

/// Small grey parts joined with " · ", each in its own colour when given.
Widget counts(BuildContext c, List<(String, Color?)> parts) => Text.rich(
      TextSpan(children: [
        for (final (i, (s, col)) in parts.indexed) ...[
          if (i > 0) const TextSpan(text: ' · '),
          TextSpan(text: s.toUpperCase(), style: col == null ? null : TextStyle(color: col)),
        ],
      ]),
      style: T.labelSm(Tok.of(c).secondary),
      textAlign: TextAlign.right,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );

/// Right side of a day's header: clashes in yellow, then "N more" today or the event count.
List<(String, Color?)> dayCounts(BuildContext c, DateTime day, List<Slot> slots, DateTime now) {
  final t = Tok.of(c), l = l10n(c);
  final coll = slots.where((x) => x.coll).length;
  return [
    if (coll > 0) (l.clashesN(coll), t.warning),
    if (day == dayOf(now))
      (l.moreN(slots.where((x) => x.e.end.isAfter(now)).length), null)
    else if (slots.isNotEmpty)
      (l.eventsN(slots.length), null),
  ];
}

/// Event line in the month and week lists (.row): title over time, location or "in N min" on the right.
class DayRow extends StatelessWidget {
  const DayRow(this.e, this.store, {super.key, this.coll = false, this.soon});
  final Ev e;
  final Store store;
  final bool coll;
  final String? soon;
  @override
  Widget build(BuildContext context) {
    final t = Tok.of(context), l = l10n(context);
    final cal = store.cal(e.calId), hol = cal?.holiday ?? false;
    final dim = pastEv(e, DateTime.now()) ? .38 : 1.0;
    final time = e.allDay ? (hol ? l.holiday : l.allDay) : '${hm(context, e.start)}–${hm(context, e.end)}';
    final place = e.allDay ? null : e.location ?? cal?.name;
    return InkWell(
      onTap: () => openEvent(context, e, store),
      child: Container(
        constraints: const BoxConstraints(minHeight: 64),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(border: Border(bottom: BorderSide(color: t.borderSubtle))),
        child: Row(spacing: 14, children: [
          Opacity(opacity: dim, child: SizedBox(width: 14, child: Center(child: Marker(cal?.shape ?? Shape.dot)))),
          Expanded(
            child: Opacity(
              opacity: dim,
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, spacing: 3, children: [
                Text(e.title, maxLines: 1, overflow: TextOverflow.ellipsis, style: T.body(t.display).copyWith(fontSize: 18, height: 1.05)),
                Text(time, maxLines: 1, softWrap: false, style: T.caption(coll ? t.warning : t.primary).copyWith(fontSize: 11.5, letterSpacing: .9)),
              ]),
            ),
          ),
          if (soon != null)
            Lbl(soon!, color: t.accentText)
          else if (place != null && place.isNotEmpty)
            ConstrainedBox(constraints: const BoxConstraints(maxWidth: 110), child: Lbl(place)),
        ]),
      ),
    );
  }
}

/// Rows of one day for the month and week lists: all-day first, the next event today gets "in N min".
List<Widget> dayRows(BuildContext c, Store store, DateTime day, List<Ev> evs, List<Slot> slots, DateTime now) {
  final next = day == dayOf(now) ? slots.where((x) => x.e.start.isAfter(now)).firstOrNull : null;
  return [
    for (final e in evs.where((e) => e.allDay)) DayRow(e, store),
    for (final x in slots) DayRow(x.e, store, coll: x.coll, soon: x == next ? soonText(c, minsTo(x.e, now)) : null),
  ];
}

/// Hour-by-day grid of the week view (.grid): each cell shows which part of the hour is taken.
class WeekGrid extends StatelessWidget {
  const WeekGrid({super.key, required this.days, required this.slots, required this.hol, required this.hours, required this.sel, required this.onTap});
  final List<DateTime> days;
  final List<List<Slot>> slots;
  final List<bool> hol;
  final (int, int) hours;
  final DateTime sel;
  final ValueChanged<DateTime> onTap;

  @override
  Widget build(BuildContext context) {
    final t = Tok.of(context), now = DateTime.now(), today = dayOf(now);
    final nowMin = now.hour * 60 + now.minute;
    Widget cell(int i, int h) {
      final d = days[i], hs = h * 60, he = hs + 60;
      final inHour = slots[i].where((x) => x.s < he && x.end > hs).toList()..sort((a, b) => (a.coll ? 1 : 0) - (b.coll ? 1 : 0));
      final isToday = d == today, isSel = d == sel;
      // Border shades from the mockup: #222 normal, #3d3d3d selected column, #5a5a5a today, #8a8a8a both.
      final border = isToday && isSel
          ? t.display.withValues(alpha: .54)
          : isToday
              ? t.display.withValues(alpha: .35)
              : isSel
                  ? t.display.withValues(alpha: .24)
                  : t.borderSubtle;
      return GestureDetector(
        onTap: () => onTap(d),
        child: Container(
          decoration: BoxDecoration(
            color: Color.alphaBlend(t.display.withValues(alpha: .02), t.bg),
            border: Border.all(color: border),
            borderRadius: BorderRadius.circular(6),
          ),
          clipBehavior: Clip.antiAlias,
          child: CustomPaint(
            painter: hol[i] ? _Hatch(t.display.withValues(alpha: .18)) : null,
            child: LayoutBuilder(builder: (c, box) {
              final px = box.maxHeight / 60;
              return Stack(children: [
                for (final x in inHour)
                  Positioned(
                    left: 0,
                    right: 0,
                    top: (math.max(x.s, hs) - hs) * px,
                    height: math.max((math.min(x.end, he) - math.max(x.s, hs)) * px, 60 * px * .06),
                    child: ColoredBox(color: fillOf(t, x, now)),
                  ),
                if (isToday && nowMin >= hs && nowMin < he)
                  Positioned(left: 0, right: 0, top: (nowMin - hs) * px - 1, height: 2, child: ColoredBox(color: t.accent)),
              ]);
            }),
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 6, 14, 0),
      child: Column(spacing: 5, children: [
        for (var h = hours.$1; h < hours.$2; h++)
          SizedBox(
            height: 38,
            child: Row(crossAxisAlignment: CrossAxisAlignment.stretch, spacing: 5, children: [
              SizedBox(
                width: 26,
                child: FittedBox(fit: BoxFit.scaleDown, alignment: Alignment.topLeft, child: Text(hourLabel(h), style: T.labelSm(t.secondary).copyWith(fontSize: 10))),
              ),
              for (var i = 0; i < days.length; i++) Expanded(child: cell(i, h)),
            ]),
          ),
      ]),
    );
  }
}

/// Day names and numbers above the week grid (.dayrow).
class WeekDays extends StatelessWidget {
  const WeekDays({super.key, required this.days, required this.hol, required this.sel, required this.onTap});
  final List<DateTime> days;
  final List<bool> hol;
  final DateTime sel;
  final ValueChanged<DateTime> onTap;
  @override
  Widget build(BuildContext context) {
    final t = Tok.of(context), today = dayOf(DateTime.now()), names = l10n(context).weekdays.split(',');
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 14, 8),
      child: Row(crossAxisAlignment: CrossAxisAlignment.end, spacing: 5, children: [
        const SizedBox(width: 26),
        for (final (i, d) in days.indexed)
          Expanded(
            child: GestureDetector(
              onTap: () => onTap(d),
              behavior: HitTestBehavior.opaque,
              child: Column(mainAxisSize: MainAxisSize.min, spacing: 4, children: [
                Text(names[d.weekday - 1],
                    style: T.labelSm(d == today && d != sel ? t.accentText : Look.dimPast && d.isBefore(today) ? t.disabled : t.display)
                        .copyWith(fontSize: 9.5, letterSpacing: 1.1)),
                dayNum(context, d, sel: d == sel, hol: hol[i]),
              ]),
            ),
          ),
      ]),
    );
  }
}

/// Day view timeline (.tl): hour lines, event cards side by side when they overlap, free time and the now line.
class DayTimeline extends StatelessWidget {
  const DayTimeline({super.key, required this.day, required this.slots, required this.store, required this.off, this.onAdd});
  final DateTime day;
  final List<Slot> slots;
  final Store store;
  final bool off; // weekend or holiday: the empty state says "day off"
  final VoidCallback? onAdd;

  static const hh = 56.0, gut = 68.0, right = 24.0;

  @override
  Widget build(BuildContext context) {
    final t = Tok.of(context), l = l10n(context), now = DateTime.now(), today = dayOf(now);
    final (h0, h1) = hourRange(slots);
    final nowMin = now.hour * 60 + now.minute, isToday = day == today;
    double y(int min) => (min - h0 * 60) * hh / 60;
    double ht(Slot x) => math.max((x.end - x.s) * hh / 60 - 3, 26);
    final height = (h1 - h0) * hh;
    final lab = T.labelSm(t.secondary).copyWith(fontSize: 10.5);

    return LayoutBuilder(builder: (context, box) {
      final span = box.maxWidth - gut - right;
      final kids = <Widget>[];
      for (var h = h0; h <= h1; h++) {
        kids
          ..add(Positioned(top: y(h * 60), left: gut, right: right, height: 1, child: ColoredBox(color: t.borderSubtle)))
          ..add(Positioned(top: y(h * 60) - 7, left: 24, width: gut - 28, height: 14, child: Align(alignment: Alignment.centerLeft, child: Text(hourLabel(h), style: lab))));
      }

      // Free time of 30 min or more between events: dotted line and its length.
      int? maxEnd;
      var maxBot = 0.0;
      for (final x in slots) {
        if (maxEnd != null && x.s - maxEnd >= 30) {
          final top0 = math.max(y(maxEnd), maxBot), end0 = y(x.s) + 1;
          final past = day.isBefore(today) || (isToday && x.s <= nowMin);
          if (isToday && maxEnd <= nowMin && nowMin < x.s) {
            kids.add(_gap(top0, math.max(y(nowMin) - top0 - 4, 2), t.accent));
            if (end0 - y(nowMin) > 8) kids.add(_gap(y(nowMin) + 4, end0 - y(nowMin) - 4, t.disabled));
          } else {
            kids.add(_gap(top0, math.max(end0 - top0, 4), past ? t.borderSubtle : t.disabled));
            if (y(x.s) - top0 >= 14) {
              kids.add(Positioned(
                top: (top0 + y(x.s)) / 2 - 6,
                left: gut,
                child: Text(_free(context, x.s - maxEnd), style: T.labelSm(past ? t.dotOff : t.display)),
              ));
            }
          }
        }
        maxEnd = maxEnd == null ? x.end : math.max(maxEnd, x.end);
        maxBot = math.max(maxBot, y(x.s) + 1 + ht(x));
      }

      // Cards: overlapping events share the width in columns.
      final groups = <List<Slot>>[];
      var groupEnd = -1;
      for (final x in slots) {
        if (x.s >= groupEnd) groups.add([]);
        groups.last.add(x);
        groupEnd = math.max(groupEnd, x.end);
      }
      for (final g in groups) {
        final colEnds = <int>[], cols = <Slot, int>{};
        for (final x in g) {
          var c = 0;
          while (c < colEnds.length && colEnds[c] > x.s) {
            c++;
          }
          if (c == colEnds.length) colEnds.add(0);
          colEnds[c] = x.end;
          cols[x] = c;
        }
        final n = colEnds.length;
        for (final x in g) {
          final c = cols[x]!;
          kids.add(Positioned(
            top: y(x.s) + 1,
            height: ht(x),
            left: gut + span * c / n,
            width: span / n - (c < n - 1 ? 4 : 0),
            child: _Card(x, store, n: n, now: now),
          ));
        }
      }

      if (slots.isEmpty) {
        kids.add(_gap(2, height - 4, t.disabled));
        if (!off) kids.add(Positioned(top: height / 2 - 6, left: gut, child: Text(l.hoursFree(h1 - h0).toUpperCase(), style: T.labelSm(t.display))));
        kids.add(Positioned(
          top: height / 2 - 70,
          left: gut,
          right: right,
          child: FractionalTranslation(
            translation: const Offset(0, -.5),
            child: Column(mainAxisSize: MainAxisSize.min, spacing: 14, children: [
              Container(
                color: t.bg,
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: Column(mainAxisSize: MainAxisSize.min, spacing: 4, children: [
                  Text(l.nothingPlanned, textAlign: TextAlign.center, style: T.headlineMd(t.display).copyWith(fontSize: 22, height: 1.1)),
                  if (off) Text(l.dayOff, textAlign: TextAlign.center, style: T.bodySm(t.secondary)),
                ]),
              ),
              if (onAdd != null)
                IntrinsicWidth(
                  child: DecoratedBox(
                    decoration: ShapeDecoration(color: t.bg, shape: const StadiumBorder()),
                    child: Btn(l.addEvent, kind: BtnKind.secondary, icon: Icons.add, onTap: onAdd),
                  ),
                ),
            ]),
          ),
        ));
      }

      if (isToday && nowMin >= h0 * 60 && nowMin < h1 * 60) {
        final next = slots.where((x) => x.e.start.isAfter(now)).firstOrNull;
        final red = T.labelSm(t.accentText).copyWith(fontSize: 11.5);
        kids.add(Positioned(
          top: y(nowMin) - 8,
          left: gut - 8,
          right: right,
          height: 16,
          child: Row(children: [
            Container(width: 8, height: 8, decoration: BoxDecoration(color: t.accent, shape: BoxShape.circle)),
            Container(width: 8, height: 1, color: t.accent),
            Container(color: t.bg, padding: const EdgeInsets.symmetric(horizontal: 4), child: monoCentred(Text(hmShort(context, now), style: red), 11.5)),
            Expanded(child: Container(height: 1, color: t.accent)),
            if (next != null)
              Container(
                color: t.bg,
                padding: const EdgeInsets.only(left: 4),
                child: monoCentred(Text(soonText(context, minsTo(next.e, now)).toUpperCase(), style: red), 11.5),
              ),
          ]),
        ));
      }
      return SizedBox(height: height, child: Stack(clipBehavior: Clip.none, children: kids));
    });
  }

  Widget _gap(double top, double h, Color c) =>
      Positioned(top: top, height: h, left: gut - 8, width: 2, child: CustomPaint(painter: _Dots(c)));

  String _free(BuildContext c, int min) =>
      min < 60 ? '$min MIN' : '${NumberFormat('0.#', loc(c)).format(min / 60)}H';
}

/// Event card in the day timeline (.card): solid white or yellow when it overlaps, grey once past.
class _Card extends StatelessWidget {
  const _Card(this.x, this.store, {required this.n, required this.now});
  final Slot x;
  final Store store;
  final int n;
  final DateTime now;
  @override
  Widget build(BuildContext context) {
    final t = Tok.of(context), e = x.e, cal = store.cal(e.calId);
    final past = pastEv(e, now), solid = x.coll || (x.base && n > 1);
    final compact = (x.end - x.s) * DayTimeline.hh / 60 - 3 < 29;
    final Color bg, fg, sub;
    if (solid) {
      bg = x.coll ? (past ? t.warning.withValues(alpha: .6) : t.warning) : (past ? t.disabled : t.display);
      fg = t.bg;
      sub = t.bg.withValues(alpha: .7);
    } else {
      bg = past ? t.bg : t.surfaceRaised;
      fg = past ? t.secondary : t.display;
      sub = past ? t.disabled : t.primary.withValues(alpha: .8);
    }
    final title = Text(e.title,
        maxLines: n > 1 && !compact ? 2 : 1,
        overflow: TextOverflow.ellipsis,
        style: T.body(fg).copyWith(fontSize: compact ? 14 : 15, height: 1.05));
    final time = Text('${hm(context, e.start)}–${hm(context, e.end)}',
        maxLines: 1, softWrap: false, overflow: TextOverflow.clip, style: T.caption(sub).copyWith(fontSize: 10.5, height: 1.1, letterSpacing: n > 1 ? .3 : 1));
    return GestureDetector(
      onTap: () => openEvent(context, e, store),
      child: Container(
        padding: n > 1 ? const EdgeInsets.fromLTRB(10, 0, 9, 0) : const EdgeInsets.fromLTRB(13, 0, 11, 0),
        decoration: BoxDecoration(
          color: bg,
          border: Border.all(color: !solid && past ? t.display.withValues(alpha: .17) : Colors.transparent),
          borderRadius: BorderRadius.circular(8),
        ),
        clipBehavior: Clip.antiAlias,
        child: Row(spacing: n > 1 ? 7 : 9, children: [
          Opacity(opacity: past && !solid ? .55 : 1, child: Marker(cal?.shape ?? Shape.dot, color: solid ? t.bg : null)),
          Expanded(
            child: compact
                ? Row(spacing: 10, children: [Flexible(child: title), time])
                : Column(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.start, spacing: 1, children: [title, time]),
          ),
          if (n == 1 && !compact && (e.location?.isNotEmpty ?? false))
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 110),
              child: Text(e.location!.toUpperCase(), maxLines: 1, overflow: TextOverflow.ellipsis, style: T.labelSm(solid ? sub : t.secondary).copyWith(fontSize: 10)),
            ),
        ]),
      ),
    );
  }
}

/// Vertical dotted line of free time (.gap).
class _Dots extends CustomPainter {
  _Dots(this.color);
  final Color color;
  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()..color = color;
    for (var y = 0.0; y < size.height; y += 4) {
      canvas.drawRect(Rect.fromLTWH(0, y, 2, 2), p);
    }
  }

  @override
  bool shouldRepaint(_Dots old) => old.color != color;
}

/// Diagonal hatching of holiday cells in the week grid (.cell.hol).
class _Hatch extends CustomPainter {
  _Hatch(this.color);
  final Color color;
  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()
      ..color = color
      ..strokeWidth = 1;
    for (var x = -size.height; x < size.width; x += 5) {
      canvas.drawLine(Offset(x, size.height), Offset(x + size.height, 0), p);
    }
  }

  @override
  bool shouldRepaint(_Hatch old) => old.color != color;
}
