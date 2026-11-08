// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Italian (`it`).
class AppLocalizationsIt extends AppLocalizations {
  AppLocalizationsIt([String locale = 'it']) : super(locale);

  @override
  String get appTitle => 'Calendario';

  @override
  String get welcomeTitle => 'Il tuo tempo,\nsenza rumore.';

  @override
  String get welcomeBody =>
      'Tutti i tuoi calendari in un unico posto. Sincronizzazione con Google, festività e calendari condivisi con le persone care.';

  @override
  String get connectGoogle => 'Connetti Google';

  @override
  String get continueWithout => 'Continua senza account';

  @override
  String get back => 'Indietro';

  @override
  String get connectTitle => 'Connetti Google Calendar';

  @override
  String get weAskFor => 'Chiederemo l’accesso a';

  @override
  String get accessEvents => 'Eventi — lettura e modifica';

  @override
  String get accessCalendars => 'L’elenco dei tuoi calendari';

  @override
  String get accessInvites => 'Risposte agli inviti';

  @override
  String get accessEmail => 'L’e-mail dell’account';

  @override
  String get noAccessTo => 'Nessun accesso a';

  @override
  String get noAccessFiles => 'Posta, Drive e Foto';

  @override
  String get noAccessContacts => 'Contatti e altre app';

  @override
  String get signInGoogle => 'Accedi con Google';

  @override
  String signInFailed(String error) {
    return 'Accesso non riuscito: $error';
  }

  @override
  String get noClientId =>
      'Questa build non ha l’ID client di Google. Vedi docs/GOOGLE.md.';

  @override
  String get chooseTitle => 'Scegli i calendari';

  @override
  String get calendars => 'Calendari';

  @override
  String get sharedWithYou => 'Condivisi con te';

  @override
  String get suggested => 'Suggeriti';

  @override
  String syncN(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: 'Sincronizza $n calendari',
      one: 'Sincronizza 1 calendario',
    );
    return '$_temp0';
  }

  @override
  String get done => 'Fatto';

  @override
  String get year => 'Anno';

  @override
  String get month => 'Mese';

  @override
  String get week => 'Settimana';

  @override
  String get day => 'Giorno';

  @override
  String weekN(int n) {
    return 'Settimana $n';
  }

  @override
  String eventsN(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n eventi',
      one: '1 evento',
    );
    return '$_temp0';
  }

  @override
  String moreN(int n) {
    return 'Altri $n';
  }

  @override
  String inMin(int n) {
    return 'Tra $n min';
  }

  @override
  String get today => 'Oggi';

  @override
  String get tomorrow => 'Domani';

  @override
  String get next => 'Prossimo';

  @override
  String get allDay => 'Tutto il giorno';

  @override
  String get noEvents => 'Nessun evento';

  @override
  String get weekdays => 'LU,MA,ME,GI,VE,SA,DO';

  @override
  String get previous => 'Precedente';

  @override
  String get following => 'Successivo';

  @override
  String get newEvent => 'Nuovo evento';

  @override
  String get eventName => 'Nome dell’evento';

  @override
  String get save => 'Salva';

  @override
  String get closeNoSave => 'Chiudi senza salvare';

  @override
  String get start => 'Inizio';

  @override
  String get end => 'Fine';

  @override
  String get calendar => 'Calendario';

  @override
  String get place => 'Luogo';

  @override
  String get notes => 'Note';

  @override
  String get add => 'Aggiungi';

  @override
  String get reminder => 'Promemoria';

  @override
  String get none => 'Nessuno';

  @override
  String minBefore(int n) {
    return '$n min prima';
  }

  @override
  String hoursBefore(int n) {
    return '$n h prima';
  }

  @override
  String daysBefore(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n giorni prima',
      one: '1 giorno prima',
    );
    return '$_temp0';
  }

  @override
  String get guests => 'Invitati';

  @override
  String get youOrganize => 'Organizzi tu';

  @override
  String get rsvpYes => 'Sì';

  @override
  String get rsvpMaybe => 'Forse';

  @override
  String get rsvpNo => 'No';

  @override
  String get rsvpWaiting => 'In attesa';

  @override
  String get edit => 'Modifica';

  @override
  String get delete => 'Elimina';

  @override
  String get cancel => 'Annulla';

  @override
  String get deleteTitle => 'Eliminare l’evento?';

  @override
  String repeats(String title) {
    return '$title si ripete.';
  }

  @override
  String get onlyThis => 'Solo questo';

  @override
  String get thisAndFollowing => 'Questo e i successivi';

  @override
  String get allOccurrences => 'Tutti';

  @override
  String get notifyGuests => 'Avvisa gli invitati';

  @override
  String get endBeforeStart => 'La fine deve essere dopo l’inizio.';

  @override
  String failed(String error) {
    return 'Non riuscito: $error';
  }

  @override
  String get syncing => 'Sincronizzazione';

  @override
  String eventsFrom(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: 'eventi da $n calendari',
      one: 'eventi da 1 calendario',
    );
    return '$_temp0';
  }

  @override
  String aboutSecondsLeft(int n) {
    return 'Circa $n s rimanenti';
  }

  @override
  String get statusDone => 'Fatto';

  @override
  String get statusRunning => 'In corso';

  @override
  String get statusQueued => 'In coda';

  @override
  String get statusFailed => 'Errore';

  @override
  String get runInBackground => 'Continua in background';

  @override
  String get search => 'Cerca';

  @override
  String get searchHint => 'Cerca eventi, persone, luoghi';

  @override
  String get clear => 'Cancella';

  @override
  String get filterAll => 'Tutto';

  @override
  String get withGuests => 'Con invitati';

  @override
  String get upcoming => 'In arrivo';

  @override
  String get past => 'Passati';

  @override
  String get noResults => 'Nessun risultato';

  @override
  String everyDays(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: 'Ogni $n giorni',
      one: 'Ogni giorno',
    );
    return '$_temp0';
  }

  @override
  String everyWeeks(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: 'Ogni $n settimane',
      one: 'Ogni settimana',
    );
    return '$_temp0';
  }

  @override
  String everyMonths(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: 'Ogni $n mesi',
      one: 'Ogni mese',
    );
    return '$_temp0';
  }

  @override
  String everyYears(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: 'Ogni $n anni',
      one: 'Ogni anno',
    );
    return '$_temp0';
  }

  @override
  String get weekdaysOn =>
      'il lunedì,il martedì,il mercoledì,il giovedì,il venerdì,il sabato,la domenica';

  @override
  String get weekdaysAcc =>
      'lunedì,martedì,mercoledì,giovedì,venerdì,sabato,domenica';

  @override
  String get and => 'e';

  @override
  String ruleUntil(String date) {
    return ', fino al $date';
  }

  @override
  String ruleCount(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: ', $n volte',
      one: ', una volta',
    );
    return '$_temp0';
  }

  @override
  String get ruleForever => ', senza fine';

  @override
  String get repeat => 'Ripeti';

  @override
  String get never => 'Mai';

  @override
  String get custom => 'Personalizzato';

  @override
  String get timeZone => 'Fuso orario';

  @override
  String get invite => 'Invita';

  @override
  String calendarDefault(String value) {
    return 'Predefinito ($value)';
  }

  @override
  String get atStart => 'All’inizio';

  @override
  String get every => 'Ogni';

  @override
  String get less => 'Meno';

  @override
  String get more => 'Più';

  @override
  String get unitDays => 'Giorni';

  @override
  String get unitWeeks => 'Settimane';

  @override
  String get unitMonths => 'Mesi';

  @override
  String get unitYears => 'Anni';

  @override
  String get onDays => 'Nei giorni';

  @override
  String get ends => 'Termina';

  @override
  String get onDate => 'Alla data';

  @override
  String get after => 'Dopo';

  @override
  String afterTimes(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n volte',
      one: '1 volta',
    );
    return '$_temp0';
  }

  @override
  String get summary => 'Riepilogo';

  @override
  String get event => 'Evento';

  @override
  String get inviteTitle => 'Invita persone';

  @override
  String get send => 'Invia';

  @override
  String get nameOrEmail => 'Nome o indirizzo e-mail';

  @override
  String get selected => 'Selezionati';

  @override
  String get suggestions => 'Suggerimenti';

  @override
  String get guestsCan => 'Gli invitati possono';

  @override
  String get canInvite => 'Invitare altri';

  @override
  String get canModify => 'Modificare l’evento';

  @override
  String get canSee => 'Vedere l’elenco degli invitati';

  @override
  String get inviteNote =>
      'Invieremo l’invito per e-mail dal tuo account Google.';

  @override
  String get inviteMore => 'Invita altre persone';

  @override
  String get shareEvent => 'Condividi evento';

  @override
  String invitationFrom(String name) {
    return 'Invito da $name';
  }

  @override
  String get organizerLabel => 'Organizzatore';

  @override
  String get conflict => 'Sovrapposizione';

  @override
  String get nothingPlanned => 'Niente in programma.';

  @override
  String get addEvent => 'Aggiungi evento';

  @override
  String get holiday => 'Festività';

  @override
  String get syncLabel => 'Sincronizzazione';

  @override
  String get conflictTitle => 'Modifiche in conflitto';

  @override
  String conflictBody(String title) {
    return '$title è stato modificato su questo telefono e in Google. Scegli la versione da tenere.';
  }

  @override
  String get thisPhone => 'Questo telefono';

  @override
  String changedAt(String time) {
    return 'Modificato $time';
  }

  @override
  String get time => 'Ora';

  @override
  String get titleLabel => 'Titolo';

  @override
  String get keepBoth => 'Tieni entrambi';

  @override
  String get useSelected => 'Usa la scelta';

  @override
  String get visibility => 'Visibilità';

  @override
  String get mineGoogle => 'Miei · Google';

  @override
  String get sharedWithMe => 'Condivisi con me';

  @override
  String get subscriptions => 'Iscrizioni';

  @override
  String get addCalendar => 'Aggiungi calendario';

  @override
  String get roleOwner => 'Proprietario';

  @override
  String get roleWriter => 'Modifica';

  @override
  String get roleReader => 'Visualizza';

  @override
  String get roleFreeBusy => 'Solo occupato';

  @override
  String shareCalendar(String name) {
    return 'Condividi il calendario $name';
  }

  @override
  String get newCalendar => 'Nuovo calendario';

  @override
  String get newCalendarHint => 'Nel tuo account Google';

  @override
  String get holidaysAndDaysOff => 'Festività e giorni liberi';

  @override
  String get holidaysHint => 'Feste nazionali e religiose';

  @override
  String get googleAccount => 'Account Google';

  @override
  String get googleAccountHint => 'Accedi e sincronizza';

  @override
  String get calendarName => 'Nome del calendario';

  @override
  String get holidays => 'Festività';

  @override
  String get country => 'Paese';

  @override
  String get addCountry => '+ Aggiungi paese';

  @override
  String holidaysInYear(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n festività quest’anno',
      one: '1 festività quest’anno',
    );
    return '$_temp0';
  }

  @override
  String get nearest => 'In arrivo';

  @override
  String get shareTitle => 'Condividi';

  @override
  String calendarNamed(String name) {
    return 'Calendario $name';
  }

  @override
  String get peopleWithAccess => 'Persone con accesso';

  @override
  String get you => 'Tu';

  @override
  String get addPerson => 'Aggiungi persona';

  @override
  String get newPeopleAccess => 'Accesso per nuove persone';

  @override
  String get freeBusyHint =>
      'Solo occupato mostra quando sei impegnato, senza i nomi degli eventi.';

  @override
  String get link => 'Link';

  @override
  String get linkAccess => 'Accesso tramite link';

  @override
  String get copyLink => 'Copia link';

  @override
  String get off => 'Disattivato';

  @override
  String get linkCopied => 'Link copiato';

  @override
  String get removeAccess => 'Rimuovi accesso';

  @override
  String get emailAddress => 'Indirizzo e-mail';

  @override
  String sharesWithYou(String name) {
    return '$name condivide un calendario con te';
  }

  @override
  String get yourAccess => 'Il tuo accesso';

  @override
  String get marker => 'Simbolo';

  @override
  String get shapeNames =>
      'Punto,Quadrato,Metà,Rombo,Anello,Tratteggiato,Triangolo,Triangolo in giù,Quadrato vuoto,Rombo vuoto,Più,Croce,Stella,Esagono,Cuore,Bersaglio,Quadrato con punto,Spicchio,Diagonale,Barra,Pilastro,Due punti,Triangolo vuoto,Metà superiore';

  @override
  String get showInViews => 'Mostra nelle viste';

  @override
  String get otherWay => 'Al contrario';

  @override
  String get shareYours => 'Condividi anche il tuo calendario';

  @override
  String get choose => 'Scegli';

  @override
  String get shared => 'Condiviso';

  @override
  String get reject => 'Rimuovi';

  @override
  String get settings => 'Impostazioni';

  @override
  String get upToDate => 'Aggiornato';

  @override
  String get offline => 'Offline';

  @override
  String get appearance => 'Aspetto';

  @override
  String get notificationsGlyph => 'Notifiche';

  @override
  String get calendarsSharing => 'Calendari e condivisione';

  @override
  String get dataPrivacy => 'Dati e privacy';

  @override
  String get help => 'Aiuto';

  @override
  String get about => 'Informazioni';

  @override
  String get themeDark => 'Scuro';

  @override
  String get themeLight => 'Chiaro';

  @override
  String get themeSystem => 'Sistema';

  @override
  String get theme => 'Tema';

  @override
  String get firstDay => 'Primo giorno della settimana';

  @override
  String get timeFormat => 'Formato dell’ora';

  @override
  String get weekNumbers => 'Numeri delle settimane';

  @override
  String get showWeekends => 'Mostra i fine settimana';

  @override
  String get declinedInvites => 'Inviti rifiutati';

  @override
  String get style => 'Stile';

  @override
  String get dotDigits => 'Cifre a punti';

  @override
  String get dimPast => 'Attenua il passato';

  @override
  String get accounts => 'Account';

  @override
  String get lastSync => 'Ultima sincronizzazione';

  @override
  String calendarsN(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n calendari',
      one: '1 calendario',
    );
    return '$_temp0';
  }

  @override
  String get syncNow => 'Sincronizza ora';

  @override
  String get active => 'Attivo';

  @override
  String get addAccount => 'Aggiungi account';

  @override
  String get automatic => 'Automaticamente';

  @override
  String get frequency => 'Frequenza';

  @override
  String everyMinutes(int n) {
    return 'Ogni $n min';
  }

  @override
  String get disconnectGoogle => 'Disconnetti l’account Google';

  @override
  String get disconnectBody =>
      'Calendari e impostazioni vengono rimossi da questo telefono. In Google non cambia nulla.';

  @override
  String get disconnect => 'Disconnetti';

  @override
  String get privacy => 'Privacy';

  @override
  String get hideOnLockScreen =>
      'Nascondi i dettagli nella schermata di blocco';

  @override
  String get device => 'Dispositivo';

  @override
  String get clearData => 'Cancella i dati su questo dispositivo';

  @override
  String get clearDataBody =>
      'Calendari, cache e impostazioni vengono rimossi da questo telefono e viene effettuata la disconnessione.';

  @override
  String get googleUntouched => 'I tuoi eventi in Google restano invariati.';

  @override
  String get searchHelp => 'Cerca nell’aiuto';

  @override
  String get faq => 'Domande frequenti';

  @override
  String get contact => 'Contatti';

  @override
  String get aboutApp => 'Informazioni sull’app';

  @override
  String readTime(String topic) {
    return '$topic · 1 min di lettura';
  }

  @override
  String get tip => 'Suggerimento';

  @override
  String openScreen(String name) {
    return 'Apri $name';
  }

  @override
  String get devVersion => 'Versione di sviluppo';

  @override
  String get stableVersion => 'Versione stabile';

  @override
  String get build => 'Build';

  @override
  String get system => 'Sistema';

  @override
  String get legal => 'Note legali';

  @override
  String get licenses => 'Licenze open source';

  @override
  String get typefaces => 'Caratteri';

  @override
  String get notifications => 'Notifiche';

  @override
  String get reminders => 'Promemoria';

  @override
  String get defaultLabel => 'Predefinito';

  @override
  String get allDayEvents => 'Tutto il giorno';

  @override
  String dayBeforeAt(String time) {
    return 'Giorno prima $time';
  }

  @override
  String get dailySummary => 'Riepilogo giornaliero';

  @override
  String everyDayAt(String time) {
    return 'Ogni giorno alle $time';
  }

  @override
  String get invitations => 'Inviti';

  @override
  String get newInvitations => 'Nuovi inviti';

  @override
  String get sharedChanges => 'Modifiche nei calendari condivisi';

  @override
  String summaryTitle(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: 'Oggi: $n eventi',
      one: 'Oggi: 1 evento',
    );
    return '$_temp0';
  }

  @override
  String invitesYou(String name, String title) {
    return '$name ti invita: $title';
  }

  @override
  String changesIn(String name) {
    return 'Modifiche: $name';
  }

  @override
  String get sharedCalendars => 'Calendari condivisi';

  @override
  String get snooze => 'Posticipa 5 min';

  @override
  String get details => 'Dettagli';

  @override
  String get off2 => 'Disattivato';

  @override
  String get personal => 'Personale';

  @override
  String get customReminder => 'Promemoria personalizzato';

  @override
  String get unitMinutes => 'Minuti';

  @override
  String get unitHours => 'Ore';

  @override
  String get reminderLimit => 'Fino a 4 settimane prima.';

  @override
  String clashesWith(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: 'si sovrappone a $n eventi',
      one: 'si sovrappone a 1 evento',
    );
    return '$_temp0';
  }

  @override
  String get crashTitle => 'L’app si è chiusa in modo imprevisto';

  @override
  String get crashBody => 'Copia questo rapporto e invialo allo sviluppatore.';

  @override
  String get close => 'Chiudi';

  @override
  String get copy => 'Copia';

  @override
  String get saveRepeating => 'Salva le modifiche a un evento ricorrente';

  @override
  String get weekNumbersHint =>
      'Numero della settimana all’inizio di ogni riga della vista mese.';

  @override
  String get showWeekendsHint =>
      'Disattivato: le viste mese e settimana mostrano solo da lunedì a venerdì.';

  @override
  String get declinedHint => 'Mostra nelle viste gli inviti che hai rifiutato.';

  @override
  String get dimPastHint =>
      'Eventi e giorni già passati sono mostrati in grigio.';

  @override
  String get inBackground => 'In background';

  @override
  String get notYet => 'Non ancora';

  @override
  String get check => 'Verifica';

  @override
  String get testBackgroundHint =>
      'Chiudi l’app per 1–2 minuti, poi torna qui.';

  @override
  String clashesN(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n sovrapposizioni',
      one: '1 sovrapposizione',
    );
    return '$_temp0';
  }

  @override
  String inH(int h) {
    return 'Tra $h h';
  }

  @override
  String inHM(int h, int m) {
    return 'Tra $h h $m min';
  }

  @override
  String get dayOff => 'Giorno libero';

  @override
  String hoursFree(int h) {
    return '$h h libere';
  }

  @override
  String get wifiOnly => 'Solo Wi-Fi';

  @override
  String get wifiOnlyHint =>
      'La sincronizzazione automatica e in background aspetta il Wi-Fi. Trascinare in basso sincronizza sempre.';

  @override
  String get importFile => 'Importa file';

  @override
  String get importFileHint => 'File .ics dal telefono';

  @override
  String get exportAll => 'Esporta tutto';

  @override
  String get importExport => 'Importa ed esporta';

  @override
  String importTo(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: 'Importa $n eventi in',
      one: 'Importa 1 evento in',
    );
    return '$_temp0';
  }

  @override
  String importing(int done, int n) {
    return 'Importazione $done di $n';
  }

  @override
  String importedN(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n eventi importati',
      one: '1 evento importato',
    );
    return '$_temp0';
  }

  @override
  String failedN(int n) {
    return '$n non riusciti';
  }

  @override
  String get icsEmpty => 'Nessun evento in questo file';

  @override
  String get exporting => 'Esportazione…';

  @override
  String get fileSaved => 'File salvato';

  @override
  String get notSignedIn => 'Accesso non effettuato';

  @override
  String get removeCountry => 'Rimuovi paese';

  @override
  String get subscribeUrl => 'Iscriviti a un indirizzo';

  @override
  String get subscribeUrlHint => 'Link .ics o webcal://';

  @override
  String get subscribe => 'Iscriviti';

  @override
  String get subscribeNote =>
      'Aggiornato ogni ora. Il calendario è di sola lettura.';

  @override
  String get subscribing => 'Iscrizione…';

  @override
  String subscribed(String name) {
    return 'Iscritto: $name';
  }

  @override
  String get unsubscribe => 'Annulla iscrizione';

  @override
  String unsubscribeBody(String name) {
    return 'Il calendario $name e i suoi eventi vengono eliminati da Google. Potrai iscriverti di nuovo più tardi.';
  }

  @override
  String get notIcs => 'Questo indirizzo non è un calendario .ics';

  @override
  String get deleteCalendar => 'Elimina calendario';

  @override
  String deleteCalendarBody(String name) {
    return 'Il calendario $name e tutti i suoi eventi vengono eliminati da Google per tutti quelli con cui è condiviso. Non si può annullare.';
  }

  @override
  String get freeNow => 'Libero';

  @override
  String ongoingUntil(String time) {
    return 'Ora · fino alle $time';
  }

  @override
  String get appLock => 'Blocco dell’app';

  @override
  String get appLockHint =>
      'Chiede impronta, volto o codice di blocco all’apertura dell’app e dopo un minuto di assenza.';

  @override
  String get appLocked => 'Il calendario è bloccato';

  @override
  String get unlock => 'Sblocca';

  @override
  String get unlockReason => 'Sblocca Calendario';

  @override
  String get appLockNoScreenLock =>
      'Imposta prima un blocco schermo sul telefono.';

  @override
  String get glyphInterface => 'Glyph Interface';

  @override
  String get glyphLight => 'Luce con i promemoria';

  @override
  String get glyphPattern => 'Schema luminoso';

  @override
  String get glyphCountdown => 'Conto alla rovescia';

  @override
  String get glyphPulse => 'Pulsazione';

  @override
  String get glyphBlink => 'Lampeggio';

  @override
  String get glyphSteady => 'Fissa';

  @override
  String get glyphGlass => 'Bicchiere';

  @override
  String get glyphClock => 'Orologio';

  @override
  String get myCalendar => 'Il mio calendario';

  @override
  String get onDevice => 'Su questo dispositivo';

  @override
  String get onlyThisPhone => 'Solo questo telefono';

  @override
  String get newCalendarLocalHint => 'Solo su questo telefono';

  @override
  String get onPhone => 'Sul telefono';

  @override
  String get chooseLanguage => 'Scegli la lingua';

  @override
  String get phoneLanguage => 'Lingua del telefono';

  @override
  String get continueBtn => 'Continua';

  @override
  String get language => 'Lingua';
}
