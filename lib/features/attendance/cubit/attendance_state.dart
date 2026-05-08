import 'package:equatable/equatable.dart';

enum AttendanceStatus {
  initial,
  loading,
  success,
  failure,
}

class AttendanceState extends Equatable {
  final AttendanceStatus status;

  final int totalKeys;

  final int totalClicks;

  final int totalMoves;

  final bool isCheckedIn;

  final String todayHours;

  final double baseHours;

  final double productiveHours;

  final double idleHours;

  final double productivityPercent;

  final int idleSeconds;

  final bool isIdle;

  final String? errorMessage;

  final String? successMessage;

  const AttendanceState({
    this.status = AttendanceStatus.initial,
    this.totalKeys = 0,
    this.totalClicks = 0,
    this.totalMoves = 0,
    this.isCheckedIn = false,
    this.todayHours = "0.00",
    this.baseHours = 0.0,
    this.productiveHours = 0.0,
    this.idleHours = 0.0,
    this.productivityPercent = 0.0,
    this.idleSeconds = 0,
    this.isIdle = false,
    this.errorMessage,
    this.successMessage,
  });

  AttendanceState copyWith({
    AttendanceStatus? status,
    int? totalKeys,
    int? totalClicks,
    int? totalMoves,
    bool? isCheckedIn,
    String? todayHours,
    double? baseHours,
    double? productiveHours,
    double? idleHours,
    double? productivityPercent,
    int? idleSeconds,
    bool? isIdle,
    String? errorMessage,
    String? successMessage,
    bool clearError = false,
    bool clearSuccess = false,
  }) {
    return AttendanceState(
      status: status ?? this.status,
      totalKeys: totalKeys ?? this.totalKeys,
      totalClicks: totalClicks ?? this.totalClicks,
      totalMoves: totalMoves ?? this.totalMoves,
      isCheckedIn: isCheckedIn ?? this.isCheckedIn,
      todayHours: todayHours ?? this.todayHours,
      baseHours: baseHours ?? this.baseHours,
      productiveHours: productiveHours ?? this.productiveHours,
      idleHours: idleHours ?? this.idleHours,
      productivityPercent:
          productivityPercent ?? this.productivityPercent,
      idleSeconds: idleSeconds ?? this.idleSeconds,
      isIdle: isIdle ?? this.isIdle,
      errorMessage:
          clearError ? null : (errorMessage ?? this.errorMessage),
      successMessage:
          clearSuccess ? null : (successMessage ?? this.successMessage),
    );
  }

  @override
  List<Object?> get props => [
        status,
        totalKeys,
        totalClicks,
        totalMoves,
        isCheckedIn,
        todayHours,
        baseHours,
        productiveHours,
        idleHours,
        productivityPercent,
        idleSeconds,
        isIdle,
        errorMessage,
        successMessage,
      ];
}