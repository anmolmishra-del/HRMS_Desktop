import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:hrms_desktop/core/services/app_usage_service.dart';
import 'package:hrms_desktop/core/services/productivity_engine_service.dart';
import 'package:hrms_desktop/core/utils/shared_pref.dart';

import 'productivity_state.dart';

class ProductivityCubit extends Cubit<ProductivityState> {
  ProductivityCubit() : super(const ProductivityState());

  Timer? _timer;

  Timer? _apiTimer;

  final Dio _dio = Dio(
    BaseOptions(
      baseUrl:
          "https://suppositionless-geralyn-jovially.ngrok-free.dev",
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

  _timer?.cancel();
  _apiTimer?.cancel();

  _timer = Timer.periodic(
    const Duration(seconds: 1),
    (_) {
      _updateState();
    },
  );

  print("STARTING API TIMER");

  _apiTimer = Timer.periodic(
    const Duration(seconds: 1), // TEMP TEST
    (_) async {
      print("CALLING PERFORMANCE API");

      await _sendPerformanceData();
    },
  );
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

  Future<void> _sendPerformanceData() async {
    try {
      final engine = ProductivityEngineService();

      final prefs = SharedPref();

      final employeeData =
          await prefs.getObject('employee_data');

      if (employeeData == null) {
        print("EMPLOYEE DATA NOT FOUND");
        return;
      }

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
  }

  @override
  Future<void> close() {
    _timer?.cancel();

    _apiTimer?.cancel();

    return super.close();
  }
}