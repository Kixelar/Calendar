import 'package:flutter/material.dart';

import '../store.dart';
import '../theme.dart';
import '../ui.dart';
import 'event.dart';

/// 05.3: reminders, daily summary and invitation notifications. The mockup's Glyph section waits for the Glyph SDK.
class Notifications extends StatelessWidget {
  const Notifications(this.store, {super.key});
  final Store store;

  @override
  Widget build(BuildContext context) => ListenableBuilder(
        listenable: store,
        builder: (context, _) {
          final t = Tok.of(context), l = l10n(context), p = store.notifyPrefs;
          String clock(int minutes) => hm(context, DateTime(2000, 1, 1, minutes ~/ 60, minutes % 60));
          Widget toggle(String label, bool v, String key) =>
              RowItem(children: [Expanded(child: Text(label)), Toggle(value: v, label: label, onChanged: (x) => store.set(key, x))]);
          return Scaffold(
            body: SafeArea(
              child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                BackBar(label: l.settings),
                Expanded(
                  child: ListView(padding: const EdgeInsets.fromLTRB(24, 24, 24, 24), children: [
                    Lbl(l.settings),
                    const SizedBox(height: 8),
                    Text(l.notifications, style: T.headlineLg(t.display)),
                    Section(left: l.reminders, children: [
                      ValueRow(l.defaultLabel, value: p.defaultReminder < 0 ? l.none : reminderText(l, p.defaultReminder), onTap: () async {
                        final r = await pick<int>(context, Pick(
                          title: l.defaultLabel,
                          selected: p.defaultReminder,
                          options: [
                            for (final m in {-1, 0, 5, 10, 15, 30, 60, p.defaultReminder}) (m, m < 0 ? l.none : reminderText(l, m)),
                            (-3, '${l.custom}…'),
                          ],
                        ));
                        if (r == null || !context.mounted) return;
                        final m = r.$1 == -3 ? await askReminder(context) : r.$1;
                        if (m != null) await store.set('defaultReminder', m);
                      }),
                      ValueRow(l.allDayEvents, value: p.allDayAt < 0 ? l.off2 : l.dayBeforeAt(clock(p.allDayAt)), onTap: () async {
                        final r = await pick<int>(context, Pick(
                          title: l.allDayEvents,
                          selected: p.allDayAt,
                          options: [for (final m in [-1, 8 * 60, 9 * 60, 18 * 60, 20 * 60]) (m, m < 0 ? l.off2 : l.dayBeforeAt(clock(m)))],
                        ));
                        if (r != null) await store.set('allDayAt', r.$1);
                      }),
                      RowItem(
                        onTap: p.summary
                            ? () async {
                                final r = await showTimePicker(context: context, initialTime: TimeOfDay(hour: p.summaryAt ~/ 60, minute: p.summaryAt % 60));
                                if (r != null) await store.set('summaryAt', r.hour * 60 + r.minute);
                              }
                            : null,
                        children: [
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              child: Column(crossAxisAlignment: CrossAxisAlignment.start, spacing: 2, children: [
                                Text(l.dailySummary),
                                Text(l.everyDayAt(clock(p.summaryAt)).toUpperCase(), style: T.caption(t.secondary)),
                              ]),
                            ),
                          ),
                          Toggle(value: p.summary, label: l.dailySummary, onChanged: (x) => store.set('summary', x)),
                        ],
                      ),
                    ]),
                    Section(left: l.invitations, children: [
                      toggle(l.newInvitations, p.invites, 'notifyInvites'),
                      toggle(l.sharedChanges, p.sharedChanges, 'notifyShared'),
                    ]),
                  ]),
                ),
              ]),
            ),
          );
        },
      );
}
