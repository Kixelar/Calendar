import 'package:extension_google_sign_in_as_googleapis_auth/extension_google_sign_in_as_googleapis_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/calendar/v3.dart' as gcal;

/// Web OAuth client ID from Google Cloud, passed at build time (docs/GOOGLE.md). Not a secret.
const serverClientId = String.fromEnvironment('GOOGLE_SERVER_CLIENT_ID');

/// Read/write events, calendar list and invitation replies; the mockup's "connect Google" screen lists exactly this.
const _scopes = [gcal.CalendarApi.calendarScope];

/// Calendars are told apart by marker shape, not colour (mockup design).
enum Shape { dot, square, half, diamond, ring, dash }

class Cal {
  final String id, name;
  final bool shared, holiday, writable;
  final Shape shape;
  final int? defaultReminder; // minutes before, applies to events that use the calendar's default reminders
  bool on;
  Cal(this.id, this.name,
      {required this.shared, required this.holiday, required this.shape, required this.on, this.writable = true, this.defaultReminder});
}

/// Invitation reply as Google stores it: accepted, tentative, declined, needsAction.
class Guest {
  final String name, email, status;
  final bool self;
  const Guest(this.name, this.email, this.status, {this.self = false});
}

class Ev {
  final String id, title, calId;
  final String? location, notes;
  final String? recurringId; // set on an occurrence of a repeating event: the series' id
  final DateTime start, end; // local time; for all-day events end is exclusive midnight
  final bool allDay;
  final bool organizer; // this calendar organizes the event (false for invitations from others)
  final List<Guest> guests;
  final int? reminder; // minutes before; null = none
  const Ev(this.title, this.calId, this.start, this.end,
      {this.id = '',
      this.allDay = false,
      this.location,
      this.notes,
      this.recurringId,
      this.organizer = true,
      this.guests = const [],
      this.reminder});
}

enum DeleteScope { one, following, all }

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
  Future<bool> restore() async {
    await _init();
    // Calendar calls need only an authorization token, which Android hands out without UI once granted.
    // Lightweight sign-in would pop an account sheet whenever One Tap auto-select is unavailable, so it is the fallback.
    if (await _authorize(interactive: false)) return true;
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

  Future<List<Cal>> calendars(Set<String>? enabled) async {
    await _authorize(interactive: false);
    final items = <gcal.CalendarListEntry>[];
    String? page;
    do {
      final r = await _api!.calendarList.list(pageToken: page);
      items.addAll(r.items ?? const []);
      page = r.nextPageToken;
    } while (page != null);
    items.sort((a, b) => (b.primary == true ? 1 : 0) - (a.primary == true ? 1 : 0));
    const own = [Shape.dot, Shape.square, Shape.half, Shape.diamond];
    var i = 0;
    return [
      for (final e in items)
        () {
          final holiday = e.id!.contains('#holiday@');
          final shared = !holiday && e.accessRole != 'owner';
          return Cal(e.id!, e.summaryOverride ?? e.summary ?? e.id!,
              shared: shared,
              holiday: holiday,
              writable: e.accessRole == 'owner' || e.accessRole == 'writer',
              defaultReminder: e.defaultReminders?.where((r) => r.method == 'popup').firstOrNull?.minutes,
              shape: holiday ? Shape.ring : shared ? Shape.dash : own[i++ % own.length],
              on: enabled?.contains(e.id) ?? e.selected == true);
        }(),
    ];
  }

  /// Events of [cals] that overlap [from, to), recurring events expanded.
  Future<List<Ev>> events(List<Cal> cals, DateTime from, DateTime to) async {
    await _authorize(interactive: false);
    final out = <Ev>[];
    await Future.wait(cals.map((cal) async {
      String? page;
      do {
        final r = await _api!.events.list(cal.id,
            timeMin: from.toUtc(), timeMax: to.toUtc(), singleEvents: true, maxResults: 2500, pageToken: page);
        for (final e in r.items ?? const <gcal.Event>[]) {
          if (e.status == 'cancelled' || e.start == null) continue;
          final s = _at(e.start);
          if (s == null) continue;
          final rem = e.reminders;
          out.add(Ev(e.summary ?? '', cal.id, s, _at(e.end) ?? s,
              id: e.id ?? '',
              allDay: e.start!.dateTime == null,
              location: e.location,
              notes: e.description,
              recurringId: e.recurringEventId,
              organizer: e.organizer?.self ?? true,
              guests: [
                for (final a in e.attendees ?? const <gcal.EventAttendee>[])
                  if (a.resource != true) Guest(a.displayName ?? a.email ?? '', a.email ?? '', a.responseStatus ?? 'needsAction', self: a.self ?? false),
              ],
              reminder: rem?.useDefault ?? true
                  ? cal.defaultReminder
                  : rem?.overrides?.where((o) => o.method == 'popup').firstOrNull?.minutes));
        }
        page = r.nextPageToken;
      } while (page != null);
    }));
    out.sort((a, b) => a.start.compareTo(b.start));
    return out;
  }

  /// Creates [e] (empty id) or updates it; [fromCal] is its calendar before the edit when the user moved it.
  Future<void> save(Ev e, {String? fromCal}) async {
    await _authorize(interactive: false);
    final api = _api!;
    if (e.id.isNotEmpty && fromCal != null && fromCal != e.calId) await api.events.move(fromCal, e.id, e.calId);
    // Updating the fetched resource keeps guests, reminders and everything this screen does not edit.
    final ev = e.id.isEmpty ? gcal.Event() : await api.events.get(e.calId, e.id);
    final endDay = DateTime(e.end.year, e.end.month, e.end.day); // all-day end is exclusive, as Google expects
    ev
      ..summary = e.title
      ..location = e.location
      ..description = e.notes
      ..start = e.allDay ? gcal.EventDateTime(date: DateTime(e.start.year, e.start.month, e.start.day)) : gcal.EventDateTime(dateTime: e.start)
      ..end = e.allDay ? gcal.EventDateTime(date: endDay) : gcal.EventDateTime(dateTime: e.end);
    if (e.id.isEmpty) {
      await api.events.insert(ev, e.calId);
    } else {
      await api.events.update(ev, e.calId, e.id, sendUpdates: e.guests.isEmpty ? 'none' : 'all');
    }
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
