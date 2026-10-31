import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_pl.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('pl'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Calendar'**
  String get appTitle;

  /// No description provided for @skip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get skip;

  /// No description provided for @welcomeTitle.
  ///
  /// In en, this message translates to:
  /// **'Your time,\nwithout the noise.'**
  String get welcomeTitle;

  /// No description provided for @welcomeBody.
  ///
  /// In en, this message translates to:
  /// **'All your calendars in one place. Google sync, holidays and calendars shared with people close to you.'**
  String get welcomeBody;

  /// No description provided for @connectGoogle.
  ///
  /// In en, this message translates to:
  /// **'Connect Google'**
  String get connectGoogle;

  /// No description provided for @continueWithout.
  ///
  /// In en, this message translates to:
  /// **'Continue without account'**
  String get continueWithout;

  /// No description provided for @back.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get back;

  /// No description provided for @step.
  ///
  /// In en, this message translates to:
  /// **'Step {n} of 3'**
  String step(int n);

  /// No description provided for @connectTitle.
  ///
  /// In en, this message translates to:
  /// **'Connect Google Calendar'**
  String get connectTitle;

  /// No description provided for @weAskFor.
  ///
  /// In en, this message translates to:
  /// **'We will ask for access to'**
  String get weAskFor;

  /// No description provided for @accessEvents.
  ///
  /// In en, this message translates to:
  /// **'Events — read and edit'**
  String get accessEvents;

  /// No description provided for @accessCalendars.
  ///
  /// In en, this message translates to:
  /// **'Your list of calendars'**
  String get accessCalendars;

  /// No description provided for @accessInvites.
  ///
  /// In en, this message translates to:
  /// **'Replies to invitations'**
  String get accessInvites;

  /// No description provided for @accessEmail.
  ///
  /// In en, this message translates to:
  /// **'Your account email'**
  String get accessEmail;

  /// No description provided for @noAccessTo.
  ///
  /// In en, this message translates to:
  /// **'No access to'**
  String get noAccessTo;

  /// No description provided for @noAccessFiles.
  ///
  /// In en, this message translates to:
  /// **'Mail, Drive and Photos'**
  String get noAccessFiles;

  /// No description provided for @noAccessContacts.
  ///
  /// In en, this message translates to:
  /// **'Contacts and other apps'**
  String get noAccessContacts;

  /// No description provided for @signInGoogle.
  ///
  /// In en, this message translates to:
  /// **'Sign in with Google'**
  String get signInGoogle;

  /// No description provided for @signInFailed.
  ///
  /// In en, this message translates to:
  /// **'Sign-in failed: {error}'**
  String signInFailed(String error);

  /// No description provided for @noClientId.
  ///
  /// In en, this message translates to:
  /// **'This build has no Google client ID. See docs/GOOGLE.md.'**
  String get noClientId;

  /// No description provided for @chooseTitle.
  ///
  /// In en, this message translates to:
  /// **'Choose calendars'**
  String get chooseTitle;

  /// No description provided for @calendars.
  ///
  /// In en, this message translates to:
  /// **'Calendars'**
  String get calendars;

  /// No description provided for @sharedWithYou.
  ///
  /// In en, this message translates to:
  /// **'Shared with you'**
  String get sharedWithYou;

  /// No description provided for @suggested.
  ///
  /// In en, this message translates to:
  /// **'Suggested'**
  String get suggested;

  /// No description provided for @syncN.
  ///
  /// In en, this message translates to:
  /// **'{n, plural, =1{Sync 1 calendar} other{Sync {n} calendars}}'**
  String syncN(int n);

  /// No description provided for @done.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get done;

  /// No description provided for @year.
  ///
  /// In en, this message translates to:
  /// **'Year'**
  String get year;

  /// No description provided for @month.
  ///
  /// In en, this message translates to:
  /// **'Month'**
  String get month;

  /// No description provided for @week.
  ///
  /// In en, this message translates to:
  /// **'Week'**
  String get week;

  /// No description provided for @day.
  ///
  /// In en, this message translates to:
  /// **'Day'**
  String get day;

  /// No description provided for @yearHint.
  ///
  /// In en, this message translates to:
  /// **'A dot is a day'**
  String get yearHint;

  /// No description provided for @weekN.
  ///
  /// In en, this message translates to:
  /// **'Week {n}'**
  String weekN(int n);

  /// No description provided for @eventsN.
  ///
  /// In en, this message translates to:
  /// **'{n, plural, =1{1 event} other{{n} events}}'**
  String eventsN(int n);

  /// No description provided for @moreN.
  ///
  /// In en, this message translates to:
  /// **'{n} more'**
  String moreN(int n);

  /// No description provided for @inMin.
  ///
  /// In en, this message translates to:
  /// **'In {n} min'**
  String inMin(int n);

  /// No description provided for @today.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get today;

  /// No description provided for @tomorrow.
  ///
  /// In en, this message translates to:
  /// **'Tomorrow'**
  String get tomorrow;

  /// No description provided for @next.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get next;

  /// No description provided for @allDay.
  ///
  /// In en, this message translates to:
  /// **'All day'**
  String get allDay;

  /// No description provided for @schedule.
  ///
  /// In en, this message translates to:
  /// **'Schedule'**
  String get schedule;

  /// No description provided for @noEvents.
  ///
  /// In en, this message translates to:
  /// **'No events'**
  String get noEvents;

  /// No description provided for @loadFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not load events. Pull to retry.'**
  String get loadFailed;

  /// No description provided for @weekdays.
  ///
  /// In en, this message translates to:
  /// **'MO,TU,WE,TH,FR,SA,SU'**
  String get weekdays;

  /// No description provided for @previous.
  ///
  /// In en, this message translates to:
  /// **'Previous'**
  String get previous;

  /// No description provided for @following.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get following;

  /// No description provided for @newEvent.
  ///
  /// In en, this message translates to:
  /// **'New event'**
  String get newEvent;

  /// No description provided for @eventName.
  ///
  /// In en, this message translates to:
  /// **'Event name'**
  String get eventName;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @closeNoSave.
  ///
  /// In en, this message translates to:
  /// **'Close without saving'**
  String get closeNoSave;

  /// No description provided for @start.
  ///
  /// In en, this message translates to:
  /// **'Start'**
  String get start;

  /// No description provided for @end.
  ///
  /// In en, this message translates to:
  /// **'End'**
  String get end;

  /// No description provided for @calendar.
  ///
  /// In en, this message translates to:
  /// **'Calendar'**
  String get calendar;

  /// No description provided for @place.
  ///
  /// In en, this message translates to:
  /// **'Location'**
  String get place;

  /// No description provided for @notes.
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get notes;

  /// No description provided for @add.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get add;

  /// No description provided for @reminder.
  ///
  /// In en, this message translates to:
  /// **'Reminder'**
  String get reminder;

  /// No description provided for @none.
  ///
  /// In en, this message translates to:
  /// **'None'**
  String get none;

  /// No description provided for @minBefore.
  ///
  /// In en, this message translates to:
  /// **'{n} min before'**
  String minBefore(int n);

  /// No description provided for @hoursBefore.
  ///
  /// In en, this message translates to:
  /// **'{n} h before'**
  String hoursBefore(int n);

  /// No description provided for @daysBefore.
  ///
  /// In en, this message translates to:
  /// **'{n, plural, =1{1 day before} other{{n} days before}}'**
  String daysBefore(int n);

  /// No description provided for @guests.
  ///
  /// In en, this message translates to:
  /// **'Guests'**
  String get guests;

  /// No description provided for @youOrganize.
  ///
  /// In en, this message translates to:
  /// **'You organize'**
  String get youOrganize;

  /// No description provided for @rsvpYes.
  ///
  /// In en, this message translates to:
  /// **'Yes'**
  String get rsvpYes;

  /// No description provided for @rsvpMaybe.
  ///
  /// In en, this message translates to:
  /// **'Maybe'**
  String get rsvpMaybe;

  /// No description provided for @rsvpNo.
  ///
  /// In en, this message translates to:
  /// **'No'**
  String get rsvpNo;

  /// No description provided for @rsvpWaiting.
  ///
  /// In en, this message translates to:
  /// **'Waiting'**
  String get rsvpWaiting;

  /// No description provided for @edit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @deleteTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete event?'**
  String get deleteTitle;

  /// No description provided for @repeats.
  ///
  /// In en, this message translates to:
  /// **'{title} repeats.'**
  String repeats(String title);

  /// No description provided for @onlyThis.
  ///
  /// In en, this message translates to:
  /// **'Only this'**
  String get onlyThis;

  /// No description provided for @thisAndFollowing.
  ///
  /// In en, this message translates to:
  /// **'This and following'**
  String get thisAndFollowing;

  /// No description provided for @allOccurrences.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get allOccurrences;

  /// No description provided for @notifyGuests.
  ///
  /// In en, this message translates to:
  /// **'Notify guests'**
  String get notifyGuests;

  /// No description provided for @endBeforeStart.
  ///
  /// In en, this message translates to:
  /// **'The end must be after the start.'**
  String get endBeforeStart;

  /// No description provided for @failed.
  ///
  /// In en, this message translates to:
  /// **'Failed: {error}'**
  String failed(String error);

  /// No description provided for @syncing.
  ///
  /// In en, this message translates to:
  /// **'Syncing'**
  String get syncing;

  /// No description provided for @eventsFrom.
  ///
  /// In en, this message translates to:
  /// **'{n, plural, =1{events from 1 calendar} other{events from {n} calendars}}'**
  String eventsFrom(int n);

  /// No description provided for @aboutSecondsLeft.
  ///
  /// In en, this message translates to:
  /// **'About {n} s left'**
  String aboutSecondsLeft(int n);

  /// No description provided for @statusDone.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get statusDone;

  /// No description provided for @statusRunning.
  ///
  /// In en, this message translates to:
  /// **'In progress'**
  String get statusRunning;

  /// No description provided for @statusQueued.
  ///
  /// In en, this message translates to:
  /// **'Queued'**
  String get statusQueued;

  /// No description provided for @statusFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed'**
  String get statusFailed;

  /// No description provided for @runInBackground.
  ///
  /// In en, this message translates to:
  /// **'Run in background'**
  String get runInBackground;

  /// No description provided for @search.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get search;

  /// No description provided for @searchHint.
  ///
  /// In en, this message translates to:
  /// **'Search events, people, places'**
  String get searchHint;

  /// No description provided for @clear.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get clear;

  /// No description provided for @filterAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get filterAll;

  /// No description provided for @withGuests.
  ///
  /// In en, this message translates to:
  /// **'With guests'**
  String get withGuests;

  /// No description provided for @upcoming.
  ///
  /// In en, this message translates to:
  /// **'Upcoming'**
  String get upcoming;

  /// No description provided for @past.
  ///
  /// In en, this message translates to:
  /// **'Past'**
  String get past;

  /// No description provided for @recentSearches.
  ///
  /// In en, this message translates to:
  /// **'Recent searches'**
  String get recentSearches;

  /// No description provided for @noResults.
  ///
  /// In en, this message translates to:
  /// **'Nothing found'**
  String get noResults;

  /// No description provided for @everyDays.
  ///
  /// In en, this message translates to:
  /// **'{n, plural, =1{Every day} other{Every {n} days}}'**
  String everyDays(int n);

  /// No description provided for @everyWeeks.
  ///
  /// In en, this message translates to:
  /// **'{n, plural, =1{Every week} other{Every {n} weeks}}'**
  String everyWeeks(int n);

  /// No description provided for @everyMonths.
  ///
  /// In en, this message translates to:
  /// **'{n, plural, =1{Every month} other{Every {n} months}}'**
  String everyMonths(int n);

  /// No description provided for @everyYears.
  ///
  /// In en, this message translates to:
  /// **'{n, plural, =1{Every year} other{Every {n} years}}'**
  String everyYears(int n);

  /// No description provided for @weekdaysOn.
  ///
  /// In en, this message translates to:
  /// **'on Monday,on Tuesday,on Wednesday,on Thursday,on Friday,on Saturday,on Sunday'**
  String get weekdaysOn;

  /// No description provided for @weekdaysAcc.
  ///
  /// In en, this message translates to:
  /// **'Monday,Tuesday,Wednesday,Thursday,Friday,Saturday,Sunday'**
  String get weekdaysAcc;

  /// No description provided for @and.
  ///
  /// In en, this message translates to:
  /// **'and'**
  String get and;

  /// No description provided for @ruleUntil.
  ///
  /// In en, this message translates to:
  /// **', until {date}'**
  String ruleUntil(String date);

  /// No description provided for @ruleCount.
  ///
  /// In en, this message translates to:
  /// **'{n, plural, =1{, once} other{, {n} times}}'**
  String ruleCount(int n);

  /// No description provided for @ruleForever.
  ///
  /// In en, this message translates to:
  /// **', forever'**
  String get ruleForever;

  /// No description provided for @repeat.
  ///
  /// In en, this message translates to:
  /// **'Repeat'**
  String get repeat;

  /// No description provided for @never.
  ///
  /// In en, this message translates to:
  /// **'Never'**
  String get never;

  /// No description provided for @custom.
  ///
  /// In en, this message translates to:
  /// **'Custom'**
  String get custom;

  /// No description provided for @timeZone.
  ///
  /// In en, this message translates to:
  /// **'Time zone'**
  String get timeZone;

  /// No description provided for @invite.
  ///
  /// In en, this message translates to:
  /// **'Invite'**
  String get invite;

  /// No description provided for @calendarDefault.
  ///
  /// In en, this message translates to:
  /// **'Default ({value})'**
  String calendarDefault(String value);

  /// No description provided for @atStart.
  ///
  /// In en, this message translates to:
  /// **'At start'**
  String get atStart;

  /// No description provided for @every.
  ///
  /// In en, this message translates to:
  /// **'Every'**
  String get every;

  /// No description provided for @less.
  ///
  /// In en, this message translates to:
  /// **'Less'**
  String get less;

  /// No description provided for @more.
  ///
  /// In en, this message translates to:
  /// **'More'**
  String get more;

  /// No description provided for @unitDays.
  ///
  /// In en, this message translates to:
  /// **'Days'**
  String get unitDays;

  /// No description provided for @unitWeeks.
  ///
  /// In en, this message translates to:
  /// **'Weeks'**
  String get unitWeeks;

  /// No description provided for @unitMonths.
  ///
  /// In en, this message translates to:
  /// **'Months'**
  String get unitMonths;

  /// No description provided for @unitYears.
  ///
  /// In en, this message translates to:
  /// **'Years'**
  String get unitYears;

  /// No description provided for @onDays.
  ///
  /// In en, this message translates to:
  /// **'On days'**
  String get onDays;

  /// No description provided for @ends.
  ///
  /// In en, this message translates to:
  /// **'Ends'**
  String get ends;

  /// No description provided for @onDate.
  ///
  /// In en, this message translates to:
  /// **'On date'**
  String get onDate;

  /// No description provided for @after.
  ///
  /// In en, this message translates to:
  /// **'After'**
  String get after;

  /// No description provided for @afterTimes.
  ///
  /// In en, this message translates to:
  /// **'{n, plural, =1{1 time} other{{n} times}}'**
  String afterTimes(int n);

  /// No description provided for @summary.
  ///
  /// In en, this message translates to:
  /// **'Summary'**
  String get summary;

  /// No description provided for @event.
  ///
  /// In en, this message translates to:
  /// **'Event'**
  String get event;

  /// No description provided for @inviteTitle.
  ///
  /// In en, this message translates to:
  /// **'Invite guests'**
  String get inviteTitle;

  /// No description provided for @send.
  ///
  /// In en, this message translates to:
  /// **'Send'**
  String get send;

  /// No description provided for @nameOrEmail.
  ///
  /// In en, this message translates to:
  /// **'Name or e-mail address'**
  String get nameOrEmail;

  /// No description provided for @selected.
  ///
  /// In en, this message translates to:
  /// **'Selected'**
  String get selected;

  /// No description provided for @suggestions.
  ///
  /// In en, this message translates to:
  /// **'Suggestions'**
  String get suggestions;

  /// No description provided for @guestsCan.
  ///
  /// In en, this message translates to:
  /// **'Guests can'**
  String get guestsCan;

  /// No description provided for @canInvite.
  ///
  /// In en, this message translates to:
  /// **'Invite others'**
  String get canInvite;

  /// No description provided for @canModify.
  ///
  /// In en, this message translates to:
  /// **'Edit the event'**
  String get canModify;

  /// No description provided for @canSee.
  ///
  /// In en, this message translates to:
  /// **'See the guest list'**
  String get canSee;

  /// No description provided for @inviteNote.
  ///
  /// In en, this message translates to:
  /// **'We will e-mail the invitation from your Google account.'**
  String get inviteNote;

  /// No description provided for @inviteMore.
  ///
  /// In en, this message translates to:
  /// **'Invite more people'**
  String get inviteMore;

  /// No description provided for @shareEvent.
  ///
  /// In en, this message translates to:
  /// **'Share event'**
  String get shareEvent;

  /// No description provided for @moreOptions.
  ///
  /// In en, this message translates to:
  /// **'More options'**
  String get moreOptions;

  /// No description provided for @invitationFrom.
  ///
  /// In en, this message translates to:
  /// **'Invitation from {name}'**
  String invitationFrom(String name);

  /// No description provided for @organizerLabel.
  ///
  /// In en, this message translates to:
  /// **'Organizer'**
  String get organizerLabel;

  /// No description provided for @conflict.
  ///
  /// In en, this message translates to:
  /// **'Conflict'**
  String get conflict;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'pl'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'pl':
      return AppLocalizationsPl();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
