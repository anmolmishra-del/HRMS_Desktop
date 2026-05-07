class AttendanceState {
  final bool loading;
  final String firstCheckIn;
  final String lastCheckOut;
  final String totalHours;
  final String error;
  final String tags;
  final String breakTime;

  AttendanceState({
    this.loading = false,
    this.firstCheckIn = "",
    this.lastCheckOut = "",
    this.totalHours = "",
    this.error = "",
    this.breakTime="",
    this.tags="",
  });

  AttendanceState copyWith({
    bool? loading,
    String? firstCheckIn,
    String? lastCheckOut,
    String? totalHours,
    String?tags,
    String?breakTime,
    String? error,
  }) {
    return AttendanceState(
      loading: loading ?? this.loading,
      firstCheckIn: firstCheckIn ?? this.firstCheckIn,
      lastCheckOut: lastCheckOut ?? this.lastCheckOut,
      totalHours: totalHours ?? this.totalHours,
      error: error ?? this.error,
      tags:tags??this.tags,
      breakTime: breakTime??this.breakTime
    );
  }
}