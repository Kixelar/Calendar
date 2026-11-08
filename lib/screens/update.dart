import 'package:flutter/material.dart';

import '../store.dart';
import '../theme.dart';
import '../ui.dart';

/// Opens the update screen with the installed version for comparison.
Future<void> openUpdate(BuildContext context, Store store) async {
  final u = store.update;
  if (u == null) return;
  final current = (await store.deviceInfo())['version']?.replaceAll('-dev', '') ?? '';
  if (context.mounted) await Navigator.push(context, MaterialPageRoute(builder: (_) => UpdateScreen(store, u, current: current)));
}

/// Red dot used next to anything that says a new version is out.
Widget redDot(BuildContext c) =>
    Container(width: 6, height: 6, decoration: BoxDecoration(color: Tok.of(c).accent, shape: BoxShape.circle));

/// Proposal A (owner, 2026-11-08): new version, what changed, download.
class UpdateScreen extends StatelessWidget {
  const UpdateScreen(this.store, this.update, {super.key, required this.current});
  final Store store;
  final Update update;
  final String current;

  @override
  Widget build(BuildContext context) {
    final t = Tok.of(context), l = l10n(context);
    final size = update.size == null ? null : '${(update.size! / 1048576).toStringAsFixed(1)} MB';
    return Scaffold(
      body: SafeArea(
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          BackBar(label: l.about),
          Expanded(
            child: ListView(padding: const EdgeInsets.fromLTRB(24, 24, 24, 24), children: [
              Row(spacing: 8, children: [redDot(context), Lbl(l.newVersion)]),
              const SizedBox(height: 16),
              FittedBox(alignment: Alignment.centerLeft, fit: BoxFit.scaleDown, child: Text(update.version, style: T.displayLg(t.display))),
              const SizedBox(height: 8),
              Lbl([l.currentVersion(current), ?size].join(' · ')),
              if (update.notes.isNotEmpty)
                Section(left: l.whatsNew, children: [
                  for (final n in update.notes)
                    RowItem(children: [
                      Expanded(child: Padding(padding: const EdgeInsets.symmetric(vertical: 12), child: Text(n))),
                    ]),
                ]),
            ]),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
            child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, spacing: 8, children: [
              // shortcut: download and install come with the update check (TODO 05.8).
              Btn(l.downloadInstall, onTap: null),
              Btn(l.later, kind: BtnKind.secondary, onTap: () {
                store.dismissUpdate();
                Navigator.pop(context);
              }),
            ]),
          ),
        ]),
      ),
    );
  }
}

/// Proposal B: a small card above the view tabs while a new version waits; the cross hides it until the next one.
class UpdateBanner extends StatelessWidget {
  const UpdateBanner(this.store, {super.key, required this.onOpen});
  final Store store;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    final t = Tok.of(context), l = l10n(context), u = store.update;
    if (u == null || store.updateDismissed == u.version) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 0),
      child: Material(
        color: t.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: t.borderSubtle)),
        child: InkWell(
          onTap: onOpen,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 4, 4),
            child: Row(spacing: 12, children: [
              redDot(context),
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, spacing: 2, children: [
                  Text(l.newVersionN(u.version), style: T.body(t.display)),
                  Text(l.tapToSee.toUpperCase(), style: T.caption(t.secondary)),
                ]),
              ),
              IconBtn(Icons.close, label: l.later, onTap: store.dismissUpdate),
            ]),
          ),
        ),
      ),
    );
  }
}
