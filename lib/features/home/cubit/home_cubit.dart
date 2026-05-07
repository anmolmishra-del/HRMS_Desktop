import 'package:dio/dio.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hrms_desktop/core/services/api_service.dart';
import 'package:hrms_desktop/core/services/device_info.dart';
import 'package:hrms_desktop/core/services/token_service.dart';
import 'package:hrms_desktop/features/home/state/home_state.dart';

class AttendanceCubit extends Cubit<AttendanceState> {
  final ApiService api;

  AttendanceCubit(this.api) : super(AttendanceState());

  Future<void> loadTodayAttendance() async {
    emit(state.copyWith(loading: true, error: ""));

    try {
      final user = await TokenService.getUser();

      if (user == null) {
        emit(state.copyWith(loading: false, error: "User not found"));
        return;
      }

      final employeeId = user["id"];

      final res = await api.get("/attendance/today/$employeeId");

      final data = res.data;

      emit(
        state.copyWith(
          loading: false,
          firstCheckIn: data["first_check_in"] ?? "",
          lastCheckOut: data["last_check_out"] ?? "",
          totalHours: data["total_working_hours"] ?? "",
          error: "",
          breakTime:data["break_time"]??"",

          tags:data["tags"]??"",

        ),
      );
    } on DioException catch (e) {
      String message = "Something went wrong";

      if (e.response != null) {
        message =
            e.response?.data["detail"] ??
            e.response?.data["message"] ??
            "Server error (${e.response?.statusCode})";
      } else {
        message = "Network error. Check internet";
      }

      emit(state.copyWith(loading: false, error: message));
    } catch (e) {
      emit(state.copyWith(loading: false, error: "Unexpected error occurred"));
    }
  }

  Future<void> checkIn() async {
    emit(state.copyWith(loading: true, error: ""));

    try {
      final user = await TokenService.getUser();

      if (user == null) {
        emit(state.copyWith(loading: false, error: "User not found"));
        return;
      }
  final ip = await getIpAddress();
    final device = await getDeviceName();
    final location = await getLocation();
      final userId = user["id"];

      final res = await api.post(
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
    message = data; // ✅ direct string response
  } else {
    message = "Unexpected server error";
  }
} else {
  message = "Network error";
}

      emit(state.copyWith(loading: false, error: message));
    } catch (e) {
      emit(state.copyWith(loading: false, error: "Something went wrong"));
    }
  }

  Future<void> checkOut() async {
    emit(state.copyWith(loading: true, error: ""));

    try {
      final user = await TokenService.getUser();

      if (user == null) {
        emit(state.copyWith(loading: false, error: "User not found"));
        return;
      } final ip = await getIpAddress();
    final device = await getDeviceName();
    final location = await getLocation();

      final userId = user["id"];

      final res = await api.put(
        "/attendance/check-out",
        data: {
          "user_id": userId,
          "check_out_ip": ip,
          "check_out_device": device,
          "check_out_location": location,
          "date": DateTime.now().toIso8601String(),
          "remarks": "string",
        },
      );

      await loadTodayAttendance();
    } on DioException catch (e) {
      String message = "Check-in failed";

      if (e.response != null) {
        message =
            e.response?.data["detail"] ??
            e.response?.data["message"] ??
            "Server error (${e.response?.statusCode})";
      } else {
        message = "Network error";
      }

      emit(state.copyWith(loading: false, error: message));
    } catch (e) {
      emit(state.copyWith(loading: false, error: "Something went wrong"));
    }
  }
}
