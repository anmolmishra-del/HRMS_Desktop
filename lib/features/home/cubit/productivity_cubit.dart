import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:hrms_desktop/core/services/app_usage_service.dart';
import 'package:hrms_desktop/core/services/productivity_engine_service.dart';
import 'package:hrms_desktop/core/utils/shared_pref.dart';

import 'productivity_state.dart';

class ProductivityCubit extends Cubit<ProductivityState> {
  // FIX: Converted to singleton so its state can be updated instantly from AttendanceCubit on Check-in/out
  static final ProductivityCubit _instance = ProductivityCubit._internal();

  factory ProductivityCubit() => _instance;

  ProductivityCubit._internal() : super(const ProductivityState());

  Timer? _timer;

  Timer? _apiTimer;

  final Dio _dio = Dio(
    BaseOptions(
      baseUrl:
          "https://124.123.30.75:8001",
      headers: {
        "accept": "application/json",
        "Content-Type": "application/json",
        "ngrok-skip-browser-warning": "true",
      },
    ),
  );

  /// =====================================
  /// START LIVE TRACKING
  /// =====================================
Future<void> startTracking() async {
  print("PRODUCTIVITY TRACKING STARTED");

  final engine = ProductivityEngineService();

  await engine.startTracking();
  await AppUsageService().startTracking();

  _timer?.cancel();
  _apiTimer?.cancel();

  // FIX: Immediately update state after loading data rather than waiting 1s for the periodic timer
  _updateState();

  _timer = Timer.periodic(
    const Duration(seconds: 1),
    (_) {
      _updateState();
    },
  );

  print("STARTING API TIMER");

  // FIX: Sync performance/productivity data every 15 minutes as requested
  _apiTimer = Timer.periodic(
    const Duration(minutes: 15),
    (_) async {
      await sendPerformanceData();
    },
  );
}

  // FIX: Force immediate UI state update without waiting for the 1-second periodic timer
  void updateStateImmediately() {
    _updateState();
  }
  /// =====================================
  /// UPDATE UI
  /// =====================================

  void _updateState() {
    final engine = ProductivityEngineService();

    final appUsage = AppUsageService().getTopApps();

    emit(
      state.copyWith(
        productivityPercent: engine.productivity,
        focusTime: engine.focusTime,
        idleTime: engine.idleTime,
        totalKeys: engine.totalKeys,
        totalClicks: engine.totalClicks,
        totalMoves: engine.totalMoves,
        appUsage: appUsage,
      ),
    );
  }

  /// =====================================
  /// SEND API
  /// =====================================

  Future<void> sendPerformanceData() async {
    try {
      final engine = ProductivityEngineService();

      final prefs = SharedPref();

      final isLoggedIn = await prefs.getBool('is_logged_in') ?? false;
      final employeeData = await prefs.getObject('employee_data');

      if (!isLoggedIn || employeeData == null) {
        return;
      }

      print("CALLING PERFORMANCE API");

      final userId = employeeData['id'] ?? 0;

      final body = {
        "user_id": userId,

        "performance_percentage":
            engine.productivity,

"idle_time_seconds":
    int.tryParse(
      engine.idleTime.replaceAll('m', '').trim(),
    ) ?? 0,

"focus_time_seconds":
    int.tryParse(
      engine.focusTime.replaceAll('m', '').trim(),
    ) ?? 0,

        "recorded_at":
            DateTime.now().toUtc().toIso8601String(),
      };

      print("PERFORMANCE API BODY => $body");

      final response = await _dio.post(
        "/api/data/performance",
        data: body,
      );

      print(
        "PERFORMANCE API SUCCESS => "
        "${response.statusCode}",
      );
    } catch (e) {
      print("PERFORMANCE API ERROR => $e");
    }
  }

  /// =====================================
  /// STOP
  /// =====================================

  void stopTracking() {
    _timer?.cancel();
    _apiTimer?.cancel();
    ProductivityEngineService().stopTracking();
    AppUsageService().stopTracking();
  }

  @override
  Future<void> close() {
    stopTracking();
    return super.close();
  }
}