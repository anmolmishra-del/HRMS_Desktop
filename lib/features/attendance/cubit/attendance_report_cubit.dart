// import 'package:bloc/bloc.dart';
// import 'package:flutter/foundation.dart';
// import 'package:hrms_desktop/core/utils/shared_pref.dart';
// import 'package:hrms_desktop/network/odoo_service.dart';
// import 'package:hrms_desktop/core/services/api_service.dart';
// import 'package:odoo_rpc/odoo_rpc.dart';
// import 'attendance_report_state.dart';

// /// Cubit responsible for managing the state of the Attendance Report.
// class AttendanceReportCubit extends Cubit<AttendanceReportState> {
//   AttendanceReportCubit() : super(AttendanceReportState(
//     // Default date range: last 7 days
//     fromDate: DateTime.now().subtract(const Duration(days: 7)),
//     toDate: DateTime.now(),
//   ));

//   /// Fetches the attendance report from the Odoo backend.
//   Future<void> fetchReport() async {
//     emit(state.copyWith(status: ReportStatus.loading));

//     final prefs = SharedPref();
//     // Retrieve session and employee data from local storage
//     final sobj = await prefs.getObject('session');
//     final baseUrl = await prefs.getString('baseUrl');
//     final employeeData = await prefs.getObject('employee_data');

//     if (sobj == null || baseUrl == null || employeeData == null) {
//       emit(state.copyWith(status: ReportStatus.failure, errorMessage: "Session info missing"));
//       return;
//     }

//     try {
//       final session = OdooSession.fromJson(Map<String, dynamic>.from(sobj));
//       final odooService = OdooService(baseUrl, session: session);
      
//       // Extract employee ID
//       final rawId = employeeData['id'];
//       final int empId = rawId is int ? rawId : int.parse(rawId.toString());

//       // Call the service to get the report
//       final results = await odooService.getAttendanceReport(
//         employeeId: empId,
//         fromDate: state.fromDate,
//         toDate: state.toDate,
//       );

//       debugPrint('AttendanceReportCubit: Raw results count=${results.length}');
//       debugPrint('================ ATTENDANCE REPORT RECORDS FROM ODOO ================');
//       for (var record in results) {
//         debugPrint('Record ID: ${record['id']}');
//         debugPrint('  Check-In: ${record['check_in']}');
//         debugPrint('  Check-Out: ${record['check_out']}');
//         debugPrint('  Worked Hours: ${record['worked_hours']}');
//         debugPrint('  Overtime Hours: ${record['overtime_hours']}');
//         debugPrint('  Validated Overtime Hours: ${record['validated_overtime_hours']}');
//       }
//           debugPrint('=====================================================================');
      
//       // Fetch dynamic weekly productivity trend only if it hasn't been loaded yet
//       Map<String, double> weeklyProd = Map<String, double>.from(state.weeklyProductivity);
//       if (weeklyProd.isEmpty) {
//         try {
//           final apiService = ApiService();
//           final prodResponse = await apiService.get('/api/data/performance/average/$empId');
//           if (prodResponse.data != null && prodResponse.data is Map) {
//             final Map rawMap = prodResponse.data;
//             weeklyProd = rawMap.map(
//               (key, value) => MapEntry(key.toString(), (value as num).toDouble()),
//             );
//           }
//           debugPrint('AttendanceReportCubit: Weekly productivity trend map fetched: $weeklyProd');
//         } catch (prodError) {
//           debugPrint('AttendanceReportCubit: Failed to fetch weekly productivity average: $prodError');
//         }
//       } else {
//         debugPrint('AttendanceReportCubit: Reusing cached weekly productivity trend: $weeklyProd');
//       }

//       // Emit success state with the retrieved records and productivity map
//       emit(state.copyWith(
//         status: ReportStatus.success,
//         records: results,
//         weeklyProductivity: weeklyProd,
//       ));
      
//       odooService.close();
//     } catch (e) {
//       debugPrint('AttendanceReportCubit Error: $e');
//       emit(state.copyWith(status: ReportStatus.failure, errorMessage: e.toString()));
//     }
//   }

//   /// Updates the date range and triggers a fresh fetch.
//   void updateDateRange(DateTime from, DateTime to) {
//     emit(state.copyWith(fromDate: from, toDate: to));
//     fetchReport();
//   }
// }



import 'package:bloc/bloc.dart';
import 'package:flutter/foundation.dart';
import 'package:hrms_desktop/core/utils/shared_pref.dart';
import 'package:hrms_desktop/network/odoo_service.dart';
import 'package:hrms_desktop/core/services/api_service.dart';
import 'package:odoo_rpc/odoo_rpc.dart';
import 'attendance_report_state.dart';

class AttendanceReportCubit extends Cubit<AttendanceReportState> {
  AttendanceReportCubit()
      : super(
          AttendanceReportState(
            fromDate: DateTime.now().subtract(
              const Duration(days: 7),
            ),
            toDate: DateTime.now(),
          ),
        );

  /// Safe emit to avoid
  /// "Cannot emit new states after calling close"
  void safeEmit(AttendanceReportState newState) {
    if (!isClosed) {
      emit(newState);
    }
  }

  Future<void> fetchReport() async {
    if (isClosed) return;

    safeEmit(
      state.copyWith(
        status: ReportStatus.loading,
      ),
    );

    final prefs = SharedPref();

    final sobj = await prefs.getObject('session');
    final baseUrl = await prefs.getString('baseUrl');
    final employeeData = await prefs.getObject('employee_data');

    if (isClosed) return;

    if (sobj == null || baseUrl == null || employeeData == null) {
      safeEmit(
        state.copyWith(
          status: ReportStatus.failure,
          errorMessage: "Session info missing",
        ),
      );
      return;
    }

    OdooService? odooService;

    try {
      final session =
          OdooSession.fromJson(Map<String, dynamic>.from(sobj));

      odooService = OdooService(
        baseUrl,
        session: session,
      );

      final rawId = employeeData['id'];

      final int empId =
          rawId is int ? rawId : int.parse(rawId.toString());

      final results = await odooService.getAttendanceReport(
        employeeId: empId,
        fromDate: state.fromDate,
        toDate: state.toDate,
      );

      if (isClosed) return;

      debugPrint(
        'AttendanceReportCubit: Raw results count=${results.length}',
      );

      debugPrint(
        '================ ATTENDANCE REPORT RECORDS FROM ODOO ================',
      );

      for (var record in results) {
        debugPrint('Record ID: ${record['id']}');
        debugPrint('  Check-In: ${record['check_in']}');
        debugPrint('  Check-Out: ${record['check_out']}');
        debugPrint('  Worked Hours: ${record['worked_hours']}');
        debugPrint('  Overtime Hours: ${record['overtime_hours']}');
        debugPrint(
          '  Validated Overtime Hours: ${record['validated_overtime_hours']}',
        );
      }

      debugPrint(
        '=====================================================================',
      );

      Map<String, double> weeklyProd =
          Map<String, double>.from(state.weeklyProductivity);

      if (weeklyProd.isEmpty) {
        try {
          final apiService = ApiService();

          final prodResponse = await apiService.get(
            '/api/data/performance/average/$empId',
          );

          if (isClosed) return;

          if (prodResponse.data != null &&
              prodResponse.data is Map) {
            final Map rawMap = prodResponse.data;

            weeklyProd = rawMap.map(
              (key, value) => MapEntry(
                key.toString(),
                (value as num).toDouble(),
              ),
            );
          }

          debugPrint(
            'AttendanceReportCubit: Weekly productivity trend map fetched: $weeklyProd',
          );
        } catch (prodError) {
          debugPrint(
            'AttendanceReportCubit: Failed to fetch productivity average: $prodError',
          );
        }
      } else {
        debugPrint(
          'AttendanceReportCubit: Reusing cached productivity trend: $weeklyProd',
        );
      }

      if (isClosed) return;

      safeEmit(
        state.copyWith(
          status: ReportStatus.success,
          records: results,
          weeklyProductivity: weeklyProd,
        ),
      );
    } catch (e, stackTrace) {
      debugPrint(
        'AttendanceReportCubit Error: $e',
      );
      debugPrint(
        'StackTrace: $stackTrace',
      );

      if (isClosed) return;

      safeEmit(
        state.copyWith(
          status: ReportStatus.failure,
          errorMessage: e.toString(),
        ),
      );
    } finally {
      odooService?.close();
    }
  }

  Future<void> updateDateRange(
    DateTime from,
    DateTime to,
  ) async {
    if (isClosed) return;

    safeEmit(
      state.copyWith(
        fromDate: from,
        toDate: to,
      ),
    );

    await fetchReport();
  }
}