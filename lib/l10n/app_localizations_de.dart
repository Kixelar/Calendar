// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class AppLocalizationsDe extends AppLocalizations {
  AppLocalizationsDe([String locale = 'de']) : super(locale);

  @override
  String get appTitle => 'Kalender';

  @override
  String get welcomeTitle => 'Deine Zeit,\nohne Lärm.';

  @override
  String get welcomeBody =>
      'Alle Kalender an einem Ort. Google-Synchronisierung, Feiertage und Kalender, die du mit deinen Liebsten teilst.';

  @override
  String get connectGoogle => 'Mit Google verbinden';

  @override
  String get continueWithout => 'Ohne Konto fortfahren';

  @override
  String get back => 'Zurück';

  @override
  String get connectTitle => 'Google Kalender verbinden';

  @override
  String get weAskFor => 'Wir fragen nach Zugriff auf';

  @override
  String get accessEvents => 'Termine — lesen und bearbeiten';

  @override
  String get accessCalendars => 'Deine Kalenderliste';

  @override
  String get accessInvites => 'Antworten auf Einladungen';

  @override
  String get accessEmail => 'Die E-Mail-Adresse deines Kontos';

  @override
  String get noAccessTo => 'Kein Zugriff auf';

  @override
  String get noAccessFiles => 'Mail, Drive und Fotos';

  @override
  String get noAccessContacts => 'Kontakte und andere Apps';

  @override
  String get signInGoogle => 'Mit Google anmelden';

  @override
  String signInFailed(String error) {
    return 'Anmeldung fehlgeschlagen: $error';
  }

  @override
  String get noClientId =>
      'Diesem Build fehlt die Google-Client-ID. Siehe docs/GOOGLE.md.';

  @override
  String get chooseTitle => 'Kalender auswählen';

  @override
  String get calendars => 'Kalender';

  @override
  String get sharedWithYou => 'Mit dir geteilt';

  @override
  String get suggested => 'Vorschläge';

  @override
  String syncN(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n Kalender synchronisieren',
      one: '1 Kalender synchronisieren',
    );
    return '$_temp0';
  }

  @override
  String get done => 'Fertig';

  @override
  String get year => 'Jahr';

  @override
  String get month => 'Monat';

  @override
  String get week => 'Woche';

  @override
  String get day => 'Tag';

  @override
  String weekN(int n) {
    return 'Woche $n';
  }

  @override
  String eventsN(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n Termine',
      one: '1 Termin',
    );
    return '$_temp0';
  }

  @override
  String moreN(int n) {
    return '$n weitere';
  }

  @override
  String inMin(int n) {
    return 'In $n Min.';
  }

  @override
  String get today => 'Heute';

  @override
  String get tomorrow => 'Morgen';

  @override
  String get next => 'Als Nächstes';

  @override
  String get allDay => 'Ganztägig';

  @override
  String get noEvents => 'Keine Termine';

  @override
  String get weekdays => 'MO,DI,MI,DO,FR,SA,SO';

  @override
  String get previous => 'Zurück';

  @override
  String get following => 'Weiter';

  @override
  String get newEvent => 'Neuer Termin';

  @override
  String get eventName => 'Titel';

  @override
  String get save => 'Speichern';

  @override
  String get closeNoSave => 'Schließen ohne Speichern';

  @override
  String get start => 'Beginn';

  @override
  String get end => 'Ende';

  @override
  String get calendar => 'Kalender';

  @override
  String get place => 'Ort';

  @override
  String get notes => 'Notizen';

  @override
  String get add => 'Hinzufügen';

  @override
  String get reminder => 'Erinnerung';

  @override
  String get none => 'Keine';

  @override
  String minBefore(int n) {
    return '$n Min. vorher';
  }

  @override
  String hoursBefore(int n) {
    return '$n Std. vorher';
  }

  @override
  String daysBefore(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n Tage vorher',
      one: '1 Tag vorher',
    );
    return '$_temp0';
  }

  @override
  String get guests => 'Gäste';

  @override
  String get youOrganize => 'Du organisierst';

  @override
  String get rsvpYes => 'Ja';

  @override
  String get rsvpMaybe => 'Vielleicht';

  @override
  String get rsvpNo => 'Nein';

  @override
  String get rsvpWaiting => 'Ausstehend';

  @override
  String get edit => 'Bearbeiten';

  @override
  String get delete => 'Löschen';

  @override
  String get cancel => 'Abbrechen';

  @override
  String get deleteTitle => 'Termin löschen?';

  @override
  String repeats(String title) {
    return '$title wiederholt sich.';
  }

  @override
  String get onlyThis => 'Nur diesen';

  @override
  String get thisAndFollowing => 'Diesen und folgende';

  @override
  String get allOccurrences => 'Alle';

  @override
  String get notifyGuests => 'Gäste benachrichtigen';

  @override
  String get endBeforeStart => 'Das Ende muss nach dem Beginn liegen.';

  @override
  String failed(String error) {
    return 'Fehlgeschlagen: $error';
  }

  @override
  String get syncing => 'Synchronisierung';

  @override
  String eventsFrom(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: 'Termine aus $n Kalendern',
      one: 'Termine aus 1 Kalender',
    );
    return '$_temp0';
  }

  @override
  String aboutSecondsLeft(int n) {
    return 'Noch etwa $n s';
  }

  @override
  String get statusDone => 'Fertig';

  @override
  String get statusRunning => 'Läuft';

  @override
  String get statusQueued => 'Wartet';

  @override
  String get statusFailed => 'Fehler';

  @override
  String get runInBackground => 'Im Hintergrund fortsetzen';

  @override
  String get search => 'Suche';

  @override
  String get searchHint => 'Termine, Personen, Orte suchen';

  @override
  String get clear => 'Löschen';

  @override
  String get filterAll => 'Alle';

  @override
  String get withGuests => 'Mit Gästen';

  @override
  String get upcoming => 'Kommende';

  @override
  String get past => 'Vergangene';

  @override
  String get noResults => 'Nichts gefunden';

  @override
  String everyDays(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: 'Alle $n Tage',
      one: 'Jeden Tag',
    );
    return '$_temp0';
  }

  @override
  String everyWeeks(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: 'Alle $n Wochen',
      one: 'Jede Woche',
    );
    return '$_temp0';
  }

  @override
  String everyMonths(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: 'Alle $n Monate',
      one: 'Jeden Monat',
    );
    return '$_temp0';
  }

  @override
  String everyYears(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: 'Alle $n Jahre',
      one: 'Jedes Jahr',
    );
    return '$_temp0';
  }

  @override
  String get weekdaysOn =>
      'am Montag,am Dienstag,am Mittwoch,am Donnerstag,am Freitag,am Samstag,am Sonntag';

  @override
  String get weekdaysAcc =>
      'Montag,Dienstag,Mittwoch,Donnerstag,Freitag,Samstag,Sonntag';

  @override
  String get and => 'und';

  @override
  String ruleUntil(String date) {
    return ', bis $date';
  }

  @override
  String ruleCount(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: ', $n-mal',
      one: ', einmal',
    );
    return '$_temp0';
  }

  @override
  String get ruleForever => ', ohne Ende';

  @override
  String get repeat => 'Wiederholen';

  @override
  String get never => 'Nie';

  @override
  String get custom => 'Benutzerdefiniert';

  @override
  String get timeZone => 'Zeitzone';

  @override
  String get invite => 'Einladen';

  @override
  String calendarDefault(String value) {
    return 'Standard ($value)';
  }

  @override
  String get atStart => 'Zu Beginn';

  @override
  String get every => 'Alle';

  @override
  String get less => 'Weniger';

  @override
  String get more => 'Mehr';

  @override
  String get unitDays => 'Tage';

  @override
  String get unitWeeks => 'Wochen';

  @override
  String get unitMonths => 'Monate';

  @override
  String get unitYears => 'Jahre';

  @override
  String get onDays => 'An Tagen';

  @override
  String get ends => 'Endet';

  @override
  String get onDate => 'Am Datum';

  @override
  String get after => 'Nach';

  @override
  String afterTimes(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n Mal',
      one: '1 Mal',
    );
    return '$_temp0';
  }

  @override
  String get summary => 'Zusammenfassung';

  @override
  String get event => 'Termin';

  @override
  String get inviteTitle => 'Gäste einladen';

  @override
  String get send => 'Senden';

  @override
  String get nameOrEmail => 'Name oder E-Mail-Adresse';

  @override
  String get selected => 'Ausgewählt';

  @override
  String get suggestions => 'Vorschläge';

  @override
  String get guestsCan => 'Gäste können';

  @override
  String get canInvite => 'Andere einladen';

  @override
  String get canModify => 'Den Termin bearbeiten';

  @override
  String get canSee => 'Die Gästeliste sehen';

  @override
  String get inviteNote =>
      'Die Einladung wird von deinem Google-Konto per E-Mail verschickt.';

  @override
  String get inviteMore => 'Weitere Personen einladen';

  @override
  String get shareEvent => 'Termin teilen';

  @override
  String invitationFrom(String name) {
    return 'Einladung von $name';
  }

  @override
  String get organizerLabel => 'Organisator';

  @override
  String get conflict => 'Überschneidung';

  @override
  String get nothingPlanned => 'Nichts geplant.';

  @override
  String get addEvent => 'Termin hinzufügen';

  @override
  String get holiday => 'Feiertag';

  @override
  String get syncLabel => 'Synchronisierung';

  @override
  String get conflictTitle => 'Widersprüchliche Änderungen';

  @override
  String conflictBody(String title) {
    return '$title wurde auf diesem Telefon und in Google geändert. Wähle die Version, die bleiben soll.';
  }

  @override
  String get thisPhone => 'Dieses Telefon';

  @override
  String changedAt(String time) {
    return 'Geändert $time';
  }

  @override
  String get time => 'Zeit';

  @override
  String get titleLabel => 'Titel';

  @override
  String get keepBoth => 'Beide behalten';

  @override
  String get useSelected => 'Auswahl übernehmen';

  @override
  String get visibility => 'Sichtbarkeit';

  @override
  String get mineGoogle => 'Meine · Google';

  @override
  String get sharedWithMe => 'Mit mir geteilt';

  @override
  String get subscriptions => 'Abos';

  @override
  String get addCalendar => 'Kalender hinzufügen';

  @override
  String get roleOwner => 'Inhaber';

  @override
  String get roleWriter => 'Bearbeiten';

  @override
  String get roleReader => 'Ansehen';

  @override
  String get roleFreeBusy => 'Nur belegt';

  @override
  String shareCalendar(String name) {
    return 'Kalender $name teilen';
  }

  @override
  String get newCalendar => 'Neuer Kalender';

  @override
  String get newCalendarHint => 'In deinem Google-Konto';

  @override
  String get holidaysAndDaysOff => 'Feiertage und freie Tage';

  @override
  String get holidaysHint => 'Gesetzliche und religiöse Feiertage';

  @override
  String get googleAccount => 'Google-Konto';

  @override
  String get googleAccountHint => 'Anmelden und synchronisieren';

  @override
  String get calendarName => 'Name des Kalenders';

  @override
  String get holidays => 'Feiertage';

  @override
  String get country => 'Land';

  @override
  String get addCountry => '+ Land hinzufügen';

  @override
  String holidaysInYear(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n Feiertage dieses Jahr',
      one: '1 Feiertag dieses Jahr',
    );
    return '$_temp0';
  }

  @override
  String get nearest => 'Demnächst';

  @override
  String get shareTitle => 'Teilen';

  @override
  String calendarNamed(String name) {
    return 'Kalender $name';
  }

  @override
  String get peopleWithAccess => 'Personen mit Zugriff';

  @override
  String get you => 'Du';

  @override
  String get addPerson => 'Person hinzufügen';

  @override
  String get newPeopleAccess => 'Zugriff für neue Personen';

  @override
  String get freeBusyHint =>
      '„Nur belegt“ zeigt nur, wann du beschäftigt bist, ohne Namen der Termine.';

  @override
  String get link => 'Link';

  @override
  String get linkAccess => 'Zugriff per Link';

  @override
  String get copyLink => 'Link kopieren';

  @override
  String get off => 'Aus';

  @override
  String get linkCopied => 'Link kopiert';

  @override
  String get removeAccess => 'Zugriff entfernen';

  @override
  String get emailAddress => 'E-Mail-Adresse';

  @override
  String sharesWithYou(String name) {
    return '$name teilt einen Kalender mit dir';
  }

  @override
  String get yourAccess => 'Dein Zugriff';

  @override
  String get marker => 'Markierung';

  @override
  String get shapeNames =>
      'Punkt,Quadrat,Hälfte,Raute,Ring,Gestrichelt,Dreieck,Dreieck nach unten,Leeres Quadrat,Leere Raute,Plus,Kreuz,Stern,Sechseck,Herz,Zielscheibe,Quadrat mit Punkt,Stück,Schräge,Balken,Säule,Zwei Punkte,Leeres Dreieck,Obere Hälfte';

  @override
  String get showInViews => 'In Ansichten zeigen';

  @override
  String get otherWay => 'Umgekehrt';

  @override
  String get shareYours => 'Deinen Kalender zurück teilen';

  @override
  String get choose => 'Auswählen';

  @override
  String get shared => 'Geteilt';

  @override
  String get reject => 'Entfernen';

  @override
  String get settings => 'Einstellungen';

  @override
  String get upToDate => 'Aktuell';

  @override
  String get offline => 'Offline';

  @override
  String get appearance => 'Darstellung';

  @override
  String get notificationsGlyph => 'Benachrichtigungen';

  @override
  String get calendarsSharing => 'Kalender und Freigabe';

  @override
  String get dataPrivacy => 'Daten und Datenschutz';

  @override
  String get help => 'Hilfe';

  @override
  String get about => 'Über';

  @override
  String get themeDark => 'Dunkel';

  @override
  String get themeLight => 'Hell';

  @override
  String get themeSystem => 'System';

  @override
  String get theme => 'Design';

  @override
  String get firstDay => 'Erster Wochentag';

  @override
  String get timeFormat => 'Zeitformat';

  @override
  String get weekNumbers => 'Kalenderwochen';

  @override
  String get showWeekends => 'Wochenenden zeigen';

  @override
  String get declinedInvites => 'Abgelehnte Einladungen';

  @override
  String get style => 'Stil';

  @override
  String get dotDigits => 'Punkt-Ziffern';

  @override
  String get dimPast => 'Vergangenes abblenden';

  @override
  String get accounts => 'Konten';

  @override
  String get lastSync => 'Letzte Synchronisierung';

  @override
  String calendarsN(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n Kalender',
      one: '1 Kalender',
    );
    return '$_temp0';
  }

  @override
  String get syncNow => 'Jetzt synchronisieren';

  @override
  String get active => 'Aktiv';

  @override
  String get addAccount => 'Konto hinzufügen';

  @override
  String get automatic => 'Automatisch';

  @override
  String get frequency => 'Häufigkeit';

  @override
  String everyMinutes(int n) {
    return 'Alle $n Min.';
  }

  @override
  String get disconnectGoogle => 'Google-Konto trennen';

  @override
  String get disconnectBody =>
      'Kalender und Einstellungen werden von diesem Telefon entfernt. In Google ändert sich nichts.';

  @override
  String get disconnect => 'Trennen';

  @override
  String get privacy => 'Datenschutz';

  @override
  String get hideOnLockScreen => 'Details auf dem Sperrbildschirm ausblenden';

  @override
  String get device => 'Gerät';

  @override
  String get clearData => 'Daten auf diesem Gerät löschen';

  @override
  String get clearDataBody =>
      'Kalender, Cache und Einstellungen werden von diesem Telefon entfernt und du wirst abgemeldet.';

  @override
  String get googleUntouched => 'Deine Termine in Google bleiben unverändert.';

  @override
  String get searchHelp => 'Hilfe durchsuchen';

  @override
  String get faq => 'Häufige Fragen';

  @override
  String get contact => 'Kontakt';

  @override
  String get aboutApp => 'Über die App';

  @override
  String readTime(String topic) {
    return '$topic · 1 Min. Lesezeit';
  }

  @override
  String get tip => 'Tipp';

  @override
  String openScreen(String name) {
    return '$name öffnen';
  }

  @override
  String get devVersion => 'Entwicklungsversion';

  @override
  String get stableVersion => 'Stabile Version';

  @override
  String get build => 'Build';

  @override
  String get system => 'System';

  @override
  String get legal => 'Rechtliches';

  @override
  String get licenses => 'Open-Source-Lizenzen';

  @override
  String get typefaces => 'Schriften';

  @override
  String get notifications => 'Benachrichtigungen';

  @override
  String get reminders => 'Erinnerungen';

  @override
  String get defaultLabel => 'Standard';

  @override
  String get allDayEvents => 'Ganztägige';

  @override
  String dayBeforeAt(String time) {
    return 'Am Vortag um $time';
  }

  @override
  String get dailySummary => 'Tagesübersicht';

  @override
  String everyDayAt(String time) {
    return 'Täglich um $time';
  }

  @override
  String get invitations => 'Einladungen';

  @override
  String get newInvitations => 'Neue Einladungen';

  @override
  String get sharedChanges => 'Änderungen in geteilten Kalendern';

  @override
  String summaryTitle(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: 'Heute: $n Termine',
      one: 'Heute: 1 Termin',
    );
    return '$_temp0';
  }

  @override
  String invitesYou(String name, String title) {
    return '$name lädt dich ein: $title';
  }

  @override
  String changesIn(String name) {
    return 'Änderungen: $name';
  }

  @override
  String get sharedCalendars => 'Geteilte Kalender';

  @override
  String get snooze => 'In 5 Min. erinnern';

  @override
  String get details => 'Details';

  @override
  String get off2 => 'Aus';

  @override
  String get personal => 'Persönlich';

  @override
  String get customReminder => 'Eigene Erinnerung';

  @override
  String get unitMinutes => 'Minuten';

  @override
  String get unitHours => 'Stunden';

  @override
  String get reminderLimit => 'Bis zu 4 Wochen vorher.';

  @override
  String clashesWith(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: 'überschneidet sich mit $n Terminen',
      one: 'überschneidet sich mit 1 Termin',
    );
    return '$_temp0';
  }

  @override
  String get crashTitle => 'Die App wurde unerwartet beendet';

  @override
  String get crashBody =>
      'Kopiere diesen Bericht und sende ihn an den Entwickler.';

  @override
  String get close => 'Schließen';

  @override
  String get copy => 'Kopieren';

  @override
  String get saveRepeating =>
      'Änderungen an einem wiederkehrenden Termin speichern';

  @override
  String get weekNumbersHint =>
      'Kalenderwoche vor jeder Zeile der Monatsansicht.';

  @override
  String get showWeekendsHint =>
      'Aus: Monats- und Wochenansicht zeigen nur Montag bis Freitag.';

  @override
  String get declinedHint => 'Abgelehnte Einladungen in den Ansichten zeigen.';

  @override
  String get dimPastHint =>
      'Vergangene Termine und Tage werden grau angezeigt.';

  @override
  String get inBackground => 'Im Hintergrund';

  @override
  String get notYet => 'Noch nicht';

  @override
  String get check => 'Prüfen';

  @override
  String get testBackgroundHint =>
      'Schließe die App für 1–2 Minuten und komm dann hierher zurück.';

  @override
  String clashesN(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n Überschneidungen',
      one: '1 Überschneidung',
    );
    return '$_temp0';
  }

  @override
  String inH(int h) {
    return 'In $h Std.';
  }

  @override
  String inHM(int h, int m) {
    return 'In $h Std. $m Min.';
  }

  @override
  String get dayOff => 'Frei';

  @override
  String hoursFree(int h) {
    return '$h Std. frei';
  }

  @override
  String get wifiOnly => 'Nur über WLAN';

  @override
  String get wifiOnlyHint =>
      'Automatische und Hintergrund-Synchronisierung warten auf WLAN. Herunterziehen synchronisiert immer.';

  @override
  String get importFile => 'Datei importieren';

  @override
  String get importFileHint => '.ics-Datei vom Telefon';

  @override
  String get exportAll => 'Alles exportieren';

  @override
  String get importExport => 'Import und Export';

  @override
  String importTo(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n Termine importieren nach',
      one: '1 Termin importieren nach',
    );
    return '$_temp0';
  }

  @override
  String importing(int done, int n) {
    return 'Importiere $done von $n';
  }

  @override
  String importedN(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n Termine importiert',
      one: '1 Termin importiert',
    );
    return '$_temp0';
  }

  @override
  String failedN(int n) {
    return '$n fehlgeschlagen';
  }

  @override
  String get icsEmpty => 'Keine Termine in dieser Datei';

  @override
  String get exporting => 'Exportiere…';

  @override
  String get fileSaved => 'Datei gespeichert';

  @override
  String get notSignedIn => 'Nicht angemeldet';

  @override
  String get removeCountry => 'Land entfernen';

  @override
  String get subscribeUrl => 'Adresse abonnieren';

  @override
  String get subscribeUrlHint => '.ics-Link oder webcal://';

  @override
  String get subscribe => 'Abonnieren';

  @override
  String get subscribeNote =>
      'Wird stündlich aktualisiert. Der Kalender ist schreibgeschützt.';

  @override
  String get subscribing => 'Abonniere…';

  @override
  String subscribed(String name) {
    return 'Abonniert: $name';
  }

  @override
  String get unsubscribe => 'Abo beenden';

  @override
  String unsubscribeBody(String name) {
    return 'Der Kalender $name und seine Termine werden aus Google gelöscht. Du kannst ihn später erneut abonnieren.';
  }

  @override
  String get notIcs => 'Diese Adresse ist kein .ics-Kalender';

  @override
  String get deleteCalendar => 'Kalender löschen';

  @override
  String deleteCalendarBody(String name) {
    return 'Der Kalender $name und alle seine Termine werden für alle, mit denen er geteilt ist, aus Google gelöscht. Das lässt sich nicht rückgängig machen.';
  }

  @override
  String get freeNow => 'Frei';

  @override
  String ongoingUntil(String time) {
    return 'Jetzt · bis $time';
  }

  @override
  String get appLock => 'App-Sperre';

  @override
  String get appLockHint =>
      'Fragt nach Fingerabdruck, Gesicht oder Bildschirmsperre, wenn die App geöffnet wird und nach einer Minute Abwesenheit.';

  @override
  String get appLocked => 'Kalender ist gesperrt';

  @override
  String get unlock => 'Entsperren';

  @override
  String get unlockReason => 'Kalender entsperren';

  @override
  String get appLockNoScreenLock =>
      'Richte zuerst eine Bildschirmsperre auf dem Telefon ein.';

  @override
  String get glyphInterface => 'Glyph Interface';

  @override
  String get glyphLight => 'Licht bei Erinnerungen';

  @override
  String get glyphPattern => 'Lichtmuster';

  @override
  String get glyphCountdown => 'Countdown zum Termin';

  @override
  String get glyphPulse => 'Puls';

  @override
  String get glyphBlink => 'Blinken';

  @override
  String get glyphSteady => 'Dauerlicht';

  @override
  String get glyphGlass => 'Glas';

  @override
  String get glyphClock => 'Uhr';

  @override
  String get myCalendar => 'Mein Kalender';

  @override
  String get onDevice => 'Auf diesem Gerät';

  @override
  String get onlyThisPhone => 'Nur dieses Telefon';

  @override
  String get newCalendarLocalHint => 'Nur auf diesem Telefon';

  @override
  String get onPhone => 'Auf dem Telefon';

  @override
  String get chooseLanguage => 'Sprache wählen';

  @override
  String get phoneLanguage => 'Sprache des Telefons';

  @override
  String get continueBtn => 'Weiter';

  @override
  String get language => 'Sprache';
}
