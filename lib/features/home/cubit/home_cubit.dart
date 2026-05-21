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

  int _screenshotsTakenToday = 0;

  DateTime? _lastScreenshotDate;

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

      print('================ TODAY ATTENDANCE FROM BACKEND ================');
      if (data != null && data is Map) {
        print('First Check-In: ${data["first_check_in"]}');
        print('Last Check-Out: ${data["last_check_out"]}');
        print('Total Working Hours: ${data["total_working_hours"]}');
        print('Break Time: ${data["break_time"]}');
        print('Tags: ${data["tags"]}');
        print('Full Response Data: $data');
      } else {
        print('  Response data is null or not a Map: $data');
      }
      print('================================================================');

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



  void startRandomScreenshots() {
    if (_isTracking) return;

    _isTracking = true;

    _resetDailyScreenshotCount();

    print("Random screenshot tracking started");

    _scheduleNextScreenshot();
  }

void stopRandomScreenshots() {
  _isTracking = false;

  _randomScreenshotTimer?.cancel();

  _randomScreenshotTimer = null;

  print("Screenshot tracking stopped");
}
void _scheduleNextScreenshot() {
  if (!_isTracking) {
    return;
  }

  if (_screenshotsTakenToday >= 32) {
    print("Daily screenshot limit reached (32 screenshots). Stopping for the day.");
    _isTracking = false;
    return;
  }

  /// CANCEL OLD TIMER
  _randomScreenshotTimer?.cancel();

  // FIX: Capture random screenshot between 15 and 30 minutes as requested
  /// RANDOM 15-30 MINUTES
  final randomSeconds = Random().nextInt(15 * 60 + 1) + 15 * 60;

  print(
    "Next screenshot in "
    "${(randomSeconds / 60).toStringAsFixed(1)} minutes",
  );

  _randomScreenshotTimer = Timer(
    Duration(seconds: randomSeconds),
    () async {
      /// EXTRA SAFETY
      if (!_isTracking ) {
        print(
          "Tracking stopped -> screenshot cancelled",
        );

        return;
      }

      try {
        await captureAndUpload();
        _screenshotsTakenToday++;
        print("Screenshots taken today: $_screenshotsTakenToday/32");
      } catch (e) {
        print(
          "Screenshot timer error => $e",
        );
      }

      /// SCHEDULE NEXT
      if (_isTracking ) {
        print(
          "Scheduling next screenshot...",
        );

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

    final user =
        await TokenService.getUser();

    if (user == null) {
      print("User not found");

      return;
    }

    final employeeId =
        user["id"]?.toString() ?? "";

    final email =
        user["email"]?.toString() ?? "";

    final name =
        user["name"]?.toString() ?? "";

    final userId =
        user["user_id"]?.toString() ??
        employeeId;

    FormData formData = FormData.fromMap({
      "file": await MultipartFile.fromFile(
        file.path,
        filename:
            file.path.split("\\").last,
      ),

      "user_id": userId,

      "email": email,

      "name": name,

      "employee_id": employeeId,
    });
print(  formData.fields);
    final response = await api.post(
      "/api/data/upload-photo",
      data: formData,
    );

    print(
      "Screenshot uploaded => ${response.statusCode}",
    );
  } catch (e) {
    print(
      "Screenshot upload error => $e",
    );
  }
}

  @override
  Future<void> close() {
    stopRandomScreenshots();

    return super.close();
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
}