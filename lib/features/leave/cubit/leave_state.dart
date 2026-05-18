
import 'package:hrms_desktop/features/leave/models/leave_model.dart';
import 'package:hrms_desktop/features/leave/models/leave_type_model.dart';

enum LeaveStatus { initial, loading, success, failure, submitting, submitted }

class LeaveState {
  final LeaveStatus status;
  final List<LeaveRequest> leaves;
  final List<LeaveType> leaveTypes;
  final String? errorMessage;
  final String? successMessage;

  const LeaveState({
    this.status = LeaveStatus.initial,
    this.leaves = const [],
    this.leaveTypes = const [],
    this.errorMessage,
    this.successMessage,
  });

  LeaveState copyWith({
    LeaveStatus? status,
    List<LeaveRequest>? leaves,
    List<LeaveType>? leaveTypes,
    String? errorMessage,
    String? successMessage,
  }) {
    return LeaveState(
      status: status ?? this.status,
      leaves: leaves ?? this.leaves,
      leaveTypes: leaveTypes ?? this.leaveTypes,
      errorMessage: errorMessage,
      successMessage: successMessage,
    );
  }
}
