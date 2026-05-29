import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_hi.dart';
import 'app_localizations_te.dart';

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
    Locale('hi'),
    Locale('te'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'HRMS Desktop'**
  String get appTitle;

  /// No description provided for @dashboard.
  ///
  /// In en, this message translates to:
  /// **'Dashboard'**
  String get dashboard;

  /// No description provided for @attendance.
  ///
  /// In en, this message translates to:
  /// **'Attendance'**
  String get attendance;

  /// No description provided for @leaves.
  ///
  /// In en, this message translates to:
  /// **'Leaves'**
  String get leaves;

  /// No description provided for @productivity.
  ///
  /// In en, this message translates to:
  /// **'Productivity'**
  String get productivity;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @chat.
  ///
  /// In en, this message translates to:
  /// **'Chat'**
  String get chat;

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logout;

  /// No description provided for @login.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get login;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @rememberMe.
  ///
  /// In en, this message translates to:
  /// **'Remember Me'**
  String get rememberMe;

  /// No description provided for @forgotPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot Password?'**
  String get forgotPassword;

  /// No description provided for @signIn.
  ///
  /// In en, this message translates to:
  /// **'Sign In'**
  String get signIn;

  /// No description provided for @recentActivities.
  ///
  /// In en, this message translates to:
  /// **'Recent Activities'**
  String get recentActivities;

  /// No description provided for @noRecentRecords.
  ///
  /// In en, this message translates to:
  /// **'No recent records'**
  String get noRecentRecords;

  /// No description provided for @checkIn.
  ///
  /// In en, this message translates to:
  /// **'Check In'**
  String get checkIn;

  /// No description provided for @checkOut.
  ///
  /// In en, this message translates to:
  /// **'Check Out'**
  String get checkOut;

  /// No description provided for @workingHours.
  ///
  /// In en, this message translates to:
  /// **'Working Hours'**
  String get workingHours;

  /// No description provided for @todayScore.
  ///
  /// In en, this message translates to:
  /// **'Today\'s Score'**
  String get todayScore;

  /// No description provided for @tasksCompleted.
  ///
  /// In en, this message translates to:
  /// **'Tasks Completed'**
  String get tasksCompleted;

  /// No description provided for @focusTime.
  ///
  /// In en, this message translates to:
  /// **'Focus Time'**
  String get focusTime;

  /// No description provided for @weeklyProductivityTrend.
  ///
  /// In en, this message translates to:
  /// **'Weekly Productivity Trend'**
  String get weeklyProductivityTrend;

  /// No description provided for @todaysTasks.
  ///
  /// In en, this message translates to:
  /// **'Today\'s Tasks'**
  String get todaysTasks;

  /// No description provided for @customizeYourExperience.
  ///
  /// In en, this message translates to:
  /// **'Customize your experience'**
  String get customizeYourExperience;

  /// No description provided for @version.
  ///
  /// In en, this message translates to:
  /// **'Version'**
  String get version;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @theme.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get theme;

  /// No description provided for @lightTheme.
  ///
  /// In en, this message translates to:
  /// **'Light Theme'**
  String get lightTheme;

  /// No description provided for @darkTheme.
  ///
  /// In en, this message translates to:
  /// **'Dark Theme'**
  String get darkTheme;

  /// No description provided for @appPreferences.
  ///
  /// In en, this message translates to:
  /// **'App Preferences'**
  String get appPreferences;

  /// No description provided for @profile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// No description provided for @personalInformation.
  ///
  /// In en, this message translates to:
  /// **'Personal Information'**
  String get personalInformation;

  /// No description provided for @jobDetails.
  ///
  /// In en, this message translates to:
  /// **'Job Details'**
  String get jobDetails;

  /// No description provided for @changePassword.
  ///
  /// In en, this message translates to:
  /// **'Change Password'**
  String get changePassword;

  /// No description provided for @notifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifications;

  /// No description provided for @languageSettings.
  ///
  /// In en, this message translates to:
  /// **'Language Settings'**
  String get languageSettings;

  /// No description provided for @chooseYourPreferredLanguage.
  ///
  /// In en, this message translates to:
  /// **'Choose your preferred language'**
  String get chooseYourPreferredLanguage;

  /// No description provided for @thisWeek.
  ///
  /// In en, this message translates to:
  /// **'This Week'**
  String get thisWeek;

  /// No description provided for @completed.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get completed;

  /// No description provided for @running.
  ///
  /// In en, this message translates to:
  /// **'Running'**
  String get running;

  /// No description provided for @checkedInAt.
  ///
  /// In en, this message translates to:
  /// **'Checked in at'**
  String get checkedInAt;

  /// No description provided for @checkedOutAt.
  ///
  /// In en, this message translates to:
  /// **'Checked out at'**
  String get checkedOutAt;

  /// No description provided for @workingSessionStartedAt.
  ///
  /// In en, this message translates to:
  /// **'Working session started at'**
  String get workingSessionStartedAt;

  /// No description provided for @welcomeBack.
  ///
  /// In en, this message translates to:
  /// **'Welcome Back'**
  String get welcomeBack;

  /// No description provided for @trackAttendanceAndProductivity.
  ///
  /// In en, this message translates to:
  /// **'Track attendance and productivity'**
  String get trackAttendanceAndProductivity;

  /// No description provided for @and.
  ///
  /// In en, this message translates to:
  /// **'and'**
  String get and;

  /// No description provided for @fixAttendance.
  ///
  /// In en, this message translates to:
  /// **'Fix Attendance'**
  String get fixAttendance;

  /// No description provided for @dailyDetails.
  ///
  /// In en, this message translates to:
  /// **'Daily Details'**
  String get dailyDetails;

  /// No description provided for @inOutReport.
  ///
  /// In en, this message translates to:
  /// **'In/Out Report'**
  String get inOutReport;

  /// No description provided for @calendarView.
  ///
  /// In en, this message translates to:
  /// **'Calendar View'**
  String get calendarView;

  /// No description provided for @workSettings.
  ///
  /// In en, this message translates to:
  /// **'Work Settings'**
  String get workSettings;

  /// No description provided for @dataAndPrivacy.
  ///
  /// In en, this message translates to:
  /// **'Data & Privacy'**
  String get dataAndPrivacy;

  /// No description provided for @supportAndHelp.
  ///
  /// In en, this message translates to:
  /// **'Support & Help'**
  String get supportAndHelp;

  /// No description provided for @helpCenter.
  ///
  /// In en, this message translates to:
  /// **'Help Center'**
  String get helpCenter;

  /// No description provided for @contactSupport.
  ///
  /// In en, this message translates to:
  /// **'Contact Support'**
  String get contactSupport;

  /// No description provided for @reportABug.
  ///
  /// In en, this message translates to:
  /// **'Report a Bug'**
  String get reportABug;

  /// No description provided for @exportData.
  ///
  /// In en, this message translates to:
  /// **'Export Data'**
  String get exportData;

  /// No description provided for @privacyPolicy.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get privacyPolicy;

  /// No description provided for @termsOfService.
  ///
  /// In en, this message translates to:
  /// **'Terms of Service'**
  String get termsOfService;

  /// No description provided for @biometricAuthentication.
  ///
  /// In en, this message translates to:
  /// **'Biometric Authentication'**
  String get biometricAuthentication;

  /// No description provided for @autoCheckIn.
  ///
  /// In en, this message translates to:
  /// **'Auto Check-in'**
  String get autoCheckIn;

  /// No description provided for @pushNotifications.
  ///
  /// In en, this message translates to:
  /// **'Push Notifications'**
  String get pushNotifications;

  /// No description provided for @receiveNotifications.
  ///
  /// In en, this message translates to:
  /// **'Receive notifications for check-in/out reminders'**
  String get receiveNotifications;

  /// No description provided for @useFingerprint.
  ///
  /// In en, this message translates to:
  /// **'Use fingerprint/face ID for check-in/out'**
  String get useFingerprint;

  /// No description provided for @automaticallyCheckIn.
  ///
  /// In en, this message translates to:
  /// **'Automatically check-in when opening the app'**
  String get automaticallyCheckIn;

  /// No description provided for @setDefaultWorkingHours.
  ///
  /// In en, this message translates to:
  /// **'Set your default working hours'**
  String get setDefaultWorkingHours;

  /// No description provided for @downloadAttendanceData.
  ///
  /// In en, this message translates to:
  /// **'Download your attendance and productivity data'**
  String get downloadAttendanceData;

  /// No description provided for @readPrivacyPolicy.
  ///
  /// In en, this message translates to:
  /// **'Read our privacy policy'**
  String get readPrivacyPolicy;

  /// No description provided for @readTermsConditions.
  ///
  /// In en, this message translates to:
  /// **'Read our terms and conditions'**
  String get readTermsConditions;

  /// No description provided for @findAnswers.
  ///
  /// In en, this message translates to:
  /// **'Find answers to common questions'**
  String get findAnswers;

  /// No description provided for @getInTouch.
  ///
  /// In en, this message translates to:
  /// **'Get in touch with our support team'**
  String get getInTouch;

  /// No description provided for @helpUsImprove.
  ///
  /// In en, this message translates to:
  /// **'Help us improve by reporting issues'**
  String get helpUsImprove;

  /// No description provided for @leaveManagement.
  ///
  /// In en, this message translates to:
  /// **'Leave Management'**
  String get leaveManagement;

  /// No description provided for @applyLeave.
  ///
  /// In en, this message translates to:
  /// **'Apply Leave'**
  String get applyLeave;

  /// No description provided for @leaveType.
  ///
  /// In en, this message translates to:
  /// **'Leave Type'**
  String get leaveType;

  /// No description provided for @fromDate.
  ///
  /// In en, this message translates to:
  /// **'From Date'**
  String get fromDate;

  /// No description provided for @toDate.
  ///
  /// In en, this message translates to:
  /// **'To Date'**
  String get toDate;

  /// No description provided for @totalDays.
  ///
  /// In en, this message translates to:
  /// **'Total Days'**
  String get totalDays;

  /// No description provided for @reason.
  ///
  /// In en, this message translates to:
  /// **'Reason'**
  String get reason;

  /// No description provided for @submit.
  ///
  /// In en, this message translates to:
  /// **'Submit'**
  String get submit;

  /// No description provided for @aiHrAssistant.
  ///
  /// In en, this message translates to:
  /// **'AI HR Assistant'**
  String get aiHrAssistant;

  /// No description provided for @typeYourMessage.
  ///
  /// In en, this message translates to:
  /// **'Type your message...'**
  String get typeYourMessage;

  /// No description provided for @docBox.
  ///
  /// In en, this message translates to:
  /// **'DOC BOX'**
  String get docBox;

  /// No description provided for @companyDocs.
  ///
  /// In en, this message translates to:
  /// **'Company Docs'**
  String get companyDocs;

  /// No description provided for @personalDocs.
  ///
  /// In en, this message translates to:
  /// **'Personal Docs'**
  String get personalDocs;

  /// No description provided for @upload.
  ///
  /// In en, this message translates to:
  /// **'Upload'**
  String get upload;

  /// No description provided for @noDocumentsAvailable.
  ///
  /// In en, this message translates to:
  /// **'No Documents Available'**
  String get noDocumentsAvailable;

  /// No description provided for @view.
  ///
  /// In en, this message translates to:
  /// **'View'**
  String get view;

  /// No description provided for @download.
  ///
  /// In en, this message translates to:
  /// **'Download'**
  String get download;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @uploadedOn.
  ///
  /// In en, this message translates to:
  /// **'Uploaded on'**
  String get uploadedOn;

  /// No description provided for @companyCalendar.
  ///
  /// In en, this message translates to:
  /// **'Company Calendar'**
  String get companyCalendar;

  /// No description provided for @addEvent.
  ///
  /// In en, this message translates to:
  /// **'Add Event'**
  String get addEvent;

  /// No description provided for @eventTitle.
  ///
  /// In en, this message translates to:
  /// **'Event Title'**
  String get eventTitle;

  /// No description provided for @type.
  ///
  /// In en, this message translates to:
  /// **'Type'**
  String get type;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @noEvents.
  ///
  /// In en, this message translates to:
  /// **'No Events'**
  String get noEvents;

  /// No description provided for @eventsOn.
  ///
  /// In en, this message translates to:
  /// **'Events on'**
  String get eventsOn;

  /// No description provided for @event.
  ///
  /// In en, this message translates to:
  /// **'Event'**
  String get event;

  /// No description provided for @holiday.
  ///
  /// In en, this message translates to:
  /// **'Holiday'**
  String get holiday;

  /// No description provided for @selectYourLanguage.
  ///
  /// In en, this message translates to:
  /// **'Select Your Language'**
  String get selectYourLanguage;

  /// No description provided for @languageSelected.
  ///
  /// In en, this message translates to:
  /// **'language selected'**
  String get languageSelected;

  /// No description provided for @messages.
  ///
  /// In en, this message translates to:
  /// **'Messages'**
  String get messages;

  /// No description provided for @channels.
  ///
  /// In en, this message translates to:
  /// **'Channels'**
  String get channels;

  /// No description provided for @directMessages.
  ///
  /// In en, this message translates to:
  /// **'Direct Messages'**
  String get directMessages;

  /// No description provided for @startNewChat.
  ///
  /// In en, this message translates to:
  /// **'Start New Chat'**
  String get startNewChat;

  /// No description provided for @searchPeople.
  ///
  /// In en, this message translates to:
  /// **'Search people...'**
  String get searchPeople;

  /// No description provided for @noContactsFound.
  ///
  /// In en, this message translates to:
  /// **'No contacts found'**
  String get noContactsFound;

  /// No description provided for @noMatchesFor.
  ///
  /// In en, this message translates to:
  /// **'No matches for'**
  String get noMatchesFor;

  /// No description provided for @noChannelsFound.
  ///
  /// In en, this message translates to:
  /// **'No Channels Found'**
  String get noChannelsFound;

  /// No description provided for @noDirectMessages.
  ///
  /// In en, this message translates to:
  /// **'No Direct Messages'**
  String get noDirectMessages;

  /// No description provided for @noMessagesYetSayHello.
  ///
  /// In en, this message translates to:
  /// **'No messages yet. Say hello!'**
  String get noMessagesYetSayHello;

  /// No description provided for @comingSoon.
  ///
  /// In en, this message translates to:
  /// **'coming soon!'**
  String get comingSoon;

  /// No description provided for @offline.
  ///
  /// In en, this message translates to:
  /// **'Offline'**
  String get offline;

  /// No description provided for @members.
  ///
  /// In en, this message translates to:
  /// **'members'**
  String get members;

  /// No description provided for @noMessagesYet.
  ///
  /// In en, this message translates to:
  /// **'No messages yet'**
  String get noMessagesYet;

  /// No description provided for @noDeadline.
  ///
  /// In en, this message translates to:
  /// **'No deadline'**
  String get noDeadline;

  /// No description provided for @noClient.
  ///
  /// In en, this message translates to:
  /// **'No client'**
  String get noClient;

  /// No description provided for @unknownManager.
  ///
  /// In en, this message translates to:
  /// **'Unknown Manager'**
  String get unknownManager;

  /// No description provided for @tasks.
  ///
  /// In en, this message translates to:
  /// **'tasks'**
  String get tasks;

  /// No description provided for @noManager.
  ///
  /// In en, this message translates to:
  /// **'No manager'**
  String get noManager;

  /// No description provided for @projects.
  ///
  /// In en, this message translates to:
  /// **'Projects'**
  String get projects;

  /// No description provided for @searchProjects.
  ///
  /// In en, this message translates to:
  /// **'Search projects...'**
  String get searchProjects;

  /// No description provided for @noProjectsAvailable.
  ///
  /// In en, this message translates to:
  /// **'No projects available'**
  String get noProjectsAvailable;

  /// No description provided for @noTasksInThisProject.
  ///
  /// In en, this message translates to:
  /// **'No tasks in this project'**
  String get noTasksInThisProject;

  /// No description provided for @lowPriority.
  ///
  /// In en, this message translates to:
  /// **'Low Priority'**
  String get lowPriority;

  /// No description provided for @highPriority.
  ///
  /// In en, this message translates to:
  /// **'High Priority'**
  String get highPriority;

  /// No description provided for @normal.
  ///
  /// In en, this message translates to:
  /// **'Normal'**
  String get normal;

  /// No description provided for @status.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get status;

  /// No description provided for @hours.
  ///
  /// In en, this message translates to:
  /// **'Hours'**
  String get hours;

  /// No description provided for @deadline.
  ///
  /// In en, this message translates to:
  /// **'Deadline'**
  String get deadline;

  /// No description provided for @description.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get description;

  /// No description provided for @searchTasks.
  ///
  /// In en, this message translates to:
  /// **'Search tasks...'**
  String get searchTasks;

  /// No description provided for @noUsersAssigned.
  ///
  /// In en, this message translates to:
  /// **'No users assigned'**
  String get noUsersAssigned;

  /// No description provided for @noMatchesFound.
  ///
  /// In en, this message translates to:
  /// **'No matches found'**
  String get noMatchesFound;

  /// No description provided for @profileSettings.
  ///
  /// In en, this message translates to:
  /// **'Profile Settings'**
  String get profileSettings;

  /// No description provided for @darkMode.
  ///
  /// In en, this message translates to:
  /// **'Dark Mode'**
  String get darkMode;

  /// No description provided for @switchToDarkTheme.
  ///
  /// In en, this message translates to:
  /// **'Switch to dark theme'**
  String get switchToDarkTheme;

  /// No description provided for @backgroundTheme.
  ///
  /// In en, this message translates to:
  /// **'Background Theme'**
  String get backgroundTheme;

  /// No description provided for @customPhotoIsActive.
  ///
  /// In en, this message translates to:
  /// **'Custom photo is active'**
  String get customPhotoIsActive;

  /// No description provided for @choosePresetOrAddPhoto.
  ///
  /// In en, this message translates to:
  /// **'Choose a preset or add your photo'**
  String get choosePresetOrAddPhoto;

  /// No description provided for @presetActive.
  ///
  /// In en, this message translates to:
  /// **'preset active'**
  String get presetActive;

  /// No description provided for @signOutFromAccount.
  ///
  /// In en, this message translates to:
  /// **'Sign out from your account'**
  String get signOutFromAccount;

  /// No description provided for @changePhoto.
  ///
  /// In en, this message translates to:
  /// **'Change Photo'**
  String get changePhoto;

  /// No description provided for @addCustomPhoto.
  ///
  /// In en, this message translates to:
  /// **'Add Custom Photo'**
  String get addCustomPhoto;

  /// No description provided for @remove.
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get remove;

  /// No description provided for @none.
  ///
  /// In en, this message translates to:
  /// **'None'**
  String get none;

  /// No description provided for @nature.
  ///
  /// In en, this message translates to:
  /// **'Nature'**
  String get nature;

  /// No description provided for @ocean.
  ///
  /// In en, this message translates to:
  /// **'Ocean'**
  String get ocean;

  /// No description provided for @mountain.
  ///
  /// In en, this message translates to:
  /// **'Mountain'**
  String get mountain;

  /// No description provided for @city.
  ///
  /// In en, this message translates to:
  /// **'City'**
  String get city;

  /// No description provided for @abstract_.
  ///
  /// In en, this message translates to:
  /// **'Abstract'**
  String get abstract_;

  /// No description provided for @performance.
  ///
  /// In en, this message translates to:
  /// **'Performance'**
  String get performance;

  /// No description provided for @activeWork.
  ///
  /// In en, this message translates to:
  /// **'Active Work'**
  String get activeWork;

  /// No description provided for @idleTime.
  ///
  /// In en, this message translates to:
  /// **'Idle Time'**
  String get idleTime;

  /// No description provided for @inactive.
  ///
  /// In en, this message translates to:
  /// **'Inactive'**
  String get inactive;

  /// No description provided for @keyboard.
  ///
  /// In en, this message translates to:
  /// **'Keyboard'**
  String get keyboard;

  /// No description provided for @keystrokes.
  ///
  /// In en, this message translates to:
  /// **'Keystrokes'**
  String get keystrokes;

  /// No description provided for @mouseClicks.
  ///
  /// In en, this message translates to:
  /// **'Mouse Clicks'**
  String get mouseClicks;

  /// No description provided for @clicks.
  ///
  /// In en, this message translates to:
  /// **'Clicks'**
  String get clicks;

  /// No description provided for @mouseMoves.
  ///
  /// In en, this message translates to:
  /// **'Mouse Moves'**
  String get mouseMoves;

  /// No description provided for @movement.
  ///
  /// In en, this message translates to:
  /// **'Movement'**
  String get movement;

  /// No description provided for @applicationUsage.
  ///
  /// In en, this message translates to:
  /// **'Application Usage'**
  String get applicationUsage;

  /// No description provided for @requestTimeOff.
  ///
  /// In en, this message translates to:
  /// **'Request Time Off'**
  String get requestTimeOff;

  /// No description provided for @dateAndDuration.
  ///
  /// In en, this message translates to:
  /// **'Date & Duration'**
  String get dateAndDuration;

  /// No description provided for @additionalDetails.
  ///
  /// In en, this message translates to:
  /// **'Additional Details'**
  String get additionalDetails;

  /// No description provided for @selectLeaveType.
  ///
  /// In en, this message translates to:
  /// **'Select leave type'**
  String get selectLeaveType;

  /// No description provided for @startDate.
  ///
  /// In en, this message translates to:
  /// **'Start Date'**
  String get startDate;

  /// No description provided for @endDate.
  ///
  /// In en, this message translates to:
  /// **'End Date'**
  String get endDate;

  /// No description provided for @halfDay.
  ///
  /// In en, this message translates to:
  /// **'Half Day'**
  String get halfDay;

  /// No description provided for @morningAm.
  ///
  /// In en, this message translates to:
  /// **'Morning (AM)'**
  String get morningAm;

  /// No description provided for @afternoonPm.
  ///
  /// In en, this message translates to:
  /// **'Afternoon (PM)'**
  String get afternoonPm;

  /// No description provided for @reasonForTimeOff.
  ///
  /// In en, this message translates to:
  /// **'Reason for time off...'**
  String get reasonForTimeOff;

  /// No description provided for @required.
  ///
  /// In en, this message translates to:
  /// **'Required'**
  String get required;

  /// No description provided for @submitRequest.
  ///
  /// In en, this message translates to:
  /// **'Submit Request'**
  String get submitRequest;

  /// No description provided for @endDateBeforeStartDate.
  ///
  /// In en, this message translates to:
  /// **'End date cannot be before start date'**
  String get endDateBeforeStartDate;

  /// No description provided for @myTimeOff.
  ///
  /// In en, this message translates to:
  /// **'My Time Off'**
  String get myTimeOff;

  /// No description provided for @requestLeave.
  ///
  /// In en, this message translates to:
  /// **'Request Leave'**
  String get requestLeave;

  /// No description provided for @noLeaveRecords.
  ///
  /// In en, this message translates to:
  /// **'No Leave Records'**
  String get noLeaveRecords;

  /// No description provided for @leaveHistoryDescription.
  ///
  /// In en, this message translates to:
  /// **'Your leave history will appear here\nonce you submit your first request.'**
  String get leaveHistoryDescription;

  /// No description provided for @daysAvailable.
  ///
  /// In en, this message translates to:
  /// **'Days Available'**
  String get daysAvailable;

  /// No description provided for @approved.
  ///
  /// In en, this message translates to:
  /// **'Approved'**
  String get approved;

  /// No description provided for @pending.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get pending;

  /// No description provided for @refused.
  ///
  /// In en, this message translates to:
  /// **'Refused'**
  String get refused;

  /// No description provided for @cancelled.
  ///
  /// In en, this message translates to:
  /// **'Cancelled'**
  String get cancelled;

  /// No description provided for @draft.
  ///
  /// In en, this message translates to:
  /// **'Draft'**
  String get draft;

  /// No description provided for @deleteDraft.
  ///
  /// In en, this message translates to:
  /// **'Delete Draft'**
  String get deleteDraft;

  /// No description provided for @cancelLeave.
  ///
  /// In en, this message translates to:
  /// **'Cancel Leave'**
  String get cancelLeave;

  /// No description provided for @cancelRequestQuestion.
  ///
  /// In en, this message translates to:
  /// **'Cancel Request?'**
  String get cancelRequestQuestion;

  /// No description provided for @cancelRequestConfirmation.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to cancel this leave request?'**
  String get cancelRequestConfirmation;

  /// No description provided for @yesCancel.
  ///
  /// In en, this message translates to:
  /// **'Yes, Cancel'**
  String get yesCancel;

  /// No description provided for @no.
  ///
  /// In en, this message translates to:
  /// **'No'**
  String get no;

  /// No description provided for @deleteDraftQuestion.
  ///
  /// In en, this message translates to:
  /// **'Delete Draft?'**
  String get deleteDraftQuestion;

  /// No description provided for @deleteDraftConfirmation.
  ///
  /// In en, this message translates to:
  /// **'This draft will be permanently removed.'**
  String get deleteDraftConfirmation;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @employee.
  ///
  /// In en, this message translates to:
  /// **'Employee'**
  String get employee;

  /// No description provided for @downloading.
  ///
  /// In en, this message translates to:
  /// **'Downloading'**
  String get downloading;

  /// No description provided for @couldNotDownloadFile.
  ///
  /// In en, this message translates to:
  /// **'Could not download file'**
  String get couldNotDownloadFile;

  /// No description provided for @success.
  ///
  /// In en, this message translates to:
  /// **'Success'**
  String get success;

  /// No description provided for @error.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get error;

  /// No description provided for @videoCall.
  ///
  /// In en, this message translates to:
  /// **'Video Call'**
  String get videoCall;

  /// No description provided for @voiceCall.
  ///
  /// In en, this message translates to:
  /// **'Voice Call'**
  String get voiceCall;

  /// No description provided for @pleaseSelectLeaveType.
  ///
  /// In en, this message translates to:
  /// **'Please select a leave type'**
  String get pleaseSelectLeaveType;

  /// No description provided for @productivityHeaderTitle.
  ///
  /// In en, this message translates to:
  /// **'Productivity 📊'**
  String get productivityHeaderTitle;

  /// No description provided for @insufficientBalanceMsg.
  ///
  /// In en, this message translates to:
  /// **'Insufficient balance. You requested {requested} days but only have {available} days available.'**
  String insufficientBalanceMsg(Object available, Object requested);

  /// No description provided for @casualLeave.
  ///
  /// In en, this message translates to:
  /// **'Casual Leave'**
  String get casualLeave;

  /// No description provided for @sickLeave.
  ///
  /// In en, this message translates to:
  /// **'Sick Leave'**
  String get sickLeave;

  /// No description provided for @earnedLeave.
  ///
  /// In en, this message translates to:
  /// **'Earned Leave'**
  String get earnedLeave;

  /// No description provided for @rejected.
  ///
  /// In en, this message translates to:
  /// **'Rejected'**
  String get rejected;

  /// No description provided for @noRecordsFound.
  ///
  /// In en, this message translates to:
  /// **'No records found'**
  String get noRecordsFound;

  /// No description provided for @attendanceReport.
  ///
  /// In en, this message translates to:
  /// **'Attendance Report'**
  String get attendanceReport;

  /// No description provided for @from.
  ///
  /// In en, this message translates to:
  /// **'From'**
  String get from;

  /// No description provided for @to.
  ///
  /// In en, this message translates to:
  /// **'To'**
  String get to;

  /// No description provided for @stillWorking.
  ///
  /// In en, this message translates to:
  /// **'Still Working'**
  String get stillWorking;

  /// No description provided for @validatedOvertime.
  ///
  /// In en, this message translates to:
  /// **'Validated Overtime: {hours} hrs'**
  String validatedOvertime(Object hours);

  /// No description provided for @hrs.
  ///
  /// In en, this message translates to:
  /// **'hrs'**
  String get hrs;

  /// No description provided for @ot.
  ///
  /// In en, this message translates to:
  /// **'OT'**
  String get ot;

  /// No description provided for @inLabel.
  ///
  /// In en, this message translates to:
  /// **'In'**
  String get inLabel;

  /// No description provided for @outLabel.
  ///
  /// In en, this message translates to:
  /// **'Out'**
  String get outLabel;

  /// No description provided for @development.
  ///
  /// In en, this message translates to:
  /// **'Development'**
  String get development;

  /// No description provided for @browser.
  ///
  /// In en, this message translates to:
  /// **'Browser'**
  String get browser;

  /// No description provided for @entertainment.
  ///
  /// In en, this message translates to:
  /// **'Entertainment'**
  String get entertainment;

  /// No description provided for @communication.
  ///
  /// In en, this message translates to:
  /// **'Communication'**
  String get communication;

  /// No description provided for @durationHoursMinutes.
  ///
  /// In en, this message translates to:
  /// **'{hours}h {minutes}m'**
  String durationHoursMinutes(Object hours, Object minutes);

  /// No description provided for @time.
  ///
  /// In en, this message translates to:
  /// **'Time'**
  String get time;

  /// No description provided for @date.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get date;
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
      <String>['en', 'hi', 'te'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'hi':
      return AppLocalizationsHi();
    case 'te':
      return AppLocalizationsTe();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
