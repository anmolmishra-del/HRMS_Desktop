import 'package:flutter/widgets.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hrms_desktop/core/services/api_service.dart';
import 'package:hrms_desktop/core/services/token_service.dart';
import 'package:hrms_desktop/features/auth/login/presentation/login_page.dart';
import 'package:hrms_desktop/features/in_out/cubit/all_in_out_cubit.dart';
import 'package:hrms_desktop/features/in_out/presentation/in_out_page.dart';
import 'package:hrms_desktop/features/main/presentation/main_page.dart';
import 'package:hrms_desktop/features/onboard/onboard_page.dart';
import 'package:hrms_desktop/features/profile/pages/change_password.dart';
import 'package:hrms_desktop/features/profile/pages/holidays_calendar.dart';
import 'package:hrms_desktop/features/profile/pages/job_details.dart';
import 'package:hrms_desktop/features/profile/pages/language.dart';
import 'package:hrms_desktop/features/profile/pages/leave_balance.dart';
import 'package:hrms_desktop/features/profile/pages/notifications.dart';
import 'package:hrms_desktop/features/profile/pages/perform_review.dart';
import 'package:hrms_desktop/features/profile/pages/reimbursement_page.dart';
import 'package:hrms_desktop/features/profile/pages/training_learning.dart';
import 'package:hrms_desktop/features/screens/ai_chat_bot_page.dart';
import 'package:hrms_desktop/features/screens/company_cal.dart';
import 'package:hrms_desktop/features/screens/doc_box_page.dart';
import 'package:hrms_desktop/features/screens/leave_page.dart';

class Routes {
  Routes._();
  static String onboarding = '/onboarding';
  static String login = '/login';
  // static String admin = '/admin';
  static String main = '/main';
  static String leave = '/leave';
  static String myPay = '/myPay';
  static String inOutReport = '/inout-report';
  static String docbox = '/docbox';
  static String companyCalendar = '/companyCalendar';
  static String aichatbot = '/aichatbot';
  // profilepage
  static String jobdetails = '/jobdetails';
  static String personalinf = '/personalInf';
  static String leavebalance = '/leavebalance';
  static String performRev = '/performRev';
  static String holidayCalendar = '/holidayCalendar';
  static String reimbursements = '/reimbursements';
  static String learnTraing = '/learnTraing';
  static String changepassword = '/changepassword';
  static String notifications = '/notifications';
  static String language = '/language';
  static Map<String, WidgetBuilder> getAll() {
    return {
      onboarding: (c) => const OnboardingScreen(),
      login: (c) => const LoginScreen(),
      // admin: (c) => AdminPanelScreen(),
      main: (c) => const MainPage(),
      leave: (c) => LeavePage(),
      // myPay: (c) => PayrollScreen(),
   inOutReport: (c) => BlocProvider(
      create: (_) {
        final cubit = AttendanceReportCubit(ApiService());

        /// 🔥 CALL API HERE
        TokenService.getUser().then((user) {
          if (user != null) {
            cubit.fetchRecords(user["id"]);
          }
        });

        return cubit;
      },
      child: const InOutReportPage(),
    ),
      docbox: (c) => DocBoxPage(),
      companyCalendar: (c) => CompanyCalendarPage(),
      aichatbot: (c) => AiChatBotPage(),
      jobdetails: (c) => JobDetailsPage(),
      // personalinf: (c) => ProfileFullDetailsPage(),
      leavebalance: (c) => LeaveBalanceModernPage(),
      performRev: (c) => PerformanceReviewPage(),
      holidayCalendar: (c) => HolidayCalendarPage(),
      reimbursements: (c) => ReimbursementPage(),
      learnTraing: (c) => TrainingLearningPage(),
      changepassword: (c) => ChangePasswordPage(),
      notifications: (c) => NotificationsPage(),
      language: (c) => LanguagePage(),
    };
  }
}
