import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

import '../google.dart';
import '../l10n/app_localizations.dart';
import '../store.dart';
import '../theme.dart';
import '../ui.dart';
import 'onboarding.dart';

/// Mockup screens 04.1 calendars, 04.2 add calendar, 04.3 holidays, 04.4 share, 04.5 shared with you.

String roleText(AppLocalizations l, String role) => switch (role) {
      'owner' => l.roleOwner,
      'writer' => l.roleWriter,
      'freeBusyReader' => l.roleFreeBusy,
      _ => l.roleReader,
    };

void _fail(BuildContext c, Object e) => ScaffoldMessenger.of(c).showSnackBar(SnackBar(content: Text(l10n(c).failed('$e'))));

Widget _head(BuildContext c, String over, String title, {Widget? overLead}) => Padding(
      padding: const EdgeInsets.only(top: 24),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, spacing: 8, children: [
        Row(spacing: 8, children: [?overLead, Lbl(over)]),
        Text(title, style: T.headlineLg(Tok.of(c).display)),
      ]),
    );

/// Row with a title and a small caption under it (.row-2).
Widget _twoLine(BuildContext c, String title, String caption, {Color? titleColor}) => Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, spacing: 2, children: [
        Text(title, maxLines: 1, overflow: TextOverflow.ellipsis, style: titleColor == null ? null : T.body(titleColor)),
        Text(caption.toUpperCase(), maxLines: 1, overflow: TextOverflow.ellipsis, style: T.caption(Tok.of(c).secondary)),
      ]),
    );

/// Simple one-field dialog styled like the mockup's .dlg.
Future<String?> askText(BuildContext context, String title, {String? hint, TextInputType? type}) => showDialog<String>(
      context: context,
      barrierColor: const Color(0xA3000000),
      builder: (c) {
        final t = Tok.of(c), l = l10n(c);
        final ctl = TextEditingController();
        return Dialog(
          backgroundColor: t.surfaceRaised,
          insetPadding: const EdgeInsets.symmetric(horizontal: 24),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8), side: BorderSide(color: t.borderSubtle)),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, spacing: 16, children: [
              Text(title, style: T.headlineMd(t.display)),
              TextField(
                controller: ctl,
                autofocus: true,
                keyboardType: type,
                style: T.body(t.primary),
                cursorColor: t.display,
                decoration: InputDecoration(
                  hintText: hint,
                  hintStyle: T.body(t.secondary),
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
            ]),
          ),
        );
      },
    );

Widget _page(BuildContext c, {required Widget top, required List<Widget> body, List<Widget> foot = const []}) => Scaffold(
      body: SafeArea(
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          top,
          Expanded(child: ListView(padding: const EdgeInsets.fromLTRB(24, 0, 24, 24), children: body)),
          if (foot.isNotEmpty)
            Padding(padding: const EdgeInsets.fromLTRB(24, 16, 24, 32), child: Row(spacing: 8, children: [for (final f in foot) Expanded(child: f)])),
        ]),
      ),
    );

Widget _closeBar(BuildContext c) => Padding(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 0),
      child: SizedBox(
        height: 44,
        child: Align(alignment: Alignment.centerLeft, child: IconBtn(Icons.close, label: l10n(c).closeNoSave, onTap: () => Navigator.pop(c))),
      ),
    );

void _go(BuildContext c, Widget page) => Navigator.push(c, MaterialPageRoute(builder: (_) => page));

/// 04.1: which calendars show up, grouped as mine, shared with me and subscriptions.
class Calendars extends StatelessWidget {
  const Calendars(this.store, {super.key, required this.backLabel});
  final Store store;
  final String backLabel;

  @override
  Widget build(BuildContext context) => ListenableBuilder(
        listenable: store,
        builder: (context, _) {
          final t = Tok.of(context), l = l10n(context);
          final mine = [for (final c in store.cals) if (!c.shared && !c.holiday && !c.birthdays) c];
          final shared = [for (final c in store.cals) if (c.shared) c];
          final birthdays = [for (final c in store.cals) if (c.birthdays) c];
          final subs = [for (final c in store.cals) if (c.holiday) c];
          Widget toggle(Cal c) => Toggle(value: c.on, label: c.name, onChanged: (v) => store.toggle(c, v));
          return _page(context, top: BackBar(label: backLabel), body: [
            _head(context, l.visibility, l.calendars),
            Section(
              left: l.mineGoogle,
              trailing: Text(store.email ?? '', style: T.caption(t.secondary)),
              children: [
                for (final c in mine)
                  RowItem(children: [
                    Marker(c.shape),
                    Expanded(child: Text(c.name, maxLines: 1, overflow: TextOverflow.ellipsis)),
                    IconBtn(Icons.ios_share, label: l.shareCalendar(c.name), onTap: () => _go(context, Share(store, c))),
                    toggle(c),
                  ]),
              ],
            ),
            if (shared.isNotEmpty)
              Section(left: l.sharedWithMe, children: [
                for (final c in shared)
                  RowItem(onTap: () => _go(context, SharedWithYou(store, c)), children: [
                    Marker(c.shape),
                    Expanded(child: _twoLine(context, c.name, roleText(l, c.role))),
                    toggle(c),
                  ]),
              ]),
            if (birthdays.isNotEmpty)
              Section(left: l.birthdays, children: [
                for (final c in birthdays)
                  RowItem(onTap: () => _go(context, SharedWithYou(store, c)), children: [
                    Marker(c.shape),
                    Expanded(child: Text(c.name, maxLines: 1, overflow: TextOverflow.ellipsis)),
                    toggle(c),
                  ]),
              ]),
            if (subs.isNotEmpty)
              Section(left: l.subscriptions, children: [
                for (final c in subs)
                  RowItem(onTap: () => _go(context, c.holiday ? Holidays(store) : SharedWithYou(store, c)), children: [
                    Marker(c.shape),
                    Expanded(child: _twoLine(context, c.name, c.holiday ? l.holidays : roleText(l, c.role))),
                    toggle(c),
                  ]),
              ]),
          ], foot: [
            Btn(l.addCalendar, kind: BtnKind.secondary, icon: Icons.add, onTap: () => _go(context, AddCalendar(store))),
          ]);
        },
      );
}

/// 04.2: ways to add a calendar that the Google Calendar API supports.
class AddCalendar extends StatelessWidget {
  const AddCalendar(this.store, {super.key});
  final Store store;

  @override
  Widget build(BuildContext context) {
    final t = Tok.of(context), l = l10n(context);
    Widget option(IconData icon, String title, String caption, VoidCallback onTap) => RowItem(onTap: onTap, children: [
          Icon(icon, size: 24, color: t.display),
          Expanded(child: _twoLine(context, title, caption)),
          Icon(Icons.chevron_right, size: 20, color: t.secondary),
        ]);
    return _page(context, top: _closeBar(context), body: [
      _head(context, l.calendars, l.addCalendar),
      Group(children: [
        option(Icons.add, l.newCalendar, l.newCalendarHint, () async {
          final name = await askText(context, l.newCalendar, hint: l.calendarName);
          if (name == null || name.isEmpty || !context.mounted) return;
          try {
            await store.createCalendar(name);
            if (context.mounted) Navigator.pop(context);
          } catch (e) {
            if (context.mounted) _fail(context, e);
          }
        }),
        option(Icons.wb_sunny_outlined, l.holidaysAndDaysOff, l.holidaysHint, () => _go(context, Holidays(store))),
        option(Icons.person_outline, l.googleAccount, l.googleAccountHint, () => _go(context, Connect(store))),
      ]),
    ]);
  }
}

/// Google's public holiday calendars this screen offers; names follow the app language.
const holidayCountries = <(String id, String en, String pl)>[
  ('pl.polish', 'Poland', 'Polska'),
  ('en.uk', 'United Kingdom', 'Wielka Brytania'),
  ('en.usa', 'United States', 'Stany Zjednoczone'),
  ('de.german', 'Germany', 'Niemcy'),
  ('cs.czech', 'Czechia', 'Czechy'),
  ('sk.slovak', 'Slovakia', 'Słowacja'),
  ('uk.ukrainian', 'Ukraine', 'Ukraina'),
  ('lt.lithuanian', 'Lithuania', 'Litwa'),
  ('fr.french', 'France', 'Francja'),
  ('es.spain', 'Spain', 'Hiszpania'),
  ('it.italian', 'Italy', 'Włochy'),
  ('nl.dutch', 'Netherlands', 'Holandia'),
  ('en.irish', 'Ireland', 'Irlandia'),
  ('no.norwegian', 'Norway', 'Norwegia'),
  ('sv.swedish', 'Sweden', 'Szwecja'),
];

String holidayId(String code) => '$code#holiday@group.v.calendar.google.com';

/// 04.3: holiday calendars by country and the next holidays.
class Holidays extends StatelessWidget {
  const Holidays(this.store, {super.key});
  final Store store;

  @override
  Widget build(BuildContext context) => ListenableBuilder(
        listenable: store,
        builder: (context, _) {
          final t = Tok.of(context), l = l10n(context), pl = loc(context).startsWith('pl');
          final now = DateTime.now(), today = dayOf(now);
          final mine = [for (final c in store.cals) if (c.holiday) c];
          String name(Cal c) => holidayCountries.where((h) => holidayId(h.$1) == c.id).map((h) => pl ? h.$3 : h.$2).firstOrNull ?? c.name;
          int count(Cal c) {
            final seen = <String>{};
            for (var d = DateTime(now.year); d.year == now.year; d = DateTime(d.year, d.month, d.day + 1)) {
              for (final e in store.on(d) ?? const <Ev>[]) {
                if (e.calId == c.id) seen.add(e.id);
              }
            }
            return seen.length;
          }

          final next = <Ev>[];
          for (var i = 0; i < 120 && next.length < 3; i++) {
            for (final e in store.on(DateTime(today.year, today.month, today.day + i)) ?? const <Ev>[]) {
              if ((store.cal(e.calId)?.holiday ?? false) && dayOf(e.start) == DateTime(today.year, today.month, today.day + i)) next.add(e);
            }
          }
          return _page(context, top: BackBar(label: l.calendars), body: [
            _head(context, l.subscriptions, l.holidays),
            Section(
              left: l.country,
              trailing: InkWell(
                onTap: () async {
                  final have = {for (final c in mine) c.id};
                  final p = await pick<String>(context, Pick(
                    title: l.country,
                    selected: '',
                    options: [for (final h in holidayCountries) if (!have.contains(holidayId(h.$1))) (h.$1, pl ? h.$3 : h.$2)],
                  ));
                  if (p == null || !context.mounted) return;
                  try {
                    await store.addCalendar(holidayId(p.$1));
                  } catch (e) {
                    if (context.mounted) _fail(context, e);
                  }
                },
                child: Lbl(l.addCountry, color: t.display),
              ),
              children: [
                for (final c in mine)
                  RowItem(onTap: () => store.toggle(c, !c.on), children: [
                    Marker(c.shape),
                    Expanded(child: _twoLine(context, name(c), l.holidaysInYear(count(c)))),
                    if (c.on) Icon(Icons.check, size: 20, color: t.display),
                  ]),
              ],
            ),
            if (next.isNotEmpty)
              Section(left: l.nearest, children: [
                for (final e in next)
                  RowItem(children: [
                    SizedBox(
                      width: 48,
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, spacing: 2, children: [
                        Lbl(DateFormat.LLL(loc(context)).format(e.start).replaceAll('.', '')),
                        Text('${e.start.day}'.padLeft(2, '0'), style: T.displayMd(t.display)),
                      ]),
                    ),
                    Expanded(child: _twoLine(context, e.title, DateFormat.EEEE(loc(context)).format(e.start))),
                  ]),
              ]),
          ]);
        },
      );
}

/// 04.4: who can see a calendar, at what level, and access by link.
class Share extends StatefulWidget {
  const Share(this.store, this.cal, {super.key});
  final Store store;
  final Cal cal;
  @override
  State<Share> createState() => _ShareState();
}

class _ShareState extends State<Share> {
  List<Access>? _rules;
  String _newRole = 'reader';
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final r = await widget.store.g.access(widget.cal.id);
      if (mounted) setState(() => _rules = r);
    } catch (e) {
      if (mounted) {
        setState(() => _rules = const []);
        _fail(context, e);
      }
    }
  }

  Future<void> _run(Future<void> Function() action) async {
    setState(() => _busy = true);
    try {
      await action();
      await _load();
    } catch (e) {
      if (mounted) _fail(context, e);
    }
    if (mounted) setState(() => _busy = false);
  }

  @override
  Widget build(BuildContext context) {
    final t = Tok.of(context), l = l10n(context), g = widget.store.g, cal = widget.cal;
    final rules = _rules;
    final people = [for (final r in rules ?? const <Access>[]) if (r.scope == 'user') r];
    final public = rules?.any((r) => r.scope == 'default') ?? false;
    const levels = ['freeBusyReader', 'reader', 'writer'];
    return _page(context, top: BackBar(label: l.calendars), body: [
      _head(context, l.calendarNamed(cal.name), l.shareTitle, overLead: Marker(cal.shape)),
      Section(left: l.peopleWithAccess, children: [
        if (rules == null) const Padding(padding: EdgeInsets.all(16), child: Center(child: SizedBox.square(dimension: 16, child: CircularProgressIndicator(strokeWidth: 1.5)))),
        for (final r in people)
          RowItem(
            onTap: r.role == 'owner'
                ? null
                : () async {
                    final p = await pick<String>(context, Pick(
                      title: r.email ?? '',
                      selected: r.role,
                      options: [for (final lv in levels) (lv, roleText(l, lv)), ('', l.removeAccess)],
                    ));
                    if (p == null) return;
                    await _run(() => p.$1.isEmpty ? g.removeAccess(cal.id, r.id) : g.setAccess(cal.id, r.id, p.$1));
                  },
            children: [
              Avatar(r.email ?? '', filled: r.email == widget.store.email),
              Expanded(child: Text(r.email == widget.store.email ? l.you : r.email ?? '', maxLines: 1, overflow: TextOverflow.ellipsis)),
              Lbl(roleText(l, r.role), color: r.role == 'owner' ? t.secondary : t.display),
              if (r.role != 'owner') Icon(Icons.chevron_right, size: 20, color: t.secondary),
            ],
          ),
        RowItem(
          onTap: _busy
              ? null
              : () async {
                  final email = await askText(context, l.addPerson, hint: l.emailAddress, type: TextInputType.emailAddress);
                  if (email == null || !email.contains('@')) return;
                  await _run(() => g.share(cal.id, email, _newRole));
                },
          children: [
            const Avatar('', icon: Icons.add),
            Expanded(child: Text(l.addPerson, style: T.body(t.display))),
            if (_busy) SizedBox.square(dimension: 16, child: CircularProgressIndicator(strokeWidth: 1.5, color: t.secondary)),
          ],
        ),
      ]),
      Section(left: l.newPeopleAccess, children: [
        const SizedBox(height: 16),
        Container(
          height: 40,
          padding: const EdgeInsets.all(3),
          decoration: ShapeDecoration(shape: StadiumBorder(side: BorderSide(color: t.borderControl))),
          child: Row(children: [
            for (final lv in levels)
              Expanded(
                child: InkWell(
                  onTap: () => setState(() => _newRole = lv),
                  customBorder: const StadiumBorder(),
                  child: Container(
                    alignment: Alignment.center,
                    decoration: ShapeDecoration(color: lv == _newRole ? t.display : null, shape: const StadiumBorder()),
                    child: Text(roleText(l, lv).toUpperCase(), style: T.labelSm(lv == _newRole ? t.bg : t.secondary)),
                  ),
                ),
              ),
          ]),
        ),
        const SizedBox(height: 8),
        Text(l.freeBusyHint, style: T.bodySm(t.secondary)),
      ]),
      Section(left: l.link, children: [
        RowItem(children: [
          Expanded(child: Text(l.linkAccess)),
          Toggle(value: public, label: l.linkAccess, onChanged: (v) => _run(() => g.setPublic(cal.id, v))),
        ]),
        RowItem(
          onTap: public
              ? () async {
                  await Clipboard.setData(ClipboardData(text: publicLink(cal.id)));
                  if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l.linkCopied)));
                }
              : null,
          children: [
            Icon(Icons.link, size: 24, color: public ? t.display : t.disabled),
            Expanded(child: Text(l.copyLink, style: T.body(public ? t.primary : t.disabled))),
            if (!public) Lbl(l.off),
          ],
        ),
      ]),
    ]);
  }
}

/// 04.5: a calendar someone shares with you: your access, its marker, show it or remove it.
class SharedWithYou extends StatelessWidget {
  const SharedWithYou(this.store, this.cal, {super.key});
  final Store store;
  final Cal cal;

  @override
  Widget build(BuildContext context) => ListenableBuilder(
        listenable: store,
        builder: (context, _) {
          final t = Tok.of(context), l = l10n(context);
          final c = store.cal(cal.id) ?? cal;
          final who = c.ownerEmail;
          final shapes = l.shapeNames.split(',');
          return _page(context, top: _closeBar(context), body: [
            const SizedBox(height: 24),
            SizedBox(
              height: 56,
              child: Row(spacing: 16, children: [
                SizedBox.square(dimension: 56, child: FittedBox(child: Avatar(c.name))),
                Expanded(
                  child: Column(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.start, spacing: 2, children: [
                    Text(c.name, style: T.body(t.display), maxLines: 1, overflow: TextOverflow.ellipsis),
                    if (who != null) Text(who, style: T.caption(t.secondary), maxLines: 1, overflow: TextOverflow.ellipsis),
                  ]),
                ),
              ]),
            ),
            const SizedBox(height: 24),
            Text(l.sharesWithYou(c.name.split(' ').first), style: T.headlineLg(t.display)),
            Group(children: [
              ValueRow(l.calendar, value: c.name),
              ValueRow(l.yourAccess, value: roleText(l, c.role), valueColor: t.display),
              RowItem(
                onTap: () async {
                  final p = await pick<Shape>(context, Pick(
                    title: l.marker,
                    selected: c.shape,
                    options: [for (final s in Shape.values) (s, shapes[s.index])],
                    leading: (s) => Marker(s),
                  ));
                  if (p == null) return;
                  try {
                    await store.setShape(c, p.$1);
                  } catch (e) {
                    if (context.mounted) _fail(context, e);
                  }
                },
                children: [
                  Expanded(child: Text(l.marker)),
                  Marker(c.shape),
                  Lbl(shapes[c.shape.index]),
                  Icon(Icons.chevron_right, size: 20, color: t.secondary),
                ],
              ),
              RowItem(children: [
                Expanded(child: Text(l.showInViews)),
                Toggle(value: c.on, label: l.showInViews, onChanged: (v) => store.toggle(c, v)),
              ]),
            ]),
            if (who != null)
              Section(left: l.otherWay, children: [
                ValueRow(l.shareYours, value: l.choose, onTap: () async {
                  final own = [for (final x in store.cals) if (x.role == 'owner' && !x.holiday && !x.birthdays) x];
                  final p = await pick<String>(context, Pick(
                    title: l.shareYours,
                    selected: '',
                    options: [for (final x in own) (x.id, x.name)],
                    leading: (id) => Marker(store.cal(id)?.shape ?? Shape.dot),
                  ));
                  if (p == null) return;
                  try {
                    await store.g.share(p.$1, who, 'reader');
                    if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l.shared)));
                  } catch (e) {
                    if (context.mounted) _fail(context, e);
                  }
                }),
              ]),
          ], foot: [
            Btn(l.reject, kind: BtnKind.secondary, onTap: () async {
              try {
                await store.removeCalendar(c);
                if (context.mounted) Navigator.pop(context);
              } catch (e) {
                if (context.mounted) _fail(context, e);
              }
            }),
            Btn(l.add, onTap: () async {
              await store.toggle(c, true);
              if (context.mounted) Navigator.pop(context);
            }),
          ]);
        },
      );
}
