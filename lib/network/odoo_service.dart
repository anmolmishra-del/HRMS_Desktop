import 'package:intl/intl.dart';
import 'package:odoo_rpc/odoo_rpc.dart';
import 'package:flutter/foundation.dart';

class OdooService {
  final String baseUrl;
  final OdooClient _client;

  OdooService(this.baseUrl, {OdooSession? session})
    : _client = OdooClient(baseUrl, sessionId: session);

  /// Authenticates the user with the Odoo backend.
  Future<OdooSession> authenticate(
    String db,
    String username,
    String password,
  ) async {
    debugPrint('OdooService: authenticate db=$db username=$username');
    return _client.authenticate(db, username, password);
  }

  /// Fetches the employee record ID associated with a specific user ID.
  Future<List<dynamic>> getEmployeeRecordsForUser(int userId) async {
    debugPrint('OdooService: getEmployeeRecordsForUser userId=$userId');
    final response = await executeModelMethod(
      'hr.employee',
      'search_read',
      [],
      kwargs: {
        'context': {'bin_size': true},
        'domain': [
          ['user_id', '=', userId],
        ],
        'fields': ['id'],
      },
    );

    if (response == null || response is! List || response.isEmpty) {
      throw Exception('Employee not found for this user');
    }

    return response;
  }

  /// Fetches detailed employee information from the backend.
  Future<Map<String, dynamic>> fetchEmployeeDetails(
    int employeeId,
    int userId,
  ) async {
    debugPrint(
      'OdooService: fetchEmployeeDetails employeeId=$employeeId userId=$userId',
    );
    final response = await executeModelMethod(
      'hr.employee',
      'fetch_all_employees_info',
      [employeeId, userId],
      kwargs: {},
    );

    if (response == null || response is! Map<String, dynamic>) {
      throw Exception('Failed to fetch complete employee details');
    }

    return response;
  }

  /// Checks if the user belongs to the 'Internal User' group (group ID 96).
  Future<bool> isInternalUser(int userId) async {
    debugPrint('OdooService: isInternalUser userId=$userId');
    final response = await executeModelMethod(
      'res.users',
      'search_read',
      [],
      kwargs: {
        'context': {'bin_size': true},
        'domain': [
          ['id', '=', userId],
        ],
        'fields': ['groups_id'],
      },
    );

    if (response == null || response is! List || response.isEmpty) {
      return false;
    }

    final groups = response[0]['groups_id'] as List<dynamic>? ?? [];
    const internalUserGroupId = 96;
    final isInternal = groups.contains(internalUserGroupId);
    debugPrint('OdooService: isInternalUser=$isInternal');
    return isInternal;
  }

  /// Generic helper method to execute any Odoo model method using callKw.
  Future<dynamic> executeModelMethod(
    String model,
    String method,
    List<dynamic> args, {
    Map<String, dynamic>? kwargs,
  }) async {
    debugPrint(
      'OdooService: executeModelMethod model=$model method=$method args=$args kwargs=$kwargs',
    );
    final payload = {
      'model': model,
      'method': method,
      'args': args,
      'kwargs': kwargs ?? {},
    };
    return _client.callKw(payload);
  }

  /// Alternative way to call a method using a pre-built payload.
  Future<dynamic> callKw(Map<String, dynamic> payload) async {
    return executeModelMethod(
      payload['model'] as String,
      payload['method'] as String,
      payload['args'] as List<dynamic>,
      kwargs: payload['kwargs'] as Map<String, dynamic>?,
    );
  }

  /// Performs mobile check-in or check-out.
  Future<Map<String, dynamic>> mobileCheckInOut({
    required int employeeId,
    required bool isCheckIn,
    required double longitude,
    required double latitude,
    required String ipAddress,
  }) async {
    final response = await executeModelMethod(
      'hr.employee',
      'mobile_check_in_out',
      [employeeId, isCheckIn, longitude, latitude, ipAddress],
      kwargs: {},
    );

    if (response == null || response is! Map<String, dynamic>) {
      throw Exception('Failed to perform check in/out');
    }

    return response;
  }

  /// Fetches attendance records for a specific employee within a date range.
  Future<List<dynamic>> getAttendanceReport({
    required int employeeId,
    required DateTime fromDate,
    required DateTime toDate,
  }) async {
    final DateFormat formatter = DateFormat('yyyy-MM-dd HH:mm:ss');
    // Convert local boundaries to UTC for Odoo
    final String fromStr = formatter.format(DateTime(fromDate.year, fromDate.month, fromDate.day).toUtc());
    final String toStr = formatter.format(DateTime(toDate.year, toDate.month, toDate.day, 23, 59, 59).toUtc());

    final response = await executeModelMethod(
      'hr.attendance',
      'search_read',
      [],
      kwargs: {
        'domain': [
          ['employee_id', '=', employeeId],
          ['check_in', '>=', fromStr],
          ['check_in', '<=', toStr],
        ],
        'fields': [
          'id',
          'check_in',
          'check_out',
          'worked_hours',
          'overtime_hours',
          'validated_overtime_hours',
          'in_latitude',
          'in_longitude',
          'out_latitude',
          'out_longitude'
        ],
        'order': 'check_in desc',
      },
    );

    return response is List ? response : [];
  }

  /// Fetches resume lines for a specific employee.
  Future<List<dynamic>> getResumeLines(int employeeId) async {
    final response = await executeModelMethod(
      'hr.resume.line',
      'search_read',
      [],
      kwargs: {
        'domain': [['employee_id', '=', employeeId]],
        'fields': [
          'id',
          'name',
          'line_type_id', 
          'date_start',
          'date_end',
          'display_type',
          'description',
        ],
      },
    );
    return response is List ? response : [];
  }

  /// Fetches skills for a specific employee.
  Future<List<dynamic>> getEmployeeSkills(int employeeId) async {
    final response = await executeModelMethod(
      'hr.employee.skill',
      'search_read',
      [],
      kwargs: {
        'domain': [['employee_id', '=', employeeId]],
        'fields': [
          'id',
          'skill_type_id',
          'skill_id',
          'skill_level_id',
          'level_progress',
          'color',
        ],
      },
    );
    return response is List ? response : [];
  }

  /// Fetches leave requests for a specific employee.
  Future<List<dynamic>> fetchMyLeaves(int employeeId) async {
    final response = await executeModelMethod(
      'hr.leave',
      'search_read',
      [],
      kwargs: {
        'domain': [['employee_id', '=', employeeId]],
        'fields': [
          'id',
          'display_name',
          'holiday_status_id',
          'payslip_state',
          'request_date_from',
          'request_date_to',
          'duration_display',
          'name',
          'supported_attachment_ids',
          'request_unit_half',
          'request_date_from_period',
          'request_unit_hours',
          'request_hour_from',
          'request_hour_to',
          'state',
        ],
        'order': 'request_date_from desc',
      },
    );
    return response is List ? response : [];
  }

  /// Fetches available leave types.
  Future<List<dynamic>> fetchLeaveTypes({int? employeeId}) async {
    final response = await executeModelMethod(
      'hr.leave.type',
      'search_read',
      [],
      kwargs: {
        'fields': ['id', 'name', 'virtual_remaining_leaves', 'max_leaves'],
        'context': employeeId != null ? {'employee_id': employeeId} : {},
      },
    );
    debugPrint('OdooService: fetchLeaveTypes RAW RESPONSE: $response');
    return response is List ? response : [];
  }

  /// Creates a new leave request.
  Future<int> createLeaveRequest(Map<String, dynamic> data) async {
    final response = await executeModelMethod(
      'hr.leave',
      'create',
      [data],
    );
    return response is int ? response : 0;
  }

  /// Executes a leave action (submit, cancel, etc.)
  Future<dynamic> executeLeaveAction(int leaveId, String action) async {
    debugPrint('OdooService: executeLeaveAction leaveId=$leaveId action=$action');
    
    // Odoo 18 action_cancel returns a wizard (hr.holidays.cancel.leave)
    // We need to create the wizard and call its action_cancel_leave method
    if (action == 'action_cancel') {
      try {
        debugPrint('OdooService: Handling cancellation wizard for Odoo 18');
        final wizardId = await executeModelMethod(
          'hr.holidays.cancel.leave',
          'create',
          [{'leave_id': leaveId, 'reason': 'Cancelled via Mobile App'}],
        );
        
        if (wizardId is int) {
          return await executeModelMethod(
            'hr.holidays.cancel.leave',
            'action_cancel_leave',
            [[wizardId]],
          );
        }
      } catch (e) {
        debugPrint('OdooService: Wizard cancellation failed, trying direct action: $e');
        // Fallback to direct action if wizard fails (some setups might differ)
      }
    }

    final response = await executeModelMethod(
      'hr.leave',
      action,
      [[leaveId]],
    );
    debugPrint('OdooService: action response: $response');
    return response;
  }

  /// Closes the Odoo client connection.
  void close() {
    debugPrint('OdooService: closing client');
    _client.close();
  }
}
