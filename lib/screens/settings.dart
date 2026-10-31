import 'package:flutter/material.dart';

import '../help.dart';
import '../l10n/app_localizations.dart';
import '../store.dart';
import '../theme.dart';
import '../ui.dart';
import 'calendars.dart';
import 'notifications.dart';

/// Mockup screens 05.1 settings, 05.2 appearance, 05.4 accounts, 05.5 data, 05.6 help, 05.7 article, 05.8 about.
/// 05.3 notifications lives in notifications.dart.

void _go(BuildContext c, Widget page) => Navigator.push(c, MaterialPageRoute(builder: (_) => page));

Widget _page(BuildContext c, String back, List<Widget> body, {List<Widget> foot = const []}) => Scaffold(
      body: SafeArea(
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          BackBar(label: back),
          Expanded(child: ListView(padding: const EdgeInsets.fromLTRB(24, 0, 24, 24), children: body)),
          if (foot.isNotEmpty)
            Padding(padding: const EdgeInsets.fromLTRB(24, 16, 24, 32), child: Row(spacing: 8, children: [for (final f in foot) Expanded(child: f)])),
        ]),
      ),
    );

Widget _head(BuildContext c, String over, String? title) => Padding(
      padding: const EdgeInsets.only(top: 24),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, spacing: 8, children: [
        Lbl(over),
        if (title != null) Text(title, style: T.headlineLg(Tok.of(c).display)),
      ]),
    );

Widget _switch(String label, bool value, ValueChanged<bool> onChanged, {Widget? extra, String? hint}) => Builder(
      builder: (c) => RowItem(children: [
        Expanded(
          child: hint == null
              ? Text(label)
              : Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, spacing: 2, children: [
                    Text(label),
                    Text(hint, style: T.bodySm(Tok.of(c).secondary)),
                  ]),
                ),
        ),
        ?extra,
        Toggle(value: value, label: label, onChanged: onChanged),
      ]),
    );

/// Segmented choice (.seg).
Widget _seg<V>(BuildContext c, List<(V, String)> options, V value, ValueChanged<V> onChanged) {
  final t = Tok.of(c);
  return Container(
    height: 40,
    margin: const EdgeInsets.only(top: 16),
    padding: const EdgeInsets.all(3),
    decoration: ShapeDecoration(shape: StadiumBorder(side: BorderSide(color: t.borderControl))),
    child: Row(children: [
      for (final (v, label) in options)
        Expanded(
          child: Semantics(
            button: true,
            selected: v == value,
            child: InkWell(
              onTap: () => onChanged(v),
              customBorder: const StadiumBorder(),
              child: Container(
                alignment: Alignment.center,
                decoration: ShapeDecoration(color: v == value ? t.display : null, shape: const StadiumBorder()),
                child: Text(label.toUpperCase(), style: T.labelSm(v == value ? t.bg : t.secondary)),
              ),
            ),
          ),
        ),
    ]),
  );
}

String _themeName(AppLocalizations l, String v) => switch (v) { 'dark' => l.themeDark, 'light' => l.themeLight, _ => l.themeSystem };

/// 05.1: entry to all settings.
class Settings extends StatelessWidget {
  const Settings(this.store, {super.key, required this.backLabel});
  final Store store;
  final String backLabel;

  @override
  Widget build(BuildContext context) => ListenableBuilder(
        listenable: store,
        builder: (context, _) {
          final t = Tok.of(context), l = l10n(context), pl = loc(context).startsWith('pl');
          final countries = [
            for (final c in store.cals)
              if (c.holiday) holidayCountries.where((h) => holidayId(h.$1) == c.id).map((h) => pl ? h.$3 : h.$2).firstOrNull ?? c.name,
          ];
          return _page(context, backLabel, [
            _head(context, l.appTitle, l.settings),
            if (store.signedIn)
              Group(children: [
                RowItem(onTap: () => _go(context, Accounts(store)), children: [
                  Avatar(store.name ?? store.email ?? '', filled: true),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, spacing: 2, children: [
                        Text(store.name ?? store.email ?? '', maxLines: 1, overflow: TextOverflow.ellipsis, style: T.body(t.display)),
                        if (store.name != null) Text(store.email ?? '', maxLines: 1, overflow: TextOverflow.ellipsis, style: T.caption(t.secondary)),
                      ]),
                    ),
                  ),
                  Lbl(store.error == null ? l.upToDate : l.offline, color: store.error == null ? t.success : t.warning),
                  Icon(Icons.chevron_right, size: 20, color: t.secondary),
                ]),
              ]),
            Group(children: [
              ValueRow(l.appearance, value: _themeName(l, store.theme), onTap: () => _go(context, Appearance(store))),
              ValueRow(l.notificationsGlyph, onTap: () => _go(context, Notifications(store))),
            ]),
            Group(children: [
              ValueRow(l.accountsSync, value: store.signedIn ? 'Google' : l.none, onTap: () => _go(context, Accounts(store))),
              if (store.signedIn) ...[
                ValueRow(l.calendarsSharing, value: '${store.cals.length}', onTap: () => _go(context, Calendars(store, backLabel: l.settings))),
                ValueRow(l.holidays, value: countries.isEmpty ? l.none : countries.join(', '), onTap: () => _go(context, Holidays(store))),
              ],
            ]),
            Group(children: [
              ValueRow(l.dataPrivacy, onTap: () => _go(context, DataPrivacy(store))),
              ValueRow(l.help, onTap: () => _go(context, Help(store))),
              ValueRow(l.about, onTap: () => _go(context, About(store))),
            ]),
          ]);
        },
      );
}

/// 05.2: theme, week layout, time format and the dot-matrix style.
class Appearance extends StatelessWidget {
  const Appearance(this.store, {super.key});
  final Store store;

  @override
  Widget build(BuildContext context) => ListenableBuilder(
        listenable: store,
        builder: (context, _) {
          final t = Tok.of(context), l = l10n(context);
          final dayNames = l.weekdaysAcc.split(',');
          String dayName(int d) => '${dayNames[d - 1][0].toUpperCase()}${dayNames[d - 1].substring(1)}';
          return _page(context, l.settings, [
            _head(context, l.settings, l.appearance),
            Section(left: l.theme, children: [
              _seg(context, [('dark', l.themeDark), ('light', l.themeLight), ('system', l.themeSystem)], store.theme, (v) => store.set('theme', v)),
            ]),
            Section(left: l.calendar, children: [
              ValueRow(l.firstDay, value: dayName(store.weekStart), onTap: () async {
                final p = await pick<int>(context, Pick(
                  title: l.firstDay,
                  selected: store.weekStart,
                  options: [for (final d in [DateTime.monday, DateTime.sunday, DateTime.saturday]) (d, dayName(d))],
                ));
                if (p != null) await store.set('weekStart', p.$1);
              }),
              ValueRow(l.timeFormat, value: store.use24h ? '24 h' : '12 h', onTap: () async {
                final p = await pick<bool>(context, Pick(title: l.timeFormat, selected: store.use24h, options: const [(true, '24 h'), (false, '12 h')]));
                if (p != null) await store.set('use24h', p.$1);
              }),
              _switch(l.weekNumbers, store.weekNumbers, (v) => store.set('weekNumbers', v), hint: l.weekNumbersHint),
              _switch(l.showWeekends, store.weekends, (v) => store.set('weekends', v), hint: l.showWeekendsHint),
              _switch(l.declinedInvites, store.showDeclined, (v) => store.set('showDeclined', v), hint: l.declinedHint),
            ]),
            Section(left: l.style, children: [
              _switch(l.dotDigits, store.dotDigits, (v) => store.set('dotDigits', v),
                  extra: ExcludeSemantics(child: Text('30', style: T.displayMd(t.secondary)))),
              _switch(l.dimPast, store.dimPast, (v) => store.set('dimPast', v), hint: l.dimPastHint),
            ]),
          ]);
        },
      );
}

/// 05.4: last sync, the Google account, automatic sync and disconnecting.
class Accounts extends StatefulWidget {
  const Accounts(this.store, {super.key});
  final Store store;
  @override
  State<Accounts> createState() => _AccountsState();
}

class _AccountsState extends State<Accounts> {
  bool _syncing = false;

  @override
  void initState() {
    super.initState();
    widget.store.reloadPrefs(); // shows the latest background run
  }

  Future<void> _syncNow() async {
    setState(() => _syncing = true);
    await widget.store.refresh();
    // The refresh reloads calendars; touching the current year fetches its events again.
    widget.store.on(DateTime.now());
    if (mounted) setState(() => _syncing = false);
  }

  @override
  Widget build(BuildContext context) => ListenableBuilder(
        listenable: widget.store,
        builder: (context, _) {
          final t = Tok.of(context), l = l10n(context), store = widget.store;
          final last = store.lastSync;
          return _page(context, l.settings, [
            _head(context, l.settings, l.accounts),
            if (store.signedIn)
              Container(
                margin: const EdgeInsets.only(top: 24),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: t.surface, border: Border.all(color: t.borderSubtle), borderRadius: BorderRadius.circular(8)),
                child: Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
                  Expanded(
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Lbl(l.lastSync),
                      const SizedBox(height: 8),
                      Text(last == null ? '--:--' : hm(context, last), style: T.displayLg(t.display)),
                      const SizedBox(height: 4),
                      Text('${l.eventsN(store.eventCount)} · ${l.calendarsN(store.cals.where((c) => c.on).length)}', style: T.caption(t.secondary)),
                    ]),
                  ),
                  Container(
                    decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: t.borderControl)),
                    child: _syncing
                        ? Padding(padding: const EdgeInsets.all(14), child: SizedBox.square(dimension: 16, child: CircularProgressIndicator(strokeWidth: 1.5, color: t.display)))
                        : IconBtn(Icons.refresh, label: l.syncNow, onTap: _syncNow),
                  ),
                ]),
              ),
            Section(left: l.accounts, children: [
              if (store.signedIn)
                RowItem(children: [
                  const Avatar('G'),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, spacing: 2, children: [
                        const Text('Google'),
                        Text(store.email ?? '', maxLines: 1, overflow: TextOverflow.ellipsis, style: T.caption(t.secondary)),
                      ]),
                    ),
                  ),
                  Lbl(store.error == null ? l.active : l.offline, color: store.error == null ? t.success : t.warning),
                ]),
              RowItem(onTap: () => _go(context, AddCalendar(store)), children: [
                const Avatar('', icon: Icons.add),
                Expanded(child: Text(l.addAccount, style: T.body(t.display))),
              ]),
            ]),
            if (store.signedIn)
              Section(left: l.syncLabel, children: [
                _switch(l.automatic, store.autoSync, (v) => store.set('autoSync', v)),
                if (store.autoSync)
                  Builder(builder: (context) {
                    final bg = store.lastBackground;
                    final ok = bg?.result == 'ok';
                    return RowItem(children: [
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          child: Column(crossAxisAlignment: CrossAxisAlignment.start, spacing: 2, children: [
                            Text(l.inBackground),
                            if (bg != null && !ok) Text(bg.result, maxLines: 3, overflow: TextOverflow.ellipsis, style: T.caption(t.secondary)),
                          ]),
                        ),
                      ),
                      Lbl(bg == null ? l.notYet : '${hm(context, bg.at)} · ${ok ? 'OK' : l.statusFailed}',
                          color: bg == null ? t.secondary : ok ? t.success : t.accentText),
                    ]);
                  }),
                if (store.autoSync)
                  ValueRow(l.frequency, value: l.everyMinutes(store.syncMinutes), onTap: () async {
                    final p = await pick<int>(context, Pick(
                      title: l.frequency,
                      selected: store.syncMinutes,
                      options: [for (final m in [5, 15, 30, 60]) (m, l.everyMinutes(m))],
                    ));
                    if (p != null) await store.set('syncMinutes', p.$1);
                  }),
                RowItem(
                  onTap: () async {
                    if (await _confirm(context, l.disconnectGoogle, l.disconnectBody, l.disconnect) && context.mounted) {
                      Navigator.of(context).popUntil((r) => r.isFirst);
                      await store.forget();
                    }
                  },
                  children: [Expanded(child: Text(l.disconnectGoogle, style: T.body(t.accentText)))],
                ),
              ]),
          ]);
        },
      );
}

Future<bool> _confirm(BuildContext context, String title, String body, String action) async =>
    await showDialog<bool>(
      context: context,
      barrierColor: const Color(0xA3000000),
      builder: (c) {
        final t = Tok.of(c), l = l10n(c);
        return Dialog(
          backgroundColor: t.surfaceRaised,
          insetPadding: const EdgeInsets.symmetric(horizontal: 24),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8), side: BorderSide(color: t.borderSubtle)),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, spacing: 16, children: [
              Text(title, style: T.headlineMd(t.display)),
              Text(body, style: T.bodySm(t.secondary)),
              Row(spacing: 8, children: [
                Expanded(child: Btn(l.cancel, kind: BtnKind.secondary, onTap: () => Navigator.pop(c, false))),
                Expanded(child: Btn(action, kind: BtnKind.danger, onTap: () => Navigator.pop(c, true))),
              ]),
            ]),
          ),
        );
      },
    ) ??
    false;

/// 05.5: privacy switches and clearing this phone's data.
class DataPrivacy extends StatelessWidget {
  const DataPrivacy(this.store, {super.key});
  final Store store;

  @override
  Widget build(BuildContext context) => ListenableBuilder(
        listenable: store,
        builder: (context, _) {
          final t = Tok.of(context), l = l10n(context);
          return _page(context, l.settings, [
            _head(context, l.settings, l.dataPrivacy),
            Section(left: l.privacy, children: [
              _switch(l.hideOnLockScreen, store.hideOnLock, (v) => store.set('hideOnLock', v)),
            ]),
            Section(left: l.device, children: [
              RowItem(
                onTap: () async {
                  if (await _confirm(context, l.clearData, l.clearDataBody, l.clear) && context.mounted) {
                    Navigator.of(context).popUntil((r) => r.isFirst);
                    await store.forget();
                  }
                },
                children: [Expanded(child: Text(l.clearData, style: T.body(t.accentText)))],
              ),
              Padding(padding: const EdgeInsets.only(top: 8), child: Text(l.googleUntouched, style: T.bodySm(t.secondary))),
            ]),
          ]);
        },
      );
}

/// 05.6: searchable questions.
class Help extends StatefulWidget {
  const Help(this.store, {super.key});
  final Store store;
  @override
  State<Help> createState() => _HelpState();
}

class _HelpState extends State<Help> {
  String q = '';

  @override
  Widget build(BuildContext context) {
    final t = Tok.of(context), l = l10n(context);
    final all = helpFor(loc(context));
    final shown = [for (final a in all) if (q.isEmpty || '${a.title} ${a.steps.join(' ')}'.toLowerCase().contains(q.toLowerCase())) a];
    return _page(context, l.settings, [
      _head(context, l.settings, l.help),
      const SizedBox(height: 24),
      Container(
        height: 48,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(color: t.surface, border: Border.all(color: t.borderControl), borderRadius: BorderRadius.circular(6)),
        child: Row(spacing: 8, children: [
          Icon(Icons.search, size: 20, color: t.secondary),
          Expanded(
            child: TextField(
              onChanged: (v) => setState(() => q = v.trim()),
              style: T.body(t.primary),
              cursorColor: t.display,
              decoration: InputDecoration.collapsed(hintText: l.searchHelp, hintStyle: T.body(t.secondary)),
            ),
          ),
        ]),
      ),
      Section(left: l.faq, children: [
        for (final a in shown)
          RowItem(onTap: () => _go(context, HelpArticle(widget.store, a)), children: [
            Expanded(child: Padding(padding: const EdgeInsets.symmetric(vertical: 12), child: Text(a.title))),
            Icon(Icons.chevron_right, size: 20, color: t.secondary),
          ]),
        if (shown.isEmpty) Padding(padding: const EdgeInsets.only(top: 16), child: Text(l.noResults, style: T.body(t.secondary))),
      ]),
      Section(left: l.contact, children: [
        ValueRow(l.aboutApp, onTap: () => _go(context, About(widget.store))),
      ]),
    ]);
  }
}

/// 05.7: numbered steps, a tip and a button to the screen the article is about.
class HelpArticle extends StatelessWidget {
  const HelpArticle(this.store, this.a, {super.key});
  final Store store;
  final Article a;

  @override
  Widget build(BuildContext context) {
    final t = Tok.of(context), l = l10n(context);
    final (label, page) = switch (a.open) {
      'add' => (l.addCalendar, AddCalendar(store) as Widget),
      'holidays' => (l.holidays, Holidays(store)),
      _ => (l.calendars, Calendars(store, backLabel: l.help)),
    };
    return _page(context, l.help, [
      _head(context, l.readTime(a.topic), a.title),
      const SizedBox(height: 32),
      for (final (i, s) in a.steps.indexed)
        Container(
          constraints: const BoxConstraints(minHeight: 56),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(border: Border(bottom: BorderSide(color: t.borderSubtle))),
          child: Row(crossAxisAlignment: CrossAxisAlignment.start, spacing: 16, children: [
            SizedBox(width: 32, child: ExcludeSemantics(child: Text('${i + 1}'.padLeft(2, '0'), style: T.displayMd(t.display)))),
            Expanded(child: Text(s)),
          ]),
        ),
      Container(
        margin: const EdgeInsets.only(top: 32),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: t.surface, border: Border.all(color: t.borderSubtle), borderRadius: BorderRadius.circular(8)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, spacing: 8, children: [
          Lbl(l.tip),
          Text(a.tip, style: T.bodySm(t.primary)),
        ]),
      ),
    ], foot: [
      if (store.signedIn) Btn(l.openScreen(label), onTap: () => _go(context, page)),
    ]);
  }
}

/// 05.8: version, system, time zone, licences and typefaces.
class About extends StatelessWidget {
  const About(this.store, {super.key});
  final Store store;

  @override
  Widget build(BuildContext context) {
    final t = Tok.of(context), l = l10n(context), now = DateTime.now();
    final off = now.timeZoneOffset, sign = off.isNegative ? '−' : '+';
    final utc = 'UTC$sign${off.inHours.abs()}${off.inMinutes % 60 == 0 ? '' : ':${(off.inMinutes.abs() % 60).toString().padLeft(2, '0')}'}';
    return FutureBuilder(
      future: Future.wait([store.deviceInfo(), store.timeZone()]),
      builder: (context, snap) {
        final info = (snap.data?[0] as Map<String, String>?) ?? const {};
        final zone = (snap.data?[1] as String?)?.split('/').last.replaceAll('_', ' ');
        final version = (info['version'] ?? '').replaceAll('-dev', '');
        return _page(context, l.settings, [
          _head(context, l.about, null),
          const SizedBox(height: 16),
          SizedBox(
            height: 56,
            child: Row(crossAxisAlignment: CrossAxisAlignment.end, spacing: 16, children: [
              Flexible(child: FittedBox(child: Text(version.isEmpty ? '—' : version, style: T.displayLg(t.display)))),
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Lbl((info['version'] ?? '').endsWith('-dev') ? l.devVersion : l.stableVersion),
              ),
            ]),
          ),
          const SizedBox(height: 16),
          Text(l.appTitle, style: T.headlineLg(t.display)),
          Group(children: [
            if (info['build'] != null) ValueRow(l.build, value: info['build']),
            if (info['android'] != null) ValueRow(l.system, value: 'Android ${info['android']}'),
            ValueRow(l.timeZone, value: [?zone, utc].join(' · ')),
          ]),
          Section(left: l.legal, children: [
            ValueRow(l.licenses, onTap: () => showLicensePage(context: context, applicationName: l.appTitle, applicationVersion: version)),
            RowItem(children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, spacing: 2, children: [
                    Text(l.typefaces),
                    Text('NDOT 57 · NTYPE 82 · LETTERA MONO', style: T.caption(t.secondary)),
                  ]),
                ),
              ),
            ]),
          ]),
        ]);
      },
    );
  }
}
