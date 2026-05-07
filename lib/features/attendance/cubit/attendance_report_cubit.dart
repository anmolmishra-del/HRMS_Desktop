import 'package:bloc/bloc.dart';
import 'package:flutter/foundation.dart';
import 'package:hrms_desktop/core/utils/shared_pref.dart';
import 'package:hrms_desktop/network/odoo_service.dart';
import 'package:odoo_rpc/odoo_rpc.dart';
import 'attendance_report_state.dart';

/// Cubit responsible for managing the state of the Attendance Report.
class AttendanceReportCubit extends Cubit<AttendanceReportState> {
  AttendanceReportCubit() : super(AttendanceReportState(
    // Default date range: last 7 days
    fromDate: DateTime.now().subtract(const Duration(days: 7)),
    toDate: DateTime.now(),
  ));

  /// Fetches the attendance report from the Odoo backend.
  Future<void> fetchReport() async {
    emit(state.copyWith(status: ReportStatus.loading));

    final prefs = SharedPref();
    // Retrieve session and employee data from local storage
    final sobj = await prefs.getObject('session');
    final baseUrl = await prefs.getString('baseUrl');
    final employeeData = await prefs.getObject('employee_data');

    if (sobj == null || baseUrl == null || employeeData == null) {
      emit(state.copyWith(status: ReportStatus.failure, errorMessage: "Session info missing"));
      return;
    }

    try {
      final session = OdooSession.fromJson(Map<String, dynamic>.from(sobj));
      final odooService = OdooService(baseUrl, session: session);
      
      // Extract employee ID
      final rawId = employeeData['id'];
      final int empId = rawId is int ? rawId : int.parse(rawId.toString());

      // Call the service to get the report
      final results = await odooService.getAttendanceReport(
        employeeId: empId,
        fromDate: state.fromDate,
        toDate: state.toDate,
      );

      debugPrint('AttendanceReportCubit: Raw results count=${results.length}');
      
      // Emit success state with the retrieved records
      emit(state.copyWith(
        status: ReportStatus.success,
        records: results,
      ));
      
      odooService.close();
    } catch (e) {
      debugPrint('AttendanceReportCubit Error: $e');
      emit(state.copyWith(status: ReportStatus.failure, errorMessage: e.toString()));
    }
  }

  /// Updates the date range and triggers a fresh fetch.
  void updateDateRange(DateTime from, DateTime to) {
    emit(state.copyWith(fromDate: from, toDate: to));
    fetchReport();
  }
}
