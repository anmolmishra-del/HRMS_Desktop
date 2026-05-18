import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:dio/dio.dart';
import 'package:ffi/ffi.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:geolocator/geolocator.dart';
import 'package:hrms_desktop/core/services/app_usage_service.dart';
import 'package:hrms_desktop/core/services/productivity_engine_service.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:odoo_rpc/odoo_rpc.dart';
import 'package:win32/win32.dart';

import 'package:hrms_desktop/core/utils/shared_pref.dart';
import 'package:hrms_desktop/features/home/cubit/screenshot_service.dart';
import 'package:hrms_desktop/network/odoo_service.dart';

import 'attendance_state.dart';

class AttendanceCubit extends Cubit<AttendanceState> {
  AttendanceCubit(this.navigatorKey) : super(const AttendanceState());

  final GlobalKey<NavigatorState> navigatorKey;

  static const MethodChannel _methodChannel = MethodChannel('hrms/activity');

  static const EventChannel _eventChannel = EventChannel(
    'hrms/activity_stream',
  );

  StreamSubscription? _activitySubscription;

  late OdooService _odooService;

  late int _empId;

  bool _isInitialized = false;

  String _cachedIp = "0.0.0.0";

  Position? _cachedPosition;

  Timer? _ticker;

  Timer? _randomScreenshotTimer;

  Timer? _productivityTimer;

  int _screenshotsTakenToday = 0;

  DateTime? _lastScreenshotDate;

  Timer? _autoCheckoutTimer;

  DateTime? _currentCheckInTime;

  bool _isTracking = false;

  bool _dialogShown = false;

  bool _trackingPaused = false;

  bool _isIdle = false;

  int _lastIdleSeconds = 0;

  int _totalKeys = 0;

  int _totalClicks = 0;

  int _totalMoves = 0;

  double _activeSeconds = 0;

  double _idleSeconds = 0;

  int _minuteKeys = 0;

  int _minuteClicks = 0;

  int _minuteMoves = 0;

  int _minuteIdleSeconds = 0;

  double _smoothProductivity = 75;

  // =========================================
  // CLEAR MESSAGE
  // =========================================

  void clearMessages() {
    emit(state.copyWith(clearError: true, clearSuccess: true));
  }

  // =========================================
  // INIT
  // =========================================

  Future<void> initCubit() async {
    if (_isInitialized) {
      return;
    }

    final prefs = SharedPref();

    final sobj = await prefs.getObject('session');

    final baseUrl = await prefs.getString('baseUrl');

    final employeeData = await prefs.getObject('employee_data');

    if (sobj == null || baseUrl == null || employeeData == null) {
      throw Exception("Session expired");
    }

    final session = OdooSession.fromJson(Map<String, dynamic>.from(sobj));

    _odooService = OdooService(baseUrl, session: session);

    final rawEmpId = employeeData['id'];

    _empId = rawEmpId is int ? rawEmpId : int.parse(rawEmpId.toString());

    _cachedIp = await _getIpAddress();

    _cachedPosition = await _getCurrentPosition();

    _totalKeys = await prefs.getInt('total_keys') ?? 0;
    _totalClicks = await prefs.getInt('total_clicks') ?? 0;
    _totalMoves = await prefs.getInt('total_moves') ?? 0;
    _activeSeconds = (await prefs.getDouble('active_seconds') ?? 0);
    _idleSeconds = (await prefs.getDouble('idle_seconds') ?? 0);
    _screenshotsTakenToday = await prefs.getInt('screenshots_today') ?? 0;
    final lastDateStr = await prefs.getString('last_screenshot_date');
    if (lastDateStr != null && lastDateStr.isNotEmpty) {
      _lastScreenshotDate = DateTime.parse(lastDateStr);
    }

    print(
      "LOADED TRACKING DATA => Keys: $_totalKeys, Clicks: $_totalClicks, Moves: $_totalMoves",
    );

    _isInitialized = true;
  }

  Future<void> _saveTrackingData() async {
    final prefs = SharedPref();
    await prefs.saveInt('total_keys', _totalKeys);
    await prefs.saveInt('total_clicks', _totalClicks);
    await prefs.saveInt('total_moves', _totalMoves);
    await prefs.saveDouble('active_seconds', _activeSeconds);
    await prefs.saveDouble('idle_seconds', _idleSeconds);
    await prefs.saveInt('screenshots_today', _screenshotsTakenToday);
    await prefs.saveString(
      'last_screenshot_date',
      _lastScreenshotDate?.toIso8601String() ?? '',
    );
  }

  @override
  Future<void> close() {
    _ticker?.cancel();

    _randomScreenshotTimer?.cancel();

    _productivityTimer?.cancel();

    _activitySubscription?.cancel();

    _autoCheckoutTimer?.cancel();

    if (_isInitialized) {
      _odooService.close();
    }

    return super.close();
  }

  // =========================================
  // LOAD STATUS
  // =========================================

  Future<void> loadInitialStatus() async {
    await initCubit();

    emit(state.copyWith(status: AttendanceStatus.loading));

    try {
      final checkInStatus = await _odooService.executeModelMethod(
        'hr.attendance',
        'search_read',
        [],
        kwargs: {
          'domain': [
            ['employee_id', '=', _empId],
            ['check_out', '=', false],
          ],
          'fields': ['id', 'check_in'],
          'limit': 1,
        },
      );

      final isCheckedIn =
          checkInStatus != null && (checkInStatus as List).isNotEmpty;

      if (isCheckedIn) {
        String lastCheckIn = (checkInStatus)[0]['check_in'];

        if (!lastCheckIn.endsWith('Z')) {
          lastCheckIn = '${lastCheckIn.replaceAll(' ', 'T')}Z';
        }

        _currentCheckInTime = DateTime.parse(lastCheckIn).toLocal();

        /// =====================================
        /// AUTO RESUME TRACKING AFTER RESTART
        /// =====================================

        print("USER ALREADY CHECKED IN");

        _listenActivityStream();

        //_startProductivityTimer();
        ProductivityEngineService().startTracking();

        startRandomScreenshots();

        await _methodChannel.invokeMethod('startTracking');

        AppUsageService().startTracking();

        print("TRACKING AUTO RESUMED");
      }

      final baseHours = await _fetchBaseHours();
      print(baseHours);
      emit(
        state.copyWith(
          status: AttendanceStatus.success,
          isCheckedIn: isCheckedIn,
          baseHours: baseHours,
          todayHours: _formatHours(baseHours),
          productiveHours: productiveHours,
          idleHours: _idleSeconds / 3600.0,
          productivityPercent: productivityPercent,
        ),
      );

      _startTicker();
    } catch (e) {
      emit(
        state.copyWith(
          status: AttendanceStatus.failure,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  // =========================================
  // ACTIVITY STREAM
  // =========================================
  void _listenActivityStream() {
    _activitySubscription?.cancel();

    _activitySubscription = _eventChannel.receiveBroadcastStream().listen((
      event,
    ) async {
      try {
        if (isClosed) return;

        if (!state.isCheckedIn) return;

        if (event == null) return;

        if (event is! Map) return;

        final engine = ProductivityEngineService();

        final int keys = event['keys'] ?? 0;

        final int clicks = event['clicks'] ?? 0;

        final int moves = event['moves'] ?? 0;

        final int idle = event['idle'] ?? 0;

        print(
          "IDLE TIME => "
          "$idle seconds",
        );

        final bool currentlyIdle = idle >= 60;

        /// =====================================
        /// TOTAL COUNTERS
        /// =====================================

        _totalKeys += keys;

        _totalClicks += clicks;

        _totalMoves += moves;

        /// =====================================
        /// PRODUCTIVITY ENGINE
        /// =====================================

        for (int i = 0; i < keys; i++) {
          engine.onKeyboardActivity();
        }

        for (int i = 0; i < clicks; i++) {
          engine.onMouseClick();
        }

        for (int i = 0; i < moves; i++) {
          engine.onMouseMove();
        }

        print(
          "ENGINE KEYS => "
          "${engine.totalKeys}",
        );

        print(
          "ENGINE CLICKS => "
          "${engine.totalClicks}",
        );

        print(
          "ENGINE MOVES => "
          "${engine.totalMoves}",
        );

        print(
          "FOCUS => "
          "${engine.focusTime}",
        );

        print(
          "IDLE => "
          "${engine.idleTime}",
        );

        /// =====================================
        /// IDLE WARNING
        /// =====================================

        if (currentlyIdle && !_isIdle) {
          print("IDLE DETECTED");

          _isIdle = true;

          _dialogShown = true;

          _trackingPaused = true;

          _showIdleWarning();
        }
        /// =====================================
        /// ACTIVE AGAIN
        /// =====================================
        else if (!currentlyIdle && _isIdle) {
          print("USER ACTIVE AGAIN");

          _isIdle = false;

          _trackingPaused = false;

          _dialogShown = false;

          _autoCheckoutTimer?.cancel();

          final context = navigatorKey.currentState?.overlay?.context;

          if (context != null && Navigator.canPop(context)) {
            Navigator.of(context, rootNavigator: true).pop();
          }
        }

        /// =====================================
        /// UPDATE UI
        /// =====================================

        emit(
          state.copyWith(
            totalKeys: engine.totalKeys,

            totalClicks: engine.totalClicks,

            totalMoves: engine.totalMoves,

            productiveHours: engine.activeSeconds / 3600,

            idleHours: engine.idleSeconds / 3600,

            productivityPercent: engine.productivity,
          ),
        );
      } catch (e) {
        debugPrint("Tracker crash => $e");
      }
    });
  } // =========================================
  // PRODUCTIVITY TIMER
  // =========================================

  // void _startProductivityTimer() {
  //   _productivityTimer?.cancel();

  //   _productivityTimer = Timer.periodic(const Duration(minutes: 1), (_) {
  //     double activityScore = 0;

  //     activityScore += (_minuteKeys * 0.02);

  //     activityScore += (_minuteClicks * 0.03);

  //     activityScore += (_minuteMoves * 0.001);

  //     activityScore -= (_minuteIdleSeconds * 0.5);

  //     activityScore = activityScore.clamp(0, 100);

  //     _smoothProductivity =
  //         (_smoothProductivity * 0.85) + (activityScore * 0.15);

  //     _smoothProductivity = _smoothProductivity.clamp(0, 100);

  //     emit(
  //       state.copyWith(
  //         productiveHours: productiveHours,
  //         idleHours: _idleSeconds / 3600,
  //         productivityPercent: _smoothProductivity,
  //         totalKeys: _totalKeys,
  //         totalClicks: _totalClicks,
  //         totalMoves: _totalMoves,
  //       ),
  //     );

  //     _saveTrackingData();

  //     _minuteKeys = 0;

  //     _minuteClicks = 0;

  //     _minuteMoves = 0;

  //     _minuteIdleSeconds = 0;
  //   });
  // }

  // =========================================
  // IDLE WARNING
  // =========================================

  void _showIdleWarning() {
    print("SHOWING IDLE WARNING DIALOG");
    final context = navigatorKey.currentState?.overlay?.context;

    if (context == null) {
      print("CONTEXT IS NULL - Cannot show dialog");
      return;
    }

    _autoCheckoutTimer?.cancel();

    print("SETTING AUTO CHECKOUT TIMER FOR 1 MINUTE");
    _autoCheckoutTimer = Timer(const Duration(minutes: 1), () {
      print("AUTO CHECKOUT TIMER FIRED");
      _performAutoCheckout();
    });

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) {
        return AlertDialog(
          title: const Text("Inactivity detected"),

          content: const Text("Are you still working?"),

          actions: [
            TextButton(
              onPressed: () {
                print("USER CLICKED CONTINUE WORKING");
                Navigator.pop(context);

                _trackingPaused = false;

                _dialogShown = false;

                _isIdle = false;

                _autoCheckoutTimer?.cancel();
              },

              child: const Text("Continue Working"),
            ),
          ],
        );
      },
    );
  }

  Future<void> _performAutoCheckout() async {
    print("PERFORMING AUTO CHECKOUT");
    await toggleAttendance(isAutoCheckout: true);
  }

  // =========================================
  // TOGGLE ATTENDANCE
  // =========================================
  Future<void> toggleAttendance({bool isAutoCheckout = false}) async {
    final currentlyCheckedIn = state.isCheckedIn;

    emit(state.copyWith(status: AttendanceStatus.loading));

    try {
      await _odooService.mobileCheckInOut(
        employeeId: _empId,
        isCheckIn: currentlyCheckedIn,
        longitude: _cachedPosition?.longitude ?? 0,
        latitude: _cachedPosition?.latitude ?? 0,
        ipAddress: _cachedIp,
      );

      final updatedState = !currentlyCheckedIn;

      /// =========================================
      /// CHECK-IN
      /// =========================================
      if (updatedState) {
        _currentCheckInTime = DateTime.now();

        _listenActivityStream();

        //  _startProductivityTimer();

        startRandomScreenshots();
        ProductivityEngineService().startTracking();

        await _methodChannel.invokeMethod('startTracking');

        AppUsageService().startTracking();

        print("TRACKING STARTED");
      }
      /// =========================================
      /// CHECK-OUT
      /// =========================================
      else {
        _isTracking = false;

        stopRandomScreenshots();
        ProductivityEngineService().stopTracking();
        ProductivityEngineService().reset();
        _productivityTimer?.cancel();

        await _activitySubscription?.cancel();

        _activitySubscription = null;

        await _methodChannel.invokeMethod('stopTracking');

        AppUsageService().stopTracking();

        print("TRACKING STOPPED");

        _saveTrackingData();

        /// =====================================
        /// SAVE FINAL SESSION HOURS
        /// =====================================

        double finalSessionHours = 0;

        if (_currentCheckInTime != null) {
          finalSessionHours =
              DateTime.now().difference(_currentCheckInTime!).inSeconds /
              3600.0;
        }

        final finalTotalHours = state.baseHours + finalSessionHours;

        /// NOW CLEAR SESSION
        _currentCheckInTime = null;

        _dialogShown = false;

        _trackingPaused = false;

        _isIdle = false;

        _autoCheckoutTimer?.cancel();

        /// DO NOT RESET IMMEDIATELY
        Future.delayed(const Duration(minutes: 5), () {
          _totalKeys = 0;
          _totalClicks = 0;
          _totalMoves = 0;
          _activeSeconds = 0;
          _idleSeconds = 0;
        });

        emit(
          state.copyWith(
            status: AttendanceStatus.success,
            isCheckedIn: false,

            /// IMPORTANT FIX
            baseHours: finalTotalHours,

            /// IMPORTANT FIX
            todayHours: _formatHours(finalTotalHours),

            productiveHours: productiveHours,

            idleHours: _idleSeconds / 3600,

            productivityPercent: _smoothProductivity,

            totalKeys: _totalKeys,

            totalClicks: _totalClicks,

            totalMoves: _totalMoves,

            successMessage: isAutoCheckout
                ? "Auto checked out"
                : "Checked out successfully",
          ),
        );

        return;
      }

      /// =========================================
      /// NORMAL STATE UPDATE
      /// =========================================

      emit(
        state.copyWith(
          status: AttendanceStatus.success,
          isCheckedIn: updatedState,
          successMessage: updatedState
              ? "Checked in successfully"
              : "Checked out successfully",
          productiveHours: updatedState
              ? productiveHours
              : state.productiveHours,
          idleHours: updatedState ? _idleSeconds / 3600 : state.idleHours,
          productivityPercent: updatedState
              ? _smoothProductivity
              : state.productivityPercent,
          totalKeys: updatedState ? _totalKeys : state.totalKeys,
          totalClicks: updatedState ? _totalClicks : state.totalClicks,
          totalMoves: updatedState ? _totalMoves : state.totalMoves,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: AttendanceStatus.failure,
          errorMessage: e.toString(),
        ),
      );
    }
  }
  // =========================================
  // SCREENSHOT MONITORING
  // =========================================

  void startRandomScreenshots() {
    if (_isTracking) {
      print("Tracking already running");

      return;
    }

    if (!state.isCheckedIn && _currentCheckInTime == null) {
      print("User not checked in -> tracking blocked");

      return;
    }

    _isTracking = true;

    _resetDailyScreenshotCount();

    print("SCREENSHOT TRACKING STARTED");

    _scheduleNextScreenshot();
  }

  void stopRandomScreenshots() {
    print("STOPPING SCREENSHOT TRACKING");

    _isTracking = false;

    _randomScreenshotTimer?.cancel();

    _randomScreenshotTimer = null;
  }

  void _scheduleNextScreenshot() {
    if (!_isTracking) {
      return;
    }

    /// CANCEL OLD TIMER
    _randomScreenshotTimer?.cancel();

    /// DAILY LIMIT
    if (_screenshotsTakenToday >= 300) {
      print("Daily screenshot limit reached");

      _isTracking = false;

      return;
    }

    /// RANDOM 15-30 SECONDS
    final randomSeconds = Random().nextInt(15) + 15;

    print(
      "Next screenshot in "
      "$randomSeconds seconds",
    );

    _randomScreenshotTimer = Timer(Duration(seconds: randomSeconds), () async {
      /// EXTRA SAFETY
      if (!_isTracking || !state.isCheckedIn || _currentCheckInTime == null) {
        print("Tracking stopped -> screenshot cancelled");

        return;
      }

      try {
        await captureAndUpload();

        _screenshotsTakenToday++;

        await _saveTrackingData();

        print(
          "Screenshots today => "
          "$_screenshotsTakenToday",
        );
      } catch (e) {
        print("Screenshot timer error => $e");
      }

      /// REPEAT AGAIN
      if (_isTracking && state.isCheckedIn) {
        _scheduleNextScreenshot();
      }
    });
  }

  // =========================================
  // ACTIVE WINDOW
  // =========================================

  String getActiveWindowTitle() {
    if (!Platform.isWindows) {
      return "";
    }

    final hwnd = GetForegroundWindow();

    final length = GetWindowTextLength(hwnd);

    final buffer = wsalloc(length + 1);

    GetWindowText(hwnd, buffer, length + 1);

    final title = buffer.toDartString();

    calloc.free(buffer);

    return title.toLowerCase();
  }

  // =========================================
  // CAPTURE LOGIC
  // =========================================

  Future<void> captureAndUpload() async {
    try {
      final title = getActiveWindowTitle();

      print("ACTIVE WINDOW => $title");

      final blockedKeywords = [
        "ftprotech",

        "bank",
        "sbi",
        "hdfc",
        "icici",
        "axis bank",
        "kotak",
        "paytm",
        "phonepe",
        "gpay",
        "google pay",
        "netbanking",
        "upi",
      ];

      final isBlocked = blockedKeywords.any((word) => title.contains(word));

      if (isBlocked) {
        print("BLOCKED WINDOW => NO SCREENSHOT");

        return;
      }

      print("TAKING SCREENSHOT...");

      final file = await ScreenshotService.captureScreen();

      if (file == null) {
        print("SCREENSHOT FAILED");

        return;
      }

      print("SCREENSHOT SAVED => ${file.path}");

      // Upload the screenshot to API
      final prefs = SharedPref();
      final employeeData = await prefs.getObject('employee_data');

      if (employeeData == null) {
        print("Employee data not found, skipping upload");
        return;
      }

      final employeeId = employeeData['id']?.toString() ?? "";
      final email =
          employeeData['work_email']?.toString() ??
          employeeData['email']?.toString() ??
          "";
      final name = employeeData['name']?.toString() ?? "";
      final enployeecode = employeeData['employee_code']?.toString() ?? "";
      FormData formData = FormData.fromMap({
        "file": await MultipartFile.fromFile(
          file.path,
          filename: file.path.split("\\").last,
        ),
        "user_id": employeeId,
        "email": email,
        "name": name,
        "employee_id": enployeecode,
      });

      final dio = Dio(
        BaseOptions(
          baseUrl: "https://suppositionless-geralyn-jovially.ngrok-free.dev",
          headers: {
            "accept": "application/json",
            "ngrok-skip-browser-warning": "true",
          },
        ),
      );

      final response = await dio.post("/api/data/upload-photo", data: formData);

      print("SCREENSHOT UPLOADED => ${response.statusCode}");
    } on DioException catch (e) {
      debugPrint("Screenshot upload DioException => ${e.message}");
      debugPrint("Response status => ${e.response?.statusCode}");
      debugPrint("Response data => ${e.response?.data}");
    } catch (e) {
      debugPrint("Screenshot error => $e");
    }
  }

  // =========================================
  // TICKER
  // =========================================
  void _startTicker() {
    _ticker?.cancel();

    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      /// WHEN CHECKED IN
      if (state.isCheckedIn && _currentCheckInTime != null) {
        final sessionHours = _calculateCurrentSessionHours();

        final totalHours = state.baseHours + sessionHours;

        final formatted = _formatHours(totalHours);

        if (formatted != state.todayHours) {
          emit(state.copyWith(todayHours: formatted));
        }
      }
      /// WHEN CHECKED OUT
      else {
        final formatted = _formatHours(state.baseHours);

        if (formatted != state.todayHours) {
          emit(state.copyWith(todayHours: formatted));
        }
      }
    });
  }

  double _calculateCurrentSessionHours() {
    if (_currentCheckInTime == null) {
      return 0.0;
    }

    final duration = DateTime.now().difference(_currentCheckInTime!);

    return duration.inSeconds / 3600.0;
  }

  String _formatHours(double hours) {
    return NumberFormat("0.00").format(hours);
  }

  double get productiveHours {
    return _activeSeconds / 3600.0;
  }

  double get productivityPercent {
    return _smoothProductivity;
  }

  void _resetDailyScreenshotCount() {
    final today = DateTime.now();
    if (_lastScreenshotDate == null ||
        today.day != _lastScreenshotDate!.day ||
        today.month != _lastScreenshotDate!.month ||
        today.year != _lastScreenshotDate!.year) {
      _screenshotsTakenToday = 0;
      _lastScreenshotDate = today;
      print("Reset daily screenshot count for new day");
    }
  }

  // =========================================
  // FETCH HOURS
  // =========================================
  Future<double> _fetchBaseHours() async {
    DateTime now = DateTime.now();

    DateTime start = DateTime(now.year, now.month, now.day);

    DateTime end = start.add(const Duration(days: 1));

    final formatter = DateFormat('yyyy-MM-dd HH:mm:ss');

    final records = await _odooService.executeModelMethod(
      'hr.attendance',
      'search_read',
      [],
      kwargs: {
        'domain': [
          ['employee_id', '=', _empId],
          ['check_in', '>=', formatter.format(start.toUtc())],
          ['check_in', '<', formatter.format(end.toUtc())],
        ],
        'fields': ['worked_hours', 'check_in', 'check_out'],
        'order': 'check_in asc',
      },
    );

    double total = 0;

    if (records != null) {
      for (final item in (records as List)) {
        final workedHours = (item['worked_hours'] ?? 0).toDouble();

        final rawCheckIn = item['check_in'];

        final rawCheckOut = item['check_out'];
        print(workedHours);

        /// =====================================
        /// SAFE PARSE CHECK-IN
        /// =====================================

        if (rawCheckIn == null || rawCheckIn == false) {
          continue;
        }

        try {
          String checkInStr = rawCheckIn.toString();

          if (!checkInStr.endsWith('Z')) {
            checkInStr = '${checkInStr.replaceAll(' ', 'T')}Z';
          }

          final checkIn = DateTime.parse(checkInStr).toLocal();

          /// =====================================
          /// ACTIVE SESSION
          /// =====================================

          if (rawCheckOut == null || rawCheckOut == false) {
            final duration = DateTime.now().difference(checkIn);

            total += duration.inSeconds / 3600.0;
          } else {
            /// If Odoo worked_hours is updated use it
            if (workedHours > 0) {
              total += workedHours;
            }
            /// Otherwise calculate manually
            else {
              String checkOutStr = rawCheckOut.toString();

              if (!checkOutStr.endsWith('Z')) {
                checkOutStr = '${checkOutStr.replaceAll(' ', 'T')}Z';
              }

              final checkOut = DateTime.parse(checkOutStr).toLocal();

              final duration = checkOut.difference(checkIn);

              total += duration.inSeconds / 3600.0;
            }
          }
        } catch (e) {
          debugPrint("Hours parse error => $e");
        }
      }
    }

    return total;
  }

  Future<String> _getIpAddress() async {
    try {
      final response = await http.get(
        Uri.parse('https://api.ipify.org?format=json'),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body)['ip'];
      }
    } catch (_) {}

    return "0.0.0.0";
  }

  Future<Position?> _getCurrentPosition() async {
    try {
      LocationPermission permission = await Geolocator.checkPermission();

      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.whileInUse ||
          permission == LocationPermission.always) {
        return await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.medium,
        );
      }
    } catch (_) {}

    return null;
  }
}
