import 'package:equatable/equatable.dart';
import '../models/project_model.dart';

enum ProjectsStatus { initial, loading, loaded, error }

class ProjectsState extends Equatable {
  final ProjectsStatus status;
  final List<ProjectModel> projects;
  final String? errorMessage;

  const ProjectsState({
    this.status = ProjectsStatus.initial,
    this.projects = const [],
    this.errorMessage,
  });

  ProjectsState copyWith({
    ProjectsStatus? status,
    List<ProjectModel>? projects,
    String? errorMessage,
  }) {
    return ProjectsState(
      status: status ?? this.status,
      projects: projects ?? this.projects,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, projects, errorMessage];
}
