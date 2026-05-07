import 'dart:async';
import 'dart:convert';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/foundation.dart';
import 'package:hrms_desktop/core/utils/shared_pref.dart';
import 'package:hrms_desktop/network/odoo_service.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:odoo_rpc/odoo_rpc.dart';
import 'attendance_state.dart';

/// Cubit for managing the active check-in/check-out state and timer.
class AttendanceCubit extends Cubit<AttendanceState> {
  Timer? _ticker;
  DateTime? _currentCheckInTime;

  AttendanceCubit() : super(const AttendanceState());

  @override
  Future<void> close() {
    _ticker?.cancel();
    return super.close();
  }

  /// Loads the initial attendance status from the server.
  Future<void> loadInitialStatus() async {
    emit(state.copyWith(status: AttendanceStatus.loading));
    
    final prefs = SharedPref();
    final sobj = await prefs.getObject('session');
    var baseUrl = await prefs.getString('baseUrl');
    final employeeData = await prefs.getObject('employee_data');

    if (sobj == null || baseUrl == null || employeeData == null) {
      emit(state.copyWith(status: AttendanceStatus.failure, errorMessage: "Session expired"));
      return;
    }

    final session = OdooSession.fromJson(Map<String, dynamic>.from(sobj));
    final odooService = OdooService(baseUrl, session: session);
    
    final rawEmpId = employeeData['id'];
    final int empId = rawEmpId is int ? rawEmpId : int.parse(rawEmpId.toString());

    try {
      debugPrint('AttendanceCubit: Loading initial status for empId=$empId');
      // Check if there is an active (unclosed) attendance record
      final checkInStatus = await odooService.executeModelMethod(
        'hr.attendance',
        'search_read',
        [],
        kwargs: {
          'domain': [
            ['employee_id', '=', empId],
            ['check_in', '!=', false],
            ['check_out', '=', false]
          ],
          'fields': ['id', 'check_in'],
        },
      );

      final isCheckedIn = checkInStatus != null && (checkInStatus as List).isNotEmpty;
      if (isCheckedIn) {
        String lastCheckInStr = (checkInStatus as List)[0]['check_in'];
        debugPrint('AttendanceCubit: RAW check_in from Odoo: $lastCheckInStr');
        
        // Format the date string for parsing
        if (!lastCheckInStr.endsWith('Z')) {
          lastCheckInStr = '${lastCheckInStr.replaceAll(' ', 'T')}Z';
        }
        _currentCheckInTime = DateTime.parse(lastCheckInStr).toLocal();
        debugPrint('AttendanceCubit: PARSED local check_in: $_currentCheckInTime');
      } else {
        _currentCheckInTime = null;
      }
      
      // Fetch base hours (completed sessions today)
      final baseHours = await _fetchBaseHours(odooService, empId);

      emit(state.copyWith(
        status: AttendanceStatus.success,
        isCheckedIn: isCheckedIn,
        baseHours: baseHours,
        todayHours: _formatHours(baseHours + _calculateCurrentSessionHours()),
      ));

      _startTicker(); // Always start ticker to keep UI clock updated
    } catch (e) {
      debugPrint('AttendanceCubit: Error loading status: $e');
      emit(state.copyWith(status: AttendanceStatus.failure, errorMessage: e.toString()));
    } finally {
      odooService.close();
    }
  }

  /// Starts a periodic timer to update the displayed working hours and UI clock every second.
  void _startTicker() {
    _ticker?.cancel();
    _ticker = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!isClosed) {
        // Even if not checked in, we emit state to trigger UI rebuild for the current time clock
        final totalHours = state.baseHours + _calculateCurrentSessionHours();
        emit(state.copyWith(
          todayHours: _formatHours(totalHours),
          clearSuccess: true,
          clearError: true,
        ));
      } else {
        timer.cancel();
      }
    });
  }

  /// Clears success and error messages from the state.
  void clearMessages() {
    emit(state.copyWith(clearSuccess: true, clearError: true));
  }

  /// Calculates the hours elapsed in the current active session.
  double _calculateCurrentSessionHours() {
    if (_currentCheckInTime == null) return 0.0;
    final duration = DateTime.now().difference(_currentCheckInTime!);
    return duration.inSeconds / 3600.0;
  }

  /// Formats double hours into "0.00" string format.
  String _formatHours(double hours) {
    return NumberFormat("0.00").format(hours);
  }

  /// Fetches the sum of worked hours from already closed sessions for today.
  Future<double> _fetchBaseHours(OdooService odooService, int empId) async {
    DateTime now = DateTime.now();
    // Start of today in local time, then converted to UTC for Odoo
    DateTime todayStartLocal = DateTime(now.year, now.month, now.day);
    DateTime todayEndLocal = todayStartLocal.add(const Duration(days: 1));

    final DateFormat formatter = DateFormat('yyyy-MM-dd HH:mm:ss');
    final String fromStr = formatter.format(todayStartLocal.toUtc());
    final String toStr = formatter.format(todayEndLocal.toUtc());

    final finishedRecords = await odooService.executeModelMethod(
      'hr.attendance',
      'search_read',
      [],
      kwargs: {
        'domain': [
          ['employee_id', '=', empId],
          ['check_in', '>=', fromStr],
          ['check_in', '<', toStr],
          ['check_out', '!=', false],
        ],
        'fields': ['worked_hours'],
      },
    );

    double total = 0.0;
    if (finishedRecords != null) {
      for (var record in (finishedRecords as List)) {
        total += (record['worked_hours'] ?? 0.0).toDouble();
      }
    }
    return total;
  }

  /// Toggles between check-in and check-out.
  Future<void> toggleAttendance() async { 
    final currentlyCheckedIn = state.isCheckedIn;
    _ticker?.cancel();
    emit(state.copyWith(status: AttendanceStatus.loading));

    final prefs = SharedPref();
    final sobj = await prefs.getObject('session');
    var baseUrl = await prefs.getString('baseUrl');
    final employeeData = await prefs.getObject('employee_data');

    if (baseUrl == null || sobj == null || employeeData == null) {
      emit(state.copyWith(status: AttendanceStatus.failure, errorMessage: "Session info missing"));
      return;
    }

    final session = OdooSession.fromJson(Map<String, dynamic>.from(sobj));
    final odooService = OdooService(baseUrl, session: session);
    final rawEmpId = employeeData['id'];
    final int empId = rawEmpId is int ? rawEmpId : int.parse(rawEmpId.toString());

    try {
      // Capture device IP and GPS location in parallel for better performance
      final results = await Future.wait([
        _getIpAddress().timeout(const Duration(seconds: 5), onTimeout: () => "0.0.0.0"),
        _getCurrentPosition().timeout(const Duration(seconds: 5), onTimeout: () => null),
      ]);
      
      final String ipAddress = results[0] as String;
      final Position? position = results[1] as Position?;
      
      // Perform the check-in/out action on the server
      await odooService.mobileCheckInOut(
        employeeId: empId,
        isCheckIn: currentlyCheckedIn, 
        longitude: position?.longitude ?? 0,
        latitude: position?.latitude ?? 0,
        ipAddress: ipAddress,
      );

      // Refresh status from server to get exact check-in time and base hours
      odooService.close(); // Close current service to avoid multiple clients
      await loadInitialStatus();

      final successMsg = currentlyCheckedIn ? "Checked out successfully" : "Checked in successfully";
      emit(state.copyWith(
        successMessage: successMsg,
      ));
    } catch (e) {
      debugPrint('AttendanceCubit Toggle Error: $e');
      emit(state.copyWith(status: AttendanceStatus.failure, errorMessage: e.toString()));
    } finally {
      odooService.close();
    }
  }

  /// Retrieves the public IP address of the device.
  Future<String> _getIpAddress() async {
    try {
      final response = await http
          .get(Uri.parse('https://api.ipify.org?format=json'))
          .timeout(const Duration(seconds: 4));
      if (response.statusCode == 200) {
        return jsonDecode(response.body)['ip'];
      }
    } catch (e) {
      debugPrint('AttendanceCubit: IP fetch failed or timed out');
    }
    return "0.0.0.0";
  }

  /// Requests location permissions and retrieves the current GPS coordinates.
  Future<Position?> _getCurrentPosition() async {
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.whileInUse || permission == LocationPermission.always) {
        // Try to get last known position first for near-instant response
        final lastKnown = await Geolocator.getLastKnownPosition();
        if (lastKnown != null) return lastKnown;

        // Fallback to current position with a strict time limit
        return await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.medium,
          timeLimit: const Duration(seconds: 5),
        );
      }
    } catch (e) {}
    return null;
  }
}
