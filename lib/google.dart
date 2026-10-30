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
  final bool shared, holiday;
  final Shape shape;
  bool on;
  Cal(this.id, this.name, {required this.shared, required this.holiday, required this.shape, required this.on});
}

class Ev {
  final String title, calId;
  final String? location;
  final DateTime start, end; // local time; for all-day events end is exclusive midnight
  final bool allDay;
  const Ev(this.title, this.calId, this.start, this.end, {this.allDay = false, this.location});
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
          final allDay = e.start!.dateTime == null;
          DateTime? at(gcal.EventDateTime? t) =>
              t?.dateTime?.toLocal() ?? (t?.date == null ? null : DateTime(t!.date!.year, t.date!.month, t.date!.day));
          final s = at(e.start);
          if (s == null) continue;
          out.add(Ev(e.summary ?? '', cal.id, s, at(e.end) ?? s, allDay: allDay, location: e.location));
        }
        page = r.nextPageToken;
      } while (page != null);
    }));
    out.sort((a, b) => a.start.compareTo(b.start));
    return out;
  }
}
