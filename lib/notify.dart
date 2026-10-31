import 'dart:convert';
import 'dart:ui';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:intl/intl.dart';
import 'package:timezone/data/latest.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

import 'google.dart';
import 'l10n/app_localizations.dart';

/// 05.3 notification settings. Minutes are before the event; -1 = off.
class NotifyPrefs {
  const NotifyPrefs({
    this.defaultReminder = 10,
    this.allDayAt = 9 * 60,
    this.summary = true,
    this.summaryAt = 7 * 60 + 30,
    this.invites = true,
    this.sharedChanges = true,
    this.hideOnLock = true,
  });
  final int defaultReminder; // for events whose calendar has no reminder
  final int allDayAt; // minutes after midnight, the day before an all-day event
  final bool summary;
  final int summaryAt; // minutes after midnight
  final bool invites, sharedChanges, hideOnLock;
}

/// One notification to schedule.
class Planned {
  const Planned(this.id, this.at, this.title, this.body, this.payload, {this.summary = false});
  final int id;
  final DateTime at;
  final String title, body, payload;
  final bool summary;
}

/// Payload that leads back to an event: calendar, event id and its start (for finding the day).
String eventPayload(Ev e) => jsonEncode({'c': e.calId, 'i': e.id, 's': e.start.millisecondsSinceEpoch});

int _id(String key) => key.hashCode & 0x3fffffff;

/// What to notify in the next [days] days: event reminders, all-day reminders the day before and daily summaries.
List<Planned> plan(List<Ev> evs, DateTime now, NotifyPrefs p, AppLocalizations l, String locale, {int days = 7}) {
  final until = now.add(Duration(days: days));
  final hm = DateFormat.Hm(locale);
  final out = <Planned>[];
  final seen = <String>{};
  for (final e in evs) {
    if (!seen.add('${e.calId}|${e.id}|${e.start}') || e.me?.status == 'declined') continue;
    DateTime? at;
    String body;
    if (e.allDay) {
      if (p.allDayAt < 0) continue;
      at = DateTime(e.start.year, e.start.month, e.start.day - 1).add(Duration(minutes: p.allDayAt));
      body = '${DateFormat.EEEE(locale).format(e.start)} · ${l.allDay}';
    } else {
      // An explicit "none" in Google stays none; a calendar without a default falls back to the app's default.
      final m = e.customReminder ? e.reminder : e.reminder ?? (p.defaultReminder < 0 ? null : p.defaultReminder);
      if (m == null) continue;
      at = e.start.subtract(Duration(minutes: m));
      body = [m == 0 ? l.atStart : l.inMin(m), '${hm.format(e.start)}–${hm.format(e.end)}', if (e.location?.isNotEmpty ?? false) e.location!]
          .join(' · ');
    }
    if (at.isAfter(now) && at.isBefore(until)) out.add(Planned(_id('${e.id}${e.start}'), at, e.title, body, eventPayload(e)));
  }
  if (p.summary) {
    for (var d = 0; d < days; d++) {
      final day = DateTime(now.year, now.month, now.day + d);
      final at = day.add(Duration(minutes: p.summaryAt));
      if (!at.isAfter(now)) continue;
      final today = [
        for (final e in evs)
          if (!e.allDay && e.me?.status != 'declined' && DateTime(e.start.year, e.start.month, e.start.day) == day) e,
      ]..sort((a, b) => a.start.compareTo(b.start));
      if (today.isEmpty) continue;
      out.add(Planned(_id('summary$day'), at, l.summaryTitle(today.length),
          [for (final e in today.take(3)) '${hm.format(e.start)} ${e.title}'].join(' · '), '', summary: true));
    }
  }
  return out;
}

const _snooze = 'snooze', details = 'details';

/// Shows and schedules Android notifications (07.3). [onOpen] gets the payload and action of a tapped notification.
class Notifier {
  final _p = FlutterLocalNotificationsPlugin();
  void Function(String payload, String? action)? onOpen;
  bool _ready = false;

  /// [background]: in the sync job, without asking for permission or reading a launch tap.
  Future<void> init(String timeZone, {bool background = false}) async {
    if (_ready) return;
    tzdata.initializeTimeZones();
    try {
      tz.setLocalLocation(tz.getLocation(timeZone));
    } catch (_) {} // unknown zone: the plugin falls back to UTC offsets
    await _p.initialize(
      settings: const InitializationSettings(android: AndroidInitializationSettings('ic_notification')),
      onDidReceiveNotificationResponse: (r) => onOpen?.call(r.payload ?? '', r.actionId),
      onDidReceiveBackgroundNotificationResponse: notificationTapBackground,
    );
    _ready = true;
    if (background) return;
    await _p.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()?.requestNotificationsPermission();
    final launch = await _p.getNotificationAppLaunchDetails();
    if (launch?.didNotificationLaunchApp ?? false) {
      final r = launch!.notificationResponse;
      if (r != null) onOpen?.call(r.payload ?? '', r.actionId);
    }
  }

  static AndroidNotificationDetails _channel(AppLocalizations l, String id, String name, bool hide, {List<AndroidNotificationAction>? actions}) =>
      AndroidNotificationDetails(id, name,
          importance: Importance.high,
          priority: Priority.high,
          category: AndroidNotificationCategory.event,
          visibility: hide ? NotificationVisibility.private : NotificationVisibility.public,
          actions: actions);

  /// Replaces all scheduled reminders and summaries with [plans].
  Future<void> reschedule(List<Planned> plans, AppLocalizations l, NotifyPrefs p) async {
    if (!_ready) return;
    await _p.cancelAllPendingNotifications();
    for (final n in plans) {
      final nd = NotificationDetails(
        android: n.summary
            ? _channel(l, 'summary', l.dailySummary, p.hideOnLock)
            : _channel(l, 'reminders', l.reminders, p.hideOnLock, actions: [
                AndroidNotificationAction(_snooze, l.snooze),
                AndroidNotificationAction(details, l.details, showsUserInterface: true),
              ]),
      );
      await _p.zonedSchedule(
        id: n.id,
        scheduledDate: tz.TZDateTime.from(n.at, tz.local),
        notificationDetails: nd,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        title: n.title,
        body: n.body,
        payload: n.summary ? '' : jsonEncode({...jsonDecode(n.payload) as Map, 't': n.title, 'b': n.body}),
      );
    }
  }

  /// A new invitation (07.3): Yes / Maybe / No open the app, which sends the reply.
  Future<void> invitation(Ev e, AppLocalizations l, String locale, NotifyPrefs p, {int clashes = 0}) async {
    if (!_ready) return;
    final hm = DateFormat.Hm(locale);
    await _p.show(
      id: _id('invite${e.id}${e.start}'),
      title: l.invitesYou(e.organizerName ?? '', e.title),
      body: [
        DateFormat.MMMEd(locale).format(e.start),
        '${hm.format(e.start)}–${hm.format(e.end)}',
        if (clashes > 0) l.clashesWith(clashes),
      ].join(' · '),
      notificationDetails: NotificationDetails(
        android: _channel(l, 'invites', l.invitations, p.hideOnLock, actions: [
          AndroidNotificationAction('accepted', l.rsvpYes, showsUserInterface: true),
          AndroidNotificationAction('tentative', l.rsvpMaybe, showsUserInterface: true),
          AndroidNotificationAction('declined', l.rsvpNo, showsUserInterface: true),
        ]),
      ),
      payload: eventPayload(e),
    );
  }

  /// Events changed by others in a shared calendar since the last sync.
  Future<void> sharedChanged(Cal c, int count, AppLocalizations l, NotifyPrefs p) async {
    if (!_ready) return;
    await _p.show(
      id: _id('shared${c.id}'),
      title: l.changesIn(c.name),
      body: l.eventsN(count),
      notificationDetails: NotificationDetails(android: _channel(l, 'shared', l.sharedCalendars, p.hideOnLock)),
    );
  }
}

/// "Snooze 5 min" works without opening the app: shows the same reminder again in five minutes.
@pragma('vm:entry-point')
Future<void> notificationTapBackground(NotificationResponse r) async {
  if (r.actionId != _snooze || r.payload == null || r.payload!.isEmpty) return;
  final j = jsonDecode(r.payload!) as Map;
  final l = lookupAppLocalizations(PlatformDispatcher.instance.locale.languageCode == 'pl' ? const Locale('pl') : const Locale('en'));
  tzdata.initializeTimeZones();
  final p = FlutterLocalNotificationsPlugin();
  await p.initialize(settings: const InitializationSettings(android: AndroidInitializationSettings('ic_notification')));
  await p.zonedSchedule(
    id: r.id ?? 0,
    scheduledDate: tz.TZDateTime.now(tz.UTC).add(const Duration(minutes: 5)),
    notificationDetails: NotificationDetails(
      android: Notifier._channel(l, 'reminders', l.reminders, false, actions: [
        AndroidNotificationAction(_snooze, l.snooze),
        AndroidNotificationAction(details, l.details, showsUserInterface: true),
      ]),
    ),
    androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    title: j['t'] as String?,
    body: j['b'] as String?,
    payload: r.payload,
  );
}
