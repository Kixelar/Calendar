import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../google.dart';
import '../l10n/app_localizations.dart';
import '../rrule.dart';
import '../store.dart';
import '../theme.dart';
import '../ui.dart';
import 'invite.dart';
import 'repeat.dart';

/// Mockup screens 03.1 (event details), 03.2 (new / edit event), 03.5 (received invitation) and 06.2 (delete dialog).

String reminderText(AppLocalizations l, int? m) => switch (m) {
      null => l.none,
      0 => l.atStart,
      final m when m % 1440 == 0 => l.daysBefore(m ~/ 1440),
      final m when m % 60 == 0 => l.hoursBefore(m ~/ 60),
      final m => l.minBefore(m),
    };

/// "PT 30" style short day, as in the details screen's back link.
String shortDay(BuildContext c, DateTime d) => '${l10n(c).weekdays.split(',')[d.weekday - 1]} ${d.day}';

/// "Demo sprintu · Pt 30 paź" above the invite screen's title.
String _eventLine(BuildContext c, String title, DateTime d) =>
    [if (title.isNotEmpty) title, '${shortDay(c, d)} ${DateFormat.MMM(loc(c)).format(d).replaceAll('.', '')}'].join(' · ');

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

/// Big start time with "— end" (or the day number and "all day") at the top of 03.1 and 03.5.
Widget _timeHero(BuildContext context, Ev e) {
  final t = Tok.of(context), l = l10n(context);
  return Padding(
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
  );
}

/// The series' rule text for an occurrence ("Co 2 tygodnie..."), fetched once per screen.
class _RuleText extends StatelessWidget {
  const _RuleText(this.e, this.store, {required this.builder});
  final Ev e;
  final Store store;
  final Widget Function(String? text) builder;
  @override
  Widget build(BuildContext context) {
    final series = e.recurringId;
    if (series == null) return builder(null);
    return FutureBuilder(
      future: store.g.recurrence(e.calId, series).catchError((_) => const <String>[]),
      builder: (context, snap) {
        final rule = snap.data?.map(Rule.parse).nonNulls.firstOrNull;
        return builder(rule?.describe(l10n(context), loc(context)));
      },
    );
  }
}

Future<void> _inviteAndSave(BuildContext context, Ev e, Store store) async {
  final l = l10n(context);
  final r = await Navigator.push<InviteResult>(
    context,
    MaterialPageRoute(
      builder: (_) => Invite(store,
          subtitle: _eventLine(context, e.title, e.start),
          initial: (guests: e.guests, invite: e.guestsInvite, modify: e.guestsModify, see: e.guestsSee),
          sendLabel: l.send),
    ),
  );
  if (r == null || !context.mounted) return;
  try {
    await store.save(Ev(e.title, e.calId, e.start, e.end,
        id: e.id,
        allDay: e.allDay,
        location: e.location,
        notes: e.notes,
        recurringId: e.recurringId,
        reminder: e.reminder,
        customReminder: e.customReminder,
        guests: r.guests,
        guestsInvite: r.invite,
        guestsModify: r.modify,
        guestsSee: r.see));
    if (context.mounted) Navigator.of(context).popUntil((r) => r.isFirst);
  } catch (err) {
    if (context.mounted) _fail(context, err);
  }
}

class EventDetails extends StatelessWidget {
  const EventDetails(this.e, this.store, {super.key});
  final Ev e;
  final Store store;

  @override
  Widget build(BuildContext context) {
    if (e.isInvitation) return _Invitation(e, store);
    final t = Tok.of(context), l = l10n(context), now = DateTime.now();
    final cal = store.cal(e.calId);
    final writable = cal?.writable ?? false;
    final canEdit = writable && e.organizer; // invitations from others are edited by their organizer
    final canInvite = canEdit || (writable && e.guestsInvite);
    final soon = (e.start.difference(now).inSeconds + 59) ~/ 60;
    Color rsvpColor(String s) => switch (s) { 'accepted' => t.success, 'tentative' => t.warning, _ => t.secondary };
    String rsvp(String s) => switch (s) { 'accepted' => l.rsvpYes, 'tentative' => l.rsvpMaybe, 'declined' => l.rsvpNo, _ => l.rsvpWaiting };
    return Scaffold(
      body: SafeArea(
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          BackBar(label: shortDay(context, e.start), actions: [
            if (canInvite) IconBtn(Icons.ios_share, label: l.shareEvent, onTap: () => _inviteAndSave(context, e, store)),
            if (writable) IconBtn(Icons.more_horiz, label: l.moreOptions, onTap: () => _delete(context)),
          ]),
          Expanded(
            child: ListView(padding: const EdgeInsets.fromLTRB(24, 0, 24, 24), children: [
              _timeHero(context, e),
              const SizedBox(height: 16),
              Text(e.title, style: T.headlineLg(t.display)),
              const SizedBox(height: 8),
              _RuleText(e, store, builder: (rule) {
                final meta = [?cal?.name, ?rule?.replaceAll(RegExp(r'\.$'), ''), if (!e.allDay && e.start.isAfter(now) && soon <= 60) l.inMin(soon)];
                return Row(spacing: 8, children: [Marker(cal?.shape ?? Shape.dot), Expanded(child: Lbl(meta.join(' · ')))]);
              }),
              Group(children: [
                if (e.location?.isNotEmpty ?? false) ValueRow(l.place, value: e.location),
                ValueRow(l.reminder, value: reminderText(l, e.reminder)),
              ]),
              if (e.notes?.isNotEmpty ?? false)
                Section(left: l.notes, children: [
                  Padding(padding: const EdgeInsets.symmetric(vertical: 16), child: Text(e.notes!, style: T.body(t.primary))),
                ]),
              if (e.guests.isNotEmpty || canInvite)
                Section(left: l.guests, right: e.organizer && e.guests.isNotEmpty ? l.youOrganize : null, children: [
                  for (final g in e.guests)
                    RowItem(children: [
                      Avatar(g.name),
                      Expanded(child: Text(g.name, maxLines: 1, overflow: TextOverflow.ellipsis)),
                      Lbl(rsvp(g.status), color: rsvpColor(g.status)),
                    ]),
                  if (canInvite)
                    RowItem(onTap: () => _inviteAndSave(context, e, store), children: [
                      const Avatar('', icon: Icons.add),
                      Expanded(child: Text(l.inviteMore, style: T.body(t.display))),
                      Icon(Icons.chevron_right, size: 20, color: t.secondary),
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

/// 03.5: an invitation from someone else, answered Yes / Maybe / No.
class _Invitation extends StatefulWidget {
  const _Invitation(this.e, this.store);
  final Ev e;
  final Store store;
  @override
  State<_Invitation> createState() => _InvitationState();
}

class _InvitationState extends State<_Invitation> {
  String? busy; // the reply being sent

  Future<void> _answer(String status) async {
    setState(() => busy = status);
    try {
      await widget.store.respond(widget.e, status);
      if (mounted) Navigator.of(context).popUntil((r) => r.isFirst);
    } catch (err) {
      if (mounted) {
        setState(() => busy = null);
        _fail(context, err);
      }
    }
  }

  @override
  Widget build(BuildContext context) => ListenableBuilder(listenable: widget.store, builder: _build); // clash check needs the day loaded

  Widget _build(BuildContext context, Widget? _) {
    final t = Tok.of(context), l = l10n(context), e = widget.e, store = widget.store;
    final cal = store.cal(e.calId);
    // Another timed event that overlaps this one, shown in red like the mockup.
    final clash = (store.on(e.start) ?? const <Ev>[])
        .where((o) => o.id != e.id && !o.allDay && !e.allDay && o.start.isBefore(e.end) && o.end.isAfter(e.start))
        .firstOrNull;
    final others = [for (final g in e.guests) if (!g.self) g.name.split(' ').first];
    final current = e.me?.status == 'needsAction' ? 'accepted' : e.me?.status; // unanswered: "Yes" leads, as in the mockup
    return Scaffold(
      body: SafeArea(
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          const BackBar(),
          Expanded(
            child: ListView(padding: const EdgeInsets.fromLTRB(24, 24, 24, 24), children: [
              Lbl(l.invitationFrom(e.organizerName ?? '')),
              const SizedBox(height: 8),
              Text(e.title, style: T.headlineLg(t.display)),
              _timeHero(context, e),
              const SizedBox(height: 8),
              Lbl(DateFormat('EEEE · d MMMM', loc(context)).format(e.start)),
              Group(children: [
                if (e.location?.isNotEmpty ?? false) ValueRow(l.place, value: e.location),
                if (e.organizerName != null) ValueRow(l.organizerLabel, value: e.organizerName),
                if (others.isNotEmpty) ValueRow(l.guests, value: others.join(', ')),
                if (clash != null) ValueRow(l.conflict, value: '${clash.title} ${hm(context, clash.start)}', valueColor: t.accentText),
                RowItem(children: [
                  Expanded(child: Text(l.calendar)),
                  Marker(cal?.shape ?? Shape.dot),
                  ConstrainedBox(constraints: const BoxConstraints(maxWidth: 150), child: Lbl(cal?.name ?? '')),
                ]),
              ]),
            ]),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
            child: Semantics(
              container: true,
              child: Row(spacing: 8, children: [
                for (final (s, label) in [('accepted', l.rsvpYes), ('tentative', l.rsvpMaybe), ('declined', l.rsvpNo)])
                  Expanded(
                    child: Btn(label,
                        kind: s == current ? BtnKind.primary : BtnKind.secondary,
                        busy: busy == s,
                        onTap: busy == null ? () => _answer(s) : null),
                  ),
              ]),
            ),
          ),
        ]),
      ),
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

// Reminder choices; _defaultReminder means "use the calendar's default".
const _defaultReminder = -1;
const _reminderChoices = [_defaultReminder, -2, 0, 5, 10, 15, 30, 60, 1440];

class _EventEditState extends State<EventEdit> {
  late final _title = TextEditingController(text: widget.ev?.title);
  late bool allDay;
  late DateTime start, end;
  late String calId;
  String? place, notes;
  Rule? rule; // null: does not repeat
  late int reminderChoice; // one of _reminderChoices, or the event's own minutes
  late InviteResult guests;
  String timeZone = '';
  bool busy = false;

  bool get _occurrence => widget.ev?.recurringId != null; // its rule belongs to the series and is not edited here

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
      reminderChoice = !e.customReminder ? _defaultReminder : e.reminder ?? -2;
      guests = (guests: e.guests, invite: e.guestsInvite, modify: e.guestsModify, see: e.guestsSee);
    } else {
      final now = DateTime.now(), d = widget.day ?? dayOf(now);
      allDay = false;
      start = d == dayOf(now) ? DateTime(d.year, d.month, d.day, now.hour + 1) : DateTime(d.year, d.month, d.day, 9);
      end = start.add(const Duration(hours: 1));
      calId = widget.store.writable.first.id;
      reminderChoice = _defaultReminder;
      guests = (guests: const [], invite: true, modify: false, see: true);
    }
    widget.store.timeZone().then((z) {
      if (mounted) setState(() => timeZone = z);
    });
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
            id: old?.id ?? '',
            allDay: allDay,
            location: place,
            notes: notes,
            recurringId: old?.recurringId,
            recurrence: _occurrence ? null : [?rule?.format()],
            reminder: reminderChoice >= 0 ? reminderChoice : null,
            customReminder: reminderChoice != _defaultReminder,
            guests: guests.guests,
            guestsInvite: guests.invite,
            guestsModify: guests.modify,
            guestsSee: guests.see),
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

  Future<void> _pickRepeat() async {
    final l = l10n(context);
    final presets = {
      'daily': const Rule(Freq.daily),
      'weekly': Rule(Freq.weekly, days: {start.weekday}),
      'monthly': const Rule(Freq.monthly),
      'yearly': const Rule(Freq.yearly),
    };
    final current = rule == null
        ? 'never'
        : presets.entries.where((p) => p.value.format() == rule!.format()).firstOrNull?.key ?? 'custom';
    final p = await pick<String>(context, Pick(title: l.repeat, selected: current, options: [
      ('never', l.never),
      ('daily', l.everyDays(1)),
      ('weekly', l.everyWeeks(1)),
      ('monthly', l.everyMonths(1)),
      ('yearly', l.everyYears(1)),
      ('custom', '${l.custom}…'),
    ]));
    if (p == null || !mounted) return;
    if (p.$1 != 'custom') return setState(() => rule = presets[p.$1]);
    final r = await Navigator.push<Rule>(
      context,
      MaterialPageRoute(builder: (_) => CustomRepeat(rule: rule ?? Rule(Freq.weekly, days: {start.weekday}), start: start)),
    );
    if (r != null) setState(() => rule = r);
  }

  String _reminderLabel(AppLocalizations l, int c) => switch (c) {
        _defaultReminder => l.calendarDefault(reminderText(l, widget.store.cal(calId)?.defaultReminder).toLowerCase()),
        -2 => l.none,
        final m => reminderText(l, m),
      };

  Future<void> _pickReminder() async {
    final l = l10n(context);
    final p = await pick<int>(context, Pick(
      title: l.reminder,
      selected: reminderChoice,
      options: [
        for (final c in {..._reminderChoices, reminderChoice}) (c, _reminderLabel(l, c)),
      ],
    ));
    if (p != null) setState(() => reminderChoice = p.$1);
  }

  Future<void> _pickGuests() async {
    final l = l10n(context);
    final r = await Navigator.push<InviteResult>(
      context,
      MaterialPageRoute(
        builder: (_) => Invite(widget.store, subtitle: _eventLine(context, _title.text.trim(), start), initial: guests, sendLabel: l.done),
      ),
    );
    if (r != null) setState(() => guests = r);
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
    final guestNames = [for (final g in guests.guests) g.name.split(' ').first];
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
                // Read-only: events are saved in the phone's zone; a zone picker needs a time zone database.
                if (!allDay && timeZone.isNotEmpty) ValueRow(l.timeZone, value: timeZone.split('/').last.replaceAll('_', ' ')),
              ]),
              Group(children: [
                if (_occurrence)
                  _RuleText(widget.ev!, store, builder: (text) => ValueRow(l.repeat, value: text ?? l.custom))
                else
                  ValueRow(l.repeat, value: rule?.describe(l, loc(context)) ?? l.never, onTap: _pickRepeat),
                ValueRow(l.reminder, value: _reminderLabel(l, reminderChoice), onTap: _pickReminder),
                RowItem(
                  onTap: () async {
                    final p = await pick<String>(context, Pick(
                      title: l.calendar,
                      selected: calId,
                      options: [
                        for (final c in [...store.writable, if (!store.writable.any((c) => c.id == calId)) ?cal]) (c.id, c.name),
                      ],
                      leading: (id) => Marker(store.cal(id)?.shape ?? Shape.dot),
                    ));
                    if (p != null) setState(() => calId = p.$1);
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
                ValueRow(l.guests, value: guestNames.isEmpty ? l.invite : guestNames.join(', '), onTap: _pickGuests),
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
