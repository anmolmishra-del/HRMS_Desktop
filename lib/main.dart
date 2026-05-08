import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hrms_desktop/core/constants/app_images.dart';
import 'package:hrms_desktop/core/services/api_service.dart';
import 'package:hrms_desktop/features/attendance/cubit/attendance_cubit.dart';
import 'package:hrms_desktop/routes.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:window_manager/window_manager.dart';

import 'package:hrms_desktop/core/constants/app_images.dart';
import 'package:hrms_desktop/core/services/api_service.dart';

import 'package:hrms_desktop/features/home/cubit/home_cubit.dart' hide AttendanceCubit;

import 'package:hrms_desktop/routes.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

 
  await windowManager.ensureInitialized();

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

class _MyAppState extends State<MyApp> with WindowListener {
  static const MethodChannel _methodChannel =
      MethodChannel('hrms/activity');

  static const EventChannel _eventChannel =
      EventChannel('hrms/activity_stream');

  StreamSubscription? _sub;
final GlobalKey<NavigatorState> navigatorKey =
    GlobalKey<NavigatorState>();
  @override
  void initState() {
    super.initState();

    windowManager.addListener(this);

    print("🚀 HRMS App Started");

    _startTracker();

    _listenEvents();
  }

  // START NATIVE TRACKER
  Future<void> _startTracker() async {
    try {
      await _methodChannel.invokeMethod('startTracking');
      print("▶️ Native tracker started");
    } catch (e) {
      print("❌ Failed to start tracker: $e");
    }
  }

  bool _dialogShown = false;
bool _trackingPaused = false;
  Timer? _autoCheckoutTimer; // ⬅️ Timer for auto checkout
bool testMode = true;

void _listenEvents() {
  _sub = _eventChannel.receiveBroadcastStream().listen(
    (event) {
      if (event is! Map) return;

      int idle = event['idle'] ?? 0;

  

      // ❌ STOP IF PAUSED
      if (_trackingPaused) return;

      if (idle >= 60 && !_dialogShown) {
        _dialogShown = true;
        _trackingPaused = true; 
        _showIdleWarning();
        print(idle);
      }

      // if (idle < 60) {
      //   _dialogShown = false;
      // }
    },
    onError: (error) {
      print("❌ Tracker error: $error");
    },
  );
}

void _showIdleWarning() {
  final context = navigatorKey.currentState?.overlay?.context;

  if (context == null) return;
    _autoCheckoutTimer?.cancel();
    _autoCheckoutTimer = Timer(const Duration(minutes: 1), () {
      _performAutoCheckout();
    });
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (_) {
      return AlertDialog(
        title: const Text("Inactivity detected"),
        content: const Text(
          "You have been idle for more than 5 minutes. Are you still working?",
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);

              // ✅ RESUME TRACKING
              _trackingPaused = false;

              print("▶️ Tracking resumed");
            },
            child: const Text("Yes, I'm here"),
          ),
        ],
      );
    },
  );
}
  void _performAutoCheckout() async {
    // Stop all tracking
    _trackingPaused = true;
    _dialogShown = false;
  _autoCheckoutTimer?.cancel();
    // Call native method to stop screenshots, key/mouse tracking
    try {
      await _methodChannel.invokeMethod('stopTracking');
      print("🛑 Auto checkout triggered: tracking stopped");
    } catch (e) {
      print("❌ Failed to stop tracker: $e");
    }

    // Optional: navigate to login/checkout screen
    final context = navigatorKey.currentState?.overlay?.context;
    if (context != null) {
      Navigator.of(context, rootNavigator: true).pop(); // Close dialog if open

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) {
          return AlertDialog(
            title: const Text("Auto Checkout"),
            content: const Text(
              "You were inactive for too long. You have been checked out automatically.",
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text("OK"),
              ),
            ],
          );
        },
      );
    }
  }
  @override
  void dispose() {
    _sub?.cancel();
     _autoCheckoutTimer?.cancel();
    windowManager.removeListener(this);
    super.dispose();
  }

  @override
  void onWindowClose() async {
    await windowManager.hide();
    print("App hidden to background");
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) =>
              AttendanceCubit()..loadInitialStatus(),
        ),
      ],
      child: MaterialApp(
          navigatorKey: navigatorKey,
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