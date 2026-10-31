/// 05.6 / 05.7 help articles, written for how this app works. [open] names the screen the article's button opens.
class Article {
  const Article(this.topic, this.title, this.steps, this.tip, this.open);
  final String topic, title, tip, open; // open: calendars, add, holidays
  final List<String> steps;
}

const _pl = [
  Article('Udostępnianie', 'Jak udostępnić komuś kalendarz?', [
    'Otwórz Kalendarze z górnego paska.',
    'Przy wybranym kalendarzu dotknij ikony udostępniania.',
    'Dodaj osobę po adresie e-mail.',
    'Wybierz dostęp: Zajętość, Podgląd lub Edycja.',
  ], 'Zajętość pokazuje tylko godziny, w których masz coś w kalendarzu, bez nazw i miejsc wydarzeń.', 'calendars'),
  Article('Konto', 'Jak połączyć kalendarz Google?', [
    'Otwórz Kalendarze z górnego paska.',
    'Dotknij Dodaj kalendarz, potem Konto Google.',
    'Zaloguj się i zgódź na dostęp do kalendarza.',
    'Wybierz kalendarze, które mają być widoczne.',
  ], 'Aplikacja łączy się bezpośrednio z Google. Twoje wydarzenia nie trafiają na żaden inny serwer.', 'add'),
  Article('Synchronizacja', 'Wydarzenie się nie synchronizuje', [
    'Pociągnij widok w dół, żeby odświeżyć.',
    'Sprawdź w Kalendarzach, czy kalendarz wydarzenia jest włączony.',
    'Upewnij się, że telefon ma internet.',
    'W Ustawieniach → Konta dotknij Synchronizuj teraz.',
  ], 'Bez internetu widzisz ostatnio pobrane wydarzenia. Zmiany zapiszesz, gdy połączenie wróci.', 'calendars'),
  Article('Święta', 'Jak dodać święta?', [
    'Otwórz Kalendarze z górnego paska.',
    'Dotknij Dodaj kalendarz, potem Święta i dni wolne.',
    'Dotknij + Dodaj kraj i wybierz kraj.',
    'Święta pojawią się w widokach jako pierścień przy dacie.',
  ], 'Kalendarze świąt pochodzą od Google i aktualizują się same.', 'holidays'),
];

const _en = [
  Article('Sharing', 'How do I share a calendar?', [
    'Open Calendars from the top bar.',
    'Tap the share icon next to the calendar.',
    'Add a person by e-mail address.',
    'Choose the access: Busy only, View or Edit.',
  ], 'Busy only shows just the hours when you have something on, without event names or places.', 'calendars'),
  Article('Account', 'How do I connect Google Calendar?', [
    'Open Calendars from the top bar.',
    'Tap Add calendar, then Google account.',
    'Sign in and allow calendar access.',
    'Choose which calendars to show.',
  ], 'The app talks to Google directly. Your events do not go to any other server.', 'add'),
  Article('Sync', 'An event does not sync', [
    'Pull the view down to refresh.',
    'Check in Calendars that the event\'s calendar is switched on.',
    'Make sure the phone is online.',
    'In Settings → Accounts tap Sync now.',
  ], 'Offline you see the events fetched last. Changes can be saved once you are back online.', 'calendars'),
  Article('Holidays', 'How do I add holidays?', [
    'Open Calendars from the top bar.',
    'Tap Add calendar, then Holidays and days off.',
    'Tap + Add country and pick a country.',
    'Holidays show in the views as a ring around the date.',
  ], 'Holiday calendars come from Google and update by themselves.', 'holidays'),
];

List<Article> helpFor(String locale) => locale.startsWith('pl') ? _pl : _en;
