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
  String get weekdays => 'MO,TU,WE,TH,FR,SA,SU';

  @override
  String get previous => 'Previous';

  @override
  String get following => 'Next';

  @override
  String get newEvent => 'New event';

  @override
  String get eventName => 'Event name';

  @override
  String get save => 'Save';

  @override
  String get closeNoSave => 'Close without saving';

  @override
  String get start => 'Start';

  @override
  String get end => 'End';

  @override
  String get calendar => 'Calendar';

  @override
  String get place => 'Location';

  @override
  String get notes => 'Notes';

  @override
  String get add => 'Add';

  @override
  String get reminder => 'Reminder';

  @override
  String get none => 'None';

  @override
  String minBefore(int n) {
    return '$n min before';
  }

  @override
  String hoursBefore(int n) {
    return '$n h before';
  }

  @override
  String daysBefore(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n days before',
      one: '1 day before',
    );
    return '$_temp0';
  }

  @override
  String get guests => 'Guests';

  @override
  String get youOrganize => 'You organize';

  @override
  String get rsvpYes => 'Yes';

  @override
  String get rsvpMaybe => 'Maybe';

  @override
  String get rsvpNo => 'No';

  @override
  String get rsvpWaiting => 'Waiting';

  @override
  String get edit => 'Edit';

  @override
  String get delete => 'Delete';

  @override
  String get cancel => 'Cancel';

  @override
  String get deleteTitle => 'Delete event?';

  @override
  String repeats(String title) {
    return '$title repeats.';
  }

  @override
  String get onlyThis => 'Only this';

  @override
  String get thisAndFollowing => 'This and following';

  @override
  String get allOccurrences => 'All';

  @override
  String get notifyGuests => 'Notify guests';

  @override
  String get endBeforeStart => 'The end must be after the start.';

  @override
  String failed(String error) {
    return 'Failed: $error';
  }

  @override
  String get syncing => 'Syncing';

  @override
  String eventsFrom(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: 'events from $n calendars',
      one: 'events from 1 calendar',
    );
    return '$_temp0';
  }

  @override
  String aboutSecondsLeft(int n) {
    return 'About $n s left';
  }

  @override
  String get statusDone => 'Done';

  @override
  String get statusRunning => 'In progress';

  @override
  String get statusQueued => 'Queued';

  @override
  String get statusFailed => 'Failed';

  @override
  String get runInBackground => 'Run in background';

  @override
  String get search => 'Search';

  @override
  String get searchHint => 'Search events, people, places';

  @override
  String get clear => 'Clear';

  @override
  String get filterAll => 'All';

  @override
  String get withGuests => 'With guests';

  @override
  String get upcoming => 'Upcoming';

  @override
  String get past => 'Past';

  @override
  String get recentSearches => 'Recent searches';

  @override
  String get noResults => 'Nothing found';

  @override
  String everyDays(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: 'Every $n days',
      one: 'Every day',
    );
    return '$_temp0';
  }

  @override
  String everyWeeks(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: 'Every $n weeks',
      one: 'Every week',
    );
    return '$_temp0';
  }

  @override
  String everyMonths(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: 'Every $n months',
      one: 'Every month',
    );
    return '$_temp0';
  }

  @override
  String everyYears(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: 'Every $n years',
      one: 'Every year',
    );
    return '$_temp0';
  }

  @override
  String get weekdaysOn =>
      'on Monday,on Tuesday,on Wednesday,on Thursday,on Friday,on Saturday,on Sunday';

  @override
  String get weekdaysAcc =>
      'Monday,Tuesday,Wednesday,Thursday,Friday,Saturday,Sunday';

  @override
  String get and => 'and';

  @override
  String ruleUntil(String date) {
    return ', until $date';
  }

  @override
  String ruleCount(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: ', $n times',
      one: ', once',
    );
    return '$_temp0';
  }

  @override
  String get ruleForever => ', forever';

  @override
  String get repeat => 'Repeat';

  @override
  String get never => 'Never';

  @override
  String get custom => 'Custom';

  @override
  String get timeZone => 'Time zone';

  @override
  String get invite => 'Invite';

  @override
  String calendarDefault(String value) {
    return 'Default ($value)';
  }

  @override
  String get atStart => 'At start';

  @override
  String get every => 'Every';

  @override
  String get less => 'Less';

  @override
  String get more => 'More';

  @override
  String get unitDays => 'Days';

  @override
  String get unitWeeks => 'Weeks';

  @override
  String get unitMonths => 'Months';

  @override
  String get unitYears => 'Years';

  @override
  String get onDays => 'On days';

  @override
  String get ends => 'Ends';

  @override
  String get onDate => 'On date';

  @override
  String get after => 'After';

  @override
  String afterTimes(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n times',
      one: '1 time',
    );
    return '$_temp0';
  }

  @override
  String get summary => 'Summary';

  @override
  String get event => 'Event';

  @override
  String get inviteTitle => 'Invite guests';

  @override
  String get send => 'Send';

  @override
  String get nameOrEmail => 'Name or e-mail address';

  @override
  String get selected => 'Selected';

  @override
  String get suggestions => 'Suggestions';

  @override
  String get guestsCan => 'Guests can';

  @override
  String get canInvite => 'Invite others';

  @override
  String get canModify => 'Edit the event';

  @override
  String get canSee => 'See the guest list';

  @override
  String get inviteNote =>
      'We will e-mail the invitation from your Google account.';

  @override
  String get inviteMore => 'Invite more people';

  @override
  String get shareEvent => 'Share event';

  @override
  String get moreOptions => 'More options';

  @override
  String invitationFrom(String name) {
    return 'Invitation from $name';
  }

  @override
  String get organizerLabel => 'Organizer';

  @override
  String get conflict => 'Conflict';

  @override
  String get nothingPlanned => 'Nothing planned.';

  @override
  String get freeDay => 'A day off work. Rest or add something for yourself.';

  @override
  String get openDay => 'This day is free. Add something or keep it that way.';

  @override
  String get addEvent => 'Add event';

  @override
  String get holiday => 'Holiday';

  @override
  String get syncLabel => 'Sync';

  @override
  String get conflictTitle => 'Conflicting changes';

  @override
  String conflictBody(String title) {
    return '$title was changed on this phone and in Google. Choose the version to keep.';
  }

  @override
  String get thisPhone => 'This phone';

  @override
  String changedAt(String time) {
    return 'Changed $time';
  }

  @override
  String get time => 'Time';

  @override
  String get titleLabel => 'Title';

  @override
  String get keepBoth => 'Keep both';

  @override
  String get useSelected => 'Use selected';

  @override
  String get visibility => 'Visibility';

  @override
  String get mineGoogle => 'Mine · Google';

  @override
  String get sharedWithMe => 'Shared with me';

  @override
  String get subscriptions => 'Subscriptions';

  @override
  String get addCalendar => 'Add calendar';

  @override
  String get roleOwner => 'Owner';

  @override
  String get roleWriter => 'Edit';

  @override
  String get roleReader => 'View';

  @override
  String get roleFreeBusy => 'Busy only';

  @override
  String shareCalendar(String name) {
    return 'Share calendar $name';
  }

  @override
  String get newCalendar => 'New calendar';

  @override
  String get newCalendarHint => 'In your Google account';

  @override
  String get holidaysAndDaysOff => 'Holidays and days off';

  @override
  String get holidaysHint => 'Public and religious holidays';

  @override
  String get googleAccount => 'Google account';

  @override
  String get googleAccountHint => 'Sign in and sync';

  @override
  String get calendarName => 'Calendar name';

  @override
  String get holidays => 'Holidays';

  @override
  String get country => 'Country';

  @override
  String get addCountry => '+ Add country';

  @override
  String holidaysInYear(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n holidays this year',
      one: '1 holiday this year',
    );
    return '$_temp0';
  }

  @override
  String get nearest => 'Coming up';

  @override
  String get shareTitle => 'Share';

  @override
  String calendarNamed(String name) {
    return 'Calendar $name';
  }

  @override
  String get peopleWithAccess => 'People with access';

  @override
  String get you => 'You';

  @override
  String get addPerson => 'Add person';

  @override
  String get newPeopleAccess => 'Access for new people';

  @override
  String get freeBusyHint =>
      'Busy only shows when you are busy, without event names.';

  @override
  String get link => 'Link';

  @override
  String get linkAccess => 'Access by link';

  @override
  String get copyLink => 'Copy link';

  @override
  String get off => 'Off';

  @override
  String get linkCopied => 'Link copied';

  @override
  String get removeAccess => 'Remove access';

  @override
  String get emailAddress => 'E-mail address';

  @override
  String sharesWithYou(String name) {
    return '$name shares a calendar with you';
  }

  @override
  String get yourAccess => 'Your access';

  @override
  String get marker => 'Marker';

  @override
  String get shapeNames => 'Dot,Square,Half,Diamond,Ring,Dashed';

  @override
  String get showInViews => 'Show in views';

  @override
  String get otherWay => 'The other way';

  @override
  String get shareYours => 'Share your calendar back';

  @override
  String get choose => 'Choose';

  @override
  String get shared => 'Shared';

  @override
  String get reject => 'Remove';

  @override
  String get settings => 'Settings';

  @override
  String get upToDate => 'Up to date';

  @override
  String get offline => 'Offline';

  @override
  String get appearance => 'Appearance';

  @override
  String get notificationsGlyph => 'Notifications';

  @override
  String get accountsSync => 'Accounts and sync';

  @override
  String get calendarsSharing => 'Calendars and sharing';

  @override
  String get dataPrivacy => 'Data and privacy';

  @override
  String get help => 'Help';

  @override
  String get about => 'About';

  @override
  String get themeDark => 'Dark';

  @override
  String get themeLight => 'Light';

  @override
  String get themeSystem => 'System';

  @override
  String get theme => 'Theme';

  @override
  String get firstDay => 'First day of the week';

  @override
  String get timeFormat => 'Time format';

  @override
  String get weekNumbers => 'Week numbers';

  @override
  String get showWeekends => 'Show weekends';

  @override
  String get declinedInvites => 'Declined invitations';

  @override
  String get style => 'Style';

  @override
  String get dotDigits => 'Dot digits';

  @override
  String get dimPast => 'Dim past events';

  @override
  String get accounts => 'Accounts';

  @override
  String get lastSync => 'Last sync';

  @override
  String calendarsN(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n calendars',
      one: '1 calendar',
    );
    return '$_temp0';
  }

  @override
  String get syncNow => 'Sync now';

  @override
  String get active => 'Active';

  @override
  String get addAccount => 'Add account';

  @override
  String get automatic => 'Automatically';

  @override
  String get frequency => 'Frequency';

  @override
  String everyMinutes(int n) {
    return 'Every $n min';
  }

  @override
  String get disconnectGoogle => 'Disconnect Google account';

  @override
  String get disconnectBody =>
      'Calendars and settings are removed from this phone. Nothing changes in Google.';

  @override
  String get disconnect => 'Disconnect';

  @override
  String get privacy => 'Privacy';

  @override
  String get hideOnLockScreen => 'Hide details on the lock screen';

  @override
  String get device => 'Device';

  @override
  String get clearData => 'Clear data on this device';

  @override
  String get clearDataBody =>
      'Calendars, cache and settings are removed from this phone and you are signed out.';

  @override
  String get googleUntouched => 'Your events in Google stay untouched.';

  @override
  String get searchHelp => 'Search help';

  @override
  String get faq => 'Common questions';

  @override
  String get contact => 'Contact';

  @override
  String get aboutApp => 'About the app';

  @override
  String readTime(String topic) {
    return '$topic · 1 min read';
  }

  @override
  String get tip => 'Tip';

  @override
  String openScreen(String name) {
    return 'Open $name';
  }

  @override
  String get devVersion => 'Development version';

  @override
  String get stableVersion => 'Stable version';

  @override
  String get build => 'Build';

  @override
  String get system => 'System';

  @override
  String get legal => 'Legal';

  @override
  String get licenses => 'Open source licences';

  @override
  String get typefaces => 'Typefaces';

  @override
  String get notifications => 'Notifications';

  @override
  String get reminders => 'Reminders';

  @override
  String get defaultLabel => 'Default';

  @override
  String get allDayEvents => 'All-day';

  @override
  String dayBeforeAt(String time) {
    return '$time the day before';
  }

  @override
  String get dailySummary => 'Daily summary';

  @override
  String everyDayAt(String time) {
    return 'Every day $time';
  }

  @override
  String get invitations => 'Invitations';

  @override
  String get newInvitations => 'New invitations';

  @override
  String get sharedChanges => 'Changes in shared calendars';

  @override
  String summaryTitle(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: 'Today: $n events',
      one: 'Today: 1 event',
    );
    return '$_temp0';
  }

  @override
  String invitesYou(String name, String title) {
    return '$name invites you: $title';
  }

  @override
  String changesIn(String name) {
    return 'Changes: $name';
  }

  @override
  String get sharedCalendars => 'Shared calendars';

  @override
  String get snooze => 'Snooze 5 min';

  @override
  String get details => 'Details';

  @override
  String get off2 => 'Off';

  @override
  String get personal => 'Personal';

  @override
  String get birthdays => 'Birthdays';

  @override
  String get customReminder => 'Custom reminder';

  @override
  String get unitMinutes => 'Minutes';

  @override
  String get unitHours => 'Hours';

  @override
  String get reminderLimit => 'Up to 4 weeks before.';
}
