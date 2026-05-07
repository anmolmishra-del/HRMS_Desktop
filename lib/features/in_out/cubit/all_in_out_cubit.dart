
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hrms_desktop/core/services/api_service.dart';
import 'package:hrms_desktop/features/in_out/model/all_in_out_model.dart';
import 'package:hrms_desktop/features/in_out/model/all_in_out_state.dart';

class AttendanceReportCubit extends Cubit<AttendanceReportState> {
  final ApiService api;

  AttendanceReportCubit(this.api) : super(const AttendanceReportState());

  Future<void> fetchRecords(int userId) async {
    emit(state.copyWith(loading: true, error: ""));

    try {
      final res = await api.get("/attendance/records/$userId");

      final List list = res.data["records"];

      final records =
          list.map((e) => AllAttendanceRecord.fromJson(e)).toList();

      emit(state.copyWith(loading: false, records: records));
    } catch (e) {
      emit(state.copyWith(
        loading: false,
        error: "Failed to load attendance",
      ));
    }
  }
}