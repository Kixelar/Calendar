// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Dutch Flemish (`nl`).
class AppLocalizationsNl extends AppLocalizations {
  AppLocalizationsNl([String locale = 'nl']) : super(locale);

  @override
  String get appTitle => 'Agenda';

  @override
  String get welcomeTitle => 'Jouw tijd,\nzonder ruis.';

  @override
  String get welcomeBody =>
      'Al je agenda\'s op één plek. Synchronisatie met Google, feestdagen en agenda\'s die je deelt met je naasten.';

  @override
  String get connectGoogle => 'Google koppelen';

  @override
  String get continueWithout => 'Doorgaan zonder account';

  @override
  String get back => 'Terug';

  @override
  String get connectTitle => 'Google Agenda koppelen';

  @override
  String get weAskFor => 'We vragen toegang tot';

  @override
  String get accessEvents => 'Afspraken — lezen en bewerken';

  @override
  String get accessCalendars => 'Je lijst met agenda\'s';

  @override
  String get accessInvites => 'Antwoorden op uitnodigingen';

  @override
  String get accessEmail => 'Het e-mailadres van je account';

  @override
  String get noAccessTo => 'Geen toegang tot';

  @override
  String get noAccessFiles => 'Mail, Drive en Foto\'s';

  @override
  String get noAccessContacts => 'Contacten en andere apps';

  @override
  String get signInGoogle => 'Inloggen met Google';

  @override
  String signInFailed(String error) {
    return 'Inloggen mislukt: $error';
  }

  @override
  String get noClientId =>
      'Deze build heeft geen Google-client-ID. Zie docs/GOOGLE.md.';

  @override
  String get chooseTitle => 'Kies agenda\'s';

  @override
  String get calendars => 'Agenda\'s';

  @override
  String get sharedWithYou => 'Met jou gedeeld';

  @override
  String get suggested => 'Voorgesteld';

  @override
  String syncN(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n agenda\'s synchroniseren',
      one: '1 agenda synchroniseren',
    );
    return '$_temp0';
  }

  @override
  String get done => 'Klaar';

  @override
  String get year => 'Jaar';

  @override
  String get month => 'Maand';

  @override
  String get week => 'Week';

  @override
  String get day => 'Dag';

  @override
  String weekN(int n) {
    return 'Week $n';
  }

  @override
  String eventsN(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n afspraken',
      one: '1 afspraak',
    );
    return '$_temp0';
  }

  @override
  String moreN(int n) {
    return 'Nog $n';
  }

  @override
  String inMin(int n) {
    return 'Over $n min';
  }

  @override
  String get today => 'Vandaag';

  @override
  String get tomorrow => 'Morgen';

  @override
  String get next => 'Hierna';

  @override
  String get allDay => 'Hele dag';

  @override
  String get noEvents => 'Geen afspraken';

  @override
  String get weekdays => 'MA,DI,WO,DO,VR,ZA,ZO';

  @override
  String get previous => 'Vorige';

  @override
  String get following => 'Volgende';

  @override
  String get newEvent => 'Nieuwe afspraak';

  @override
  String get eventName => 'Naam van de afspraak';

  @override
  String get save => 'Opslaan';

  @override
  String get closeNoSave => 'Sluiten zonder opslaan';

  @override
  String get start => 'Begin';

  @override
  String get end => 'Einde';

  @override
  String get calendar => 'Agenda';

  @override
  String get place => 'Locatie';

  @override
  String get notes => 'Notities';

  @override
  String get add => 'Toevoegen';

  @override
  String get reminder => 'Herinnering';

  @override
  String get none => 'Geen';

  @override
  String minBefore(int n) {
    return '$n min van tevoren';
  }

  @override
  String hoursBefore(int n) {
    return '$n uur van tevoren';
  }

  @override
  String daysBefore(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n dagen van tevoren',
      one: '1 dag van tevoren',
    );
    return '$_temp0';
  }

  @override
  String get guests => 'Gasten';

  @override
  String get youOrganize => 'Jij organiseert';

  @override
  String get rsvpYes => 'Ja';

  @override
  String get rsvpMaybe => 'Misschien';

  @override
  String get rsvpNo => 'Nee';

  @override
  String get rsvpWaiting => 'In afwachting';

  @override
  String get edit => 'Bewerken';

  @override
  String get delete => 'Verwijderen';

  @override
  String get cancel => 'Annuleren';

  @override
  String get deleteTitle => 'Afspraak verwijderen?';

  @override
  String repeats(String title) {
    return '$title herhaalt zich.';
  }

  @override
  String get onlyThis => 'Alleen deze';

  @override
  String get thisAndFollowing => 'Deze en volgende';

  @override
  String get allOccurrences => 'Alle';

  @override
  String get notifyGuests => 'Gasten op de hoogte brengen';

  @override
  String get endBeforeStart => 'Het einde moet na het begin liggen.';

  @override
  String failed(String error) {
    return 'Mislukt: $error';
  }

  @override
  String get syncing => 'Synchroniseren';

  @override
  String eventsFrom(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: 'afspraken uit $n agenda\'s',
      one: 'afspraken uit 1 agenda',
    );
    return '$_temp0';
  }

  @override
  String aboutSecondsLeft(int n) {
    return 'Nog ongeveer $n s';
  }

  @override
  String get statusDone => 'Klaar';

  @override
  String get statusRunning => 'Bezig';

  @override
  String get statusQueued => 'In de wachtrij';

  @override
  String get statusFailed => 'Mislukt';

  @override
  String get runInBackground => 'Op de achtergrond doorgaan';

  @override
  String get search => 'Zoeken';

  @override
  String get searchHint => 'Zoek afspraken, mensen, plaatsen';

  @override
  String get clear => 'Wissen';

  @override
  String get filterAll => 'Alles';

  @override
  String get withGuests => 'Met gasten';

  @override
  String get upcoming => 'Komend';

  @override
  String get past => 'Voorbij';

  @override
  String get noResults => 'Niets gevonden';

  @override
  String everyDays(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: 'Elke $n dagen',
      one: 'Elke dag',
    );
    return '$_temp0';
  }

  @override
  String everyWeeks(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: 'Elke $n weken',
      one: 'Elke week',
    );
    return '$_temp0';
  }

  @override
  String everyMonths(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: 'Elke $n maanden',
      one: 'Elke maand',
    );
    return '$_temp0';
  }

  @override
  String everyYears(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: 'Elke $n jaar',
      one: 'Elk jaar',
    );
    return '$_temp0';
  }

  @override
  String get weekdaysOn =>
      'op maandag,op dinsdag,op woensdag,op donderdag,op vrijdag,op zaterdag,op zondag';

  @override
  String get weekdaysAcc =>
      'maandag,dinsdag,woensdag,donderdag,vrijdag,zaterdag,zondag';

  @override
  String get and => 'en';

  @override
  String ruleUntil(String date) {
    return ', tot $date';
  }

  @override
  String ruleCount(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: ', $n keer',
      one: ', één keer',
    );
    return '$_temp0';
  }

  @override
  String get ruleForever => ', zonder einde';

  @override
  String get repeat => 'Herhalen';

  @override
  String get never => 'Nooit';

  @override
  String get custom => 'Aangepast';

  @override
  String get timeZone => 'Tijdzone';

  @override
  String get invite => 'Uitnodigen';

  @override
  String calendarDefault(String value) {
    return 'Standaard ($value)';
  }

  @override
  String get atStart => 'Bij begin';

  @override
  String get every => 'Elke';

  @override
  String get less => 'Minder';

  @override
  String get more => 'Meer';

  @override
  String get unitDays => 'Dagen';

  @override
  String get unitWeeks => 'Weken';

  @override
  String get unitMonths => 'Maanden';

  @override
  String get unitYears => 'Jaren';

  @override
  String get onDays => 'Op dagen';

  @override
  String get ends => 'Eindigt';

  @override
  String get onDate => 'Op datum';

  @override
  String get after => 'Na';

  @override
  String afterTimes(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n keer',
      one: '1 keer',
    );
    return '$_temp0';
  }

  @override
  String get summary => 'Overzicht';

  @override
  String get event => 'Afspraak';

  @override
  String get inviteTitle => 'Gasten uitnodigen';

  @override
  String get send => 'Versturen';

  @override
  String get nameOrEmail => 'Naam of e-mailadres';

  @override
  String get selected => 'Geselecteerd';

  @override
  String get suggestions => 'Suggesties';

  @override
  String get guestsCan => 'Gasten kunnen';

  @override
  String get canInvite => 'Anderen uitnodigen';

  @override
  String get canModify => 'De afspraak bewerken';

  @override
  String get canSee => 'De gastenlijst zien';

  @override
  String get inviteNote => 'We mailen de uitnodiging vanuit je Google-account.';

  @override
  String get inviteMore => 'Meer mensen uitnodigen';

  @override
  String get shareEvent => 'Afspraak delen';

  @override
  String invitationFrom(String name) {
    return 'Uitnodiging van $name';
  }

  @override
  String get organizerLabel => 'Organisator';

  @override
  String get conflict => 'Overlap';

  @override
  String get nothingPlanned => 'Niets gepland.';

  @override
  String get addEvent => 'Afspraak toevoegen';

  @override
  String get holiday => 'Feestdag';

  @override
  String get syncLabel => 'Synchronisatie';

  @override
  String get conflictTitle => 'Tegenstrijdige wijzigingen';

  @override
  String conflictBody(String title) {
    return '$title is gewijzigd op deze telefoon en in Google. Kies welke versie je houdt.';
  }

  @override
  String get thisPhone => 'Deze telefoon';

  @override
  String changedAt(String time) {
    return 'Gewijzigd $time';
  }

  @override
  String get time => 'Tijd';

  @override
  String get titleLabel => 'Titel';

  @override
  String get keepBoth => 'Beide houden';

  @override
  String get useSelected => 'Keuze gebruiken';

  @override
  String get visibility => 'Zichtbaarheid';

  @override
  String get mineGoogle => 'Mijn · Google';

  @override
  String get sharedWithMe => 'Met mij gedeeld';

  @override
  String get subscriptions => 'Abonnementen';

  @override
  String get addCalendar => 'Agenda toevoegen';

  @override
  String get roleOwner => 'Eigenaar';

  @override
  String get roleWriter => 'Bewerken';

  @override
  String get roleReader => 'Bekijken';

  @override
  String get roleFreeBusy => 'Alleen bezet';

  @override
  String shareCalendar(String name) {
    return 'Agenda $name delen';
  }

  @override
  String get newCalendar => 'Nieuwe agenda';

  @override
  String get newCalendarHint => 'In je Google-account';

  @override
  String get holidaysAndDaysOff => 'Feestdagen en vrije dagen';

  @override
  String get holidaysHint => 'Nationale en religieuze feestdagen';

  @override
  String get googleAccount => 'Google-account';

  @override
  String get googleAccountHint => 'Inloggen en synchroniseren';

  @override
  String get calendarName => 'Naam van de agenda';

  @override
  String get holidays => 'Feestdagen';

  @override
  String get country => 'Land';

  @override
  String get addCountry => '+ Land toevoegen';

  @override
  String holidaysInYear(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n feestdagen dit jaar',
      one: '1 feestdag dit jaar',
    );
    return '$_temp0';
  }

  @override
  String get nearest => 'Binnenkort';

  @override
  String get shareTitle => 'Delen';

  @override
  String calendarNamed(String name) {
    return 'Agenda $name';
  }

  @override
  String get peopleWithAccess => 'Mensen met toegang';

  @override
  String get you => 'Jij';

  @override
  String get addPerson => 'Persoon toevoegen';

  @override
  String get newPeopleAccess => 'Toegang voor nieuwe mensen';

  @override
  String get freeBusyHint =>
      'Alleen bezet laat zien wanneer je bezig bent, zonder namen van afspraken.';

  @override
  String get link => 'Link';

  @override
  String get linkAccess => 'Toegang via link';

  @override
  String get copyLink => 'Link kopiëren';

  @override
  String get off => 'Uit';

  @override
  String get linkCopied => 'Link gekopieerd';

  @override
  String get removeAccess => 'Toegang intrekken';

  @override
  String get emailAddress => 'E-mailadres';

  @override
  String sharesWithYou(String name) {
    return '$name deelt een agenda met je';
  }

  @override
  String get yourAccess => 'Jouw toegang';

  @override
  String get marker => 'Markering';

  @override
  String get shapeNames =>
      'Punt,Vierkant,Helft,Ruit,Ring,Gestreept,Driehoek,Driehoek omlaag,Leeg vierkant,Lege ruit,Plus,Kruis,Ster,Zeshoek,Hart,Doel,Vierkant met punt,Punt van taart,Diagonaal,Balk,Zuil,Twee punten,Lege driehoek,Bovenste helft';

  @override
  String get showInViews => 'Tonen in weergaven';

  @override
  String get otherWay => 'Andersom';

  @override
  String get shareYours => 'Deel je agenda terug';

  @override
  String get choose => 'Kiezen';

  @override
  String get shared => 'Gedeeld';

  @override
  String get reject => 'Verwijderen';

  @override
  String get settings => 'Instellingen';

  @override
  String get upToDate => 'Bijgewerkt';

  @override
  String get offline => 'Offline';

  @override
  String get appearance => 'Weergave';

  @override
  String get notificationsGlyph => 'Meldingen';

  @override
  String get calendarsSharing => 'Agenda\'s en delen';

  @override
  String get dataPrivacy => 'Gegevens en privacy';

  @override
  String get help => 'Hulp';

  @override
  String get about => 'Over';

  @override
  String get themeDark => 'Donker';

  @override
  String get themeLight => 'Licht';

  @override
  String get themeSystem => 'Systeem';

  @override
  String get theme => 'Thema';

  @override
  String get firstDay => 'Eerste dag van de week';

  @override
  String get timeFormat => 'Tijdnotatie';

  @override
  String get weekNumbers => 'Weeknummers';

  @override
  String get showWeekends => 'Weekenden tonen';

  @override
  String get declinedInvites => 'Afgewezen uitnodigingen';

  @override
  String get style => 'Stijl';

  @override
  String get dotDigits => 'Puntcijfers';

  @override
  String get dimPast => 'Verleden dimmen';

  @override
  String get accounts => 'Accounts';

  @override
  String get lastSync => 'Laatste synchronisatie';

  @override
  String calendarsN(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n agenda\'s',
      one: '1 agenda',
    );
    return '$_temp0';
  }

  @override
  String get syncNow => 'Nu synchroniseren';

  @override
  String get active => 'Actief';

  @override
  String get addAccount => 'Account toevoegen';

  @override
  String get automatic => 'Automatisch';

  @override
  String get frequency => 'Frequentie';

  @override
  String everyMinutes(int n) {
    return 'Elke $n min';
  }

  @override
  String get disconnectGoogle => 'Google-account ontkoppelen';

  @override
  String get disconnectBody =>
      'Agenda\'s en instellingen worden van deze telefoon verwijderd. In Google verandert niets.';

  @override
  String get disconnect => 'Ontkoppelen';

  @override
  String get privacy => 'Privacy';

  @override
  String get hideOnLockScreen => 'Details op het vergrendelscherm verbergen';

  @override
  String get device => 'Apparaat';

  @override
  String get clearData => 'Gegevens op dit apparaat wissen';

  @override
  String get clearDataBody =>
      'Agenda\'s, cache en instellingen worden van deze telefoon verwijderd en je wordt uitgelogd.';

  @override
  String get googleUntouched => 'Je afspraken in Google blijven ongewijzigd.';

  @override
  String get searchHelp => 'Zoeken in hulp';

  @override
  String get faq => 'Veelgestelde vragen';

  @override
  String get contact => 'Contact';

  @override
  String get aboutApp => 'Over de app';

  @override
  String readTime(String topic) {
    return '$topic · 1 min lezen';
  }

  @override
  String get tip => 'Tip';

  @override
  String openScreen(String name) {
    return '$name openen';
  }

  @override
  String get devVersion => 'Ontwikkelversie';

  @override
  String get stableVersion => 'Stabiele versie';

  @override
  String get build => 'Build';

  @override
  String get system => 'Systeem';

  @override
  String get legal => 'Juridisch';

  @override
  String get licenses => 'Opensourcelicenties';

  @override
  String get typefaces => 'Lettertypen';

  @override
  String get notifications => 'Meldingen';

  @override
  String get reminders => 'Herinneringen';

  @override
  String get defaultLabel => 'Standaard';

  @override
  String get allDayEvents => 'Hele dag';

  @override
  String dayBeforeAt(String time) {
    return 'Dag ervoor, $time';
  }

  @override
  String get dailySummary => 'Dagoverzicht';

  @override
  String everyDayAt(String time) {
    return 'Elke dag om $time';
  }

  @override
  String get invitations => 'Uitnodigingen';

  @override
  String get newInvitations => 'Nieuwe uitnodigingen';

  @override
  String get sharedChanges => 'Wijzigingen in gedeelde agenda\'s';

  @override
  String summaryTitle(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: 'Vandaag: $n afspraken',
      one: 'Vandaag: 1 afspraak',
    );
    return '$_temp0';
  }

  @override
  String invitesYou(String name, String title) {
    return '$name nodigt je uit: $title';
  }

  @override
  String changesIn(String name) {
    return 'Wijzigingen: $name';
  }

  @override
  String get sharedCalendars => 'Gedeelde agenda\'s';

  @override
  String get snooze => 'Over 5 min herinneren';

  @override
  String get details => 'Details';

  @override
  String get off2 => 'Uit';

  @override
  String get personal => 'Persoonlijk';

  @override
  String get customReminder => 'Eigen herinnering';

  @override
  String get unitMinutes => 'Minuten';

  @override
  String get unitHours => 'Uren';

  @override
  String get reminderLimit => 'Tot 4 weken van tevoren.';

  @override
  String clashesWith(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: 'overlapt met $n afspraken',
      one: 'overlapt met 1 afspraak',
    );
    return '$_temp0';
  }

  @override
  String get crashTitle => 'De app is onverwacht gesloten';

  @override
  String get crashBody =>
      'Kopieer dit rapport en stuur het naar de ontwikkelaar.';

  @override
  String get close => 'Sluiten';

  @override
  String get copy => 'Kopiëren';

  @override
  String get saveRepeating =>
      'Wijzigingen in een terugkerende afspraak opslaan';

  @override
  String get weekNumbersHint =>
      'Weeknummer voor elke rij van de maandweergave.';

  @override
  String get showWeekendsHint =>
      'Uit: de maand- en weekweergave tonen alleen maandag tot en met vrijdag.';

  @override
  String get declinedHint => 'Afgewezen uitnodigingen in de weergaven tonen.';

  @override
  String get dimPastHint =>
      'Afspraken en dagen die voorbij zijn, worden grijs getoond.';

  @override
  String get inBackground => 'Op de achtergrond';

  @override
  String get notYet => 'Nog niet';

  @override
  String get check => 'Controleren';

  @override
  String get testBackgroundHint =>
      'Sluit de app 1–2 minuten en kom dan hier terug.';

  @override
  String clashesN(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n overlappingen',
      one: '1 overlap',
    );
    return '$_temp0';
  }

  @override
  String inH(int h) {
    return 'Over $h uur';
  }

  @override
  String inHM(int h, int m) {
    return 'Over $h uur $m min';
  }

  @override
  String get dayOff => 'Vrije dag';

  @override
  String hoursFree(int h) {
    return '$h uur vrij';
  }

  @override
  String get wifiOnly => 'Alleen via wifi';

  @override
  String get wifiOnlyHint =>
      'Automatische en achtergrondsynchronisatie wachten op wifi. Omlaag trekken synchroniseert altijd.';

  @override
  String get importFile => 'Bestand importeren';

  @override
  String get importFileHint => '.ics-bestand van de telefoon';

  @override
  String get exportAll => 'Alles exporteren';

  @override
  String get importExport => 'Importeren en exporteren';

  @override
  String importTo(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n afspraken importeren naar',
      one: '1 afspraak importeren naar',
    );
    return '$_temp0';
  }

  @override
  String importing(int done, int n) {
    return 'Importeren $done van $n';
  }

  @override
  String importedN(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n afspraken geïmporteerd',
      one: '1 afspraak geïmporteerd',
    );
    return '$_temp0';
  }

  @override
  String failedN(int n) {
    return '$n mislukt';
  }

  @override
  String get icsEmpty => 'Geen afspraken in dit bestand';

  @override
  String get exporting => 'Exporteren…';

  @override
  String get fileSaved => 'Bestand opgeslagen';

  @override
  String get notSignedIn => 'Niet ingelogd';

  @override
  String get removeCountry => 'Land verwijderen';

  @override
  String get subscribeUrl => 'Abonneren op adres';

  @override
  String get subscribeUrlHint => '.ics-link of webcal://';

  @override
  String get subscribe => 'Abonneren';

  @override
  String get subscribeNote => 'Elk uur bijgewerkt. De agenda is alleen-lezen.';

  @override
  String get subscribing => 'Abonneren…';

  @override
  String subscribed(String name) {
    return 'Geabonneerd: $name';
  }

  @override
  String get unsubscribe => 'Abonnement opzeggen';

  @override
  String unsubscribeBody(String name) {
    return 'De agenda $name en de afspraken erin worden uit Google verwijderd. Je kunt je later opnieuw abonneren.';
  }

  @override
  String get notIcs => 'Dit adres is geen .ics-agenda';

  @override
  String get deleteCalendar => 'Agenda verwijderen';

  @override
  String deleteCalendarBody(String name) {
    return 'De agenda $name en alle afspraken erin worden uit Google verwijderd, voor iedereen met wie hij gedeeld is. Dit kan niet ongedaan worden gemaakt.';
  }

  @override
  String get freeNow => 'Vrij';

  @override
  String ongoingUntil(String time) {
    return 'Nu · tot $time';
  }

  @override
  String get appLock => 'App-vergrendeling';

  @override
  String get appLockHint =>
      'Vraagt om je vingerafdruk, gezicht of schermvergrendeling als de app opent en na een minuut weg.';

  @override
  String get appLocked => 'Agenda is vergrendeld';

  @override
  String get unlock => 'Ontgrendelen';

  @override
  String get unlockReason => 'Agenda ontgrendelen';

  @override
  String get appLockNoScreenLock =>
      'Stel eerst een schermvergrendeling in op je telefoon.';

  @override
  String get glyphInterface => 'Glyph Interface';

  @override
  String get glyphLight => 'Licht bij herinneringen';

  @override
  String get glyphPattern => 'Lichtpatroon';

  @override
  String get glyphCountdown => 'Aftellen tot afspraak';

  @override
  String get glyphPulse => 'Puls';

  @override
  String get glyphBlink => 'Knipperen';

  @override
  String get glyphSteady => 'Constant';

  @override
  String get glyphGlass => 'Glas';

  @override
  String get glyphClock => 'Klok';

  @override
  String get myCalendar => 'Mijn agenda';

  @override
  String get onDevice => 'Op dit apparaat';

  @override
  String get onlyThisPhone => 'Alleen deze telefoon';

  @override
  String get newCalendarLocalHint => 'Alleen op deze telefoon';

  @override
  String get onPhone => 'Op telefoon';

  @override
  String get chooseLanguage => 'Kies een taal';

  @override
  String get phoneLanguage => 'Taal van de telefoon';

  @override
  String get continueBtn => 'Doorgaan';

  @override
  String get language => 'Taal';
}
