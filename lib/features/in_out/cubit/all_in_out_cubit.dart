
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

      print('================ ALL IN-OUT RECORDS FROM BACKEND ================');
      print('Raw Response List count: ${list.length}');
      for (var record in list) {
        print('Record => Check-In: ${record['check_in']}, Check-Out: ${record['check_out']}, Worked Hours: ${record['worked_hours']}, Total Hours: ${record['total_hours']}, Date: ${record['date']}');
      }
      print('=================================================================');

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