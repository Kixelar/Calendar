import 'dart:convert';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

import 'package:googleapis/calendar/v3.dart' as gcal;

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
/// One-field dialog; [note] is a grey line under the field, [action] the confirm button (default "Done").
Future<String?> askText(BuildContext context, String title, {String? hint, TextInputType? type, String? note, String? action}) => showDialog<String>(
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
              if (note != null) Text(note, style: T.bodySm(t.secondary)),
              Row(spacing: 8, children: [
                Expanded(child: Btn(l.cancel, kind: BtnKind.secondary, onTap: () => Navigator.pop(c))),
                Expanded(child: Btn(action ?? l.done, onTap: () => Navigator.pop(c, ctl.text.trim()))),
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

/// Menu with all marker shapes (04.5, calendar list); the chosen one is saved for [cal].
Future<void> _chooseShape(BuildContext context, Store store, Cal cal) async {
  final names = l10n(context).shapeNames.split(',');
  final s = await showDialog<Shape>(
    context: context,
    barrierColor: const Color(0xA3000000),
    builder: (c) {
      final t = Tok.of(c);
      return Dialog(
        backgroundColor: t.surfaceRaised,
        insetPadding: const EdgeInsets.symmetric(horizontal: 24),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8), side: BorderSide(color: t.borderSubtle)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, spacing: 16, children: [
            Text(l10n(c).marker, style: T.headlineMd(t.display)),
            Text(cal.name, maxLines: 1, overflow: TextOverflow.ellipsis, style: T.bodySm(t.secondary)),
            GridView.count(
              crossAxisCount: 6,
              shrinkWrap: true,
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
              children: [
                for (final s in Shape.values)
                  Semantics(
                    label: names[s.index],
                    selected: s == cal.shape,
                    child: InkWell(
                      onTap: () => Navigator.pop(c, s),
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: s == cal.shape ? t.display : t.borderSubtle),
                        ),
                        alignment: Alignment.center,
                        child: Transform.scale(scale: 1.6, child: Marker(s)),
                      ),
                    ),
                  ),
              ],
            ),
          ]),
        ),
      );
    },
  );
  if (s == null || s == cal.shape) return;
  try {
    await store.setShape(cal, s);
  } catch (e) {
    if (context.mounted) _fail(context, e);
  }
}

/// A calendar's marker that opens the shape menu.
class _ShapeBtn extends StatelessWidget {
  const _ShapeBtn(this.store, this.cal);
  final Store store;
  final Cal cal;
  @override
  Widget build(BuildContext context) => InkWell(
        onTap: () => _chooseShape(context, store, cal),
        customBorder: const CircleBorder(),
        child: SizedBox.square(dimension: 32, child: Center(child: Marker(cal.shape))),
      );
}

void _say(BuildContext c, String text) => ScaffoldMessenger.of(c).showSnackBar(SnackBar(content: Text(text)));

/// Small blocking dialog while a long job runs (import, export).
void _busy(BuildContext context, Widget child) => showDialog<void>(
      context: context,
      barrierDismissible: false,
      barrierColor: const Color(0xA3000000),
      builder: (c) => PopScope(
        canPop: false,
        child: Dialog(
          backgroundColor: Tok.of(c).surfaceRaised,
          child: Padding(padding: const EdgeInsets.all(24), child: child),
        ),
      ),
    );

/// 04.2 / 05.5 "Import file": an .ics from the phone into a chosen calendar; [onPhone] limits the choice to calendars
/// on this phone (true) or in Google (false), as the 04.2 switch says.
Future<void> importIcsFile(BuildContext context, Store store, {bool? onPhone}) async {
  final l = l10n(context), t = Tok.of(context);
  final file = await FilePicker.pickFile();
  if (file == null || !context.mounted) return;
  final List<gcal.Event> evs;
  try {
    evs = await store.readIcs(utf8.decode(await file.readAsBytes(), allowMalformed: true));
  } catch (e) {
    if (context.mounted) _fail(context, e);
    return;
  }
  if (!context.mounted) return;
  if (evs.isEmpty) return _say(context, l.icsEmpty);
  final cal = await pick<String?>(context, Pick(
    title: l.importTo(evs.length),
    selected: null,
    options: [for (final c in store.writable) if (onPhone == null || store.isLocal(c.id) == onPhone) (c.id, c.name)],
    leading: (id) => Marker(store.cal(id!)?.shape ?? Shape.dot),
  ));
  if (cal?.$1 == null || !context.mounted) return;
  final done = ValueNotifier(0);
  _busy(
    context,
    ValueListenableBuilder(
      valueListenable: done,
      builder: (c, n, _) => Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, spacing: 16, children: [
        Text(l.importing(n, evs.length), style: T.body(t.display)),
        LinearProgressIndicator(value: n / evs.length, color: t.display, backgroundColor: t.borderSubtle),
      ]),
    ),
  );
  final failed = await store.importIcs(evs, cal!.$1!, (n) => done.value = n);
  if (!context.mounted) return;
  Navigator.pop(context);
  _say(context, [l.importedN(evs.length - failed), if (failed > 0) l.failedN(failed)].join(' · '));
}

/// 05.5 "Export all": one .ics with the shown calendars, saved where the user picks.
Future<void> exportIcsFile(BuildContext context, Store store) async {
  final l = l10n(context), t = Tok.of(context);
  _busy(context, Row(spacing: 16, children: [
    SizedBox.square(dimension: 16, child: CircularProgressIndicator(strokeWidth: 1.5, color: t.display)),
    Text(l.exporting, style: T.body(t.display)),
  ]));
  String text;
  try {
    text = await store.exportIcs();
  } catch (e) {
    if (context.mounted) {
      Navigator.pop(context);
      _fail(context, e);
    }
    return;
  }
  if (!context.mounted) return;
  Navigator.pop(context);
  final now = DateTime.now();
  final saved = await FilePicker.saveFile(
    fileName: 'calendar-${DateFormat('yyyy-MM-dd').format(now)}.ics',
    bytes: utf8.encode(text),
    mimeType: 'text/calendar',
  );
  if (saved != null && context.mounted) _say(context, l.fileSaved);
}

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
          final feeds = store.subscriptions;
          final mine = [for (final c in store.cals) if (!c.shared && !c.holiday && !feeds.containsKey(c.id) && !store.isLocal(c.id)) c];
          final phone = [for (final c in store.cals) if (store.isLocal(c.id) && !c.holiday && !feeds.containsKey(c.id)) c];
          final shared = [for (final c in store.cals) if (c.shared) c];
          final subs = [for (final c in store.cals) if (c.holiday || feeds.containsKey(c.id)) c];
          Widget toggle(Cal c) => Toggle(value: c.on, label: c.name, onChanged: (v) => store.toggle(c, v));
          return _page(context, top: BackBar(label: backLabel), body: [
            _head(context, l.visibility, l.calendars),
            if (store.signedIn)
              Section(
              left: l.mineGoogle,
              trailing: Text(store.email ?? '', style: T.caption(t.secondary)),
              children: [
                for (final c in mine)
                  RowItem(children: [
                    _ShapeBtn(store, c),
                    Expanded(child: Text(c.name, maxLines: 1, overflow: TextOverflow.ellipsis)),
                    IconBtn(Icons.ios_share, label: l.shareCalendar(c.name), onTap: () => _go(context, Share(store, c))),
                    toggle(c),
                    // Google cannot delete the primary calendar (its id is the account e-mail), only other own ones.
                    if (c.role == 'owner' && c.id != store.email)
                      IconBtn(Icons.delete_outline, label: l.deleteCalendar, onTap: () async {
                        if (!await confirm(context, l.deleteCalendar, l.deleteCalendarBody(c.name), l.delete) || !context.mounted) return;
                        try {
                          await store.deleteCalendar(c);
                        } catch (e) {
                          if (context.mounted) _fail(context, e);
                        }
                      }),
                  ]),
              ],
            ),
            if (phone.isNotEmpty)
              Section(left: l.onDevice, children: [
                for (final c in phone)
                  RowItem(children: [
                    _ShapeBtn(store, c),
                    Expanded(child: Text(c.name, maxLines: 1, overflow: TextOverflow.ellipsis)),
                    toggle(c),
                    IconBtn(Icons.delete_outline, label: l.deleteCalendar, onTap: () async {
                      if (!await confirm(context, l.deleteCalendar, l.deleteCalendarBody(c.name), l.delete) || !context.mounted) return;
                      await store.deleteCalendar(c);
                    }),
                  ]),
              ]),
            if (shared.isNotEmpty)
              Section(left: l.sharedWithMe, children: [
                for (final c in shared)
                  RowItem(onTap: () => _go(context, SharedWithYou(store, c)), children: [
                    _ShapeBtn(store, c),
                    Expanded(child: _twoLine(context, c.name, roleText(l, c.role))),
                    toggle(c),
                  ]),
              ]),
            if (subs.isNotEmpty)
              Section(left: l.subscriptions, children: [
                for (final c in subs)
                  if (feeds[c.id] case final url?)
                    RowItem(children: [
                      _ShapeBtn(store, c),
                      Expanded(child: _twoLine(context, c.name, Uri.tryParse(url)?.host ?? url)),
                      toggle(c),
                      IconBtn(Icons.delete_outline, label: l.unsubscribe, onTap: () async {
                        if (!await confirm(context, l.unsubscribe, l.unsubscribeBody(c.name), l.unsubscribe) || !context.mounted) return;
                        try {
                          await store.unsubscribe(c);
                        } catch (e) {
                          if (context.mounted) _fail(context, e);
                        }
                      }),
                    ])
                  else
                    RowItem(onTap: () => _go(context, c.holiday ? Holidays(store) : SharedWithYou(store, c)), children: [
                      _ShapeBtn(store, c),
                      Expanded(child: _twoLine(context, c.name, c.holiday ? l.holidays : roleText(l, c.role))),
                      toggle(c),
                      if (c.holiday)
                        IconBtn(Icons.delete_outline, label: l.removeCountry, onTap: () async {
                          try {
                            await store.removeCalendar(c);
                          } catch (e) {
                            if (context.mounted) _fail(context, e);
                          }
                        }),
                    ]),
              ]),
          ], foot: [
            Btn(l.addCalendar, kind: BtnKind.secondary, icon: Icons.add, onTap: () => _go(context, AddCalendar(store))),
          ]);
        },
      );
}

/// 04.2: ways to add a calendar. With a Google account a switch says where new calendars and imports go: Google or
/// this phone (owner, 2026-11-08). Holidays and address subscriptions go to Google with an account, to the phone without.
class AddCalendar extends StatefulWidget {
  const AddCalendar(this.store, {super.key});
  final Store store;
  @override
  State<AddCalendar> createState() => _AddCalendarState();
}

class _AddCalendarState extends State<AddCalendar> {
  late bool _phone = !widget.store.signedIn;
  Store get store => widget.store;

  /// 04.2 "Subscribe to address": copies the file into a new calendar, refreshed every hour.
  Future<void> _subscribe(BuildContext context) async {
    final l = l10n(context), t = Tok.of(context);
    final url = await askText(context, l.subscribeUrl,
        hint: 'webcal://… .ics', type: TextInputType.url, note: l.subscribeNote, action: l.subscribe);
    if (url == null || url.isEmpty || !context.mounted) return;
    _busy(context, Row(spacing: 16, children: [
      SizedBox.square(dimension: 16, child: CircularProgressIndicator(strokeWidth: 1.5, color: t.display)),
      Expanded(child: Text(l.subscribing, style: T.body(t.display))),
    ]));
    try {
      final name = await store.subscribe(url);
      if (!context.mounted) return;
      Navigator.pop(context); // busy dialog
      Navigator.pop(context);
      _say(context, l.subscribed(name));
    } catch (e) {
      if (!context.mounted) return;
      Navigator.pop(context);
      _fail(context, e);
    }
  }

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
      if (store.signedIn) seg(context, [(false, 'Google'), (true, l.onPhone)], _phone, (v) => setState(() => _phone = v)),
      Group(children: [
        option(Icons.add, l.newCalendar, _phone ? l.newCalendarLocalHint : l.newCalendarHint, () async {
          final name = await askText(context, l.newCalendar, hint: l.calendarName);
          if (name == null || name.isEmpty || !context.mounted) return;
          try {
            await store.createCalendar(name, onPhone: _phone);
            if (context.mounted) Navigator.pop(context);
          } catch (e) {
            if (context.mounted) _fail(context, e);
          }
        }),
        if (!store.signedIn || !_phone) ...[
          option(Icons.wb_sunny_outlined, l.holidaysAndDaysOff, l.holidaysHint, () => _go(context, Holidays(store))),
          option(Icons.link, l.subscribeUrl, l.subscribeUrlHint, () => _subscribe(context)),
        ],
        option(Icons.file_download_outlined, l.importFile, l.importFileHint, () => importIcsFile(context, store, onPhone: _phone)),
        // One Google account at a time: offered only when signed out.
        if (!store.signedIn) option(Icons.person_outline, l.googleAccount, l.googleAccountHint, () => _go(context, Connect(store))),
      ]),
    ]);
  }
}

/// Countries with a Google holiday calendar: ISO codes, each checked against Google on 2026-11-01.
/// Country names come from Android in the app's language (Store.countryNames).
final holidayCodes = '''
    ad ae af ag ai al am ao ar as at au aw ax az ba bb bd be bf bg bh bi bj bl bm bn bo bq br bs bt bw by bz ca cc
    cd cf cg ch ci ck cl cm cn co cr cu cv cw cx cy cz de dj dk dm do dz ec ee eg er es et fi fj fk fm fo fr ga gb
    gd ge gf gg gh gi gl gm gn gp gq gr gt gu gw gy hk hn hr ht hu id ie il im in io iq ir is it je jm jo jp ke kg
    kh ki km kn kp kr kw ky kz la lb lc li lk lr ls lt lu lv ly ma mc md me mf mg mh mk ml mm mn mo mp mq mr ms mt
    mu mv mw mx my mz na nc ne nf ng ni nl no np nr nu nz om pa pe pf pg ph pk pl pm pn pr ps pt pw py qa re ro rs
    ru rw sa sb sc sd se sg sh si sj sk sl sm sn so sr ss st sv sx sy sz tc td tg th tj tk tl tm tn to tr tt tv tw
    tz ua ug um us uy uz va vc ve vg vi vn vu wf ws xk ye yt za zm zw'''
    .split(RegExp(r'\s+'))
    .where((c) => c.isNotEmpty)
    .toList();

// Most calendars are named after the ISO code; these keep Google's older names.
const _holidayNames = {'at': 'austrian', 'au': 'australian', 'bg': 'bulgarian', 'br': 'brazilian', 'ca': 'canadian', 'cn': 'china', 'cz': 'czech', 'de': 'german', 'dk': 'danish', 'es': 'spain', 'fi': 'finnish', 'fr': 'french', 'gb': 'uk', 'gr': 'greek', 'hk': 'hong_kong', 'hr': 'croatian', 'hu': 'hungarian', 'id': 'indonesian', 'ie': 'irish', 'il': 'jewish', 'in': 'indian', 'it': 'italian', 'jp': 'japanese', 'kr': 'south_korea', 'lt': 'lithuanian', 'lv': 'latvian', 'mx': 'mexican', 'my': 'malaysia', 'nl': 'dutch', 'no': 'norwegian', 'nz': 'new_zealand', 'ph': 'philippines', 'pl': 'polish', 'pt': 'portuguese', 'ro': 'romanian', 'ru': 'russian', 'sa': 'saudiarabian', 'se': 'swedish', 'sg': 'singapore', 'si': 'slovenian', 'sk': 'slovak', 'tr': 'turkish', 'tw': 'taiwan', 'ua': 'ukrainian', 'us': 'usa', 'vn': 'vietnamese', 'za': 'sa'};

/// Holiday calendar of [code] with holiday names in [lang] (pl or en).
String holidayId(String code, String lang) => '$lang.${_holidayNames[code] ?? code}#holiday@group.v.calendar.google.com';

/// Key for sorting names the Polish way: Ą after A, Ł after L, Ś after S... (plain compareTo puts them after Z).
String sortKey(String s) =>
    s.toLowerCase().replaceAllMapped(RegExp('[ąćęłńóśźż]'), (m) => '${'acelnoszz'['ąćęłńóśźż'.indexOf(m[0]!)]}\u007f');

/// Country code of a holiday calendar id in any language, e.g. "pl.polish#holiday@..." → "pl".
String? holidayCode(String calId) {
  final name = calId.split('#').first.split('.').last;
  return _holidayNames.entries.where((e) => e.value == name).firstOrNull?.key ?? (holidayCodes.contains(name) ? name : null);
}

/// 04.3: holiday calendars by country and the next holidays.
class Holidays extends StatelessWidget {
  const Holidays(this.store, {super.key});
  final Store store;

  @override
  Widget build(BuildContext context) => ListenableBuilder(
        listenable: store,
        builder: (context, _) {
          final t = Tok.of(context), l = l10n(context), lang = Localizations.localeOf(context).languageCode;
          final now = DateTime.now(), today = dayOf(now);
          final mine = [for (final c in store.cals) if (c.holiday) c];
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
                  final have = {for (final c in mine) holidayCode(c.id)};
                  final names = await store.countryNames(holidayCodes, lang);
                  if (!context.mounted) return;
                  final options = [for (final c in holidayCodes) if (!have.contains(c)) (c, names[c] ?? c.toUpperCase())]
                    ..sort((a, b) => sortKey(a.$2).compareTo(sortKey(b.$2)));
                  final p = await pick<String>(context, Pick(title: l.country, selected: '', options: options));
                  if (p == null || !context.mounted) return;
                  try {
                    await store.addCalendar(holidayId(p.$1, lang));
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
                    Expanded(child: _twoLine(context, c.name, l.holidaysInYear(count(c)))),
                    if (c.on) Icon(Icons.check, size: 20, color: t.display),
                    IconBtn(Icons.delete_outline, label: l.removeCountry, onTap: () async {
                      try {
                        await store.removeCalendar(c);
                      } catch (e) {
                        if (context.mounted) _fail(context, e);
                      }
                    }),
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
                onTap: () => _chooseShape(context, store, c),
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
                  final own = [for (final x in store.cals) if (x.role == 'owner' && !x.holiday) x];
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
