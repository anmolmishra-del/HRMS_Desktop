import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:window_manager/window_manager.dart';

import 'package:hrms_desktop/core/constants/app_images.dart';
import 'package:hrms_desktop/core/services/api_service.dart';

import 'package:hrms_desktop/features/home/cubit/home_cubit.dart';

import 'package:hrms_desktop/routes.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // WINDOW MANAGER
  await windowManager.ensureInitialized();

  // PREVENT APP CLOSE
  await windowManager.setPreventClose(true);

  WindowOptions windowOptions =
      const WindowOptions(
    size: Size(1000, 700),
    minimumSize: Size(800, 600),
    center: true,
    backgroundColor: Colors.transparent,
    skipTaskbar: false,
    titleBarStyle: TitleBarStyle.normal,
  );

  windowManager.waitUntilReadyToShow(
    windowOptions,
    () async {
      await windowManager.show();

      await windowManager.focus();
    },
  );

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() =>
      _MyAppState();
}

class _MyAppState extends State<MyApp>
    with WindowListener {

  @override
  void initState() {
    super.initState();

    windowManager.addListener(this);
  }

  @override
  void dispose() {
    windowManager.removeListener(this);

    super.dispose();
  }

  // =========================
  // WHEN USER CLOSES APP
  // =========================

  @override
  void onWindowClose() async {

    // HIDE APP
    // KEEP RUNNING IN BACKGROUND

    await windowManager.hide();

    print(
      "App hidden to background",
    );
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          lazy: false,
          create: (_) =>
              AttendanceCubit(
                ApiService(),
              ),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        routes: Routes.getAll(),
        home: const SplashScreen(),
      ),
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() =>
      _SplashScreenState();
}

class _SplashScreenState
    extends State<SplashScreen> {

  @override
  void initState() {
    super.initState();

    _navigateToNext();
  }

  Future<void> _navigateToNext() async {
    await Future.delayed(
      const Duration(seconds: 3),
    );

    final prefs =
        await SharedPreferences.getInstance();

    final bool isLoggedIn =
        prefs.getBool('is_logged_in') ??
            false;

    if (!mounted) return;

    if (isLoggedIn) {
      Navigator.pushReplacementNamed(
        context,
        Routes.main,
      );
    } else {
      Navigator.pushReplacementNamed(
        context,
        Routes.onboarding,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      body: Center(
        child: SizedBox(
          width: 180,
          height: 180,

          child: Image.asset(
            AppImages.logo,
            fit: BoxFit.fill,
          ),
        ),
      ),
    );
  }
}