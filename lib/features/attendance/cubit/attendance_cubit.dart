import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:ffi/ffi.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:geolocator/geolocator.dart';
import 'package:hrms_desktop/core/services/app_usage_service.dart';
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

    _isInitialized = true;
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
      }

      final baseHours = await _fetchBaseHours();

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

        final int keys = event['keys'] ?? 0;

        final int clicks = event['clicks'] ?? 0;

        final int moves = event['moves'] ?? 0;

        final int idle = event['idle'] ?? 0;

        final bool currentlyIdle = idle >= 60;

        _totalKeys += keys;

        _totalClicks += clicks;

        _totalMoves += moves;

        _minuteKeys += keys;

        _minuteClicks += clicks;

        _minuteMoves += moves;

        print("TOTAL KEYS => $_totalKeys");

        print("TOTAL CLICKS => $_totalClicks");

        print("TOTAL MOVES => $_totalMoves");

        if (currentlyIdle) {
          _idleSeconds++;

          _minuteIdleSeconds++;
        } else {
          _activeSeconds++;
        }

        // =========================================
        // IDLE DETECTION
        // =========================================

        if (currentlyIdle && !_isIdle) {
          _isIdle = true;

          _dialogShown = true;

          _trackingPaused = true;

          _showIdleWarning();
        }
        // =========================================
        // USER ACTIVE AGAIN
        // =========================================
        else if (!currentlyIdle && _isIdle) {
          _isIdle = false;

          _trackingPaused = false;

          _dialogShown = false;

          _autoCheckoutTimer?.cancel();

          final context = navigatorKey.currentState?.overlay?.context;

          if (context != null && Navigator.canPop(context)) {
            Navigator.of(context, rootNavigator: true).pop();
          }
        }

        emit(
          state.copyWith(
            totalKeys: _totalKeys,
            totalClicks: _totalClicks,
            totalMoves: _totalMoves,
            idleHours: _idleSeconds / 3600,
            productiveHours: productiveHours,
          ),
        );
      } catch (e) {
        debugPrint("Tracker crash => $e");
      }
    });
  }

  // =========================================
  // PRODUCTIVITY TIMER
  // =========================================

  void _startProductivityTimer() {
    _productivityTimer?.cancel();

    _productivityTimer = Timer.periodic(const Duration(minutes: 1), (_) {
      double activityScore = 0;

      activityScore += (_minuteKeys * 0.02);

      activityScore += (_minuteClicks * 0.03);

      activityScore += (_minuteMoves * 0.001);

      activityScore -= (_minuteIdleSeconds * 0.5);

      activityScore = activityScore.clamp(0, 100);

      _smoothProductivity =
          (_smoothProductivity * 0.85) + (activityScore * 0.15);

      _smoothProductivity = _smoothProductivity.clamp(0, 100);

      emit(
        state.copyWith(
          productiveHours: productiveHours,
          idleHours: _idleSeconds / 3600,
          productivityPercent: _smoothProductivity,
          totalKeys: _totalKeys,
          totalClicks: _totalClicks,
          totalMoves: _totalMoves,
        ),
      );

      _minuteKeys = 0;

      _minuteClicks = 0;

      _minuteMoves = 0;

      _minuteIdleSeconds = 0;
    });
  }

  // =========================================
  // IDLE WARNING
  // =========================================

  void _showIdleWarning() {
    final context = navigatorKey.currentState?.overlay?.context;

    if (context == null) {
      return;
    }

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

          content: const Text("Are you still working?"),

          actions: [
            TextButton(
              onPressed: () {
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

      if (updatedState) {
        _currentCheckInTime = DateTime.now();

        _listenActivityStream();

        _startProductivityTimer();

        startRandomScreenshots();

        await _methodChannel.invokeMethod('startTracking');
        AppUsageService().startTracking();
        print("TRACKING STARTED");
      } else {
        stopRandomScreenshots();

        _productivityTimer?.cancel();

        await _activitySubscription?.cancel();

        _activitySubscription = null;

        await _methodChannel.invokeMethod('stopTracking');
        AppUsageService().stopTracking();
        print("TRACKING STOPPED");

        _currentCheckInTime = null;

        _dialogShown = false;

        _trackingPaused = false;

        _isIdle = false;

        _totalKeys = 0;

        _totalClicks = 0;

        _totalMoves = 0;

        _activeSeconds = 0;

        _idleSeconds = 0;

        _autoCheckoutTimer?.cancel();
      }

      emit(
        state.copyWith(
          status: AttendanceStatus.success,
          isCheckedIn: updatedState,
          successMessage: isAutoCheckout
              ? "Auto checked out"
              : updatedState
              ? "Checked in successfully"
              : "Checked out successfully",
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
      return;
    }

    _isTracking = true;

    _scheduleNextScreenshot();
  }

  void stopRandomScreenshots() {
    _isTracking = false;

    _randomScreenshotTimer?.cancel();
  }

  void _scheduleNextScreenshot() {
    if (!_isTracking) {
      return;
    }

    final randomSeconds = Random().nextInt(10) + 10;

    _randomScreenshotTimer = Timer(Duration(seconds: randomSeconds), () async {
      await captureAndUpload();

      if (_isTracking) {
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
      final totalHours = state.baseHours + _calculateCurrentSessionHours();

      final formatted = _formatHours(totalHours);

      if (formatted == state.todayHours) {
        return;
      }

      emit(state.copyWith(todayHours: formatted));
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
          ['check_out', '!=', false],
        ],
        'fields': ['worked_hours'],
      },
    );

    double total = 0;

    if (records != null) {
      for (var item in (records as List)) {
        total += (item['worked_hours'] ?? 0.0).toDouble();
      }
    }

    return total;
  }

  // =========================================
  // IP ADDRESS
  // =========================================

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

  // =========================================
  // LOCATION
  // =========================================

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
