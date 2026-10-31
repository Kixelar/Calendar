import 'package:flutter/material.dart';

import '../google.dart';
import '../store.dart';
import '../theme.dart';
import '../ui.dart';

/// What the invite screen hands back: the full guest list and what guests may do.
typedef InviteResult = ({List<Guest> guests, bool invite, bool modify, bool see});

final _email = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

/// 03.4: pick guests from people in your events or by e-mail, set guest permissions.
class Invite extends StatefulWidget {
  const Invite(this.store, {super.key, required this.subtitle, required this.initial, required this.sendLabel});
  final Store store;
  final String subtitle; // "Demo sprintu · Pt 30 paź"
  final InviteResult initial;
  final String sendLabel; // "Send" from the details screen, "Done" from the edit screen
  @override
  State<Invite> createState() => _InviteState();
}

class _InviteState extends State<Invite> {
  final _q = TextEditingController();
  late final _guests = [...widget.initial.guests];
  late bool invite = widget.initial.invite, modify = widget.initial.modify, see = widget.initial.see;

  @override
  void dispose() {
    _q.dispose();
    super.dispose();
  }

  void _add(Guest g) => setState(() {
        _guests.add(g);
        _q.clear();
      });

  @override
  Widget build(BuildContext context) => ListenableBuilder(listenable: widget.store, builder: _build); // suggestions grow as events load

  Widget _build(BuildContext context, Widget? _) {
    final t = Tok.of(context), l = l10n(context);
    final q = _q.text.trim().toLowerCase();
    final chosen = {for (final g in _guests) g.email.toLowerCase()};
    final suggestions = [
      for (final p in widget.store.people)
        if (!chosen.contains(p.email.toLowerCase()) && (q.isEmpty || p.name.toLowerCase().contains(q) || p.email.toLowerCase().contains(q))) p,
    ].take(8).toList();
    // A typed address nobody has used before can be invited directly.
    if (_email.hasMatch(q) && !chosen.contains(q) && !suggestions.any((p) => p.email.toLowerCase() == q)) {
      suggestions.insert(0, Guest(_q.text.trim(), _q.text.trim(), 'needsAction'));
    }
    Widget person(Guest g, {required bool selected}) => RowItem(children: [
          Avatar(g.name, filled: selected),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, spacing: 2, children: [
              Text(g.name, maxLines: 1, overflow: TextOverflow.ellipsis),
              if (g.email != g.name) Text(g.email, maxLines: 1, overflow: TextOverflow.ellipsis, style: T.caption(t.secondary)),
            ]),
          ),
          Transform.translate(
            offset: const Offset(10, 0),
            child: selected
                ? IconBtn(Icons.close, label: '${l.delete} ${g.name}', onTap: () => setState(() => _guests.remove(g)))
                : IconBtn(Icons.add, label: '${l.add} ${g.name}', onTap: () => _add(g)),
          ),
        ]);
    Widget perm(String label, bool v, ValueChanged<bool> set) =>
        RowItem(children: [Expanded(child: Text(label)), Toggle(value: v, label: label, onChanged: (x) => setState(() => set(x)))]);
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
                TextButton(
                  onPressed: () => Navigator.pop<InviteResult>(context, (guests: _guests, invite: invite, modify: modify, see: see)),
                  child: Text(widget.sendLabel.toUpperCase(), style: T.labelMd(t.display)),
                ),
              ]),
            ),
          ),
          Expanded(
            child: ListView(padding: const EdgeInsets.fromLTRB(24, 24, 24, 24), children: [
              Lbl(widget.subtitle),
              const SizedBox(height: 8),
              Text(l.inviteTitle, style: T.headlineLg(t.display)),
              const SizedBox(height: 24),
              Container(
                height: 48,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(color: t.surface, border: Border.all(color: t.borderControl), borderRadius: BorderRadius.circular(6)),
                child: Row(spacing: 8, children: [
                  Icon(Icons.search, size: 20, color: t.secondary),
                  Expanded(
                    child: TextField(
                      controller: _q,
                      keyboardType: TextInputType.emailAddress,
                      onChanged: (_) => setState(() {}),
                      onSubmitted: (s) {
                        if (_email.hasMatch(s.trim()) && !chosen.contains(s.trim().toLowerCase())) _add(Guest(s.trim(), s.trim(), 'needsAction'));
                      },
                      style: T.body(t.primary),
                      cursorColor: t.display,
                      decoration: InputDecoration.collapsed(hintText: l.nameOrEmail, hintStyle: T.body(t.secondary)),
                    ),
                  ),
                ]),
              ),
              if (_guests.isNotEmpty) Section(left: l.selected, children: [for (final g in _guests) person(g, selected: true)]),
              if (suggestions.isNotEmpty) Section(left: l.suggestions, children: [for (final g in suggestions) person(g, selected: false)]),
              Section(left: l.guestsCan, children: [
                perm(l.canInvite, invite, (v) => invite = v),
                perm(l.canModify, modify, (v) => modify = v),
                perm(l.canSee, see, (v) => see = v),
              ]),
              const SizedBox(height: 16),
              Text(l.inviteNote, style: T.caption(t.secondary)),
            ]),
          ),
        ]),
      ),
    );
  }
}
