import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../google.dart';
import '../store.dart';
import '../theme.dart';
import '../ui.dart';

/// Mockup screens 01.1 (welcome), 01.2 (connect Google) and 01.3 (choose calendars).

Widget _screen(BuildContext c, {required Widget top, required List<Widget> body, required List<Widget> foot}) => Scaffold(
      body: SafeArea(
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          top,
          Expanded(
            child: ListView(padding: const EdgeInsets.symmetric(horizontal: 24), children: body),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
            child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, spacing: 8, children: foot),
          ),
        ]),
      ),
    );

Widget _head(BuildContext c, String? over, String title) => Padding(
      padding: const EdgeInsets.only(top: 24),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, spacing: 8, children: [
        if (over != null) Lbl(over),
        Text(title, style: T.headlineLg(Tok.of(c).display)),
      ]),
    );

class Welcome extends StatelessWidget {
  const Welcome(this.store, {super.key});
  final Store store;

  @override
  Widget build(BuildContext context) {
    final t = Tok.of(context), l = l10n(context), now = DateTime.now();
    final date = '${DateFormat.EEEE(loc(context)).format(now)} · ${DateFormat.LLLL(loc(context)).format(now)}';
    return Scaffold(
      body: SafeArea(
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 0),
            child: SizedBox(
              height: 44,
              child: Align(
                alignment: Alignment.centerRight,
                child: TextButton(onPressed: store.finishOnboarding, child: Text(l.skip.toUpperCase(), style: T.labelMd(t.secondary))),
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const SizedBox(height: 24),
                Lbl(l.appTitle),
                Expanded(
                  child: Column(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.start, spacing: 24, children: [
                    Row(crossAxisAlignment: CrossAxisAlignment.end, spacing: 16, children: [
                      Text('${now.day}', style: T.displayXl(t.display)),
                      Padding(padding: const EdgeInsets.only(bottom: 8), child: Lbl(date)),
                    ]),
                    Text(l.welcomeTitle, style: T.headlineLg(t.display)),
                    Text(l.welcomeBody, style: T.body(t.secondary)),
                  ]),
                ),
                SizedBox(
                  width: 96,
                  child: Row(spacing: 4, children: [
                    for (var i = 0; i < 3; i++)
                      Expanded(
                        child: Container(
                          height: 8,
                          decoration: BoxDecoration(color: i == 0 ? t.display : t.dotOff, borderRadius: BorderRadius.circular(2)),
                        ),
                      ),
                  ]),
                ),
              ]),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
            child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, spacing: 8, children: [
              Btn(l.connectGoogle, onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => Connect(store)))),
              Btn(l.continueWithout, kind: BtnKind.text, onTap: store.finishOnboarding),
            ]),
          ),
        ]),
      ),
    );
  }
}

class Connect extends StatefulWidget {
  const Connect(this.store, {super.key});
  final Store store;
  @override
  State<Connect> createState() => _ConnectState();
}

class _ConnectState extends State<Connect> {
  bool busy = false;

  Future<void> _signIn() async {
    final l = l10n(context);
    if (serverClientId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l.noClientId)));
      return;
    }
    setState(() => busy = true);
    try {
      await widget.store.signIn();
      if (mounted) await Navigator.push(context, MaterialPageRoute(builder: (_) => Choose(widget.store, onboarding: true)));
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l.signInFailed('$e'))));
    }
    if (mounted) setState(() => busy = false);
  }

  @override
  Widget build(BuildContext context) {
    final t = Tok.of(context), l = l10n(context);
    Widget item(IconData i, String s, bool ok) => RowItem(children: [
          Icon(i, size: 20, color: ok ? t.display : t.secondary),
          Expanded(child: Text(s, style: T.body(ok ? t.primary : t.secondary))),
        ]);
    return _screen(context, top: const BackBar(), body: [
      _head(context, l.step(1), l.connectTitle),
      Section(left: l.weAskFor, children: [
        item(Icons.check, l.accessEvents, true),
        item(Icons.check, l.accessCalendars, true),
        item(Icons.check, l.accessInvites, true),
        item(Icons.check, l.accessEmail, true),
      ]),
      Section(left: l.noAccessTo, children: [
        item(Icons.close, l.noAccessFiles, false),
        item(Icons.close, l.noAccessContacts, false),
      ]),
    ], foot: [
      Btn(l.signInGoogle, busy: busy, onTap: _signIn),
    ]);
  }
}

/// Calendar picker; also opened from the main screen's calendars button ([onboarding] false).
class Choose extends StatelessWidget {
  const Choose(this.store, {super.key, required this.onboarding});
  final Store store;
  final bool onboarding;

  @override
  Widget build(BuildContext context) {
    final l = l10n(context);
    return ListenableBuilder(
      listenable: store,
      builder: (context, _) {
        Widget row(Cal c) => RowItem(children: [
              Marker(c.shape),
              Expanded(child: Text(c.name, maxLines: 1, overflow: TextOverflow.ellipsis)),
              Toggle(value: c.on, label: c.name, onChanged: (v) => store.toggle(c, v)),
            ]);
        final own = store.cals.where((c) => !c.shared && !c.holiday);
        final shared = store.cals.where((c) => c.shared);
        final holidays = store.cals.where((c) => c.holiday);
        final n = store.cals.where((c) => c.on).length;
        return _screen(context, top: const BackBar(), body: [
          _head(context, onboarding ? l.step(2) : null, onboarding ? l.chooseTitle : l.calendars),
          Section(
            left: 'Google',
            trailing: Text(store.email ?? '', style: T.caption(Tok.of(context).secondary)),
            children: [for (final c in own) row(c)],
          ),
          if (shared.isNotEmpty) Section(left: l.sharedWithYou, children: [for (final c in shared) row(c)]),
          if (holidays.isNotEmpty) Section(left: l.suggested, children: [for (final c in holidays) row(c)]),
        ], foot: [
          Btn(onboarding ? l.syncN(n) : l.done, onTap: () {
            if (onboarding) {
              Navigator.push(context, MaterialPageRoute(builder: (_) => Syncing(store)));
            } else {
              Navigator.pop(context);
            }
          }),
        ]);
      },
    );
  }
}

/// 01.4: fetches this year's events calendar by calendar, showing progress. "Run in background" leaves at once.
class Syncing extends StatefulWidget {
  const Syncing(this.store, {super.key});
  final Store store;
  @override
  State<Syncing> createState() => _SyncingState();
}

class _SyncingState extends State<Syncing> {
  final _count = <String, int>{}; // calendar id -> events fetched
  final _failed = <String>{};
  final _watch = Stopwatch();
  late final _list = [for (final c in widget.store.cals) if (c.on) c];
  int _current = 0;
  bool _finished = false;

  @override
  void initState() {
    super.initState();
    _run();
  }

  Future<void> _run() async {
    final store = widget.store, year = DateTime.now().year, all = <Ev>[];
    _watch.start();
    for (final (i, c) in _list.indexed) {
      if (mounted) setState(() => _current = i);
      try {
        final evs = await store.g.events([c], DateTime(year), DateTime(year + 1));
        all.addAll(evs);
        _count[c.id] = evs.length;
      } catch (_) {
        _failed.add(c.id); // the main screen fetches again and shows the error
      }
    }
    store.putYear(year, all..sort((a, b) => a.start.compareTo(b.start)));
    if (mounted) setState(() => _finished = true);
  }

  Future<void> _leave() async {
    Navigator.of(context).popUntil((r) => r.isFirst);
    await widget.store.finishOnboarding();
  }

  @override
  Widget build(BuildContext context) {
    final t = Tok.of(context), l = l10n(context);
    final done = _count.length + _failed.length, total = _list.length;
    final pct = total == 0 ? 100 : done * 100 ~/ total;
    final left = done == 0 || _finished ? null : (_watch.elapsed.inSeconds / done * (total - done)).ceil();
    final events = _count.values.fold(0, (a, b) => a + b);
    String status(int i, Cal c) => _failed.contains(c.id)
        ? l.statusFailed
        : _count.containsKey(c.id)
            ? l.statusDone
            : i == _current
                ? l.statusRunning
                : l.statusQueued;
    Color color(int i, Cal c) => _failed.contains(c.id)
        ? t.accentText
        : _count.containsKey(c.id)
            ? t.success
            : i == _current
                ? t.display
                : t.secondary;
    return _screen(context, top: const SizedBox(height: 56), body: [
      _head(context, l.step(3), l.syncing),
      const SizedBox(height: 40),
      Row(crossAxisAlignment: CrossAxisAlignment.end, spacing: 16, children: [
        Text('$events', style: T.displayXl(t.display)),
        Expanded(child: Padding(padding: const EdgeInsets.only(bottom: 8), child: Lbl(l.eventsFrom(total)))),
      ]),
      const SizedBox(height: 24),
      Semantics(
        value: '$pct%',
        child: Row(spacing: 4, children: [
          for (var i = 0; i < 10; i++)
            Expanded(
              child: Container(
                height: 8,
                decoration: BoxDecoration(color: i < pct ~/ 10 ? t.display : t.dotOff, borderRadius: BorderRadius.circular(2)),
              ),
            ),
        ]),
      ),
      const SizedBox(height: 8),
      Row(children: [
        Text('$pct%', style: T.caption(t.display)),
        const Spacer(),
        if (left != null) Text(l.aboutSecondsLeft(left), style: T.caption(t.secondary)),
      ]),
      Section(left: l.calendars, children: [
        for (final (i, c) in _list.indexed)
          RowItem(children: [
            Marker(c.shape),
            Expanded(child: Text(c.name, maxLines: 1, overflow: TextOverflow.ellipsis)),
            Lbl(status(i, c), color: color(i, c)),
          ]),
      ]),
    ], foot: [
      Btn(_finished ? l.done : l.runInBackground, kind: _finished ? BtnKind.primary : BtnKind.secondary, onTap: _leave),
    ]);
  }
}
