import 'package:equatable/equatable.dart';

/// Enum to track the status of the report fetching process.
enum ReportStatus { initial, loading, success, failure }

/// State class for the Attendance Report.
class AttendanceReportState extends Equatable {
  final ReportStatus status;
  final DateTime fromDate;
  final DateTime toDate;
  final List<dynamic> records; // List of attendance records fetched from Odoo
  final String? errorMessage;

  const AttendanceReportState({
    this.status = ReportStatus.initial,
    required this.fromDate,
    required this.toDate,
    this.records = const [],
    this.errorMessage,
  });

  /// Helper method to create a new state with updated fields.
  AttendanceReportState copyWith({
    ReportStatus? status,
    DateTime? fromDate,
    DateTime? toDate,
    List<dynamic>? records,
    String? errorMessage,
  }) {
    return AttendanceReportState(
      status: status ?? this.status,
      fromDate: fromDate ?? this.fromDate,
      toDate: toDate ?? this.toDate,
      records: records ?? this.records,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, fromDate, toDate, records, errorMessage];
}
