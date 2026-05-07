import 'package:equatable/equatable.dart';

enum AttendanceStatus { initial, loading, success, failure }

class AttendanceState extends Equatable {
  final AttendanceStatus status;
  final bool isCheckedIn;
  final String todayHours;
  final double baseHours; // Total hours from finished sessions
  final String? errorMessage;
  final String? successMessage;

  const AttendanceState({
    this.status = AttendanceStatus.initial,
    this.isCheckedIn = false,
    this.todayHours = "0.00",
    this.baseHours = 0.0,
    this.errorMessage,
    this.successMessage,
  });

  AttendanceState copyWith({
    AttendanceStatus? status,
    bool? isCheckedIn,
    String? todayHours,
    double? baseHours,
    String? errorMessage,
    String? successMessage,
    bool clearError = false,
    bool clearSuccess = false,
  }) {
    return AttendanceState(
      status: status ?? this.status,
      isCheckedIn: isCheckedIn ?? this.isCheckedIn,
      todayHours: todayHours ?? this.todayHours,
      baseHours: baseHours ?? this.baseHours,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      successMessage: clearSuccess ? null : (successMessage ?? this.successMessage),
    );
  }

  @override
  List<Object?> get props => [
        status,
        isCheckedIn,
        todayHours,
        baseHours,
        errorMessage,
        successMessage,
      ];
}
