
import 'package:hrms_desktop/features/in_out/model/all_in_out_model.dart';

class AttendanceReportState {
  final bool loading;
  final List<AllAttendanceRecord> records;
  final String error;

  const AttendanceReportState({
    this.loading = false,
    this.records = const [],
    this.error = "",
  });

  AttendanceReportState copyWith({
    bool? loading,
    List<AllAttendanceRecord>? records,
    String? error,
  }) {
    return AttendanceReportState(
      loading: loading ?? this.loading,
      records: records ?? this.records,
      error: error ?? this.error,
    );
  }
}