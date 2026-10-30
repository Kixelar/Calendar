// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Calendar';

  @override
  String get skip => 'Skip';

  @override
  String get welcomeTitle => 'Your time,\nwithout the noise.';

  @override
  String get welcomeBody =>
      'All your calendars in one place. Google sync, holidays and calendars shared with people close to you.';

  @override
  String get connectGoogle => 'Connect Google';

  @override
  String get continueWithout => 'Continue without account';

  @override
  String get back => 'Back';

  @override
  String step(int n) {
    return 'Step $n of 3';
  }

  @override
  String get connectTitle => 'Connect Google Calendar';

  @override
  String get weAskFor => 'We will ask for access to';

  @override
  String get accessEvents => 'Events — read and edit';

  @override
  String get accessCalendars => 'Your list of calendars';

  @override
  String get accessInvites => 'Replies to invitations';

  @override
  String get accessEmail => 'Your account email';

  @override
  String get noAccessTo => 'No access to';

  @override
  String get noAccessFiles => 'Mail, Drive and Photos';

  @override
  String get noAccessContacts => 'Contacts and other apps';

  @override
  String get signInGoogle => 'Sign in with Google';

  @override
  String signInFailed(String error) {
    return 'Sign-in failed: $error';
  }

  @override
  String get noClientId =>
      'This build has no Google client ID. See docs/GOOGLE.md.';

  @override
  String get chooseTitle => 'Choose calendars';

  @override
  String get calendars => 'Calendars';

  @override
  String get sharedWithYou => 'Shared with you';

  @override
  String get suggested => 'Suggested';

  @override
  String syncN(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: 'Sync $n calendars',
      one: 'Sync 1 calendar',
    );
    return '$_temp0';
  }

  @override
  String get done => 'Done';

  @override
  String get year => 'Year';

  @override
  String get month => 'Month';

  @override
  String get week => 'Week';

  @override
  String get day => 'Day';

  @override
  String get yearHint => 'A dot is a day';

  @override
  String weekN(int n) {
    return 'Week $n';
  }

  @override
  String eventsN(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n events',
      one: '1 event',
    );
    return '$_temp0';
  }

  @override
  String moreN(int n) {
    return '$n more';
  }

  @override
  String inMin(int n) {
    return 'In $n min';
  }

  @override
  String get today => 'Today';

  @override
  String get tomorrow => 'Tomorrow';

  @override
  String get next => 'Next';

  @override
  String get allDay => 'All day';

  @override
  String get schedule => 'Schedule';

  @override
  String get noEvents => 'No events';

  @override
  String get loadFailed => 'Could not load events. Pull to retry.';

  @override
  String get weekdays => 'MO,TU,WE,TH,FR,SA,SU';

  @override
  String get previous => 'Previous';

  @override
  String get following => 'Next';
}
