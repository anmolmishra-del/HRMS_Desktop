import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hrms_desktop/core/utils/shared_pref.dart';
import 'package:hrms_desktop/features/leave/cubit/leave_state.dart';
import 'package:hrms_desktop/features/leave/models/leave_model.dart';
import 'package:hrms_desktop/features/leave/models/leave_type_model.dart';
import 'package:hrms_desktop/network/odoo_service.dart';

import 'package:odoo_rpc/odoo_rpc.dart';

class LeaveCubit extends Cubit<LeaveState> {
  LeaveCubit() : super(const LeaveState());

  Future<void> fetchLeavesAndTypes() async {
    if (isClosed) return;
    emit(state.copyWith(status: LeaveStatus.loading));
    final prefs = SharedPref();
    final baseUrl = await prefs.getString('baseUrl');
    final employeeData = await prefs.getObject('employee_data');
    final sessionObj = await prefs.getObject('session');

    if (baseUrl == null || employeeData == null || sessionObj == null) {
      if (!isClosed) emit(state.copyWith(status: LeaveStatus.failure, errorMessage: "Session expired"));
      return;
    }

    final session = OdooSession.fromJson(sessionObj);
    final employeeId = int.tryParse(employeeData['id']?.toString() ?? '0') ?? 0;
    final odooService = OdooService(baseUrl, session: session);

    try {
      final results = await Future.wait([
        odooService.fetchMyLeaves(employeeId),
        odooService.fetchLeaveTypes(employeeId: employeeId),
      ]);
// ...

      final leaves = (results[0] as List).map((l) => LeaveRequest.fromJson(l)).toList();
      final types = (results[1] as List).map((t) => LeaveType.fromJson(t)).toList();

      if (!isClosed) {
        emit(state.copyWith(
          status: LeaveStatus.success,
          leaves: leaves,
          leaveTypes: types,
        ));
      }
    } catch (e, stackTrace) {
      debugPrint('LeaveCubit ERROR: $e');
      if (!isClosed) {
        emit(state.copyWith(
          status: LeaveStatus.failure,
          errorMessage: _getErrorMessage(e),
        ));
      }
    } finally {
      odooService.close();
    }
  }

  Future<void> applyLeave(Map<String, dynamic> data) async {
    if (isClosed) return;
    emit(state.copyWith(status: LeaveStatus.submitting));
    final prefs = SharedPref();
    final baseUrl = await prefs.getString('baseUrl');
    final sessionObj = await prefs.getObject('session');
    
    if (baseUrl == null || sessionObj == null) {
      if (!isClosed) emit(state.copyWith(status: LeaveStatus.failure, errorMessage: "Session expired"));
      return;
    } 

    final session = OdooSession.fromJson(sessionObj);
    final odooService = OdooService(baseUrl, session: session);

    try {
      final leaveId = await odooService.createLeaveRequest(data);
      if (leaveId > 0) {
        await odooService.executeLeaveAction(leaveId, 'action_draft');
        
        if (!isClosed) {
          emit(state.copyWith(
            status: LeaveStatus.submitted,
            successMessage: "Leave request submitted successfully",
          ));
        }
        
        await fetchLeavesAndTypes();
      } else {
        throw Exception("Failed to create leave request");
      }
    } catch (e, stackTrace) {
      debugPrint('LeaveCubit ERROR: $e');
      if (!isClosed) {
        emit(state.copyWith(
          status: LeaveStatus.failure,
          errorMessage: _getErrorMessage(e),
        ));
      }
    } finally {
      odooService.close();
    }
  }

  Future<void> cancelLeave(int leaveId) async {
    if (isClosed) return;
    final prefs = SharedPref();
    final baseUrl = await prefs.getString('baseUrl');
    final sessionObj = await prefs.getObject('session');
    
    if (baseUrl == null || sessionObj == null) {
      return;
    }

    final session = OdooSession.fromJson(sessionObj);
    final odooService = OdooService(baseUrl, session: session);
    try {
      await odooService.executeLeaveAction(leaveId, 'action_cancel');
      // Increased delay to let server process the state change before refreshing
      await Future.delayed(const Duration(milliseconds: 1000));
      await fetchLeavesAndTypes();
    } catch (e, stackTrace) {
      debugPrint('LeaveCubit ERROR: $e');
      if (!isClosed) {
        emit(state.copyWith(
          status: LeaveStatus.failure,
          errorMessage: _getErrorMessage(e),
        ));
      }
    } finally {
      odooService.close();
    }
  }

  Future<void> deleteLeave(int leaveId) async {
    if (isClosed) return;
    final prefs = SharedPref();
    final baseUrl = await prefs.getString('baseUrl');
    final sessionObj = await prefs.getObject('session');
    
    if (baseUrl == null || sessionObj == null) return;

    final session = OdooSession.fromJson(sessionObj);
    final odooService = OdooService(baseUrl, session: session);
    try {
      debugPrint('LeaveCubit: Deleting (unlink) leaveId=$leaveId');
      await odooService.executeModelMethod('hr.leave', 'unlink', [[leaveId]]);
      await fetchLeavesAndTypes();
    } catch (e) {
      debugPrint('LeaveCubit ERROR: $e');
      if (!isClosed) {
        emit(state.copyWith(
          status: LeaveStatus.failure,
          errorMessage: _getErrorMessage(e),
        ));
      }
    } finally {
      odooService.close();
    }
  }

  String _getErrorMessage(Object e) {
    if (e is OdooException) {
      try {
        final data = e.error;
        if (data is Map && data['message'] != null) {
          return data['message'].toString();
        }
      } catch (_) {}
      return e.message;
    }
    return e.toString();
  }

  void clearMessages() {
    emit(state.copyWith(errorMessage: null, successMessage: null));
  }
}
