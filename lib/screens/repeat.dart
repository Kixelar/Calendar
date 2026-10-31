import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../rrule.dart';
import '../theme.dart';
import '../ui.dart';

/// 03.3: every N days/weeks/months/years, weekdays for weekly rules, end never / on a date / after N times.
/// Pops the edited [Rule] on "Done".
class CustomRepeat extends StatefulWidget {
  const CustomRepeat({super.key, required this.rule, required this.start});
  final Rule rule;
  final DateTime start; // the event's first day: default weekday and earliest end date
  @override
  State<CustomRepeat> createState() => _CustomRepeatState();
}

enum _End { never, date, count }

class _CustomRepeatState extends State<CustomRepeat> {
  late Rule r = widget.rule;
  late _End end = r.until != null ? _End.date : r.count != null ? _End.count : _End.never;
  late DateTime until = r.until ?? DateTime(widget.start.year, 12, 31);
  late int count = r.count ?? 10;

  Rule get _result => Rule(r.freq,
      interval: r.interval,
      days: r.freq == Freq.weekly ? (r.days.isEmpty ? {widget.start.weekday} : r.days) : const {},
      until: end == _End.date ? until : null,
      count: end == _End.count ? count : null,
      extra: r.extra);

  Widget _round(BuildContext c, IconData icon, String label, VoidCallback? onTap) {
    final t = Tok.of(c);
    return Semantics(
      button: true,
      label: label,
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: t.borderControl)),
          child: Icon(icon, size: 20, color: onTap == null ? t.disabled : t.display),
        ),
      ),
    );
  }

  Future<void> _pickUntil() async {
    final p = await showDatePicker(context: context, initialDate: until, firstDate: widget.start, lastDate: DateTime(2100));
    if (p != null) setState(() => until = p);
  }

  Future<void> _pickCount() async {
    final p = await pick<int>(context, Pick(
      title: l10n(context).after,
      options: [for (final n in [2, 3, 4, 5, 6, 8, 10, 12, 15, 20, 26, 30, 52]) (n, l10n(context).afterTimes(n))],
      selected: count,
    ));
    if (p != null) setState(() => count = p.$1);
  }

  @override
  Widget build(BuildContext context) {
    final t = Tok.of(context), l = l10n(context);
    final units = [(Freq.daily, l.unitDays), (Freq.weekly, l.unitWeeks), (Freq.monthly, l.unitMonths), (Freq.yearly, l.unitYears)];
    final names = l.weekdays.split(','), full = l.weekdaysAcc.split(',');
    final days = _result.days;
    Widget radio(_End v, String label, {String? value, VoidCallback? onValue}) => RowItem(
          onTap: () {
            setState(() => end = v);
            onValue?.call(); // choosing "on date" / "after" opens its value picker right away
          },
          children: [
            Icon(v == end ? Icons.radio_button_checked : Icons.radio_button_unchecked, size: 24, color: v == end ? t.display : t.borderControl),
            Expanded(child: Text(label)),
            if (value != null) Lbl(value),
          ],
        );
    return Scaffold(
      body: SafeArea(
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          BackBar(label: l.event, actions: [
            TextButton(onPressed: () => Navigator.pop(context, _result), child: Text(l.done.toUpperCase(), style: T.labelMd(t.display))),
          ]),
          Expanded(
            child: ListView(padding: const EdgeInsets.fromLTRB(24, 24, 24, 24), children: [
              Lbl(l.repeat),
              const SizedBox(height: 8),
              Text(l.custom, style: T.headlineLg(t.display)),
              Section(left: l.every, children: [
                const SizedBox(height: 16),
                Row(spacing: 16, children: [
                  _round(context, Icons.remove, l.less, r.interval > 1 ? () => setState(() => r = r.copyWith(interval: r.interval - 1)) : null),
                  Semantics(liveRegion: true, child: Text('${r.interval}', style: T.displayLg(t.display))),
                  _round(context, Icons.add, l.more, r.interval < 99 ? () => setState(() => r = r.copyWith(interval: r.interval + 1)) : null),
                ]),
                const SizedBox(height: 16),
                // Segmented unit choice (.seg)
                Container(
                  height: 40,
                  padding: const EdgeInsets.all(3),
                  decoration: ShapeDecoration(shape: StadiumBorder(side: BorderSide(color: t.borderControl))),
                  child: Row(children: [
                    for (final (f, label) in units)
                      Expanded(
                        child: Semantics(
                          selected: f == r.freq,
                          button: true,
                          child: InkWell(
                            onTap: () => setState(() => r = r.copyWith(freq: f)),
                            customBorder: const StadiumBorder(),
                            child: Container(
                              alignment: Alignment.center,
                              decoration: ShapeDecoration(color: f == r.freq ? t.display : null, shape: const StadiumBorder()),
                              child: Text(label.toUpperCase(), style: T.labelSm(f == r.freq ? t.bg : t.secondary)),
                            ),
                          ),
                        ),
                      ),
                  ]),
                ),
              ]),
              if (r.freq == Freq.weekly)
                Section(left: l.onDays, children: [
                  const SizedBox(height: 16),
                  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                    for (var d = 1; d <= 7; d++)
                      Semantics(
                        button: true,
                        selected: days.contains(d),
                        label: full[d - 1],
                        child: InkWell(
                          customBorder: const CircleBorder(),
                          onTap: () => setState(() {
                            final next = {...days};
                            // At least one weekday stays selected.
                            if (!next.remove(d)) next.add(d);
                            if (next.isNotEmpty) r = r.copyWith(days: next);
                          }),
                          child: Container(
                            width: 40,
                            height: 40,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: days.contains(d) ? t.display : null,
                              border: Border.all(color: days.contains(d) ? t.display : t.borderControl),
                            ),
                            child: ExcludeSemantics(child: Text(names[d - 1], style: T.labelSm(days.contains(d) ? t.bg : t.primary))),
                          ),
                        ),
                      ),
                  ]),
                ]),
              Section(left: l.ends, children: [
                radio(_End.never, l.never),
                radio(_End.date, l.onDate, value: DateFormat.yMMMd(loc(context)).format(until).replaceAll('.', ''), onValue: _pickUntil),
                radio(_End.count, l.after, value: l.afterTimes(count), onValue: _pickCount),
              ]),
              Container(
                margin: const EdgeInsets.only(top: 32),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: t.surface, border: Border.all(color: t.borderSubtle), borderRadius: BorderRadius.circular(8)),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, spacing: 8, children: [
                  Lbl(l.summary),
                  Text(_result.describe(l, loc(context)), style: T.body(t.display)),
                ]),
              ),
            ]),
          ),
        ]),
      ),
    );
  }
}
