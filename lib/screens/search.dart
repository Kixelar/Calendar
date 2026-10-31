import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../google.dart';
import '../store.dart';
import '../theme.dart';
import '../ui.dart';

/// 02.5: Google full-text search with calendar / "with guests" filters and recent searches.
class Search extends StatefulWidget {
  const Search(this.store, {super.key, required this.backLabel});
  final Store store;
  final String backLabel; // the view the user came from
  @override
  State<Search> createState() => _SearchState();
}

class _SearchState extends State<Search> {
  static const _recentKey = 'recentSearches', _recentMax = 6, _guests = '#guests';
  final _q = TextEditingController();
  Timer? _debounce;
  List<Ev>? _results;
  String? _error, _filter; // filter: null = all, a calendar id, or _guests
  bool _busy = false;
  int _seq = 0; // drops answers to older queries that arrive late

  Store get store => widget.store;
  List<String> get _recent => store.prefs.getStringList(_recentKey) ?? const [];

  @override
  void dispose() {
    _debounce?.cancel();
    _q.dispose();
    super.dispose();
  }

  void _changed(String _) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), _run);
    setState(() {});
  }

  Future<void> _run() async {
    final q = _q.text.trim(), seq = ++_seq;
    if (q.isEmpty) {
      setState(() {
        _results = null;
        _busy = false;
      });
      return;
    }
    setState(() => _busy = true);
    try {
      final r = await store.g.search([for (final c in store.cals) if (c.on) c], q);
      if (seq != _seq || !mounted) return;
      await store.prefs.setStringList(_recentKey, [q, ..._recent.where((s) => s != q)].take(_recentMax).toList());
      setState(() {
        _results = r;
        _error = null;
      });
    } catch (e) {
      if (seq == _seq && mounted) setState(() => _error = '$e');
    } finally {
      if (seq == _seq && mounted) setState(() => _busy = false);
    }
  }

  void _use(String q) {
    _q.text = q;
    _run();
  }

  @override
  Widget build(BuildContext context) {
    final t = Tok.of(context), l = l10n(context), now = DateTime.now();
    final own = [for (final c in store.cals) if (c.on && !c.holiday && !c.shared) c];
    final shown = (_results ?? const <Ev>[]).where((e) => switch (_filter) {
          null => true,
          _guests => e.guests.isNotEmpty,
          final id => e.calId == id,
        });
    final upcoming = [for (final e in shown) if (e.end.isAfter(now)) e];
    final past = [for (final e in shown) if (!e.end.isAfter(now)) e].reversed.toList(); // most recent first
    Widget row(Ev e, bool isPast) {
      final when = e.allDay ? l.allDay : '${hm(context, e.start)}–${hm(context, e.end)}';
      final info = [l.weekdays.split(',')[e.start.weekday - 1], when, if (e.location?.isNotEmpty ?? false) e.location!].join(' · ');
      return RowItem(onTap: () => openEvent(context, e, store), children: [
        SizedBox(
          width: 48,
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, spacing: 2, children: [
            Lbl(DateFormat.LLL(loc(context)).format(e.start).replaceAll('.', '')),
            Text('${e.start.day}', style: T.displayMd(isPast ? t.secondary : t.display)),
          ]),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, spacing: 2, children: [
              Text(e.title, maxLines: 1, overflow: TextOverflow.ellipsis, style: T.body(isPast ? t.secondary : t.display)),
              Text(info.toUpperCase(), maxLines: 1, overflow: TextOverflow.ellipsis, style: T.caption(t.secondary)),
            ]),
          ),
        ),
        Marker(store.cal(e.calId)?.shape ?? Shape.dot),
      ]);
    }

    Widget note(String s, Color c) => Padding(padding: const EdgeInsets.only(top: 32), child: Text(s, style: T.body(c)));

    return Scaffold(
      body: SafeArea(
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          BackBar(label: widget.backLabel),
          Expanded(
            child: ListView(padding: const EdgeInsets.fromLTRB(24, 24, 24, 24), children: [
              Container(
                height: 48,
                padding: const EdgeInsets.only(left: 12),
                decoration: BoxDecoration(color: t.surface, border: Border.all(color: t.borderControl), borderRadius: BorderRadius.circular(6)),
                child: Row(spacing: 8, children: [
                  Icon(Icons.search, size: 20, color: t.secondary),
                  Expanded(
                    child: TextField(
                      controller: _q,
                      autofocus: true,
                      onChanged: _changed,
                      onSubmitted: (_) => _run(),
                      textInputAction: TextInputAction.search,
                      style: T.body(t.primary),
                      cursorColor: t.display,
                      decoration: InputDecoration.collapsed(hintText: l.searchHint, hintStyle: T.body(t.secondary)),
                    ),
                  ),
                  if (_q.text.isNotEmpty)
                    IconBtn(Icons.close, label: l.clear, onTap: () {
                      _q.clear();
                      _changed('');
                    }),
                ]),
              ),
              const SizedBox(height: 16),
              Wrap(spacing: 8, runSpacing: 8, children: [
                Chip2(l.filterAll, pressed: _filter == null, onTap: () => setState(() => _filter = null)),
                for (final c in own)
                  Chip2(c.name,
                      pressed: _filter == c.id,
                      leading: Transform.scale(scale: 0.8, child: Marker(c.shape, color: _filter == c.id ? t.bg : null)),
                      onTap: () => setState(() => _filter = c.id)),
                Chip2(l.withGuests, pressed: _filter == _guests, onTap: () => setState(() => _filter = _guests)),
              ]),
              if (_busy)
                Padding(
                  padding: const EdgeInsets.only(top: 32),
                  child: Center(child: SizedBox.square(dimension: 16, child: CircularProgressIndicator(strokeWidth: 1.5, color: t.secondary))),
                )
              else if (_error != null)
                note(l.failed(_error!), t.accentText)
              else if (_results != null && shown.isEmpty)
                note(l.noResults, t.secondary),
              if (upcoming.isNotEmpty) Section(left: l.upcoming, right: '${upcoming.length}', children: [for (final e in upcoming) row(e, false)]),
              if (past.isNotEmpty) Section(left: l.past, right: '${past.length}', children: [for (final e in past) row(e, true)]),
              if (_recent.isNotEmpty)
                Section(
                  left: l.recentSearches,
                  trailing: InkWell(
                    onTap: () async {
                      await store.prefs.remove(_recentKey);
                      setState(() {});
                    },
                    child: Lbl(l.clear),
                  ),
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 16),
                      child: Wrap(spacing: 8, runSpacing: 8, children: [for (final s in _recent) Chip2(s, onTap: () => _use(s))]),
                    ),
                  ],
                ),
            ]),
          ),
        ]),
      ),
    );
  }
}
