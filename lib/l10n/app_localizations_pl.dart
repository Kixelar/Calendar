// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Polish (`pl`).
class AppLocalizationsPl extends AppLocalizations {
  AppLocalizationsPl([String locale = 'pl']) : super(locale);

  @override
  String get appTitle => 'Kalendarz';

  @override
  String get skip => 'Pomiń';

  @override
  String get welcomeTitle => 'Twój czas,\nbez szumu.';

  @override
  String get welcomeBody =>
      'Wszystkie kalendarze w jednym miejscu. Synchronizacja z Google, święta i wspólne kalendarze z bliskimi.';

  @override
  String get connectGoogle => 'Połącz z Google';

  @override
  String get continueWithout => 'Kontynuuj bez konta';

  @override
  String get back => 'Wstecz';

  @override
  String step(int n) {
    return 'Krok $n z 3';
  }

  @override
  String get connectTitle => 'Połącz kalendarz Google';

  @override
  String get weAskFor => 'Poprosimy o dostęp do';

  @override
  String get accessEvents => 'Wydarzeń — odczyt i edycja';

  @override
  String get accessCalendars => 'Listy Twoich kalendarzy';

  @override
  String get accessInvites => 'Odpowiedzi na zaproszenia';

  @override
  String get accessEmail => 'Adresu e-mail konta';

  @override
  String get noAccessTo => 'Bez dostępu do';

  @override
  String get noAccessFiles => 'Poczty, Dysku i Zdjęć';

  @override
  String get noAccessContacts => 'Kontaktów i innych aplikacji';

  @override
  String get signInGoogle => 'Zaloguj przez Google';

  @override
  String signInFailed(String error) {
    return 'Logowanie nieudane: $error';
  }

  @override
  String get noClientId =>
      'Ta wersja nie ma identyfikatora klienta Google. Zobacz docs/GOOGLE.md.';

  @override
  String get chooseTitle => 'Wybierz kalendarze';

  @override
  String get calendars => 'Kalendarze';

  @override
  String get sharedWithYou => 'Udostępnione Ci';

  @override
  String get suggested => 'Polecane';

  @override
  String syncN(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: 'Synchronizuj $n kalendarzy',
      few: 'Synchronizuj $n kalendarze',
      one: 'Synchronizuj 1 kalendarz',
    );
    return '$_temp0';
  }

  @override
  String get done => 'Gotowe';

  @override
  String get year => 'Rok';

  @override
  String get month => 'Miesiąc';

  @override
  String get week => 'Tydzień';

  @override
  String get day => 'Dzień';

  @override
  String get yearHint => 'Kropka to dzień';

  @override
  String weekN(int n) {
    return 'Tydzień $n';
  }

  @override
  String eventsN(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n wydarzeń',
      few: '$n wydarzenia',
      one: '1 wydarzenie',
    );
    return '$_temp0';
  }

  @override
  String moreN(int n) {
    return 'Jeszcze $n';
  }

  @override
  String inMin(int n) {
    return 'Za $n min';
  }

  @override
  String get today => 'Dziś';

  @override
  String get tomorrow => 'Jutro';

  @override
  String get next => 'Następne';

  @override
  String get allDay => 'Cały dzień';

  @override
  String get schedule => 'Harmonogram';

  @override
  String get noEvents => 'Brak wydarzeń';

  @override
  String get loadFailed =>
      'Nie udało się wczytać wydarzeń. Pociągnij, aby ponowić.';

  @override
  String get weekdays => 'PN,WT,ŚR,CZ,PT,SB,ND';

  @override
  String get previous => 'Poprzedni';

  @override
  String get following => 'Następny';

  @override
  String get newEvent => 'Nowe wydarzenie';

  @override
  String get eventName => 'Nazwa wydarzenia';

  @override
  String get save => 'Zapisz';

  @override
  String get closeNoSave => 'Zamknij bez zapisu';

  @override
  String get start => 'Początek';

  @override
  String get end => 'Koniec';

  @override
  String get calendar => 'Kalendarz';

  @override
  String get place => 'Miejsce';

  @override
  String get notes => 'Notatki';

  @override
  String get add => 'Dodaj';

  @override
  String get reminder => 'Przypomnienie';

  @override
  String get none => 'Brak';

  @override
  String minBefore(int n) {
    return '$n min przed';
  }

  @override
  String hoursBefore(int n) {
    return '$n godz. przed';
  }

  @override
  String daysBefore(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n dni przed',
      one: '1 dzień przed',
    );
    return '$_temp0';
  }

  @override
  String get guests => 'Goście';

  @override
  String get youOrganize => 'Organizujesz';

  @override
  String get rsvpYes => 'Tak';

  @override
  String get rsvpMaybe => 'Może';

  @override
  String get rsvpNo => 'Nie';

  @override
  String get rsvpWaiting => 'Czeka';

  @override
  String get edit => 'Edytuj';

  @override
  String get delete => 'Usuń';

  @override
  String get cancel => 'Anuluj';

  @override
  String get deleteTitle => 'Usunąć wydarzenie?';

  @override
  String repeats(String title) {
    return '$title powtarza się.';
  }

  @override
  String get onlyThis => 'Tylko to';

  @override
  String get thisAndFollowing => 'To i następne';

  @override
  String get allOccurrences => 'Wszystkie';

  @override
  String get notifyGuests => 'Powiadom gości';

  @override
  String get endBeforeStart => 'Koniec musi być po początku.';

  @override
  String failed(String error) {
    return 'Nie udało się: $error';
  }

  @override
  String get syncing => 'Synchronizuję';

  @override
  String eventsFrom(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: 'wydarzeń z $n kalendarzy',
      one: 'wydarzeń z 1 kalendarza',
    );
    return '$_temp0';
  }

  @override
  String aboutSecondsLeft(int n) {
    return 'Jeszcze ok. $n s';
  }

  @override
  String get statusDone => 'Gotowe';

  @override
  String get statusRunning => 'W toku';

  @override
  String get statusQueued => 'W kolejce';

  @override
  String get statusFailed => 'Błąd';

  @override
  String get runInBackground => 'Działaj w tle';
}
