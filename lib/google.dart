import 'package:extension_google_sign_in_as_googleapis_auth/extension_google_sign_in_as_googleapis_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/calendar/v3.dart' as gcal;

/// Web OAuth client ID from Google Cloud, passed at build time (docs/GOOGLE.md). Not a secret.
const serverClientId = String.fromEnvironment('GOOGLE_SERVER_CLIENT_ID');

/// Read/write events, calendar list and invitation replies; the mockup's "connect Google" screen lists exactly this.
const _scopes = [gcal.CalendarApi.calendarScope];

/// Calendars are told apart by marker shape, not colour (mockup design).
/// Order in which own calendars get shapes: filled ones first. Ring and dash are kept for holidays and shared calendars.
final ownShapes = [
  Shape.dot, Shape.square, Shape.half, Shape.diamond, Shape.triangle, Shape.star, Shape.hexagon, Shape.heart,
  ...Shape.values.where((s) => s.index > Shape.dash.index && !const {Shape.triangle, Shape.star, Shape.hexagon, Shape.heart}.contains(s)),
];

/// The first own shape not in [used] (added to it), so calendars differ; the [n]th in order once all are taken.
Shape freeShape(Set<Shape> used, int n) {
  final s = ownShapes.where((s) => !used.contains(s)).firstOrNull ?? ownShapes[n % ownShapes.length];
  used.add(s);
  return s;
}

/// Calendar markers (owner approved the 18 added on 2026-11-01). Saved by index: only ever append.
enum Shape {
  dot, square, half, diamond, ring, dash,
  triangle, triangleDown, openSquare, openDiamond, plus, cross, star, hexagon, heart,
  target, squareDot, slice, diagonal, bar, pillar, twoDots, openTriangle, topHalf,
}

class Cal {
  final String id, name;
  final bool shared, holiday, writable;
  final Shape shape;
  final int? defaultReminder; // minutes before, applies to events that use the calendar's default reminders
  final String role; // owner, writer, reader or freeBusyReader
  bool on;
  Cal(this.id, this.name,
      {required this.shared,
      required this.holiday,
      required this.shape,
      required this.on,
      this.writable = true,
      this.defaultReminder,
      this.role = 'owner'});

  /// The owner's address for a calendar shared by a person (their primary calendar's id is their e-mail).
  String? get ownerEmail => id.contains('@') && !id.endsWith('calendar.google.com') ? id : null;

  Map<String, Object?> toJson() =>
      {'id': id, 'name': name, 'shared': shared, 'holiday': holiday, 'writable': writable, 'shape': shape.index, 'rem': defaultReminder, 'on': on, 'role': role};
  factory Cal.fromJson(Map<String, Object?> j) => Cal(j['id'] as String, j['name'] as String,
      shared: j['shared'] as bool,
      holiday: j['holiday'] as bool,
      writable: j['writable'] as bool,
      shape: Shape.values[j['shape'] as int],
      defaultReminder: j['rem'] as int?,
      role: (j['role'] as String?) ?? 'owner',
      on: j['on'] as bool);
}

/// Invitation reply as Google stores it: accepted, tentative, declined, needsAction.
class Guest {
  final String name, email, status;
  final bool self;
  const Guest(this.name, this.email, this.status, {this.self = false});

  List<Object> toJson() => [name, email, status, self];
  factory Guest.fromJson(List<Object?> j) => Guest(j[0] as String, j[1] as String, j[2] as String, self: j[3] as bool);
}

class Ev {
  final String id, title, calId;
  final String? location, notes;
  final String? recurringId; // set on an occurrence of a repeating event: the series' id
  final List<String>? recurrence; // RRULE/EXDATE lines of a series being created or edited (03.3); null on occurrences
  final DateTime start, end; // local time; for all-day events end is exclusive midnight
  final bool allDay;
  final bool organizer; // this calendar organizes the event (false for invitations from others)
  final String? organizerName;
  final List<Guest> guests;
  final int? reminder; // minutes before; null = none
  final bool customReminder; // false: the calendar's default reminders apply
  final bool guestsInvite, guestsModify, guestsSee; // what guests may do (03.4), Google's defaults
  final DateTime? updated; // Google's last change, to catch edits made elsewhere meanwhile (06.3)
  const Ev(this.title, this.calId, this.start, this.end,
      {this.id = '',
      this.allDay = false,
      this.location,
      this.notes,
      this.recurringId,
      this.recurrence,
      this.organizer = true,
      this.organizerName,
      this.guests = const [],
      this.reminder,
      this.customReminder = false,
      this.guestsInvite = true,
      this.guestsModify = false,
      this.guestsSee = true,
      this.updated});

  /// A copy saved as a separate new event ("keep both" in 06.3): no id, not part of a series.
  Ev asNew() => Ev(title, calId, start, end,
      allDay: allDay, location: location, notes: notes, recurrence: const [], reminder: reminder, customReminder: customReminder,
      guests: guests, guestsInvite: guestsInvite, guestsModify: guestsModify, guestsSee: guestsSee);

  /// The signed-in user's own reply when they are a guest, otherwise null.
  Guest? get me => guests.where((g) => g.self).firstOrNull;

  /// An invitation from someone else that the user can answer (03.5).
  bool get isInvitation => !organizer && me != null;

  /// Offline cache form (store.dart). Times are kept as epoch milliseconds.
  Map<String, Object?> toJson() => {
        'id': id, 't': title, 'c': calId, 's': start.millisecondsSinceEpoch, 'e': end.millisecondsSinceEpoch, 'a': allDay,
        'l': location, 'n': notes, 'r': recurringId, 'o': organizer, 'on': organizerName, 'g': [for (final g in guests) g.toJson()],
        'm': reminder, 'cm': customReminder, 'p': [guestsInvite, guestsModify, guestsSee], 'u': updated?.millisecondsSinceEpoch,
      };
  factory Ev.fromJson(Map<String, Object?> j) {
    final p = (j['p'] as List?) ?? const [true, false, true];
    return Ev(j['t'] as String, j['c'] as String,
        DateTime.fromMillisecondsSinceEpoch(j['s'] as int), DateTime.fromMillisecondsSinceEpoch(j['e'] as int),
        id: j['id'] as String,
        allDay: j['a'] as bool,
        location: j['l'] as String?,
        notes: j['n'] as String?,
        recurringId: j['r'] as String?,
        organizer: j['o'] as bool,
        organizerName: j['on'] as String?,
        guests: [for (final g in j['g'] as List) Guest.fromJson(g as List)],
        reminder: j['m'] as int?,
        customReminder: (j['cm'] as bool?) ?? false,
        guestsInvite: p[0] as bool,
        guestsModify: p[1] as bool,
        guestsSee: p[2] as bool,
        updated: j['u'] == null ? null : DateTime.fromMillisecondsSinceEpoch(j['u'] as int));
  }
}

enum DeleteScope { one, following, all }

/// One access rule of a calendar (04.4). [scope] is user, group, domain or default (anyone with the link).
class Access {
  const Access(this.id, this.scope, this.email, this.role);
  final String id, scope, role;
  final String? email;
}

/// Public link to a calendar that has `default` read access.
String publicLink(String calId) => 'https://calendar.google.com/calendar/embed?src=${Uri.encodeComponent(calId)}';

/// Saving found that Google changed the event after it was opened here; [remote] is Google's version (06.3).
class EditConflict implements Exception {
  const EditConflict(this.remote);
  final Ev remote;
}


class GoogleCalendar {
  GoogleSignInAccount? user;
  gcal.CalendarApi? _api;
  bool _inited = false;

  String? get email => user?.email;

  Future<void> _init() async {
    if (_inited) return;
    await GoogleSignIn.instance.initialize(serverClientId: serverClientId.isEmpty ? null : serverClientId);
    _inited = true;
  }

  /// Restores calendar access on app start; true when it is still granted.
  /// [silentOnly] (background sync) never falls back to sign-in, which may need UI.
  Future<bool> restore({bool silentOnly = false}) async {
    await _init();
    // Calendar calls need only an authorization token, which Android hands out without UI once granted.
    // Lightweight sign-in would pop an account sheet whenever One Tap auto-select is unavailable, so it is the fallback.
    if (await _authorize(interactive: false)) return true;
    if (silentOnly) return false;
    user = await GoogleSignIn.instance.attemptLightweightAuthentication();
    return user != null && await _authorize(interactive: false);
  }

  /// Interactive sign-in; must be called from a button press.
  Future<void> signIn() async {
    await _init();
    user = await GoogleSignIn.instance.authenticate(scopeHint: _scopes);
    if (!await _authorize(interactive: true)) throw StateError('Calendar access was not granted');
  }

  Future<void> signOut() async {
    await GoogleSignIn.instance.signOut();
    user = null;
    _api = null;
  }

  // Asking the platform each time gives a fresh access token (the plugin hands out no refresh token).
  Future<bool> _authorize({required bool interactive}) async {
    // Without a signed-in user (silent restore) Android uses the account that granted access before.
    final c = user?.authorizationClient ?? GoogleSignIn.instance.authorizationClient;
    final auth = await c.authorizationForScopes(_scopes) ?? (interactive ? await c.authorizeScopes(_scopes) : null);
    if (auth == null) return false;
    _api = gcal.CalendarApi(auth.authClient(scopes: _scopes));
    return true;
  }

  /// [shapes] are markers the user picked (04.5); others follow the default order. Google names the primary
  /// calendar after the account's e-mail; it is shown as [primaryName] (the account name) instead, like Google does.
  /// Hidden calendars are listed too. Contacts' birthdays are left out (owner, 2026-11-01).
  Future<List<Cal>> calendars(Set<String>? enabled, {Map<String, Shape> shapes = const {}, String? primaryName}) async {
    await _authorize(interactive: false);
    final items = <gcal.CalendarListEntry>[];
    String? page;
    do {
      final r = await _api!.calendarList.list(pageToken: page, showHidden: true);
      items.addAll(r.items ?? const []);
      page = r.nextPageToken;
    } while (page != null);
    items.sort((a, b) => (b.primary == true ? 1 : 0) - (a.primary == true ? 1 : 0));
    final used = {...shapes.values};
    var i = 0;
    Shape next() => freeShape(used, i++);

    return [
      for (final e in items.where((e) => !e.id!.contains('#contacts@')))
        () {
          final holiday = e.id!.contains('#holiday@');
          final shared = !holiday && e.accessRole != 'owner';
          final name = e.summaryOverride ?? e.summary ?? e.id!;
          return Cal(e.id!, e.primary == true && name.contains('@') && primaryName != null ? primaryName : name,
              shared: shared,
              holiday: holiday,
              writable: e.accessRole == 'owner' || e.accessRole == 'writer',
              role: e.accessRole ?? 'reader',
              defaultReminder: e.defaultReminders?.where((r) => r.method == 'popup').firstOrNull?.minutes,
              shape: shapes[e.id] ?? (holiday ? Shape.ring : shared ? Shape.dash : next()),
              on: enabled?.contains(e.id) ?? e.selected == true);
        }(),
    ];
  }

  /// 04.2: a new secondary Google calendar.
  /// Returns the new calendar's id.
  Future<String> createCalendar(String name, String timeZone) async {
    await _authorize(interactive: false);
    return (await _api!.calendars.insert(gcal.Calendar(summary: name, timeZone: timeZone))).id!;
  }

  /// Deletes an own calendar with all its events (an address subscription, 04.2).
  Future<void> deleteCalendar(String id) async {
    await _authorize(interactive: false);
    await _api!.calendars.delete(id);
  }

  /// Deletes one event by id, without notifying anyone (address subscriptions drop what left the feed).
  Future<void> deleteEvent(String calId, String id) async {
    await _authorize(interactive: false);
    await _api!.events.delete(calId, id);
  }

  /// Adds an existing calendar (e.g. a holiday calendar, 04.3) to the user's list.
  Future<void> addCalendar(String id) async {
    await _authorize(interactive: false);
    await _api!.calendarList.insert(gcal.CalendarListEntry(id: id));
  }

  /// Removes a calendar from the user's list (it is not deleted for its owner).
  Future<void> removeCalendar(String id) async {
    await _authorize(interactive: false);
    await _api!.calendarList.delete(id);
  }

  /// 04.4: who has access to [calId]: (rule id, scope type, e-mail or null, role).
  Future<List<Access>> access(String calId) async {
    await _authorize(interactive: false);
    final r = await _api!.acl.list(calId);
    return [
      for (final a in r.items ?? const <gcal.AclRule>[])
        Access(a.id ?? '', a.scope?.type ?? 'user', a.scope?.value, a.role ?? 'reader'),
    ];
  }

  /// Shares [calId] with [email] ([role] reader, writer or freeBusyReader); Google e-mails them.
  Future<void> share(String calId, String email, String role) async {
    await _authorize(interactive: false);
    await _api!.acl.insert(gcal.AclRule(role: role, scope: gcal.AclRuleScope(type: 'user', value: email)), calId, sendNotifications: true);
  }

  Future<void> setAccess(String calId, String ruleId, String role) async {
    await _authorize(interactive: false);
    await _api!.acl.patch(gcal.AclRule(role: role), calId, ruleId);
  }

  Future<void> removeAccess(String calId, String ruleId) async {
    await _authorize(interactive: false);
    await _api!.acl.delete(calId, ruleId);
  }

  /// Public read access ("access by link"): a rule with scope type `default`.
  Future<void> setPublic(String calId, bool on) async {
    await _authorize(interactive: false);
    if (on) {
      await _api!.acl.insert(gcal.AclRule(role: 'reader', scope: gcal.AclRuleScope(type: 'default')), calId);
    } else {
      await _api!.acl.delete(calId, 'default');
    }
  }

  /// Events of [cals] that overlap [from, to), recurring events expanded.
  Future<List<Ev>> events(List<Cal> cals, DateTime from, DateTime to) => _list(cals, from, to);

  Future<List<Ev>> _list(List<Cal> cals, DateTime from, DateTime to) async {
    await _authorize(interactive: false);
    final out = <Ev>[];
    await Future.wait(cals.where((c) => !c.id.startsWith('#')).map((cal) async {
      String? page;
      do {
        final r = await _api!.events.list(cal.id,
            timeMin: from.toUtc(), timeMax: to.toUtc(), singleEvents: true, maxResults: 2500, pageToken: page);
        for (final e in r.items ?? const <gcal.Event>[]) {
          if (evOf(e, cal) case final ev?) out.add(ev);
        }
        page = r.nextPageToken;
      } while (page != null);
    }));
    out.sort((a, b) => a.start.compareTo(b.start));
    return out;
  }

  /// Creates [e] (empty id) or updates it; [fromCal] is its calendar before the edit when the user moved it.
  /// [timeZone] (IANA, e.g. Europe/Warsaw) is required by Google for repeating timed events.
  /// Throws [EditConflict] when Google's copy changed after [e] was loaded, unless [force].
  Future<void> save(Ev e, {String? fromCal, required String timeZone, bool force = false}) async {
    await _authorize(interactive: false);
    final api = _api!;
    if (e.id.isNotEmpty && fromCal != null && fromCal != e.calId) await api.events.move(fromCal, e.id, e.calId);
    // Updating the fetched resource keeps conference links and everything this app does not edit.
    final ev = e.id.isEmpty ? gcal.Event() : await api.events.get(e.calId, e.id);
    final seen = e.updated, now = ev.updated?.toLocal();
    if (!force && seen != null && now != null && now.isAfter(seen)) {
      throw EditConflict(evOf(ev, Cal(e.calId, '', shared: false, holiday: false, shape: Shape.dot, on: true))!);
    }
    fillEvent(ev, e, e.start, e.end, timeZone);
    // Occurrences cannot carry a rule; a series or single event can.
    if (e.recurringId == null && e.recurrence != null) ev.recurrence = e.recurrence!.isEmpty ? null : e.recurrence;
    final send = e.guests.isEmpty ? 'none' : 'all';
    if (e.id.isEmpty) {
      await api.events.insert(ev, e.calId, sendUpdates: send);
    } else {
      await api.events.update(ev, e.calId, e.id, sendUpdates: send);
    }
  }

  /// Saves an edited occurrence of a series for "this and following" or "all" (03.2), like Google Calendar:
  /// time changes shift the series by the same amount; [e.recurrence] is the series' new rule ([] = stop repeating).
  /// "This and following" ends the old series before [originalStart] and starts a new one there.
  Future<void> saveSeries(Ev e, DeleteScope scope, {required DateTime originalStart, required String timeZone}) async {
    await _authorize(interactive: false);
    final api = _api!, series = e.recurringId!, send = e.guests.isEmpty ? 'none' : 'all';
    final master = await api.events.get(e.calId, series);
    final first = _at(master.start) ?? originalStart;
    final rule = e.recurrence ?? [for (final r in master.recurrence ?? const <String>[]) if (r.startsWith('RRULE:')) r];
    final shift = e.start.difference(originalStart), length = e.end.difference(e.start);
    if (scope == DeleteScope.all || !originalStart.isAfter(first)) {
      final start = first.add(shift);
      fillEvent(master, e, start, start.add(length), timeZone);
      // Keep exceptions (EXDATE) of the series, replace its rule.
      master.recurrence = rule.isEmpty ? null : [...rule, for (final r in master.recurrence ?? const <String>[]) if (!r.startsWith('RRULE:')) r];
      await api.events.update(master, e.calId, series, sendUpdates: send);
      return;
    }
    master.recurrence = [for (final r in master.recurrence ?? const <String>[]) endRuleBefore(r, originalStart, allDay: e.allDay)];
    await api.events.update(master, e.calId, series, sendUpdates: send);
    // The new series repeats as before (without the old end), unless a new rule was chosen.
    final next = gcal.Event();
    fillEvent(next, e, e.start, e.end, timeZone);
    next.recurrence = [
      for (final r in rule)
        e.recurrence != null ? r : 'RRULE:${r.substring(6).split(';').where((p) => !p.startsWith('UNTIL=') && !p.startsWith('COUNT=')).join(';')}',
    ];
    if (next.recurrence!.isEmpty) next.recurrence = null;
    await api.events.insert(next, e.calId, sendUpdates: send);
  }

  /// Adds an event from an .ics file (04.2 / 05.5). `import` keeps its iCalUID, so importing the same file again
  /// updates those events instead of doubling them. Guests are not invited.
  Future<void> importEvent(String calId, gcal.Event e) async {
    await _authorize(interactive: false);
    await _api!.events.import(e, calId);
  }

  /// Every event of a calendar as Google keeps it (series with their rules, changed and cancelled occurrences),
  /// for the .ics export (05.5).
  Future<List<gcal.Event>> allEvents(String calId) async {
    await _authorize(interactive: false);
    final out = <gcal.Event>[];
    String? page;
    do {
      final r = await _api!.events.list(calId, singleEvents: false, showDeleted: true, maxResults: 2500, pageToken: page);
      out.addAll((r.items ?? const <gcal.Event>[]).where((e) => e.status != 'cancelled' || e.recurringEventId != null));
      page = r.nextPageToken;
    } while (page != null);
    return out;
  }

  /// Recurrence lines of a series, for the "every 2 weeks" text of an occurrence (03.1).
  Future<List<String>> recurrence(String calId, String seriesId) async {
    await _authorize(interactive: false);
    return (await _api!.events.get(calId, seriesId)).recurrence ?? const [];
  }

  /// Answers an invitation (03.5): accepted, tentative or declined. The organizer is told.
  Future<void> respond(Ev e, String status) async {
    await _authorize(interactive: false);
    final api = _api!;
    final ev = await api.events.get(e.calId, e.id);
    for (final a in ev.attendees ?? const <gcal.EventAttendee>[]) {
      if (a.self == true) a.responseStatus = status;
    }
    await api.events.patch(gcal.Event(attendees: ev.attendees), e.calId, e.id, sendUpdates: 'all');
  }

  /// Deletes one occurrence, the series from this occurrence on, or the whole series (06.2).
  Future<void> delete(Ev e, DeleteScope scope, {required bool notify}) async {
    await _authorize(interactive: false);
    final api = _api!, send = notify ? 'all' : 'none';
    final series = e.recurringId;
    if (series == null || scope == DeleteScope.one) return api.events.delete(e.calId, e.id, sendUpdates: send);
    final parent = await api.events.get(e.calId, series);
    final first = _at(parent.start);
    if (scope == DeleteScope.all || first == null || !e.start.isAfter(first)) {
      return api.events.delete(e.calId, series, sendUpdates: send);
    }
    parent.recurrence = [for (final r in parent.recurrence ?? const <String>[]) endRuleBefore(r, e.start, allDay: e.allDay)];
    await api.events.update(parent, e.calId, series, sendUpdates: send);
  }
}

/// A Google (or locally stored) event as the app shows it, in calendar [cal].
Ev? evOf(gcal.Event e, Cal cal) {
  if (e.status == 'cancelled' || e.start == null || e.eventType == 'birthday') return null;
  final s = _at(e.start);
  if (s == null) return null;
  final rem = e.reminders;
  return Ev(e.summary ?? '', cal.id, s, _at(e.end) ?? s,
      id: e.id ?? '',
      allDay: e.start!.dateTime == null,
      location: e.location,
      notes: e.description,
      recurringId: e.recurringEventId,
      organizer: organizes(e, cal.id),
      organizerName: e.organizer?.displayName ?? e.organizer?.email,
      customReminder: !(rem?.useDefault ?? true),
      guestsInvite: e.guestsCanInviteOthers ?? true,
      guestsModify: e.guestsCanModify ?? false,
      guestsSee: e.guestsCanSeeOtherGuests ?? true,
      updated: e.updated?.toLocal(),
      guests: [
        for (final a in e.attendees ?? const <gcal.EventAttendee>[])
          if (a.resource != true) Guest(a.displayName ?? a.email ?? '', a.email ?? '', a.responseStatus ?? 'needsAction', self: a.self ?? false),
      ],
      reminder: rem?.useDefault ?? true
          ? cal.defaultReminder
          : rem?.overrides?.where((o) => o.method == 'popup').firstOrNull?.minutes);
}

/// Copies what the edit screen changes from [e] onto [ev], with [start]–[end] as its time.
void fillEvent(gcal.Event ev, Ev e, DateTime start, DateTime end, String timeZone) {
  gcal.EventDateTime at(DateTime t) => e.allDay
      ? gcal.EventDateTime(date: DateTime(t.year, t.month, t.day)) // all-day end is exclusive, as Google expects
      : gcal.EventDateTime(dateTime: t, timeZone: timeZone);
  // Existing guests keep their reply; new e-mails are invited.
  final old = {for (final a in ev.attendees ?? const <gcal.EventAttendee>[]) a.email: a};
  ev
    ..summary = e.title
    ..location = e.location
    ..description = e.notes
    ..start = at(start)
    ..end = at(end)
    ..attendees = [for (final g in e.guests) old[g.email] ?? gcal.EventAttendee(email: g.email, displayName: g.name == g.email ? null : g.name)]
    ..guestsCanInviteOthers = e.guestsInvite
    ..guestsCanModify = e.guestsModify
    ..guestsCanSeeOtherGuests = e.guestsSee
    ..reminders = e.customReminder
        ? gcal.EventReminders(useDefault: false, overrides: [if (e.reminder != null) gcal.EventReminder(method: 'popup', minutes: e.reminder)])
        : gcal.EventReminders(useDefault: true);
}

/// Whether the calendar [calId] organizes [e]. Google sends `organizer.self` only when it is true, so a missing
/// value means someone else organizes it (an invitation), unless the organizer is this calendar itself.
bool organizes(gcal.Event e, String calId) => e.organizer == null || e.organizer!.self == true || e.organizer!.email == calId;

DateTime? _at(gcal.EventDateTime? t) =>
    t?.dateTime?.toLocal() ?? (t?.date == null ? null : DateTime(t!.date!.year, t.date!.month, t.date!.day));

/// Ends an RRULE so its last occurrence is before [occurrence] ("delete this and following").
/// Other recurrence lines (EXDATE, RDATE) pass through unchanged.
String endRuleBefore(String line, DateTime occurrence, {required bool allDay}) {
  if (!line.startsWith('RRULE:')) return line;
  final parts = line.substring(6).split(';').where((p) => !p.startsWith('UNTIL=') && !p.startsWith('COUNT='));
  String two(int n) => n.toString().padLeft(2, '0');
  final String until;
  if (allDay) {
    final d = DateTime(occurrence.year, occurrence.month, occurrence.day - 1);
    until = '${d.year}${two(d.month)}${two(d.day)}';
  } else {
    final u = occurrence.subtract(const Duration(seconds: 1)).toUtc();
    until = '${u.year}${two(u.month)}${two(u.day)}T${two(u.hour)}${two(u.minute)}${two(u.second)}Z';
  }
  return 'RRULE:${[...parts, 'UNTIL=$until'].join(';')}';
}
