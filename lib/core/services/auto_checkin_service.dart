import 'package:flutter/foundation.dart';
import 'package:hrms_desktop/core/utils/shared_pref.dart';
import 'package:hrms_desktop/features/attendance/cubit/attendance_cubit.dart';

class AutoCheckInService {
  static const String _autoCheckInKey = 'auto_check_in_enabled';
  
  /// Check if auto check-in is enabled
  static Future<bool> isAutoCheckInEnabled() async {
    final value = await SharedPref().getBool(_autoCheckInKey);
    return value ?? false;
  }
  
  /// Perform auto check-in if enabled and user is not already checked in
  static Future<void> performAutoCheckInIfNeeded(AttendanceCubit attendanceCubit) async {
    try {
      final isEnabled = await isAutoCheckInEnabled();
      
      if (!isEnabled) {
        debugPrint('Auto check-in is disabled');
        return;
      }
      
      // Check if already checked in
      final currentState = attendanceCubit.state;
      if (currentState.isCheckedIn) {
        debugPrint('User is already checked in');
        return;
      }
      
      debugPrint('Performing auto check-in...');
      await attendanceCubit.toggleAttendance();
      debugPrint('Auto check-in completed successfully');
      
    } catch (e) {
      debugPrint('Auto check-in failed: $e');
    }
  }
}
