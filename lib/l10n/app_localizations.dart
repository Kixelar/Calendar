import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_de.dart';
import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_fr.dart';
import 'app_localizations_it.dart';
import 'app_localizations_nl.dart';
import 'app_localizations_pl.dart';
import 'app_localizations_pt.dart';

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
    Locale('de'),
    Locale('en'),
    Locale('es'),
    Locale('fr'),
    Locale('it'),
    Locale('nl'),
    Locale('pl'),
    Locale('pt'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Calendar'**
  String get appTitle;

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

  /// No description provided for @noEvents.
  ///
  /// In en, this message translates to:
  /// **'No events'**
  String get noEvents;

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

  /// No description provided for @nothingPlanned.
  ///
  /// In en, this message translates to:
  /// **'Nothing planned.'**
  String get nothingPlanned;

  /// No description provided for @addEvent.
  ///
  /// In en, this message translates to:
  /// **'Add event'**
  String get addEvent;

  /// No description provided for @holiday.
  ///
  /// In en, this message translates to:
  /// **'Holiday'**
  String get holiday;

  /// No description provided for @syncLabel.
  ///
  /// In en, this message translates to:
  /// **'Sync'**
  String get syncLabel;

  /// No description provided for @conflictTitle.
  ///
  /// In en, this message translates to:
  /// **'Conflicting changes'**
  String get conflictTitle;

  /// No description provided for @conflictBody.
  ///
  /// In en, this message translates to:
  /// **'{title} was changed on this phone and in Google. Choose the version to keep.'**
  String conflictBody(String title);

  /// No description provided for @thisPhone.
  ///
  /// In en, this message translates to:
  /// **'This phone'**
  String get thisPhone;

  /// No description provided for @changedAt.
  ///
  /// In en, this message translates to:
  /// **'Changed {time}'**
  String changedAt(String time);

  /// No description provided for @time.
  ///
  /// In en, this message translates to:
  /// **'Time'**
  String get time;

  /// No description provided for @titleLabel.
  ///
  /// In en, this message translates to:
  /// **'Title'**
  String get titleLabel;

  /// No description provided for @keepBoth.
  ///
  /// In en, this message translates to:
  /// **'Keep both'**
  String get keepBoth;

  /// No description provided for @useSelected.
  ///
  /// In en, this message translates to:
  /// **'Use selected'**
  String get useSelected;

  /// No description provided for @visibility.
  ///
  /// In en, this message translates to:
  /// **'Visibility'**
  String get visibility;

  /// No description provided for @mineGoogle.
  ///
  /// In en, this message translates to:
  /// **'Mine · Google'**
  String get mineGoogle;

  /// No description provided for @sharedWithMe.
  ///
  /// In en, this message translates to:
  /// **'Shared with me'**
  String get sharedWithMe;

  /// No description provided for @subscriptions.
  ///
  /// In en, this message translates to:
  /// **'Subscriptions'**
  String get subscriptions;

  /// No description provided for @addCalendar.
  ///
  /// In en, this message translates to:
  /// **'Add calendar'**
  String get addCalendar;

  /// No description provided for @roleOwner.
  ///
  /// In en, this message translates to:
  /// **'Owner'**
  String get roleOwner;

  /// No description provided for @roleWriter.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get roleWriter;

  /// No description provided for @roleReader.
  ///
  /// In en, this message translates to:
  /// **'View'**
  String get roleReader;

  /// No description provided for @roleFreeBusy.
  ///
  /// In en, this message translates to:
  /// **'Busy only'**
  String get roleFreeBusy;

  /// No description provided for @shareCalendar.
  ///
  /// In en, this message translates to:
  /// **'Share calendar {name}'**
  String shareCalendar(String name);

  /// No description provided for @newCalendar.
  ///
  /// In en, this message translates to:
  /// **'New calendar'**
  String get newCalendar;

  /// No description provided for @newCalendarHint.
  ///
  /// In en, this message translates to:
  /// **'In your Google account'**
  String get newCalendarHint;

  /// No description provided for @holidaysAndDaysOff.
  ///
  /// In en, this message translates to:
  /// **'Holidays and days off'**
  String get holidaysAndDaysOff;

  /// No description provided for @holidaysHint.
  ///
  /// In en, this message translates to:
  /// **'Public and religious holidays'**
  String get holidaysHint;

  /// No description provided for @googleAccount.
  ///
  /// In en, this message translates to:
  /// **'Google account'**
  String get googleAccount;

  /// No description provided for @googleAccountHint.
  ///
  /// In en, this message translates to:
  /// **'Sign in and sync'**
  String get googleAccountHint;

  /// No description provided for @calendarName.
  ///
  /// In en, this message translates to:
  /// **'Calendar name'**
  String get calendarName;

  /// No description provided for @holidays.
  ///
  /// In en, this message translates to:
  /// **'Holidays'**
  String get holidays;

  /// No description provided for @country.
  ///
  /// In en, this message translates to:
  /// **'Country'**
  String get country;

  /// No description provided for @addCountry.
  ///
  /// In en, this message translates to:
  /// **'+ Add country'**
  String get addCountry;

  /// No description provided for @holidaysInYear.
  ///
  /// In en, this message translates to:
  /// **'{n, plural, =1{1 holiday this year} other{{n} holidays this year}}'**
  String holidaysInYear(int n);

  /// No description provided for @nearest.
  ///
  /// In en, this message translates to:
  /// **'Coming up'**
  String get nearest;

  /// No description provided for @shareTitle.
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get shareTitle;

  /// No description provided for @calendarNamed.
  ///
  /// In en, this message translates to:
  /// **'Calendar {name}'**
  String calendarNamed(String name);

  /// No description provided for @peopleWithAccess.
  ///
  /// In en, this message translates to:
  /// **'People with access'**
  String get peopleWithAccess;

  /// No description provided for @you.
  ///
  /// In en, this message translates to:
  /// **'You'**
  String get you;

  /// No description provided for @addPerson.
  ///
  /// In en, this message translates to:
  /// **'Add person'**
  String get addPerson;

  /// No description provided for @newPeopleAccess.
  ///
  /// In en, this message translates to:
  /// **'Access for new people'**
  String get newPeopleAccess;

  /// No description provided for @freeBusyHint.
  ///
  /// In en, this message translates to:
  /// **'Busy only shows when you are busy, without event names.'**
  String get freeBusyHint;

  /// No description provided for @link.
  ///
  /// In en, this message translates to:
  /// **'Link'**
  String get link;

  /// No description provided for @linkAccess.
  ///
  /// In en, this message translates to:
  /// **'Access by link'**
  String get linkAccess;

  /// No description provided for @copyLink.
  ///
  /// In en, this message translates to:
  /// **'Copy link'**
  String get copyLink;

  /// No description provided for @off.
  ///
  /// In en, this message translates to:
  /// **'Off'**
  String get off;

  /// No description provided for @linkCopied.
  ///
  /// In en, this message translates to:
  /// **'Link copied'**
  String get linkCopied;

  /// No description provided for @removeAccess.
  ///
  /// In en, this message translates to:
  /// **'Remove access'**
  String get removeAccess;

  /// No description provided for @emailAddress.
  ///
  /// In en, this message translates to:
  /// **'E-mail address'**
  String get emailAddress;

  /// No description provided for @sharesWithYou.
  ///
  /// In en, this message translates to:
  /// **'{name} shares a calendar with you'**
  String sharesWithYou(String name);

  /// No description provided for @yourAccess.
  ///
  /// In en, this message translates to:
  /// **'Your access'**
  String get yourAccess;

  /// No description provided for @marker.
  ///
  /// In en, this message translates to:
  /// **'Marker'**
  String get marker;

  /// No description provided for @shapeNames.
  ///
  /// In en, this message translates to:
  /// **'Dot,Square,Half,Diamond,Ring,Dashed,Triangle,Triangle down,Open square,Open diamond,Plus,Cross,Star,Hexagon,Heart,Target,Square with dot,Slice,Diagonal,Bar,Pillar,Two dots,Open triangle,Top half'**
  String get shapeNames;

  /// No description provided for @showInViews.
  ///
  /// In en, this message translates to:
  /// **'Show in views'**
  String get showInViews;

  /// No description provided for @otherWay.
  ///
  /// In en, this message translates to:
  /// **'The other way'**
  String get otherWay;

  /// No description provided for @shareYours.
  ///
  /// In en, this message translates to:
  /// **'Share your calendar back'**
  String get shareYours;

  /// No description provided for @choose.
  ///
  /// In en, this message translates to:
  /// **'Choose'**
  String get choose;

  /// No description provided for @shared.
  ///
  /// In en, this message translates to:
  /// **'Shared'**
  String get shared;

  /// No description provided for @reject.
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get reject;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @upToDate.
  ///
  /// In en, this message translates to:
  /// **'Up to date'**
  String get upToDate;

  /// No description provided for @offline.
  ///
  /// In en, this message translates to:
  /// **'Offline'**
  String get offline;

  /// No description provided for @appearance.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get appearance;

  /// No description provided for @notificationsGlyph.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notificationsGlyph;

  /// No description provided for @calendarsSharing.
  ///
  /// In en, this message translates to:
  /// **'Calendars and sharing'**
  String get calendarsSharing;

  /// No description provided for @dataPrivacy.
  ///
  /// In en, this message translates to:
  /// **'Data and privacy'**
  String get dataPrivacy;

  /// No description provided for @help.
  ///
  /// In en, this message translates to:
  /// **'Help'**
  String get help;

  /// No description provided for @about.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get about;

  /// No description provided for @themeDark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get themeDark;

  /// No description provided for @themeLight.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get themeLight;

  /// No description provided for @themeSystem.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get themeSystem;

  /// No description provided for @theme.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get theme;

  /// No description provided for @firstDay.
  ///
  /// In en, this message translates to:
  /// **'First day of the week'**
  String get firstDay;

  /// No description provided for @timeFormat.
  ///
  /// In en, this message translates to:
  /// **'Time format'**
  String get timeFormat;

  /// No description provided for @weekNumbers.
  ///
  /// In en, this message translates to:
  /// **'Week numbers'**
  String get weekNumbers;

  /// No description provided for @showWeekends.
  ///
  /// In en, this message translates to:
  /// **'Show weekends'**
  String get showWeekends;

  /// No description provided for @declinedInvites.
  ///
  /// In en, this message translates to:
  /// **'Declined invitations'**
  String get declinedInvites;

  /// No description provided for @style.
  ///
  /// In en, this message translates to:
  /// **'Style'**
  String get style;

  /// No description provided for @dotDigits.
  ///
  /// In en, this message translates to:
  /// **'Dot digits'**
  String get dotDigits;

  /// No description provided for @dimPast.
  ///
  /// In en, this message translates to:
  /// **'Dim past events'**
  String get dimPast;

  /// No description provided for @accounts.
  ///
  /// In en, this message translates to:
  /// **'Accounts'**
  String get accounts;

  /// No description provided for @lastSync.
  ///
  /// In en, this message translates to:
  /// **'Last sync'**
  String get lastSync;

  /// No description provided for @calendarsN.
  ///
  /// In en, this message translates to:
  /// **'{n, plural, =1{1 calendar} other{{n} calendars}}'**
  String calendarsN(int n);

  /// No description provided for @syncNow.
  ///
  /// In en, this message translates to:
  /// **'Sync now'**
  String get syncNow;

  /// No description provided for @active.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get active;

  /// No description provided for @addAccount.
  ///
  /// In en, this message translates to:
  /// **'Add account'**
  String get addAccount;

  /// No description provided for @automatic.
  ///
  /// In en, this message translates to:
  /// **'Automatically'**
  String get automatic;

  /// No description provided for @frequency.
  ///
  /// In en, this message translates to:
  /// **'Frequency'**
  String get frequency;

  /// No description provided for @everyMinutes.
  ///
  /// In en, this message translates to:
  /// **'Every {n} min'**
  String everyMinutes(int n);

  /// No description provided for @disconnectGoogle.
  ///
  /// In en, this message translates to:
  /// **'Disconnect Google account'**
  String get disconnectGoogle;

  /// No description provided for @disconnectBody.
  ///
  /// In en, this message translates to:
  /// **'Calendars and settings are removed from this phone. Nothing changes in Google.'**
  String get disconnectBody;

  /// No description provided for @disconnect.
  ///
  /// In en, this message translates to:
  /// **'Disconnect'**
  String get disconnect;

  /// No description provided for @privacy.
  ///
  /// In en, this message translates to:
  /// **'Privacy'**
  String get privacy;

  /// No description provided for @hideOnLockScreen.
  ///
  /// In en, this message translates to:
  /// **'Hide details on the lock screen'**
  String get hideOnLockScreen;

  /// No description provided for @device.
  ///
  /// In en, this message translates to:
  /// **'Device'**
  String get device;

  /// No description provided for @clearData.
  ///
  /// In en, this message translates to:
  /// **'Clear data on this device'**
  String get clearData;

  /// No description provided for @clearDataBody.
  ///
  /// In en, this message translates to:
  /// **'Calendars, cache and settings are removed from this phone and you are signed out.'**
  String get clearDataBody;

  /// No description provided for @googleUntouched.
  ///
  /// In en, this message translates to:
  /// **'Your events in Google stay untouched.'**
  String get googleUntouched;

  /// No description provided for @searchHelp.
  ///
  /// In en, this message translates to:
  /// **'Search help'**
  String get searchHelp;

  /// No description provided for @faq.
  ///
  /// In en, this message translates to:
  /// **'Common questions'**
  String get faq;

  /// No description provided for @contact.
  ///
  /// In en, this message translates to:
  /// **'Contact'**
  String get contact;

  /// No description provided for @aboutApp.
  ///
  /// In en, this message translates to:
  /// **'About the app'**
  String get aboutApp;

  /// No description provided for @readTime.
  ///
  /// In en, this message translates to:
  /// **'{topic} · 1 min read'**
  String readTime(String topic);

  /// No description provided for @tip.
  ///
  /// In en, this message translates to:
  /// **'Tip'**
  String get tip;

  /// No description provided for @openScreen.
  ///
  /// In en, this message translates to:
  /// **'Open {name}'**
  String openScreen(String name);

  /// No description provided for @devVersion.
  ///
  /// In en, this message translates to:
  /// **'Development version'**
  String get devVersion;

  /// No description provided for @stableVersion.
  ///
  /// In en, this message translates to:
  /// **'Stable version'**
  String get stableVersion;

  /// No description provided for @build.
  ///
  /// In en, this message translates to:
  /// **'Build'**
  String get build;

  /// No description provided for @system.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get system;

  /// No description provided for @legal.
  ///
  /// In en, this message translates to:
  /// **'Legal'**
  String get legal;

  /// No description provided for @licenses.
  ///
  /// In en, this message translates to:
  /// **'Open source licences'**
  String get licenses;

  /// No description provided for @typefaces.
  ///
  /// In en, this message translates to:
  /// **'Typefaces'**
  String get typefaces;

  /// No description provided for @notifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifications;

  /// No description provided for @reminders.
  ///
  /// In en, this message translates to:
  /// **'Reminders'**
  String get reminders;

  /// No description provided for @defaultLabel.
  ///
  /// In en, this message translates to:
  /// **'Default'**
  String get defaultLabel;

  /// No description provided for @allDayEvents.
  ///
  /// In en, this message translates to:
  /// **'All-day'**
  String get allDayEvents;

  /// No description provided for @dayBeforeAt.
  ///
  /// In en, this message translates to:
  /// **'{time} the day before'**
  String dayBeforeAt(String time);

  /// No description provided for @dailySummary.
  ///
  /// In en, this message translates to:
  /// **'Daily summary'**
  String get dailySummary;

  /// No description provided for @everyDayAt.
  ///
  /// In en, this message translates to:
  /// **'Every day {time}'**
  String everyDayAt(String time);

  /// No description provided for @invitations.
  ///
  /// In en, this message translates to:
  /// **'Invitations'**
  String get invitations;

  /// No description provided for @newInvitations.
  ///
  /// In en, this message translates to:
  /// **'New invitations'**
  String get newInvitations;

  /// No description provided for @sharedChanges.
  ///
  /// In en, this message translates to:
  /// **'Changes in shared calendars'**
  String get sharedChanges;

  /// No description provided for @summaryTitle.
  ///
  /// In en, this message translates to:
  /// **'{n, plural, =1{Today: 1 event} other{Today: {n} events}}'**
  String summaryTitle(int n);

  /// No description provided for @invitesYou.
  ///
  /// In en, this message translates to:
  /// **'{name} invites you: {title}'**
  String invitesYou(String name, String title);

  /// No description provided for @changesIn.
  ///
  /// In en, this message translates to:
  /// **'Changes: {name}'**
  String changesIn(String name);

  /// No description provided for @sharedCalendars.
  ///
  /// In en, this message translates to:
  /// **'Shared calendars'**
  String get sharedCalendars;

  /// No description provided for @snooze.
  ///
  /// In en, this message translates to:
  /// **'Snooze 5 min'**
  String get snooze;

  /// No description provided for @details.
  ///
  /// In en, this message translates to:
  /// **'Details'**
  String get details;

  /// No description provided for @off2.
  ///
  /// In en, this message translates to:
  /// **'Off'**
  String get off2;

  /// No description provided for @personal.
  ///
  /// In en, this message translates to:
  /// **'Personal'**
  String get personal;

  /// No description provided for @customReminder.
  ///
  /// In en, this message translates to:
  /// **'Custom reminder'**
  String get customReminder;

  /// No description provided for @unitMinutes.
  ///
  /// In en, this message translates to:
  /// **'Minutes'**
  String get unitMinutes;

  /// No description provided for @unitHours.
  ///
  /// In en, this message translates to:
  /// **'Hours'**
  String get unitHours;

  /// No description provided for @reminderLimit.
  ///
  /// In en, this message translates to:
  /// **'Up to 4 weeks before.'**
  String get reminderLimit;

  /// No description provided for @clashesWith.
  ///
  /// In en, this message translates to:
  /// **'{n, plural, =1{clashes with 1 event} other{clashes with {n} events}}'**
  String clashesWith(int n);

  /// No description provided for @crashTitle.
  ///
  /// In en, this message translates to:
  /// **'The app closed unexpectedly'**
  String get crashTitle;

  /// No description provided for @crashBody.
  ///
  /// In en, this message translates to:
  /// **'Copy this report and send it to the developer.'**
  String get crashBody;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @copy.
  ///
  /// In en, this message translates to:
  /// **'Copy'**
  String get copy;

  /// No description provided for @saveRepeating.
  ///
  /// In en, this message translates to:
  /// **'Save changes to a repeating event'**
  String get saveRepeating;

  /// No description provided for @weekNumbersHint.
  ///
  /// In en, this message translates to:
  /// **'Week number in front of each row of the month view.'**
  String get weekNumbersHint;

  /// No description provided for @showWeekendsHint.
  ///
  /// In en, this message translates to:
  /// **'Off: the month and week views show Monday to Friday only.'**
  String get showWeekendsHint;

  /// No description provided for @declinedHint.
  ///
  /// In en, this message translates to:
  /// **'Show invitations you declined in the views.'**
  String get declinedHint;

  /// No description provided for @dimPastHint.
  ///
  /// In en, this message translates to:
  /// **'Events and days that are over are shown in grey.'**
  String get dimPastHint;

  /// No description provided for @inBackground.
  ///
  /// In en, this message translates to:
  /// **'In the background'**
  String get inBackground;

  /// No description provided for @notYet.
  ///
  /// In en, this message translates to:
  /// **'Not yet'**
  String get notYet;

  /// No description provided for @check.
  ///
  /// In en, this message translates to:
  /// **'Check'**
  String get check;

  /// No description provided for @testBackgroundHint.
  ///
  /// In en, this message translates to:
  /// **'Close the app for 1–2 minutes, then come back here.'**
  String get testBackgroundHint;

  /// No description provided for @clashesN.
  ///
  /// In en, this message translates to:
  /// **'{n, plural, =1{1 clash} other{{n} clashes}}'**
  String clashesN(int n);

  /// No description provided for @inH.
  ///
  /// In en, this message translates to:
  /// **'In {h} h'**
  String inH(int h);

  /// No description provided for @inHM.
  ///
  /// In en, this message translates to:
  /// **'In {h} h {m} min'**
  String inHM(int h, int m);

  /// No description provided for @dayOff.
  ///
  /// In en, this message translates to:
  /// **'Day off'**
  String get dayOff;

  /// No description provided for @hoursFree.
  ///
  /// In en, this message translates to:
  /// **'{h}h free'**
  String hoursFree(int h);

  /// No description provided for @wifiOnly.
  ///
  /// In en, this message translates to:
  /// **'Wi-Fi only'**
  String get wifiOnly;

  /// No description provided for @wifiOnlyHint.
  ///
  /// In en, this message translates to:
  /// **'Automatic and background sync wait for Wi-Fi. Pulling down the list always syncs.'**
  String get wifiOnlyHint;

  /// No description provided for @importFile.
  ///
  /// In en, this message translates to:
  /// **'Import file'**
  String get importFile;

  /// No description provided for @importFileHint.
  ///
  /// In en, this message translates to:
  /// **'.ics file from the phone'**
  String get importFileHint;

  /// No description provided for @exportAll.
  ///
  /// In en, this message translates to:
  /// **'Export all'**
  String get exportAll;

  /// No description provided for @importExport.
  ///
  /// In en, this message translates to:
  /// **'Import and export'**
  String get importExport;

  /// No description provided for @importTo.
  ///
  /// In en, this message translates to:
  /// **'{n, plural, =1{Import 1 event to} other{Import {n} events to}}'**
  String importTo(int n);

  /// No description provided for @importing.
  ///
  /// In en, this message translates to:
  /// **'Importing {done} of {n}'**
  String importing(int done, int n);

  /// No description provided for @importedN.
  ///
  /// In en, this message translates to:
  /// **'{n, plural, =1{Imported 1 event} other{Imported {n} events}}'**
  String importedN(int n);

  /// No description provided for @failedN.
  ///
  /// In en, this message translates to:
  /// **'{n} failed'**
  String failedN(int n);

  /// No description provided for @icsEmpty.
  ///
  /// In en, this message translates to:
  /// **'No events in this file'**
  String get icsEmpty;

  /// No description provided for @exporting.
  ///
  /// In en, this message translates to:
  /// **'Exporting…'**
  String get exporting;

  /// No description provided for @fileSaved.
  ///
  /// In en, this message translates to:
  /// **'File saved'**
  String get fileSaved;

  /// No description provided for @notSignedIn.
  ///
  /// In en, this message translates to:
  /// **'Not signed in'**
  String get notSignedIn;

  /// No description provided for @removeCountry.
  ///
  /// In en, this message translates to:
  /// **'Remove country'**
  String get removeCountry;

  /// No description provided for @subscribeUrl.
  ///
  /// In en, this message translates to:
  /// **'Subscribe to address'**
  String get subscribeUrl;

  /// No description provided for @subscribeUrlHint.
  ///
  /// In en, this message translates to:
  /// **'.ics link or webcal://'**
  String get subscribeUrlHint;

  /// No description provided for @subscribe.
  ///
  /// In en, this message translates to:
  /// **'Subscribe'**
  String get subscribe;

  /// No description provided for @subscribeNote.
  ///
  /// In en, this message translates to:
  /// **'Refreshed every hour. The calendar is read-only.'**
  String get subscribeNote;

  /// No description provided for @subscribing.
  ///
  /// In en, this message translates to:
  /// **'Subscribing…'**
  String get subscribing;

  /// No description provided for @subscribed.
  ///
  /// In en, this message translates to:
  /// **'Subscribed: {name}'**
  String subscribed(String name);

  /// No description provided for @unsubscribe.
  ///
  /// In en, this message translates to:
  /// **'Unsubscribe'**
  String get unsubscribe;

  /// No description provided for @unsubscribeBody.
  ///
  /// In en, this message translates to:
  /// **'The {name} calendar and its events are deleted from Google. You can subscribe again later.'**
  String unsubscribeBody(String name);

  /// No description provided for @notIcs.
  ///
  /// In en, this message translates to:
  /// **'This address is not an .ics calendar'**
  String get notIcs;

  /// No description provided for @deleteCalendar.
  ///
  /// In en, this message translates to:
  /// **'Delete calendar'**
  String get deleteCalendar;

  /// No description provided for @deleteCalendarBody.
  ///
  /// In en, this message translates to:
  /// **'The {name} calendar and all its events are deleted from Google for everyone it is shared with. This cannot be undone.'**
  String deleteCalendarBody(String name);

  /// No description provided for @freeNow.
  ///
  /// In en, this message translates to:
  /// **'Free'**
  String get freeNow;

  /// No description provided for @ongoingUntil.
  ///
  /// In en, this message translates to:
  /// **'Now · until {time}'**
  String ongoingUntil(String time);

  /// No description provided for @appLock.
  ///
  /// In en, this message translates to:
  /// **'App lock'**
  String get appLock;

  /// No description provided for @appLockHint.
  ///
  /// In en, this message translates to:
  /// **'Asks for your fingerprint, face or screen lock code when the app opens and after a minute away.'**
  String get appLockHint;

  /// No description provided for @appLocked.
  ///
  /// In en, this message translates to:
  /// **'Calendar is locked'**
  String get appLocked;

  /// No description provided for @unlock.
  ///
  /// In en, this message translates to:
  /// **'Unlock'**
  String get unlock;

  /// No description provided for @unlockReason.
  ///
  /// In en, this message translates to:
  /// **'Unlock Calendar'**
  String get unlockReason;

  /// No description provided for @appLockNoScreenLock.
  ///
  /// In en, this message translates to:
  /// **'Set a screen lock on your phone first.'**
  String get appLockNoScreenLock;

  /// No description provided for @glyphInterface.
  ///
  /// In en, this message translates to:
  /// **'Glyph Interface'**
  String get glyphInterface;

  /// No description provided for @glyphLight.
  ///
  /// In en, this message translates to:
  /// **'Light with reminders'**
  String get glyphLight;

  /// No description provided for @glyphPattern.
  ///
  /// In en, this message translates to:
  /// **'Light pattern'**
  String get glyphPattern;

  /// No description provided for @glyphCountdown.
  ///
  /// In en, this message translates to:
  /// **'Countdown to event'**
  String get glyphCountdown;

  /// No description provided for @glyphPulse.
  ///
  /// In en, this message translates to:
  /// **'Pulse'**
  String get glyphPulse;

  /// No description provided for @glyphBlink.
  ///
  /// In en, this message translates to:
  /// **'Blink'**
  String get glyphBlink;

  /// No description provided for @glyphSteady.
  ///
  /// In en, this message translates to:
  /// **'Steady'**
  String get glyphSteady;

  /// No description provided for @glyphGlass.
  ///
  /// In en, this message translates to:
  /// **'Glass'**
  String get glyphGlass;

  /// No description provided for @glyphClock.
  ///
  /// In en, this message translates to:
  /// **'Clock'**
  String get glyphClock;

  /// No description provided for @myCalendar.
  ///
  /// In en, this message translates to:
  /// **'My calendar'**
  String get myCalendar;

  /// No description provided for @onDevice.
  ///
  /// In en, this message translates to:
  /// **'On this device'**
  String get onDevice;

  /// No description provided for @onlyThisPhone.
  ///
  /// In en, this message translates to:
  /// **'Only this phone'**
  String get onlyThisPhone;

  /// No description provided for @newCalendarLocalHint.
  ///
  /// In en, this message translates to:
  /// **'Only on this phone'**
  String get newCalendarLocalHint;

  /// No description provided for @onPhone.
  ///
  /// In en, this message translates to:
  /// **'On phone'**
  String get onPhone;

  /// No description provided for @chooseLanguage.
  ///
  /// In en, this message translates to:
  /// **'Choose a language'**
  String get chooseLanguage;

  /// No description provided for @phoneLanguage.
  ///
  /// In en, this message translates to:
  /// **'Phone language'**
  String get phoneLanguage;

  /// No description provided for @continueBtn.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continueBtn;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>[
    'de',
    'en',
    'es',
    'fr',
    'it',
    'nl',
    'pl',
    'pt',
  ].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'de':
      return AppLocalizationsDe();
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
    case 'fr':
      return AppLocalizationsFr();
    case 'it':
      return AppLocalizationsIt();
    case 'nl':
      return AppLocalizationsNl();
    case 'pl':
      return AppLocalizationsPl();
    case 'pt':
      return AppLocalizationsPt();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
