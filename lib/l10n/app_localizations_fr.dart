// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get appTitle => 'Agenda';

  @override
  String get welcomeTitle => 'Votre temps,\nsans le bruit.';

  @override
  String get welcomeBody =>
      'Tous vos agendas au même endroit. Synchronisation Google, jours fériés et agendas partagés avec vos proches.';

  @override
  String get connectGoogle => 'Connecter Google';

  @override
  String get continueWithout => 'Continuer sans compte';

  @override
  String get back => 'Retour';

  @override
  String get connectTitle => 'Connecter Google Agenda';

  @override
  String get weAskFor => 'Nous demanderons l’accès à';

  @override
  String get accessEvents => 'Événements — lecture et modification';

  @override
  String get accessCalendars => 'La liste de vos agendas';

  @override
  String get accessInvites => 'Réponses aux invitations';

  @override
  String get accessEmail => 'L’adresse e-mail du compte';

  @override
  String get noAccessTo => 'Aucun accès à';

  @override
  String get noAccessFiles => 'Mail, Drive et Photos';

  @override
  String get noAccessContacts => 'Contacts et autres applis';

  @override
  String get signInGoogle => 'Se connecter avec Google';

  @override
  String signInFailed(String error) {
    return 'Échec de la connexion : $error';
  }

  @override
  String get noClientId =>
      'Cette version n’a pas d’ID client Google. Voir docs/GOOGLE.md.';

  @override
  String get chooseTitle => 'Choisir les agendas';

  @override
  String get calendars => 'Agendas';

  @override
  String get sharedWithYou => 'Partagés avec vous';

  @override
  String get suggested => 'Suggestions';

  @override
  String syncN(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: 'Synchroniser $n agendas',
      one: 'Synchroniser 1 agenda',
    );
    return '$_temp0';
  }

  @override
  String get done => 'OK';

  @override
  String get year => 'Année';

  @override
  String get month => 'Mois';

  @override
  String get week => 'Semaine';

  @override
  String get day => 'Jour';

  @override
  String weekN(int n) {
    return 'Semaine $n';
  }

  @override
  String eventsN(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n événements',
      one: '1 événement',
    );
    return '$_temp0';
  }

  @override
  String moreN(int n) {
    return '$n de plus';
  }

  @override
  String inMin(int n) {
    return 'Dans $n min';
  }

  @override
  String get today => 'Aujourd’hui';

  @override
  String get tomorrow => 'Demain';

  @override
  String get next => 'Ensuite';

  @override
  String get allDay => 'Toute la journée';

  @override
  String get noEvents => 'Aucun événement';

  @override
  String get weekdays => 'LU,MA,ME,JE,VE,SA,DI';

  @override
  String get previous => 'Précédent';

  @override
  String get following => 'Suivant';

  @override
  String get newEvent => 'Nouvel événement';

  @override
  String get eventName => 'Nom de l’événement';

  @override
  String get save => 'Enregistrer';

  @override
  String get closeNoSave => 'Fermer sans enregistrer';

  @override
  String get start => 'Début';

  @override
  String get end => 'Fin';

  @override
  String get calendar => 'Agenda';

  @override
  String get place => 'Lieu';

  @override
  String get notes => 'Notes';

  @override
  String get add => 'Ajouter';

  @override
  String get reminder => 'Rappel';

  @override
  String get none => 'Aucun';

  @override
  String minBefore(int n) {
    return '$n min avant';
  }

  @override
  String hoursBefore(int n) {
    return '$n h avant';
  }

  @override
  String daysBefore(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n jours avant',
      one: '1 jour avant',
    );
    return '$_temp0';
  }

  @override
  String get guests => 'Invités';

  @override
  String get youOrganize => 'Vous organisez';

  @override
  String get rsvpYes => 'Oui';

  @override
  String get rsvpMaybe => 'Peut-être';

  @override
  String get rsvpNo => 'Non';

  @override
  String get rsvpWaiting => 'En attente';

  @override
  String get edit => 'Modifier';

  @override
  String get delete => 'Supprimer';

  @override
  String get cancel => 'Annuler';

  @override
  String get deleteTitle => 'Supprimer l’événement ?';

  @override
  String repeats(String title) {
    return '$title se répète.';
  }

  @override
  String get onlyThis => 'Celui-ci uniquement';

  @override
  String get thisAndFollowing => 'Celui-ci et les suivants';

  @override
  String get allOccurrences => 'Tous';

  @override
  String get notifyGuests => 'Prévenir les invités';

  @override
  String get endBeforeStart => 'La fin doit être après le début.';

  @override
  String failed(String error) {
    return 'Échec : $error';
  }

  @override
  String get syncing => 'Synchronisation';

  @override
  String eventsFrom(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: 'événements de $n agendas',
      one: 'événements de 1 agenda',
    );
    return '$_temp0';
  }

  @override
  String aboutSecondsLeft(int n) {
    return 'Encore environ $n s';
  }

  @override
  String get statusDone => 'Terminé';

  @override
  String get statusRunning => 'En cours';

  @override
  String get statusQueued => 'En attente';

  @override
  String get statusFailed => 'Échec';

  @override
  String get runInBackground => 'Continuer en arrière-plan';

  @override
  String get search => 'Recherche';

  @override
  String get searchHint => 'Rechercher événements, personnes, lieux';

  @override
  String get clear => 'Effacer';

  @override
  String get filterAll => 'Tout';

  @override
  String get withGuests => 'Avec invités';

  @override
  String get upcoming => 'À venir';

  @override
  String get past => 'Passés';

  @override
  String get noResults => 'Aucun résultat';

  @override
  String everyDays(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: 'Tous les $n jours',
      one: 'Tous les jours',
    );
    return '$_temp0';
  }

  @override
  String everyWeeks(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: 'Toutes les $n semaines',
      one: 'Toutes les semaines',
    );
    return '$_temp0';
  }

  @override
  String everyMonths(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: 'Tous les $n mois',
      one: 'Tous les mois',
    );
    return '$_temp0';
  }

  @override
  String everyYears(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: 'Tous les $n ans',
      one: 'Tous les ans',
    );
    return '$_temp0';
  }

  @override
  String get weekdaysOn =>
      'le lundi,le mardi,le mercredi,le jeudi,le vendredi,le samedi,le dimanche';

  @override
  String get weekdaysAcc =>
      'lundi,mardi,mercredi,jeudi,vendredi,samedi,dimanche';

  @override
  String get and => 'et';

  @override
  String ruleUntil(String date) {
    return ', jusqu’au $date';
  }

  @override
  String ruleCount(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: ', $n fois',
      one: ', une fois',
    );
    return '$_temp0';
  }

  @override
  String get ruleForever => ', sans fin';

  @override
  String get repeat => 'Répéter';

  @override
  String get never => 'Jamais';

  @override
  String get custom => 'Personnalisé';

  @override
  String get timeZone => 'Fuseau horaire';

  @override
  String get invite => 'Inviter';

  @override
  String calendarDefault(String value) {
    return 'Par défaut ($value)';
  }

  @override
  String get atStart => 'Au début';

  @override
  String get every => 'Tous les';

  @override
  String get less => 'Moins';

  @override
  String get more => 'Plus';

  @override
  String get unitDays => 'Jours';

  @override
  String get unitWeeks => 'Semaines';

  @override
  String get unitMonths => 'Mois';

  @override
  String get unitYears => 'Ans';

  @override
  String get onDays => 'Les jours';

  @override
  String get ends => 'Se termine';

  @override
  String get onDate => 'À la date';

  @override
  String get after => 'Après';

  @override
  String afterTimes(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n fois',
      one: '1 fois',
    );
    return '$_temp0';
  }

  @override
  String get summary => 'Résumé';

  @override
  String get event => 'Événement';

  @override
  String get inviteTitle => 'Inviter des personnes';

  @override
  String get send => 'Envoyer';

  @override
  String get nameOrEmail => 'Nom ou adresse e-mail';

  @override
  String get selected => 'Sélectionnés';

  @override
  String get suggestions => 'Suggestions';

  @override
  String get guestsCan => 'Les invités peuvent';

  @override
  String get canInvite => 'Inviter d’autres personnes';

  @override
  String get canModify => 'Modifier l’événement';

  @override
  String get canSee => 'Voir la liste des invités';

  @override
  String get inviteNote =>
      'L’invitation sera envoyée par e-mail depuis votre compte Google.';

  @override
  String get inviteMore => 'Inviter d’autres personnes';

  @override
  String get shareEvent => 'Partager l’événement';

  @override
  String invitationFrom(String name) {
    return 'Invitation de $name';
  }

  @override
  String get organizerLabel => 'Organisateur';

  @override
  String get conflict => 'Conflit';

  @override
  String get nothingPlanned => 'Rien de prévu.';

  @override
  String get addEvent => 'Ajouter un événement';

  @override
  String get holiday => 'Jour férié';

  @override
  String get syncLabel => 'Synchronisation';

  @override
  String get conflictTitle => 'Modifications en conflit';

  @override
  String conflictBody(String title) {
    return '$title a été modifié sur ce téléphone et dans Google. Choisissez la version à garder.';
  }

  @override
  String get thisPhone => 'Ce téléphone';

  @override
  String changedAt(String time) {
    return 'Modifié $time';
  }

  @override
  String get time => 'Heure';

  @override
  String get titleLabel => 'Titre';

  @override
  String get keepBoth => 'Garder les deux';

  @override
  String get useSelected => 'Utiliser la sélection';

  @override
  String get visibility => 'Visibilité';

  @override
  String get mineGoogle => 'Les miens · Google';

  @override
  String get sharedWithMe => 'Partagés avec moi';

  @override
  String get subscriptions => 'Abonnements';

  @override
  String get addCalendar => 'Ajouter un agenda';

  @override
  String get roleOwner => 'Propriétaire';

  @override
  String get roleWriter => 'Modification';

  @override
  String get roleReader => 'Lecture';

  @override
  String get roleFreeBusy => 'Disponibilités';

  @override
  String shareCalendar(String name) {
    return 'Partager l’agenda $name';
  }

  @override
  String get newCalendar => 'Nouvel agenda';

  @override
  String get newCalendarHint => 'Dans votre compte Google';

  @override
  String get holidaysAndDaysOff => 'Jours fériés et congés';

  @override
  String get holidaysHint => 'Fêtes nationales et religieuses';

  @override
  String get googleAccount => 'Compte Google';

  @override
  String get googleAccountHint => 'Se connecter et synchroniser';

  @override
  String get calendarName => 'Nom de l’agenda';

  @override
  String get holidays => 'Jours fériés';

  @override
  String get country => 'Pays';

  @override
  String get addCountry => '+ Ajouter un pays';

  @override
  String holidaysInYear(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n jours fériés cette année',
      one: '1 jour férié cette année',
    );
    return '$_temp0';
  }

  @override
  String get nearest => 'Prochainement';

  @override
  String get shareTitle => 'Partager';

  @override
  String calendarNamed(String name) {
    return 'Agenda $name';
  }

  @override
  String get peopleWithAccess => 'Personnes ayant accès';

  @override
  String get you => 'Vous';

  @override
  String get addPerson => 'Ajouter une personne';

  @override
  String get newPeopleAccess => 'Accès pour les nouvelles personnes';

  @override
  String get freeBusyHint =>
      'Disponibilités montre seulement quand vous êtes occupé, sans le nom des événements.';

  @override
  String get link => 'Lien';

  @override
  String get linkAccess => 'Accès par lien';

  @override
  String get copyLink => 'Copier le lien';

  @override
  String get off => 'Désactivé';

  @override
  String get linkCopied => 'Lien copié';

  @override
  String get removeAccess => 'Retirer l’accès';

  @override
  String get emailAddress => 'Adresse e-mail';

  @override
  String sharesWithYou(String name) {
    return '$name partage un agenda avec vous';
  }

  @override
  String get yourAccess => 'Votre accès';

  @override
  String get marker => 'Marqueur';

  @override
  String get shapeNames =>
      'Point,Carré,Moitié,Losange,Anneau,Pointillé,Triangle,Triangle inversé,Carré vide,Losange vide,Plus,Croix,Étoile,Hexagone,Cœur,Cible,Carré à point,Part,Diagonale,Barre,Pilier,Deux points,Triangle vide,Moitié haute';

  @override
  String get showInViews => 'Afficher dans les vues';

  @override
  String get otherWay => 'Dans l’autre sens';

  @override
  String get shareYours => 'Partager votre agenda en retour';

  @override
  String get choose => 'Choisir';

  @override
  String get shared => 'Partagé';

  @override
  String get reject => 'Retirer';

  @override
  String get settings => 'Réglages';

  @override
  String get upToDate => 'À jour';

  @override
  String get offline => 'Hors ligne';

  @override
  String get appearance => 'Apparence';

  @override
  String get notificationsGlyph => 'Notifications';

  @override
  String get calendarsSharing => 'Agendas et partage';

  @override
  String get dataPrivacy => 'Données et confidentialité';

  @override
  String get help => 'Aide';

  @override
  String get about => 'À propos';

  @override
  String get themeDark => 'Sombre';

  @override
  String get themeLight => 'Clair';

  @override
  String get themeSystem => 'Système';

  @override
  String get theme => 'Thème';

  @override
  String get firstDay => 'Premier jour de la semaine';

  @override
  String get timeFormat => 'Format de l’heure';

  @override
  String get weekNumbers => 'Numéros de semaine';

  @override
  String get showWeekends => 'Afficher les week-ends';

  @override
  String get declinedInvites => 'Invitations refusées';

  @override
  String get style => 'Style';

  @override
  String get dotDigits => 'Chiffres en points';

  @override
  String get dimPast => 'Griser le passé';

  @override
  String get accounts => 'Comptes';

  @override
  String get lastSync => 'Dernière synchronisation';

  @override
  String calendarsN(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n agendas',
      one: '1 agenda',
    );
    return '$_temp0';
  }

  @override
  String get syncNow => 'Synchroniser';

  @override
  String get active => 'Actif';

  @override
  String get addAccount => 'Ajouter un compte';

  @override
  String get automatic => 'Automatiquement';

  @override
  String get frequency => 'Fréquence';

  @override
  String everyMinutes(int n) {
    return 'Toutes les $n min';
  }

  @override
  String get disconnectGoogle => 'Déconnecter le compte Google';

  @override
  String get disconnectBody =>
      'Les agendas et réglages sont supprimés de ce téléphone. Rien ne change dans Google.';

  @override
  String get disconnect => 'Déconnecter';

  @override
  String get privacy => 'Confidentialité';

  @override
  String get hideOnLockScreen =>
      'Masquer les détails sur l’écran de verrouillage';

  @override
  String get device => 'Appareil';

  @override
  String get clearData => 'Effacer les données de cet appareil';

  @override
  String get clearDataBody =>
      'Les agendas, le cache et les réglages sont supprimés de ce téléphone et vous êtes déconnecté.';

  @override
  String get googleUntouched => 'Vos événements dans Google ne changent pas.';

  @override
  String get searchHelp => 'Rechercher dans l’aide';

  @override
  String get faq => 'Questions fréquentes';

  @override
  String get contact => 'Contact';

  @override
  String get aboutApp => 'À propos de l’appli';

  @override
  String readTime(String topic) {
    return '$topic · 1 min de lecture';
  }

  @override
  String get tip => 'Astuce';

  @override
  String openScreen(String name) {
    return 'Ouvrir $name';
  }

  @override
  String get devVersion => 'Version de développement';

  @override
  String get stableVersion => 'Version stable';

  @override
  String get build => 'Build';

  @override
  String get system => 'Système';

  @override
  String get legal => 'Mentions légales';

  @override
  String get licenses => 'Licences open source';

  @override
  String get typefaces => 'Polices';

  @override
  String get notifications => 'Notifications';

  @override
  String get reminders => 'Rappels';

  @override
  String get defaultLabel => 'Par défaut';

  @override
  String get allDayEvents => 'Toute la journée';

  @override
  String dayBeforeAt(String time) {
    return 'La veille à $time';
  }

  @override
  String get dailySummary => 'Résumé du jour';

  @override
  String everyDayAt(String time) {
    return 'Tous les jours à $time';
  }

  @override
  String get invitations => 'Invitations';

  @override
  String get newInvitations => 'Nouvelles invitations';

  @override
  String get sharedChanges => 'Modifications des agendas partagés';

  @override
  String summaryTitle(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: 'Aujourd’hui : $n événements',
      one: 'Aujourd’hui : 1 événement',
    );
    return '$_temp0';
  }

  @override
  String invitesYou(String name, String title) {
    return '$name vous invite : $title';
  }

  @override
  String changesIn(String name) {
    return 'Modifications : $name';
  }

  @override
  String get sharedCalendars => 'Agendas partagés';

  @override
  String get snooze => 'Rappeler dans 5 min';

  @override
  String get details => 'Détails';

  @override
  String get off2 => 'Désactivé';

  @override
  String get personal => 'Personnel';

  @override
  String get customReminder => 'Rappel personnalisé';

  @override
  String get unitMinutes => 'Minutes';

  @override
  String get unitHours => 'Heures';

  @override
  String get reminderLimit => 'Jusqu’à 4 semaines avant.';

  @override
  String clashesWith(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: 'chevauche $n événements',
      one: 'chevauche 1 événement',
    );
    return '$_temp0';
  }

  @override
  String get crashTitle => 'L’appli s’est fermée de façon inattendue';

  @override
  String get crashBody => 'Copiez ce rapport et envoyez-le au développeur.';

  @override
  String get close => 'Fermer';

  @override
  String get copy => 'Copier';

  @override
  String get saveRepeating =>
      'Enregistrer les modifications d’un événement récurrent';

  @override
  String get weekNumbersHint =>
      'Numéro de semaine devant chaque ligne de la vue mois.';

  @override
  String get showWeekendsHint =>
      'Désactivé : les vues mois et semaine montrent seulement du lundi au vendredi.';

  @override
  String get declinedHint => 'Afficher dans les vues les invitations refusées.';

  @override
  String get dimPastHint =>
      'Les événements et jours passés sont affichés en gris.';

  @override
  String get inBackground => 'En arrière-plan';

  @override
  String get notYet => 'Pas encore';

  @override
  String get check => 'Vérifier';

  @override
  String get testBackgroundHint =>
      'Fermez l’appli pendant 1–2 minutes, puis revenez ici.';

  @override
  String clashesN(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n conflits',
      one: '1 conflit',
    );
    return '$_temp0';
  }

  @override
  String inH(int h) {
    return 'Dans $h h';
  }

  @override
  String inHM(int h, int m) {
    return 'Dans $h h $m min';
  }

  @override
  String get dayOff => 'Jour de repos';

  @override
  String hoursFree(int h) {
    return '$h h libres';
  }

  @override
  String get wifiOnly => 'Wi-Fi uniquement';

  @override
  String get wifiOnlyHint =>
      'La synchronisation automatique et en arrière-plan attend le Wi-Fi. Tirer la liste vers le bas synchronise toujours.';

  @override
  String get importFile => 'Importer un fichier';

  @override
  String get importFileHint => 'Fichier .ics du téléphone';

  @override
  String get exportAll => 'Tout exporter';

  @override
  String get importExport => 'Importer et exporter';

  @override
  String importTo(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: 'Importer $n événements dans',
      one: 'Importer 1 événement dans',
    );
    return '$_temp0';
  }

  @override
  String importing(int done, int n) {
    return 'Importation $done sur $n';
  }

  @override
  String importedN(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n événements importés',
      one: '1 événement importé',
    );
    return '$_temp0';
  }

  @override
  String failedN(int n) {
    return '$n en échec';
  }

  @override
  String get icsEmpty => 'Aucun événement dans ce fichier';

  @override
  String get exporting => 'Exportation…';

  @override
  String get fileSaved => 'Fichier enregistré';

  @override
  String get notSignedIn => 'Non connecté';

  @override
  String get removeCountry => 'Retirer le pays';

  @override
  String get subscribeUrl => 'S’abonner à une adresse';

  @override
  String get subscribeUrlHint => 'Lien .ics ou webcal://';

  @override
  String get subscribe => 'S’abonner';

  @override
  String get subscribeNote =>
      'Actualisé toutes les heures. L’agenda est en lecture seule.';

  @override
  String get subscribing => 'Abonnement…';

  @override
  String subscribed(String name) {
    return 'Abonné : $name';
  }

  @override
  String get unsubscribe => 'Se désabonner';

  @override
  String unsubscribeBody(String name) {
    return 'L’agenda $name et ses événements sont supprimés de Google. Vous pourrez vous réabonner plus tard.';
  }

  @override
  String get notIcs => 'Cette adresse n’est pas un agenda .ics';

  @override
  String get deleteCalendar => 'Supprimer l’agenda';

  @override
  String deleteCalendarBody(String name) {
    return 'L’agenda $name et tous ses événements sont supprimés de Google pour toutes les personnes avec qui il est partagé. C’est définitif.';
  }

  @override
  String get freeNow => 'Libre';

  @override
  String ongoingUntil(String time) {
    return 'Maintenant · jusqu’à $time';
  }

  @override
  String get appLock => 'Verrouillage de l’appli';

  @override
  String get appLockHint =>
      'Demande votre empreinte, votre visage ou le code de verrouillage à l’ouverture et après une minute d’absence.';

  @override
  String get appLocked => 'L’agenda est verrouillé';

  @override
  String get unlock => 'Déverrouiller';

  @override
  String get unlockReason => 'Déverrouiller l’agenda';

  @override
  String get appLockNoScreenLock =>
      'Configurez d’abord un verrouillage d’écran sur le téléphone.';

  @override
  String get glyphInterface => 'Glyph Interface';

  @override
  String get glyphLight => 'Lumière avec les rappels';

  @override
  String get glyphPattern => 'Motif lumineux';

  @override
  String get glyphCountdown => 'Compte à rebours';

  @override
  String get glyphPulse => 'Pulsation';

  @override
  String get glyphBlink => 'Clignotement';

  @override
  String get glyphSteady => 'Fixe';

  @override
  String get glyphGlass => 'Verre';

  @override
  String get glyphClock => 'Horloge';

  @override
  String get myCalendar => 'Mon agenda';

  @override
  String get onDevice => 'Sur cet appareil';

  @override
  String get onlyThisPhone => 'Ce téléphone uniquement';

  @override
  String get newCalendarLocalHint => 'Sur ce téléphone uniquement';

  @override
  String get onPhone => 'Sur le téléphone';

  @override
  String get chooseLanguage => 'Choisir la langue';

  @override
  String get phoneLanguage => 'Langue du téléphone';

  @override
  String get continueBtn => 'Continuer';

  @override
  String get language => 'Langue';

  @override
  String get newVersion => 'Nouvelle version';

  @override
  String currentVersion(String version) {
    return 'Actuelle $version';
  }

  @override
  String get whatsNew => 'Nouveautés';

  @override
  String get downloadInstall => 'Télécharger et installer';

  @override
  String get later => 'Plus tard';

  @override
  String newVersionN(String version) {
    return 'Nouvelle version $version';
  }

  @override
  String get tapToSee => 'Touchez pour voir';

  @override
  String get updates => 'Mises à jour';
}
