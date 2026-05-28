import 'package:equatable/equatable.dart';
import '../models/project_task_model.dart';

enum ProjectTasksStatus { initial, loading, loaded, error }

class ProjectTasksState extends Equatable {
  final ProjectTasksStatus status;
  final List<ProjectTaskModel> tasks;
  final List<Map<String, dynamic>> users;
  final String? errorMessage;

  const ProjectTasksState({
    this.status = ProjectTasksStatus.initial,
    this.tasks = const [],
    this.users = const [],
    this.errorMessage,
  });

  ProjectTasksState copyWith({
    ProjectTasksStatus? status,
    List<ProjectTaskModel>? tasks,
    List<Map<String, dynamic>>? users,
    String? errorMessage,
  }) {
    return ProjectTasksState(
      status: status ?? this.status,
      tasks: tasks ?? this.tasks,
      users: users ?? this.users,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, tasks, users, errorMessage];
}
