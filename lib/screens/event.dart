import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../google.dart';
import '../l10n/app_localizations.dart';
import '../store.dart';
import '../theme.dart';
import '../ui.dart';

/// Mockup screens 03.1 (event details), 03.2 (new / edit event) and 06.2 (delete dialog).

String reminderText(AppLocalizations l, int? m) => switch (m) {
      null => l.none,
      final m when m > 0 && m % 1440 == 0 => l.daysBefore(m ~/ 1440),
      final m when m > 0 && m % 60 == 0 => l.hoursBefore(m ~/ 60),
      final m => l.minBefore(m),
    };

/// "PT 30" style short day, as in the details screen's back link.
String shortDay(BuildContext c, DateTime d) => '${l10n(c).weekdays.split(',')[d.weekday - 1]} ${d.day}';

const _scrim = Color(0xA3000000); // rgba(0,0,0,.64) from the mockup's .scrim

Widget _dialog(BuildContext c, List<Widget> children) {
  final t = Tok.of(c);
  return Dialog(
    backgroundColor: t.surfaceRaised,
    insetPadding: const EdgeInsets.symmetric(horizontal: 24),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8), side: BorderSide(color: t.borderSubtle)),
    child: Padding(
      padding: const EdgeInsets.all(24),
      child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, spacing: 16, children: children),
    ),
  );
}

void _fail(BuildContext c, Object e) =>
    ScaffoldMessenger.of(c).showSnackBar(SnackBar(content: Text(l10n(c).failed('$e'))));

class EventDetails extends StatelessWidget {
  const EventDetails(this.e, this.store, {super.key});
  final Ev e;
  final Store store;

  @override
  Widget build(BuildContext context) {
    final t = Tok.of(context), l = l10n(context), now = DateTime.now();
    final cal = store.cal(e.calId);
    final writable = cal?.writable ?? false;
    final canEdit = writable && e.organizer; // invitations from others are edited by their organizer
    final soon = (e.start.difference(now).inSeconds + 59) ~/ 60;
    final meta = [?cal?.name, if (!e.allDay && e.start.isAfter(now) && soon <= 60) l.inMin(soon)].join(' · ');
    Color rsvpColor(String s) => switch (s) { 'accepted' => t.success, 'tentative' => t.warning, _ => t.secondary };
    String rsvp(String s) => switch (s) { 'accepted' => l.rsvpYes, 'tentative' => l.rsvpMaybe, 'declined' => l.rsvpNo, _ => l.rsvpWaiting };
    return Scaffold(
      body: SafeArea(
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          BackBar(label: shortDay(context, e.start)),
          Expanded(
            child: ListView(padding: const EdgeInsets.fromLTRB(24, 0, 24, 24), children: [
              Padding(
                padding: const EdgeInsets.only(top: 24),
                child: SizedBox(
                  height: 56,
                  child: Row(crossAxisAlignment: CrossAxisAlignment.end, spacing: 12, children: [
                    Text(e.allDay ? '${e.start.day}' : hm(context, e.start), style: T.displayXl(t.display)),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: Text((e.allDay ? l.allDay : '— ${hm(context, e.end)}').toUpperCase(), style: T.labelMd(t.secondary)),
                    ),
                  ]),
                ),
              ),
              const SizedBox(height: 16),
              Text(e.title, style: T.headlineLg(t.display)),
              const SizedBox(height: 8),
              Row(spacing: 8, children: [Marker(cal?.shape ?? Shape.dot), Expanded(child: Lbl(meta))]),
              Group(children: [
                if (e.location?.isNotEmpty ?? false) ValueRow(l.place, value: e.location),
                ValueRow(l.reminder, value: reminderText(l, e.reminder)),
              ]),
              if (e.notes?.isNotEmpty ?? false)
                Section(left: l.notes, children: [
                  Padding(padding: const EdgeInsets.symmetric(vertical: 16), child: Text(e.notes!, style: T.body(t.primary))),
                ]),
              if (e.guests.isNotEmpty)
                Section(left: l.guests, right: e.organizer ? l.youOrganize : null, children: [
                  for (final g in e.guests)
                    RowItem(children: [
                      _Avatar(g.name),
                      Expanded(child: Text(g.name, maxLines: 1, overflow: TextOverflow.ellipsis)),
                      Lbl(rsvp(g.status), color: rsvpColor(g.status)),
                    ]),
                ]),
            ]),
          ),
          if (writable)
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
              child: Row(spacing: 8, children: [
                if (canEdit)
                  Expanded(
                    child: Btn(l.edit, kind: BtnKind.secondary, onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => EventEdit(store, ev: e)));
                    }),
                  ),
                Expanded(child: Btn(l.delete, kind: BtnKind.danger, onTap: () => _delete(context))),
              ]),
            ),
        ]),
      ),
    );
  }

  Future<void> _delete(BuildContext context) async {
    final r = await showDialog<(DeleteScope, bool)>(context: context, barrierColor: _scrim, builder: (_) => _DeleteDialog(e));
    if (r == null || !context.mounted) return;
    try {
      await store.delete(e, r.$1, notify: r.$2);
      if (context.mounted) Navigator.of(context).popUntil((r) => r.isFirst);
    } catch (err) {
      if (context.mounted) _fail(context, err);
    }
  }
}

class _Avatar extends StatelessWidget {
  const _Avatar(this.name);
  final String name;
  @override
  Widget build(BuildContext context) {
    final t = Tok.of(context);
    final words = name.split(RegExp(r'[\s@.]+')).where((w) => w.isNotEmpty).take(2);
    return Container(
      width: 36,
      height: 36,
      alignment: Alignment.center,
      decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: t.borderControl)),
      child: Text(words.map((w) => w[0]).join().toUpperCase(), style: T.labelSm(t.display)),
    );
  }
}

/// 06.2: scope choice only for repeating events, "notify guests" only when there are guests.
class _DeleteDialog extends StatefulWidget {
  const _DeleteDialog(this.e);
  final Ev e;
  @override
  State<_DeleteDialog> createState() => _DeleteDialogState();
}

class _DeleteDialogState extends State<_DeleteDialog> {
  DeleteScope scope = DeleteScope.one;
  bool notify = true;

  @override
  Widget build(BuildContext context) {
    final t = Tok.of(context), l = l10n(context), e = widget.e;
    final repeating = e.recurringId != null;
    return _dialog(context, [
      Column(crossAxisAlignment: CrossAxisAlignment.start, spacing: 8, children: [
        Text(l.deleteTitle, style: T.headlineMd(t.display)),
        if (repeating) Text(l.repeats(e.title), style: T.bodySm(t.secondary)),
      ]),
      if (repeating || e.guests.isNotEmpty)
        Group(gap: 0, children: [
          if (repeating)
            for (final (s, label) in [(DeleteScope.one, l.onlyThis), (DeleteScope.following, l.thisAndFollowing), (DeleteScope.all, l.allOccurrences)])
              RowItem(onTap: () => setState(() => scope = s), children: [
                Icon(s == scope ? Icons.radio_button_checked : Icons.radio_button_unchecked,
                    size: 24, color: s == scope ? t.display : t.borderControl),
                Expanded(child: Text(label)),
              ]),
          if (e.guests.isNotEmpty)
            RowItem(border: false, children: [
              Expanded(child: Text(l.notifyGuests)),
              Toggle(value: notify, label: l.notifyGuests, onChanged: (v) => setState(() => notify = v)),
            ]),
        ]),
      Row(spacing: 8, children: [
        Expanded(child: Btn(l.cancel, kind: BtnKind.secondary, onTap: () => Navigator.pop(context))),
        Expanded(child: Btn(l.delete, kind: BtnKind.danger, onTap: () => Navigator.pop(context, (scope, notify)))),
      ]),
    ]);
  }
}

/// 03.2 new event, also used to edit [ev]. All-day ranges are edited with an inclusive last day.
class EventEdit extends StatefulWidget {
  const EventEdit(this.store, {super.key, this.ev, this.day});
  final Store store;
  final Ev? ev;
  final DateTime? day; // for a new event: the day it starts on
  @override
  State<EventEdit> createState() => _EventEditState();
}

class _EventEditState extends State<EventEdit> {
  late final _title = TextEditingController(text: widget.ev?.title);
  late bool allDay;
  late DateTime start, end;
  late String calId;
  String? place, notes;
  bool busy = false;

  @override
  void initState() {
    super.initState();
    final e = widget.ev;
    if (e != null) {
      allDay = e.allDay;
      start = e.start;
      end = e.allDay ? DateTime(e.end.year, e.end.month, e.end.day - 1) : e.end;
      calId = e.calId;
      place = e.location;
      notes = e.notes;
    } else {
      final now = DateTime.now(), d = widget.day ?? dayOf(now);
      allDay = false;
      start = d == dayOf(now) ? DateTime(d.year, d.month, d.day, now.hour + 1) : DateTime(d.year, d.month, d.day, 9);
      end = start.add(const Duration(hours: 1));
      calId = widget.store.writable.first.id;
    }
  }

  @override
  void dispose() {
    _title.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final l = l10n(context);
    final s = allDay ? dayOf(start) : start;
    final e = allDay ? DateTime(end.year, end.month, end.day + 1) : end;
    if (!e.isAfter(s)) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l.endBeforeStart)));
      return;
    }
    final old = widget.ev;
    setState(() => busy = true);
    try {
      await widget.store.save(
        Ev(_title.text.trim(), calId, s, e,
            id: old?.id ?? '', allDay: allDay, location: place, notes: notes, guests: old?.guests ?? const []),
        fromCal: old?.calId,
      );
      if (mounted) Navigator.of(context).popUntil((r) => r.isFirst);
    } catch (err) {
      if (mounted) {
        setState(() => busy = false);
        _fail(context, err);
      }
    }
  }

  // Moving the start keeps the duration, like most calendars.
  void _set(bool isStart, DateTime d) => setState(() {
        if (isStart) {
          end = d.add(end.difference(start));
          start = d;
        } else {
          end = d;
        }
      });

  Future<void> _pickDate(bool isStart) async {
    final d = isStart ? start : end;
    final p = await showDatePicker(context: context, initialDate: d, firstDate: DateTime(2000), lastDate: DateTime(2100));
    if (p != null) _set(isStart, DateTime(p.year, p.month, p.day, d.hour, d.minute));
  }

  Future<void> _pickTime(bool isStart) async {
    final d = isStart ? start : end;
    final p = await showTimePicker(context: context, initialTime: TimeOfDay.fromDateTime(d));
    if (p != null) _set(isStart, DateTime(d.year, d.month, d.day, p.hour, p.minute));
  }

  Future<String?> _ask(String title, String? value, {bool multi = false}) => showDialog<String>(
        context: context,
        barrierColor: _scrim,
        builder: (c) {
          final t = Tok.of(c), l = l10n(c);
          final ctl = TextEditingController(text: value);
          return _dialog(c, [
            Text(title, style: T.headlineMd(t.display)),
            TextField(
              controller: ctl,
              autofocus: true,
              minLines: 1,
              maxLines: multi ? 6 : 1,
              style: T.body(t.primary),
              cursorColor: t.display,
              decoration: InputDecoration(
                filled: true,
                fillColor: t.surface,
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 13),
                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(6), borderSide: BorderSide(color: t.borderControl)),
                focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(6), borderSide: BorderSide(color: t.display)),
              ),
            ),
            Row(spacing: 8, children: [
              Expanded(child: Btn(l.cancel, kind: BtnKind.secondary, onTap: () => Navigator.pop(c))),
              Expanded(child: Btn(l.done, onTap: () => Navigator.pop(c, ctl.text.trim()))),
            ]),
          ]);
        },
      );

  @override
  Widget build(BuildContext context) {
    final t = Tok.of(context), l = l10n(context), store = widget.store;
    final cal = store.cal(calId);
    Widget when(String label, DateTime d, bool isStart) => RowItem(children: [
          Expanded(child: Text(label)),
          InkWell(
            onTap: () => _pickDate(isStart),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Text(
                '${shortDay(context, d)} ${DateFormat.MMM(loc(context)).format(d)}'.replaceAll('.', '').toUpperCase(),
                style: T.labelMd(t.secondary),
              ),
            ),
          ),
          if (!allDay)
            InkWell(
              onTap: () => _pickTime(isStart),
              child: Padding(padding: const EdgeInsets.symmetric(vertical: 12), child: Text(hm(context, d), style: T.labelMd(t.display))),
            ),
        ]);
    return Scaffold(
      body: SafeArea(
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 0),
            child: SizedBox(
              height: 44,
              child: Row(children: [
                IconBtn(Icons.close, label: l.closeNoSave, onTap: () => Navigator.pop(context)),
                const Spacer(),
                busy
                    ? Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: SizedBox.square(dimension: 16, child: CircularProgressIndicator(strokeWidth: 1.5, color: t.display)),
                      )
                    : TextButton(onPressed: _save, child: Text(l.save.toUpperCase(), style: T.labelMd(t.display))),
              ]),
            ),
          ),
          Expanded(
            child: ListView(padding: const EdgeInsets.fromLTRB(24, 24, 24, 24), children: [
              TextField(
                controller: _title,
                autofocus: widget.ev == null,
                textCapitalization: TextCapitalization.sentences,
                style: T.headlineLg(t.display),
                cursorColor: t.display,
                decoration: InputDecoration.collapsed(hintText: l.eventName, hintStyle: T.headlineLg(t.secondary)),
              ),
              Group(children: [
                RowItem(children: [
                  Expanded(child: Text(l.allDay)),
                  Toggle(value: allDay, label: l.allDay, onChanged: (v) => setState(() => allDay = v)),
                ]),
                when(l.start, start, true),
                when(l.end, end, false),
              ]),
              Group(children: [
                RowItem(
                  onTap: () async {
                    final id = await Navigator.push<String>(context, MaterialPageRoute(builder: (_) => _CalendarPick(store, calId)));
                    if (id != null) setState(() => calId = id);
                  },
                  children: [
                    Expanded(child: Text(l.calendar)),
                    Marker(cal?.shape ?? Shape.dot),
                    ConstrainedBox(constraints: const BoxConstraints(maxWidth: 150), child: Lbl(cal?.name ?? '')),
                    Icon(Icons.chevron_right, size: 20, color: t.secondary),
                  ],
                ),
              ]),
              Group(children: [
                ValueRow(l.place, value: place ?? l.add, onTap: () async {
                  final v = await _ask(l.place, place);
                  if (v != null) setState(() => place = v.isEmpty ? null : v);
                }),
                ValueRow(l.notes, value: (notes?.isNotEmpty ?? false) ? notes!.split('\n').first : l.add, onTap: () async {
                  final v = await _ask(l.notes, notes, multi: true);
                  if (v != null) setState(() => notes = v.isEmpty ? null : v);
                }),
              ]),
            ]),
          ),
        ]),
      ),
    );
  }
}

/// Chooses the calendar of an event: writable calendars, plus the current one.
class _CalendarPick extends StatelessWidget {
  const _CalendarPick(this.store, this.selected);
  final Store store;
  final String selected;
  @override
  Widget build(BuildContext context) {
    final t = Tok.of(context), l = l10n(context);
    final list = [...store.writable, if (!store.writable.any((c) => c.id == selected)) ?store.cal(selected)];
    return Scaffold(
      body: SafeArea(
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          const BackBar(),
          Expanded(
            child: ListView(padding: const EdgeInsets.fromLTRB(24, 24, 24, 24), children: [
              Text(l.calendar, style: T.headlineLg(t.display)),
              Group(children: [
                for (final c in list)
                  RowItem(onTap: () => Navigator.pop(context, c.id), children: [
                    Marker(c.shape),
                    Expanded(child: Text(c.name, maxLines: 1, overflow: TextOverflow.ellipsis)),
                    if (c.id == selected) Icon(Icons.check, size: 20, color: t.display),
                  ]),
              ]),
            ]),
          ),
        ]),
      ),
    );
  }
}
