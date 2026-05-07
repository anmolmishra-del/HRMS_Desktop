import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/foundation.dart';

import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:odoo_rpc/odoo_rpc.dart';

import 'package:hrms_desktop/core/utils/shared_pref.dart';
import 'package:hrms_desktop/network/odoo_service.dart';

import 'package:hrms_desktop/features/home/cubit/screenshot_service.dart';

import 'attendance_state.dart';

/// Cubit for managing attendance + screenshots
class AttendanceCubit extends Cubit<AttendanceState> {

  Timer? _ticker;

  Timer? _randomScreenshotTimer;

  DateTime? _currentCheckInTime;

  bool _isTracking = false;

  AttendanceCubit()
      : super(const AttendanceState());

  // =========================
  // CLOSE
  // =========================

  @override
  Future<void> close() {

    _ticker?.cancel();

    stopRandomScreenshots();

    return super.close();
  }

  // =========================
  // LOAD INITIAL STATUS
  // =========================

  Future<void> loadInitialStatus() async {

    emit(
      state.copyWith(
        status: AttendanceStatus.loading,
      ),
    );

    final prefs = SharedPref();

    final sobj =
        await prefs.getObject('session');

    var baseUrl =
        await prefs.getString('baseUrl');

    final employeeData =
        await prefs.getObject(
          'employee_data',
        );

    if (sobj == null ||
        baseUrl == null ||
        employeeData == null) {

      emit(
        state.copyWith(
          status:
              AttendanceStatus.failure,
          errorMessage:
              "Session expired",
        ),
      );

      return;
    }

    final session = OdooSession.fromJson(
      Map<String, dynamic>.from(sobj),
    );

    final odooService = OdooService(
      baseUrl,
      session: session,
    );

    final rawEmpId =
        employeeData['id'];

    final int empId =
        rawEmpId is int
            ? rawEmpId
            : int.parse(
                rawEmpId.toString(),
              );

    try {

      debugPrint(
        'AttendanceCubit: Loading initial status for empId=$empId',
      );

      final checkInStatus =
          await odooService
              .executeModelMethod(
        'hr.attendance',
        'search_read',
        [],
        kwargs: {
          'domain': [
            [
              'employee_id',
              '=',
              empId,
            ],
            [
              'check_in',
              '!=',
              false,
            ],
            [
              'check_out',
              '=',
              false,
            ]
          ],
          'fields': [
            'id',
            'check_in',
          ],
        },
      );

      final isCheckedIn =
          checkInStatus != null &&
              (checkInStatus as List)
                  .isNotEmpty;

      if (isCheckedIn) {

        String lastCheckInStr =
            (checkInStatus as List)[0]
                ['check_in'];

        debugPrint(
          'RAW check_in: $lastCheckInStr',
        );

        if (!lastCheckInStr
            .endsWith('Z')) {

          lastCheckInStr =
              '${lastCheckInStr.replaceAll(' ', 'T')}Z';
        }

        _currentCheckInTime =
            DateTime.parse(
              lastCheckInStr,
            ).toLocal();

      } else {

        _currentCheckInTime = null;
      }

      final baseHours =
          await _fetchBaseHours(
        odooService,
        empId,
      );

      emit(
        state.copyWith(
          status:
              AttendanceStatus.success,
          isCheckedIn: isCheckedIn,
          baseHours: baseHours,
          todayHours: _formatHours(
            baseHours +
                _calculateCurrentSessionHours(),
          ),
        ),
      );

      _startTicker();

    } catch (e) {

      debugPrint(
        'Load status error: $e',
      );

      emit(
        state.copyWith(
          status:
              AttendanceStatus.failure,
          errorMessage:
              e.toString(),
        ),
      );

    } finally {

      odooService.close();
    }
  }

  // =========================
  // TICKER
  // =========================

  void _startTicker() {

    _ticker?.cancel();

    _ticker = Timer.periodic(
      const Duration(seconds: 1),
      (timer) {

        final totalHours =
            state.baseHours +
                _calculateCurrentSessionHours();

        emit(
          state.copyWith(
            todayHours:
                _formatHours(totalHours),
            clearSuccess: true,
            clearError: true,
          ),
        );
      },
    );
  }

  // =========================
  // CLEAR MESSAGES
  // =========================

  void clearMessages() {

    emit(
      state.copyWith(
        clearSuccess: true,
        clearError: true,
      ),
    );
  }

  // =========================
  // CALCULATE HOURS
  // =========================

  double _calculateCurrentSessionHours() {

    if (_currentCheckInTime == null) {
      return 0.0;
    }

    final duration =
        DateTime.now().difference(
      _currentCheckInTime!,
    );

    return duration.inSeconds / 3600.0;
  }

  String _formatHours(
    double hours,
  ) {

    return NumberFormat(
      "0.00",
    ).format(hours);
  }

  // =========================
  // FETCH BASE HOURS
  // =========================

  Future<double> _fetchBaseHours(
    OdooService odooService,
    int empId,
  ) async {

    DateTime now = DateTime.now();

    DateTime todayStartLocal =
        DateTime(
      now.year,
      now.month,
      now.day,
    );

    DateTime todayEndLocal =
        todayStartLocal.add(
      const Duration(days: 1),
    );

    final formatter = DateFormat(
      'yyyy-MM-dd HH:mm:ss',
    );

    final fromStr = formatter.format(
      todayStartLocal.toUtc(),
    );

    final toStr = formatter.format(
      todayEndLocal.toUtc(),
    );

    final finishedRecords =
        await odooService
            .executeModelMethod(
      'hr.attendance',
      'search_read',
      [],
      kwargs: {
        'domain': [
          [
            'employee_id',
            '=',
            empId,
          ],
          [
            'check_in',
            '>=',
            fromStr,
          ],
          [
            'check_in',
            '<',
            toStr,
          ],
          [
            'check_out',
            '!=',
            false,
          ],
        ],
        'fields': [
          'worked_hours',
        ],
      },
    );

    double total = 0.0;

    if (finishedRecords != null) {

      for (var record
          in (finishedRecords as List)) {

        total +=
            (record['worked_hours'] ??
                    0.0)
                .toDouble();
      }
    }

    return total;
  }

  // =========================
  // TOGGLE ATTENDANCE
  // =========================

  Future<void> toggleAttendance() async {

    final currentlyCheckedIn =
        state.isCheckedIn;

    _ticker?.cancel();

    emit(
      state.copyWith(
        status: AttendanceStatus.loading,
      ),
    );

    final prefs = SharedPref();

    final sobj =
        await prefs.getObject('session');

    var baseUrl =
        await prefs.getString('baseUrl');

    final employeeData =
        await prefs.getObject(
          'employee_data',
        );

    if (baseUrl == null ||
        sobj == null ||
        employeeData == null) {

      emit(
        state.copyWith(
          status:
              AttendanceStatus.failure,
          errorMessage:
              "Session info missing",
        ),
      );

      return;
    }

    final session = OdooSession.fromJson(
      Map<String, dynamic>.from(sobj),
    );

    final odooService = OdooService(
      baseUrl,
      session: session,
    );

    final rawEmpId =
        employeeData['id'];

    final int empId =
        rawEmpId is int
            ? rawEmpId
            : int.parse(
                rawEmpId.toString(),
              );

    try {

      final results = await Future.wait([

        _getIpAddress().timeout(
          const Duration(seconds: 5),
          onTimeout: () => "0.0.0.0",
        ),

        _getCurrentPosition().timeout(
          const Duration(seconds: 5),
          onTimeout: () => null,
        ),
      ]);

      final String ipAddress =
          results[0] as String;

      final Position? position =
          results[1] as Position?;

      await odooService.mobileCheckInOut(
        employeeId: empId,
        isCheckIn:
            currentlyCheckedIn,
        longitude:
            position?.longitude ?? 0,
        latitude:
            position?.latitude ?? 0,
        ipAddress: ipAddress,
      );

      odooService.close();

      await loadInitialStatus();

      // =========================
      // START / STOP SCREENSHOTS
      // =========================

      if (!currentlyCheckedIn) {

        // USER CHECKED IN

        startRandomScreenshots();

      } else {

        // USER CHECKED OUT

        stopRandomScreenshots();
      }

      final successMsg =
          currentlyCheckedIn
              ? "Checked out successfully"
              : "Checked in successfully";

      emit(
        state.copyWith(
          successMessage:
              successMsg,
        ),
      );

    } catch (e) {

      debugPrint(
        'Attendance toggle error: $e',
      );

      emit(
        state.copyWith(
          status:
              AttendanceStatus.failure,
          errorMessage:
              e.toString(),
        ),
      );

    } finally {

      odooService.close();
    }
  }

  // =========================
  // RANDOM SCREENSHOTS
  // =========================

  void startRandomScreenshots() {

    if (_isTracking) return;

    _isTracking = true;

    print(
      "Random screenshot tracking started",
    );

    _scheduleNextScreenshot();
  }

  void stopRandomScreenshots() {

    _isTracking = false;

    _randomScreenshotTimer?.cancel();

    print(
      "Random screenshot tracking stopped",
    );
  }

  void _scheduleNextScreenshot() {

    if (!_isTracking) return;

    final randomSeconds =
        Random().nextInt(10) + 10;

    print(
      "Next screenshot in $randomSeconds seconds",
    );

    _randomScreenshotTimer?.cancel();

    _randomScreenshotTimer = Timer(
      Duration(
        seconds: randomSeconds,
      ),
      () async {

        await captureAndUpload();

        if (_isTracking) {

          _scheduleNextScreenshot();
        }
      },
    );
  }

  Future<void> captureAndUpload() async {

    try {

      print("Taking screenshot...");

      final file =
          await ScreenshotService
              .captureScreen();

      if (file == null) {

        print("Screenshot failed");

        return;
      }

      print(
        "Screenshot captured: ${file.path}",
      );

    } catch (e) {

      print(
        "Screenshot error: $e",
      );
    }
  }

  // =========================
  // IP ADDRESS
  // =========================

  Future<String> _getIpAddress() async {

    try {

      final response = await http.get(
        Uri.parse(
          'https://api.ipify.org?format=json',
        ),
      ).timeout(
        const Duration(seconds: 4),
      );

      if (response.statusCode == 200) {

        return jsonDecode(
          response.body,
        )['ip'];
      }

    } catch (e) {

      debugPrint(
        'IP fetch failed',
      );
    }

    return "0.0.0.0";
  }

  // =========================
  // LOCATION
  // =========================

  Future<Position?> _getCurrentPosition() async {

    try {

      LocationPermission permission =
          await Geolocator
              .checkPermission();

      if (permission ==
          LocationPermission.denied) {

        permission =
            await Geolocator
                .requestPermission();
      }

      if (permission ==
              LocationPermission
                  .whileInUse ||
          permission ==
              LocationPermission
                  .always) {

        final lastKnown =
            await Geolocator
                .getLastKnownPosition();

        if (lastKnown != null) {
          return lastKnown;
        }

        return await Geolocator
            .getCurrentPosition(
          desiredAccuracy:
              LocationAccuracy.medium,
          timeLimit:
              const Duration(seconds: 5),
        );
      }

    } catch (e) {

      debugPrint(
        'Location error: $e',
      );
    }

    return null;
  }
}