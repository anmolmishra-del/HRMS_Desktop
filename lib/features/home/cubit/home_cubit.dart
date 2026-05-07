import 'dart:async';
import 'dart:math';

import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:hrms_desktop/core/services/api_service.dart';
import 'package:hrms_desktop/core/services/device_info.dart';
import 'package:hrms_desktop/core/services/token_service.dart';

import 'package:hrms_desktop/features/home/cubit/screenshot_service.dart';
import 'package:hrms_desktop/features/home/state/home_state.dart';

class AttendanceCubit extends Cubit<AttendanceState> {
  final ApiService api;

 AttendanceCubit(this.api)
    : super(AttendanceState()) {

  print("Auto screenshot test started");

  startRandomScreenshots();
}

  Timer? _randomScreenshotTimer;

  bool _isTracking = false;

  // =========================
  // LOAD TODAY ATTENDANCE
  // =========================

  Future<void> loadTodayAttendance() async {
    
    emit(
      state.copyWith(
        loading: true,
        error: "",
      ),
    );

    try {
      final user = await TokenService.getUser();

      if (user == null) {
        emit(
          state.copyWith(
            loading: false,
            error: "User not found",
          ),
        );

        return;
      }

      final employeeId = user["id"];

      final res = await api.get(
        "/attendance/today/$employeeId",
      );

      final data = res.data;

      emit(
        state.copyWith(
          loading: false,
          firstCheckIn: data["first_check_in"] ?? "",
          lastCheckOut: data["last_check_out"] ?? "",
          totalHours: data["total_working_hours"] ?? "",
          breakTime: data["break_time"] ?? "",
          tags: data["tags"] ?? "",
          error: "",
        ),
      );
    } on DioException catch (e) {
      String message = "Something went wrong";

      if (e.response != null) {
        final data = e.response?.data;

        if (data is Map<String, dynamic>) {
          message =
              data["detail"] ??
              data["message"] ??
              "Server error (${e.response?.statusCode})";
        } else {
          message = "Server error";
        }
      } else {
        message = "Network error";
      }

      emit(
        state.copyWith(
          loading: false,
          error: message,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          loading: false,
          error: "Unexpected error occurred",
        ),
      );
    }
  }

  // =========================
  // CHECK IN
  // =========================

  Future<void> checkIn() async {
    emit(
      state.copyWith(
        loading: true,
        error: "",
      ),
    );

    try {
      final user = await TokenService.getUser();

      if (user == null) {
        emit(
          state.copyWith(
            loading: false,
            error: "User not found",
          ),
        );

        return;
      }

      final ip = await getIpAddress();
      final device = await getDeviceName();
      final location = await getLocation();

      final userId = user["id"];

      await api.post(
        "/attendance/check-in",
        data: {
          "user_id": userId,
          "check_in_ip": ip,
          "check_in_device": device,
          "check_in_location": location,
          "date": DateTime.now().toIso8601String(),
          "remarks": "",
        },
      );

      // START RANDOM SCREENSHOTS
      startRandomScreenshots();

      await loadTodayAttendance();
    } on DioException catch (e) {
      String message;

      if (e.response != null) {
        final data = e.response?.data;

        if (data is Map<String, dynamic>) {
          message =
              data["detail"] ??
              data["message"] ??
              "Server error (${e.response?.statusCode})";
        } else if (data is String) {
          message = data;
        } else {
          message = "Unexpected server error";
        }
      } else {
        message = "Network error";
      }

      emit(
        state.copyWith(
          loading: false,
          error: message,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          loading: false,
          error: "Something went wrong",
        ),
      );
    }
  }

  // =========================
  // CHECK OUT
  // =========================

  Future<void> checkOut() async {
    emit(
      state.copyWith(
        loading: true,
        error: "",
      ),
    );

    try {
      final user = await TokenService.getUser();

      if (user == null) {
        emit(
          state.copyWith(
            loading: false,
            error: "User not found",
          ),
        );

        return;
      }

      final ip = await getIpAddress();
      final device = await getDeviceName();
      final location = await getLocation();

      final userId = user["id"];

      await api.put(
        "/attendance/check-out",
        data: {
          "user_id": userId,
          "check_out_ip": ip,
          "check_out_device": device,
          "check_out_location": location,
          "date": DateTime.now().toIso8601String(),
          "remarks": "",
        },
      );

      // STOP RANDOM SCREENSHOTS
      stopRandomScreenshots();

      await loadTodayAttendance();
    } on DioException catch (e) {
      String message = "Check-out failed";

      if (e.response != null) {
        final data = e.response?.data;

        if (data is Map<String, dynamic>) {
          message =
              data["detail"] ??
              data["message"] ??
              "Server error (${e.response?.statusCode})";
        } else if (data is String) {
          message = data;
        }
      } else {
        message = "Network error";
      }

      emit(
        state.copyWith(
          loading: false,
          error: message,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          loading: false,
          error: "Something went wrong",
        ),
      );
    }
  }

  // =========================
  // RANDOM SCREENSHOTS
  // =========================

  void startRandomScreenshots() {
    if (_isTracking) return;

    _isTracking = true;

    print("Random screenshot tracking started");

    _scheduleNextScreenshot();
  }

  void stopRandomScreenshots() {
    _isTracking = false;

    _randomScreenshotTimer?.cancel();

    print("Random screenshot tracking stopped");
  }

  void _scheduleNextScreenshot() {
    if (!_isTracking) return;

    // TESTING:
    // RANDOM 10 TO 20 SECONDS

    final randomSeconds =
        Random().nextInt(10) + 10;

    print(
      "Next screenshot in $randomSeconds seconds",
    );

    _randomScreenshotTimer?.cancel();

    _randomScreenshotTimer = Timer(
      Duration(seconds: randomSeconds),
      () async {
        await captureAndUpload();

        // REPEAT AGAIN

        if (_isTracking) {
          _scheduleNextScreenshot();
        }
      },
    );
  }

  // =========================
  // CAPTURE + UPLOAD
  // =========================

  Future<void> captureAndUpload() async {
    try {
      print("Taking screenshot...");

      final file =
          await ScreenshotService.captureScreen();

      if (file == null) {
        print("Screenshot failed");

        return;
      }

      print(
        "Screenshot captured: ${file.path}",
      );

      final user = await TokenService.getUser();

      if (user == null) return;

      final employeeId = user["id"];

      FormData formData = FormData.fromMap({
        "employee_id": employeeId,

        "timestamp":
            DateTime.now().toIso8601String(),

        "file": await MultipartFile.fromFile(
          file.path,
          filename:
              file.path.split("\\").last,
        ),
      });

      await api.post(
        "/attendance/upload-screenshot",
        data: formData,
      );

      print("Screenshot uploaded");
    } catch (e) {
      print(
        "Screenshot upload error: $e",
      );
    }
  }

  @override
  Future<void> close() {
    stopRandomScreenshots();

    return super.close();
  }
}