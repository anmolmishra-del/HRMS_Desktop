import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

class AppLocalization extends ChangeNotifier {
  static final AppLocalization _instance = AppLocalization._internal();
  factory AppLocalization() => _instance;
  AppLocalization._internal();

  static const List<Locale> supportedLocales = [
    Locale('en', 'US'), // English
    Locale('hi', 'IN'), // Hindi
    Locale('te', 'IN'), // Telugu
  ];

  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = [
    AppLocalizations.delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
  ];

  Locale _currentLocale = const Locale('en', 'US');
  bool _isInitialized = false;

  Locale get currentLocale => _currentLocale;
  String get currentLanguageCode => _currentLocale.languageCode;

  static const String _localeKey = 'app_locale';

  Future<void> initialize() async {
    if (_isInitialized) return;
    
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedLanguageCode = prefs.getString(_localeKey);
      
      if (savedLanguageCode != null) {
        // Find the supported locale that matches the saved language code
        final supportedLocale = supportedLocales.firstWhere(
          (locale) => locale.languageCode == savedLanguageCode,
          orElse: () => supportedLocales.first, // Default to first supported locale
        );
        _currentLocale = supportedLocale;
      }
      _isInitialized = true;
    } catch (e) {
      _isInitialized = true;
    }
  }

  Future<void> setLocale(Locale locale) async {
    if (!supportedLocales.contains(locale)) return;
    if (_currentLocale == locale) return;
    
    _currentLocale = locale;
    await _saveLocale();
    notifyListeners();
  }

  Future<void> setLocaleByLanguageCode(String languageCode) async {
    final locale = Locale(languageCode);
    await setLocale(locale);
  }

  Future<void> _saveLocale() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_localeKey, _currentLocale.languageCode);
    } catch (e) {
      // Handle error silently
    }
  }

  String getLanguageName(Locale locale) {
    switch (locale.languageCode) {
      case 'en':
        return 'English';
      case 'hi':
        return 'Hindi';
      case 'te':
        return 'Telugu';
      default:
        return locale.languageCode.toUpperCase();
    }
  }

  String getLanguageNativeName(Locale locale) {
    switch (locale.languageCode) {
      case 'en':
        return 'English';
      case 'hi':
        return 'हिन्दी';
      case 'te':
        return 'తెలుగు';
      default:
        return locale.languageCode.toUpperCase();
    }
  }
}

class AppLocalizations {
  final Locale locale;

  AppLocalizations(this.locale);

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  // Common strings
  String get appTitle => _localizedValues[locale.languageCode]!['appTitle']!;
  String get dashboard => _localizedValues[locale.languageCode]!['dashboard']!;
  String get attendance => _localizedValues[locale.languageCode]!['attendance']!;
  String get dataAndPrivacy => _localizedValues[locale.languageCode]!['dataAndPrivacy']!;
  String get supportAndHelp => _localizedValues[locale.languageCode]!['supportAndHelp']!;
  String get workSettings => _localizedValues[locale.languageCode]!['workSettings']!;
  String get leaves => _localizedValues[locale.languageCode]!['leaves']!;
  String get productivity => _localizedValues[locale.languageCode]!['productivity']!;
  String get settings => _localizedValues[locale.languageCode]!['settings']!;
  String get logout => _localizedValues[locale.languageCode]!['logout']!;
  String get login => _localizedValues[locale.languageCode]!['login']!;
  String get password => _localizedValues[locale.languageCode]!['password']!;
  String get email => _localizedValues[locale.languageCode]!['email']!;
  String get rememberMe => _localizedValues[locale.languageCode]!['rememberMe']!;
  String get forgotPassword => _localizedValues[locale.languageCode]!['forgotPassword']!;
  String get signIn => _localizedValues[locale.languageCode]!['signIn']!;
  String get recentActivities => _localizedValues[locale.languageCode]!['recentActivities']!;
  String get noRecentRecords => _localizedValues[locale.languageCode]!['noRecentRecords']!;
  String get checkIn => _localizedValues[locale.languageCode]!['checkIn']!;
  String get checkOut => _localizedValues[locale.languageCode]!['checkOut']!;
  String get workingHours => _localizedValues[locale.languageCode]!['workingHours']!;
  String get todayScore => _localizedValues[locale.languageCode]!['todayScore']!;
  String get tasksCompleted => _localizedValues[locale.languageCode]!['tasksCompleted']!;
  String get focusTime => _localizedValues[locale.languageCode]!['focusTime']!;
  String get weeklyProductivityTrend => _localizedValues[locale.languageCode]!['weeklyProductivityTrend']!;
  String get todaysTasks => _localizedValues[locale.languageCode]!['todaysTasks']!;
  String get customizeYourExperience => _localizedValues[locale.languageCode]!['customizeYourExperience']!;
  String get version => _localizedValues[locale.languageCode]!['version']!;
  String get language => _localizedValues[locale.languageCode]!['language']!;
  String get theme => _localizedValues[locale.languageCode]!['theme']!;
  String get lightTheme => _localizedValues[locale.languageCode]!['lightTheme']!;
  String get darkTheme => _localizedValues[locale.languageCode]!['darkTheme']!;
  String get profile => _localizedValues[locale.languageCode]!['profile']!;
  String get personalInformation => _localizedValues[locale.languageCode]!['personalInformation']!;
  String get jobDetails => _localizedValues[locale.languageCode]!['jobDetails']!;
  String get changePassword => _localizedValues[locale.languageCode]!['changePassword']!;
  String get notifications => _localizedValues[locale.languageCode]!['notifications']!;
  String get languageSettings => _localizedValues[locale.languageCode]!['languageSettings']!;
  String get chooseYourPreferredLanguage => _localizedValues[locale.languageCode]!['chooseYourPreferredLanguage']!;
  String get thisWeek => _localizedValues[locale.languageCode]!['thisWeek']!;
  String get completed => _localizedValues[locale.languageCode]!['completed']!;
  String get running => _localizedValues[locale.languageCode]!['running']!;
  String get checkedInAt => _localizedValues[locale.languageCode]!['checkedInAt']!;
  String get checkedOutAt => _localizedValues[locale.languageCode]!['checkedOutAt']!;
  String get workingSessionStartedAt => _localizedValues[locale.languageCode]!['workingSessionStartedAt']!;
  String get welcomeBack => _localizedValues[locale.languageCode]!['welcomeBack']!;
  String get trackAttendanceAndProductivity => _localizedValues[locale.languageCode]!['trackAttendanceAndProductivity']!;
  String get and => _localizedValues[locale.languageCode]!['and']!;
  String get appPreferences => _localizedValues[locale.languageCode]?['appPreferences'] ?? 'App Preferences';
  String get fixAttendance => _localizedValues[locale.languageCode]!['fixAttendance']!;
  String get dailyDetails => _localizedValues[locale.languageCode]!['dailyDetails']!;
  String get inOutReport => _localizedValues[locale.languageCode]!['inOutReport']!;
  String get calendarView => _localizedValues[locale.languageCode]!['calendarView']!;

  static const Map<String, Map<String, String>> _localizedValues = {
    'en': {
      'appTitle': 'HRMS Desktop',
      'dashboard': 'Dashboard',
      'attendance': 'Attendance',
      'leaves': 'Leaves',
      'productivity': 'Productivity',
      'settings': 'Settings',
      'logout': 'Logout',
      'login': 'Login',
      'password': 'Password',
      'email': 'Email',
      'rememberMe': 'Remember Me',
      'forgotPassword': 'Forgot Password?',
      'signIn': 'Sign In',
      'recentActivities': 'Recent Activities',
      'noRecentRecords': 'No recent records',
      'checkIn': 'Check In',
      'checkOut': 'Check Out',
      'workingHours': 'Working Hours',
      'todayScore': "Today's Score",
      'tasksCompleted': 'Tasks Completed',
      'focusTime': 'Focus Time',
      'weeklyProductivityTrend': 'Weekly Productivity Trend',
      'todaysTasks': "Today's Tasks",
      'customizeYourExperience': 'Customize your experience',
      'version': 'Version',
      'language': 'Language',
      'theme': 'Theme',
      'lightTheme': 'Light Theme',
      'darkTheme': 'Dark Theme',
      'appPreferences': 'App Preferences',
      'profile': 'Profile',
      'personalInformation': 'Personal Information',
      'jobDetails': 'Job Details',
      'changePassword': 'Change Password',
      'notifications': 'Notifications',
      'languageSettings': 'Language Settings',
      'chooseYourPreferredLanguage': 'Choose your preferred language',
      'thisWeek': 'This Week',
      'completed': 'Completed',
      'running': 'Running',
      'checkedInAt': 'Checked in at',
      'checkedOutAt': 'Checked out at',
      'workingSessionStartedAt': 'Working session started at',
      'welcomeBack': 'Welcome Back',
      'trackAttendanceAndProductivity': 'Track attendance and productivity',
      'and': 'and',
      'fixAttendance': 'Fix Attendance',
      'dailyDetails': 'Daily Details',
      'inOutReport': 'In/Out Report',
      'calendarView': 'Calendar View',
      'workSettings': 'Work Settings',
      'dataAndPrivacy': 'Data & Privacy',
      'supportAndHelp': 'Support & Help',
      'helpCenter': 'Help Center',
      'contactSupport': 'Contact Support',
      'reportABug': 'Report a Bug',
      'exportData': 'Export Data',
      'privacyPolicy': 'Privacy Policy',
      'termsOfService': 'Terms of Service',
      'biometricAuthentication': 'Biometric Authentication',
      'autoCheckIn': 'Auto Check-in',
      'pushNotifications': 'Push Notifications',
      'receiveNotifications': 'Receive notifications for check-in/out reminders',
      'useFingerprint': 'Use fingerprint/face ID for check-in/out',
      'automaticallyCheckIn': 'Automatically check-in when opening the app',
      'setDefaultWorkingHours': 'Set your default working hours',
      'downloadAttendanceData': 'Download your attendance and productivity data',
      'readPrivacyPolicy': 'Read our privacy policy',
      'readTermsConditions': 'Read our terms and conditions',
      'findAnswers': 'Find answers to common questions',
      'getInTouch': 'Get in touch with our support team',
      'helpUsImprove': 'Help us improve by reporting issues',
    },
    'hi': {
      'appTitle': 'HRMS डेस्कटॉप',
      'dashboard': 'डैशबोर्ड',
      'attendance': 'उपस्थिति',
      'leaves': 'छुट्टियां',
      'productivity': 'उत्पादकता',
      'settings': 'सेटिंग्स',
      'logout': 'लॉगआउट',
      'login': 'लॉग इन',
      'password': 'पासवर्ड',
      'email': 'ईमेल',
      'rememberMe': 'मुझे याद रखें',
      'forgotPassword': 'पासवर्ड भूल गए?',
      'signIn': 'साइन इन करें',
      'recentActivities': 'हाल की गतिविधियां',
      'noRecentRecords': 'कोई हाल का रिकॉर्ड नहीं',
      'checkIn': 'चेक इन',
      'checkOut': 'चेक आउट',
      'workingHours': 'काम के घंटे',
      'todayScore': 'आज का स्कोर',
      'tasksCompleted': 'पूरी हुई टास्क',
      'focusTime': 'फोकस समय',
      'weeklyProductivityTrend': 'साप्ताहिक उत्पादकता रुझान',
      'todaysTasks': 'आज की टास्क',
      'customizeYourExperience': 'अपने अनुभव को अनुकूलित करें',
      'version': 'संस्करण',
      'language': 'भाषा',
      'theme': 'थीम',
      'lightTheme': 'लाइट थीम',
      'darkTheme': 'डार्क थीम',
      'appPreferences': 'ऐप वरीयन',
      'profile': 'प्रोफाइल',
      'personalInformation': 'व्यक्तिग जानकार',
      'jobDetails': 'नौकरी विवर',
      'changePassword': 'पासवर्ड बदल',
      'notifications': 'सूचनाए',
      'languageSettings': 'भाषा सेटिंग',
      'chooseYourPreferredLanguage': 'अपनी भाषा चुनें',
      'thisWeek': 'इस हफ्ताह',
      'completed': 'पूरी हुई',
      'running': 'चल रह रहा है',
      'checkedInAt': 'पर चेक इन किया समय',
      'checkedOutAt': 'पर चेक आउट किया समय',
      'workingSessionStartedAt': 'काम के समय आरंभ हुआ',
      'welcomeBack': 'वापस आए',
      'trackAttendanceAndProductivity': 'उपस्थिति और उत्पादकता ट्रैक',
      'and': 'और',
      'fixAttendance': 'उपस्थिति सुधारें',
      'dailyDetails': 'दैनिक विवर',
      'inOutReport': 'इन/आउट रिपोर्ट',
      'calendarView': 'कैलेंडर व्यू',
      'workSettings': 'काम के सेटिंग',
      'dataAndPrivacy': 'डेटा और गोपनीयता',
      'supportAndHelp': 'सहायत और सहायत',
      'helpCenter': 'सहायत केंद्र',
      'contactSupport': 'सहायत टीम से संपर्क करें',
      'reportABug': 'एक बग रिपोर्ट करके लिए सुधारें',
      'exportData': 'अपनी उपस्थिति और उत्पादकता डेटा डाउनलोड',
      'privacyPolicy': 'हमारी गोपनीयता नीति पढ़ें',
      'termsOfService': 'सेवाओं और शर्तें पढ़ें',
      'biometricAuthentication': 'बायोमेट्रिक प्रमाणुख',
      'autoCheckIn': 'ऐप खोलने पर स्वचालय चेक इन करता है',
      'pushNotifications': 'चेक इन/आउट रिमांदर के लिए अनुसूचनाए',
      'receiveNotifications': 'चेक इन/आउट रिमांदर के लिए अनुसूचनाए',
      'useFingerprint': 'चेक इन/आउट के लिए अंगुंग्रिक प्रमाणुख',
      'automaticallyCheckIn': 'ऐप खोलने पर स्वचालय चेक इन करता है',
      'setDefaultWorkingHours': 'अपनी डिफ़ॉल्ट काम के घंटे सेट करें',
      'downloadAttendanceData': 'अपनी उपस्थिति और उत्पादकता डेटा डाउनलोड',
      'readPrivacyPolicy': 'हमारी गोपनीयता नीति पढ़ें',
      'readTermsConditions': 'सेवाओं और शर्तें पढ़ें',
      'findAnswers': 'आम सवालों के जवाब खोजने के लिए उत्तर प्राप्त करें',
      'getInTouch': 'सहायत टीम से संपर्क करें',
      'helpUsImprove': 'सुधारें मददाने मदोने मदोजोजने के लिए सुधारें',
    },
    'te': {
      'appTitle': 'HRMS డెస్క్‌టాప్',
      'dashboard': 'డ్యాష్‌బోర్డ్',
      'attendance': 'హాజరు',
      'leaves': 'సెలవలు',
      'productivity': 'ఉత్పాదకత',
      'settings': 'సెట్టింగ్‌లు',
      'logout': 'లాగ్‌అవుట్',
      'login': 'లాగిన్',
      'password': 'పాస్‌వర్డ్',
      'email': 'ఇమెయిల్',
      'rememberMe': 'నన్ను గుర్తించు',
      'forgotPassword': 'పాస్‌వర్డ్ మరిచిపోయారా?',
      'supportAndHelp':'మద్దతు మరియు సహాయం',
      'signIn': 'సైన్ ఇన్',
      'recentActivities': 'ఇటీవా కార్యాలు',
      'noRecentRecords': 'ఇటీవా రికార్డులు లేవు',
      'checkIn': 'చెక్ ఇన్',
      'checkOut': 'చెక్ అవుట్',
      'workingHours': 'పని గంటలు',
      'todayScore': 'ఈ రోజు స్కోరు',
      'tasksCompleted': 'పూర్తి అయిన పనులు',
      'focusTime': 'దృష్టి సమయం',
      'weeklyProductivityTrend': 'వారపు ఉత్పాదకత ధోరణి',
      'todaysTasks': 'ఈ రోజు పనులు',
      'customizeYourExperience': 'మీ అనుభవాన్ని అనుకూలించండి',
      'version': 'వెర్షన్',
      'language': 'భాష',
      'dataAndPrivacy':'డేటా మరియు గోప్యత',
      'theme': 'థీమ్',
      'lightTheme': 'లైట్ థీమ్',
      'darkTheme': 'డార్క్ థీమ్',
      'profile': 'ప్రొఫైల్',
      'personalInformation': 'వ్యక్తిగత సమాచారం',
      'jobDetails': 'ఉద్యోగ వివరాలు',
      'changePassword': 'పాస్‌వర్డ్ మార్చండి',
      'notifications': 'నోటిఫికేషన్లు',
      'languageSettings': 'భాష సెట్టింగ్‌లు',
      'chooseYourPreferredLanguage': 'మీ ఇష్టపిం భాష భాషను ఎంచుకోండి',
      'workSettings':'పని అమరికలు',
    'thisWeek': 'ఈ వావ',
    'completed': 'పూర్తి అయిందింది',
    'running': 'నడుస్తోండిల ఉందోంది',
    'checkedInAt': 'చెక్ ఇన్ చేశారి',
    'checkedOutAt': 'చెక్ అవుట్ చేశారి',
    'workingSessionStartedAt': 'పని సెషన్ ప్రారంభ ప్రారంభింది',
    'welcomeBack': 'స్వాగమ ఆయోంది',
    'trackAttendanceAndProductivity': 'హాజరు మరిం ఉత్పాదకత మరిం ట్రాకి చేయంది',
    'and': 'మరియు',
    },
  };
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return AppLocalization.supportedLocales
        .map((l) => l.languageCode)
        .contains(locale.languageCode);
  }

  @override
  Future<AppLocalizations> load(Locale locale) async {
    return AppLocalizations(locale);
  }

  @override
  bool shouldReload(LocalizationsDelegate<AppLocalizations> old) => false;
}
