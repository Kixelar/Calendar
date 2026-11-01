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
  String get noEvents => 'Brak wydarzeń';

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

  @override
  String get search => 'Szukaj';

  @override
  String get searchHint => 'Szukaj wydarzeń, osób, miejsc';

  @override
  String get clear => 'Wyczyść';

  @override
  String get filterAll => 'Wszystko';

  @override
  String get withGuests => 'Z gośćmi';

  @override
  String get upcoming => 'Nadchodzące';

  @override
  String get past => 'Minione';

  @override
  String get noResults => 'Nic nie znaleziono';

  @override
  String everyDays(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: 'Co $n dni',
      one: 'Codziennie',
    );
    return '$_temp0';
  }

  @override
  String everyWeeks(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: 'Co $n tygodni',
      few: 'Co $n tygodnie',
      one: 'Co tydzień',
    );
    return '$_temp0';
  }

  @override
  String everyMonths(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: 'Co $n miesięcy',
      few: 'Co $n miesiące',
      one: 'Co miesiąc',
    );
    return '$_temp0';
  }

  @override
  String everyYears(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: 'Co $n lat',
      few: 'Co $n lata',
      one: 'Co rok',
    );
    return '$_temp0';
  }

  @override
  String get weekdaysOn =>
      'w poniedziałek,we wtorek,w środę,w czwartek,w piątek,w sobotę,w niedzielę';

  @override
  String get weekdaysAcc =>
      'poniedziałek,wtorek,środę,czwartek,piątek,sobotę,niedzielę';

  @override
  String get and => 'i';

  @override
  String ruleUntil(String date) {
    return ', do $date';
  }

  @override
  String ruleCount(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: ', $n razy',
      one: ', 1 raz',
    );
    return '$_temp0';
  }

  @override
  String get ruleForever => ', bez końca';

  @override
  String get repeat => 'Powtarzanie';

  @override
  String get never => 'Nigdy';

  @override
  String get custom => 'Własne';

  @override
  String get timeZone => 'Strefa czasowa';

  @override
  String get invite => 'Zaproś';

  @override
  String calendarDefault(String value) {
    return 'Domyślne ($value)';
  }

  @override
  String get atStart => 'W chwili rozpoczęcia';

  @override
  String get every => 'Co';

  @override
  String get less => 'Mniej';

  @override
  String get more => 'Więcej';

  @override
  String get unitDays => 'Dni';

  @override
  String get unitWeeks => 'Tygodnie';

  @override
  String get unitMonths => 'Miesiące';

  @override
  String get unitYears => 'Lata';

  @override
  String get onDays => 'W dni';

  @override
  String get ends => 'Kończy się';

  @override
  String get onDate => 'W dniu';

  @override
  String get after => 'Po';

  @override
  String afterTimes(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n razach',
      one: '1 razie',
    );
    return '$_temp0';
  }

  @override
  String get summary => 'Podsumowanie';

  @override
  String get event => 'Wydarzenie';

  @override
  String get inviteTitle => 'Zaproś gości';

  @override
  String get send => 'Wyślij';

  @override
  String get nameOrEmail => 'Imię lub adres e-mail';

  @override
  String get selected => 'Wybrani';

  @override
  String get suggestions => 'Sugestie';

  @override
  String get guestsCan => 'Goście mogą';

  @override
  String get canInvite => 'Zapraszać innych';

  @override
  String get canModify => 'Edytować wydarzenie';

  @override
  String get canSee => 'Widzieć listę gości';

  @override
  String get inviteNote =>
      'Zaproszenie wyślemy e-mailem z Twojego konta Google.';

  @override
  String get inviteMore => 'Zaproś więcej osób';

  @override
  String get shareEvent => 'Udostępnij wydarzenie';

  @override
  String get moreOptions => 'Więcej opcji';

  @override
  String invitationFrom(String name) {
    return 'Zaproszenie od: $name';
  }

  @override
  String get organizerLabel => 'Organizator';

  @override
  String get conflict => 'Kolizja';

  @override
  String get nothingPlanned => 'Nic nie zaplanowano.';

  @override
  String get addEvent => 'Dodaj wydarzenie';

  @override
  String get holiday => 'Święto';

  @override
  String get syncLabel => 'Synchronizacja';

  @override
  String get conflictTitle => 'Konflikt zmian';

  @override
  String conflictBody(String title) {
    return '$title zmieniono na tym telefonie i w Google. Wybierz wersję, którą zachować.';
  }

  @override
  String get thisPhone => 'Ten telefon';

  @override
  String changedAt(String time) {
    return 'Zmieniono $time';
  }

  @override
  String get time => 'Godzina';

  @override
  String get titleLabel => 'Tytuł';

  @override
  String get keepBoth => 'Zachowaj obie';

  @override
  String get useSelected => 'Użyj wybranej';

  @override
  String get visibility => 'Widoczność';

  @override
  String get mineGoogle => 'Moje · Google';

  @override
  String get sharedWithMe => 'Udostępnione mi';

  @override
  String get subscriptions => 'Subskrypcje';

  @override
  String get addCalendar => 'Dodaj kalendarz';

  @override
  String get roleOwner => 'Właściciel';

  @override
  String get roleWriter => 'Edycja';

  @override
  String get roleReader => 'Podgląd';

  @override
  String get roleFreeBusy => 'Zajętość';

  @override
  String shareCalendar(String name) {
    return 'Udostępnij kalendarz $name';
  }

  @override
  String get newCalendar => 'Nowy kalendarz';

  @override
  String get newCalendarHint => 'Na Twoim koncie Google';

  @override
  String get holidaysAndDaysOff => 'Święta i dni wolne';

  @override
  String get holidaysHint => 'Państwowe i religijne';

  @override
  String get googleAccount => 'Konto Google';

  @override
  String get googleAccountHint => 'Zaloguj i synchronizuj';

  @override
  String get calendarName => 'Nazwa kalendarza';

  @override
  String get holidays => 'Święta';

  @override
  String get country => 'Kraj';

  @override
  String get addCountry => '+ Dodaj kraj';

  @override
  String holidaysInYear(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n świąt w roku',
      few: '$n święta w roku',
      one: '1 święto w roku',
    );
    return '$_temp0';
  }

  @override
  String get nearest => 'Najbliższe';

  @override
  String get shareTitle => 'Udostępnij';

  @override
  String calendarNamed(String name) {
    return 'Kalendarz $name';
  }

  @override
  String get peopleWithAccess => 'Osoby z dostępem';

  @override
  String get you => 'Ty';

  @override
  String get addPerson => 'Dodaj osobę';

  @override
  String get newPeopleAccess => 'Dostęp nowych osób';

  @override
  String get freeBusyHint =>
      'Zajętość pokazuje tylko, kiedy masz coś w kalendarzu, bez nazw wydarzeń.';

  @override
  String get link => 'Link';

  @override
  String get linkAccess => 'Dostęp przez link';

  @override
  String get copyLink => 'Kopiuj link';

  @override
  String get off => 'Wyłączony';

  @override
  String get linkCopied => 'Skopiowano link';

  @override
  String get removeAccess => 'Usuń dostęp';

  @override
  String get emailAddress => 'Adres e-mail';

  @override
  String sharesWithYou(String name) {
    return '$name udostępnia Ci swój kalendarz';
  }

  @override
  String get yourAccess => 'Twój dostęp';

  @override
  String get marker => 'Oznaczenie';

  @override
  String get shapeNames => 'Kropka,Kwadrat,Połówka,Romb,Pierścień,Przerywane';

  @override
  String get showInViews => 'Pokazuj w widokach';

  @override
  String get otherWay => 'W drugą stronę';

  @override
  String get shareYours => 'Udostępnij swój kalendarz';

  @override
  String get choose => 'Wybierz';

  @override
  String get shared => 'Udostępniono';

  @override
  String get reject => 'Odrzuć';

  @override
  String get settings => 'Ustawienia';

  @override
  String get upToDate => 'Aktualne';

  @override
  String get offline => 'Offline';

  @override
  String get appearance => 'Wygląd';

  @override
  String get notificationsGlyph => 'Powiadomienia';

  @override
  String get accountsSync => 'Konta i synchronizacja';

  @override
  String get calendarsSharing => 'Kalendarze i udostępnianie';

  @override
  String get dataPrivacy => 'Dane i prywatność';

  @override
  String get help => 'Pomoc';

  @override
  String get about => 'Informacje';

  @override
  String get themeDark => 'Ciemny';

  @override
  String get themeLight => 'Jasny';

  @override
  String get themeSystem => 'Systemowy';

  @override
  String get theme => 'Motyw';

  @override
  String get firstDay => 'Pierwszy dzień tygodnia';

  @override
  String get timeFormat => 'Format czasu';

  @override
  String get weekNumbers => 'Numery tygodni';

  @override
  String get showWeekends => 'Pokazuj weekendy';

  @override
  String get declinedInvites => 'Odrzucone zaproszenia';

  @override
  String get style => 'Styl';

  @override
  String get dotDigits => 'Cyfry kropkowe';

  @override
  String get dimPast => 'Przygaszaj minione';

  @override
  String get accounts => 'Konta';

  @override
  String get lastSync => 'Ostatnia synchronizacja';

  @override
  String calendarsN(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n kalendarzy',
      few: '$n kalendarze',
      one: '1 kalendarz',
    );
    return '$_temp0';
  }

  @override
  String get syncNow => 'Synchronizuj teraz';

  @override
  String get active => 'Aktywne';

  @override
  String get addAccount => 'Dodaj konto';

  @override
  String get automatic => 'Automatycznie';

  @override
  String get frequency => 'Częstotliwość';

  @override
  String everyMinutes(int n) {
    return 'Co $n min';
  }

  @override
  String get disconnectGoogle => 'Odłącz konto Google';

  @override
  String get disconnectBody =>
      'Kalendarze i ustawienia znikną z tego telefonu. W Google nic się nie zmieni.';

  @override
  String get disconnect => 'Odłącz';

  @override
  String get privacy => 'Prywatność';

  @override
  String get hideOnLockScreen => 'Ukryj szczegóły na blokadzie';

  @override
  String get device => 'Urządzenie';

  @override
  String get clearData => 'Wyczyść dane na urządzeniu';

  @override
  String get clearDataBody =>
      'Kalendarze, pamięć podręczna i ustawienia znikną z tego telefonu, a konto zostanie wylogowane.';

  @override
  String get googleUntouched => 'Wydarzenia w Google zostają nietknięte.';

  @override
  String get searchHelp => 'Szukaj w pomocy';

  @override
  String get faq => 'Częste pytania';

  @override
  String get contact => 'Kontakt';

  @override
  String get aboutApp => 'Informacje o aplikacji';

  @override
  String readTime(String topic) {
    return '$topic · 1 min czytania';
  }

  @override
  String get tip => 'Wskazówka';

  @override
  String openScreen(String name) {
    return 'Otwórz: $name';
  }

  @override
  String get devVersion => 'Wersja deweloperska';

  @override
  String get stableVersion => 'Wersja stabilna';

  @override
  String get build => 'Kompilacja';

  @override
  String get system => 'System';

  @override
  String get legal => 'Prawne';

  @override
  String get licenses => 'Licencje open source';

  @override
  String get typefaces => 'Kroje pisma';

  @override
  String get notifications => 'Powiadomienia';

  @override
  String get reminders => 'Przypomnienia';

  @override
  String get defaultLabel => 'Domyślne';

  @override
  String get allDayEvents => 'Całodniowe';

  @override
  String dayBeforeAt(String time) {
    return '$time dzień przed';
  }

  @override
  String get dailySummary => 'Podsumowanie dnia';

  @override
  String everyDayAt(String time) {
    return 'Codziennie $time';
  }

  @override
  String get invitations => 'Zaproszenia';

  @override
  String get newInvitations => 'Nowe zaproszenia';

  @override
  String get sharedChanges => 'Zmiany w udostępnionych';

  @override
  String summaryTitle(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: 'Dziś: $n wydarzeń',
      few: 'Dziś: $n wydarzenia',
      one: 'Dziś: 1 wydarzenie',
    );
    return '$_temp0';
  }

  @override
  String invitesYou(String name, String title) {
    return '$name zaprasza: $title';
  }

  @override
  String changesIn(String name) {
    return 'Zmiany: $name';
  }

  @override
  String get sharedCalendars => 'Udostępnione kalendarze';

  @override
  String get snooze => 'Odłóż 5 min';

  @override
  String get details => 'Szczegóły';

  @override
  String get off2 => 'Wyłączone';

  @override
  String get personal => 'Osobisty';

  @override
  String get birthdays => 'Urodziny';

  @override
  String get customReminder => 'Własne przypomnienie';

  @override
  String get unitMinutes => 'Minuty';

  @override
  String get unitHours => 'Godziny';

  @override
  String get reminderLimit => 'Najwyżej 4 tygodnie przed.';

  @override
  String clashesWith(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: 'koliduje z $n wydarzeniami',
      one: 'koliduje z 1 wydarzeniem',
    );
    return '$_temp0';
  }

  @override
  String get crashTitle => 'Aplikacja nieoczekiwanie się zamknęła';

  @override
  String get crashBody => 'Skopiuj ten raport i wyślij go twórcy.';

  @override
  String get close => 'Zamknij';

  @override
  String get copy => 'Kopiuj';

  @override
  String get saveRepeating => 'Zapisać zmiany w wydarzeniu cyklicznym?';

  @override
  String get weekNumbersHint =>
      'Numer tygodnia przed każdym wierszem widoku miesiąca.';

  @override
  String get showWeekendsHint =>
      'Wyłączone: widok miesiąca i tygodnia pokazuje tylko poniedziałek–piątek.';

  @override
  String get declinedHint =>
      'Pokazuj w widokach zaproszenia odrzucone przez Ciebie.';

  @override
  String get dimPastHint => 'Minione wydarzenia i dni są szare.';

  @override
  String get inBackground => 'W tle';

  @override
  String get notYet => 'Jeszcze nie';

  @override
  String get check => 'Sprawdź';

  @override
  String get testBackgroundHint =>
      'Zamknij aplikację na 1–2 minuty, potem wróć tutaj.';

  @override
  String clashesN(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n kolizji',
      few: '$n kolizje',
      one: '1 kolizja',
    );
    return '$_temp0';
  }

  @override
  String inH(int h) {
    return 'Za $h h';
  }

  @override
  String inHM(int h, int m) {
    return 'Za $h h $m min';
  }

  @override
  String get dayOff => 'Dzień wolny';

  @override
  String hoursFree(int h) {
    return '${h}h wolne';
  }

  @override
  String get wifiOnly => 'Tylko Wi-Fi';

  @override
  String get wifiOnlyHint =>
      'Synchronizacja automatyczna i w tle czeka na Wi-Fi. Przeciągnięcie listy w dół synchronizuje zawsze.';
}
