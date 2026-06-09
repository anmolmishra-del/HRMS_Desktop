import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hrms_desktop/features/auth/login/cubit/login_cubit.dart';
import 'package:hrms_desktop/features/projects/cubit/project_tasks_cubit.dart';

import 'package:hrms_desktop/core/navigation/navigator_service.dart';
import 'package:local_notifier/local_notifier.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:window_manager/window_manager.dart';

import 'package:hrms_desktop/core/constants/app_images.dart';
import 'package:hrms_desktop/core/theme/app_theme.dart';
import 'package:hrms_desktop/core/localization/app_localization.dart';
import 'package:hrms_desktop/core/theme/theme_cubit.dart';
import 'package:hrms_desktop/features/attendance/cubit/attendance_cubit.dart';
import 'package:hrms_desktop/features/leave/cubit/leave_cubit.dart';
import 'package:hrms_desktop/features/home/cubit/productivity_cubit.dart';
import 'package:hrms_desktop/features/projects/cubit/projects_cubit.dart';
import 'package:hrms_desktop/features/chat/cubit/chat_cubit.dart';
import 'package:hrms_desktop/core/widget/internet_wrapper.dart';
import 'package:hrms_desktop/routes.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await AppLocalization().initialize();

  await windowManager.ensureInitialized();

  // Prevent real close
  await windowManager.setPreventClose(true);

  const windowOptions = WindowOptions(
    size: Size(1000, 700),

    // FIXED SIZE
    minimumSize: Size(1000, 700),
    maximumSize: Size(1000, 700),

    center: true,

    backgroundColor: Colors.transparent,

    skipTaskbar: false,

    titleBarStyle: TitleBarStyle.normal,
  );

  windowManager.waitUntilReadyToShow(windowOptions, () async {
    await windowManager.show();

    await windowManager.focus();

    // Disable resize
    await windowManager.setResizable(false);
  });
  await localNotifier.setup(
    appName: 'Opzento Desktop',
    shortcutPolicy: ShortcutPolicy.requireCreate,
  );
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WindowListener {
  @override
  void initState() {
    super.initState();

    windowManager.addListener(this);

    // Initialize theme only (localization is initialized in main)
    AppTheme().initialize();

    print("HRMS STARTED");
  }

  @override
  void dispose() {
    windowManager.removeListener(this);

    super.dispose();
  }

  @override
  void onWindowClose() async {
    await windowManager.minimize();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: AppTheme(),
      builder: (context, child) {
        return AnimatedBuilder(
          animation: AppLocalization(),
          builder: (context, child) {
            return MultiBlocProvider(
              providers: [
                BlocProvider<ThemeCubit>(create: (_) => ThemeCubit()),
                BlocProvider(
                  create: (_) => AttendanceCubit(NavigatorService.navigatorKey)..loadInitialStatus(),
                ),
                BlocProvider<LoginCubit>(
                  create: (_) => LoginCubit(),
                ),
                BlocProvider(
                  create: (_) => LeaveCubit(),
                ),
                BlocProvider(
                  create: (_) => ProjectsCubit(),
                ),
                BlocProvider(
                  create: (_) => ProjectTasksCubit(),
                ),
                BlocProvider(
                  create: (_) => ProductivityCubit(),
                ),
                BlocProvider(
                  create: (_) => ChatCubit(),
                ),
                BlocProvider<LoginCubit>(create: (_) => LoginCubit()),
                BlocProvider(create: (_) => LeaveCubit()),
                BlocProvider(create: (_) => ProductivityCubit()),
                BlocProvider(create: (_) => ChatCubit()),
              ],

              child: BlocBuilder<ThemeCubit, ThemeState>(
                builder: (context, themeState) {
                  return InternetWrapper(
                    child: MaterialApp(
                      navigatorKey: NavigatorService.navigatorKey,

                      debugShowCheckedModeBanner: false,

                      theme: AppTheme.lightTheme,
                      darkTheme: AppTheme.darkTheme,
                      themeMode: themeState.themeMode,

                      // Localization setup
                      locale: AppLocalization().currentLocale,
                      supportedLocales: AppLocalization.supportedLocales,
                      localizationsDelegates:
                          AppLocalization.localizationsDelegates,

                      routes: Routes.getAll(),

                      home: const SplashScreen(),
                    ),
                  );
                },
              ),
            );
          },
        );
      },
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();

    _navigateToNext();
  }

  Future<void> _navigateToNext() async {
    await Future.delayed(const Duration(seconds: 3));

    final prefs = await SharedPreferences.getInstance();

    final bool isLoggedIn = prefs.getBool('is_logged_in') ?? false;

    if (!mounted) {
      return;
    }

    if (isLoggedIn) {
      Navigator.pushReplacementNamed(context, Routes.main);
    } else {
      Navigator.pushReplacementNamed(context, Routes.onboarding);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,

      body: Center(
        child: SizedBox(
          width: 180,

          height: 180,

          child: AnimatedBuilder(
            animation: AppTheme(),
            builder: (context, child) {
              return Image.asset(
                AppTheme().isDarkMode ? AppImages.logo : AppImages.logoDark,
                fit: BoxFit.fill,
              );
            },
          ),
        ),
      ),
    );
  }
}
